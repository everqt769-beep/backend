const { supabase } = require('../config/supabase');

// ─────────────────────────────────────────────
// Dashboard principal: resumen del día
// ─────────────────────────────────────────────
const getResumenDiario = async (req, res, next) => {
    try {
        const hoy = new Date();
        hoy.setHours(0, 0, 0, 0);
        const hoyISO = hoy.toISOString();

        // Reportes nuevos del día
        const { data: reportesHoy, error: rhError } = await supabase
            .from('reportes')
            .select(`
                *,
                usuarios(nombre, correo),
                categorias(nombre, areas(nombre)),
                estados(nombre, color, codigo),
                analisis_ia(es_valido, prioridad, justificacion)
            `)
            .gte('fecha_creacion', hoyISO)
            .order('fecha_creacion', { ascending: false });

        if (rhError) throw rhError;

        // Conteos por estado HOY
        const conteosPorEstado = {};
        for (const r of reportesHoy) {
            const estadoNombre = r.estados?.nombre || 'Sin estado';
            conteosPorEstado[estadoNombre] = (conteosPorEstado[estadoNombre] || 0) + 1;
        }

        // Total de reportes del día
        const totalHoy = reportesHoy.length;

        // Reportes rechazados hoy (falsos)
        const rechazadosHoy = reportesHoy.filter(r => r.estados?.codigo === 'rechazado').length;

        // Reportes resueltos hoy
        const resueltosHoy = reportesHoy.filter(r => r.estados?.codigo === 'resuelto').length;

        // Reportes pendientes globales (no solo hoy)
        const { count: pendientesGlobal } = await supabase
            .from('reportes')
            .select('*, estados!inner(codigo)', { count: 'exact', head: true })
            .eq('estados.codigo', 'pendiente');

        // Reportes en proceso globales
        const { count: enProcesoGlobal } = await supabase
            .from('reportes')
            .select('*, estados!inner(codigo)', { count: 'exact', head: true })
            .eq('estados.codigo', 'en_proceso');

        res.json({
            fecha: hoyISO,
            total_hoy: totalHoy,
            rechazados_hoy: rechazadosHoy,
            resueltos_hoy: resueltosHoy,
            pendientes_global: pendientesGlobal || 0,
            en_proceso_global: enProcesoGlobal || 0,
            conteos_por_estado: conteosPorEstado,
            reportes_hoy: reportesHoy
        });
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Estadísticas históricas por rango de fechas
// ─────────────────────────────────────────────
const getEstadisticasHistoricas = async (req, res, next) => {
    try {
        const { fecha_inicio, fecha_fin } = req.query;

        // Defaults: último mes
        const fin = fecha_fin ? new Date(fecha_fin) : new Date();
        const inicio = fecha_inicio ? new Date(fecha_inicio) : new Date(fin.getTime() - 30 * 24 * 60 * 60 * 1000);

        fin.setHours(23, 59, 59, 999);
        inicio.setHours(0, 0, 0, 0);

        const { data: reportes, error } = await supabase
            .from('reportes')
            .select(`
                id_reporte,
                fecha_creacion,
                descripcion,
                estados(id_estado, nombre, color, codigo),
                categorias(nombre, areas(nombre)),
                usuarios(nombre, correo),
                analisis_ia(es_valido, prioridad, justificacion)
            `)
            .gte('fecha_creacion', inicio.toISOString())
            .lte('fecha_creacion', fin.toISOString())
            .order('fecha_creacion', { ascending: false });

        if (error) throw error;

        // Calcular estadísticas
        const total = reportes.length;
        const aceptados = reportes.filter(r => r.analisis_ia?.es_valido === true).length;
        const rechazados = reportes.filter(r => r.estados?.codigo === 'rechazado').length;
        const resueltos = reportes.filter(r => r.estados?.codigo === 'resuelto').length;
        const pendientes = reportes.filter(r => r.estados?.codigo === 'pendiente').length;
        const enProceso = reportes.filter(r => r.estados?.codigo === 'en_proceso').length;
        const enRevision = reportes.filter(r => r.estados?.codigo === 'en_revision').length;
        const asignados = reportes.filter(r => r.estados?.codigo === 'asignado').length;
        const duplicados = reportes.filter(r => r.estados?.codigo === 'duplicado').length;

        // Atendidos = en_proceso + resuelto + asignado + en_revision
        const atendidos = enProceso + resueltos + asignados + enRevision;
        const noAtendidos = pendientes;

        // Por categoría
        const porCategoria = {};
        for (const r of reportes) {
            const cat = r.categorias?.nombre || 'Sin categoría';
            porCategoria[cat] = (porCategoria[cat] || 0) + 1;
        }

        // Por área
        const porArea = {};
        for (const r of reportes) {
            const area = r.categorias?.areas?.nombre || 'Sin área';
            porArea[area] = (porArea[area] || 0) + 1;
        }

        // Por estado
        const porEstado = {};
        for (const r of reportes) {
            const estado = r.estados?.nombre || 'Sin estado';
            porEstado[estado] = (porEstado[estado] || 0) + 1;
        }

        // Tendencia diaria (reportes por día)
        const tendenciaDiaria = {};
        for (const r of reportes) {
            const dia = r.fecha_creacion.substring(0, 10); // YYYY-MM-DD
            tendenciaDiaria[dia] = (tendenciaDiaria[dia] || 0) + 1;
        }

        // Prioridad según IA
        const porPrioridad = { alta: 0, media: 0, baja: 0, sin_analisis: 0 };
        for (const r of reportes) {
            if (r.analisis_ia?.prioridad) {
                porPrioridad[r.analisis_ia.prioridad]++;
            } else {
                porPrioridad.sin_analisis++;
            }
        }

        res.json({
            rango: {
                inicio: inicio.toISOString(),
                fin: fin.toISOString()
            },
            totales: {
                total,
                aceptados,
                rechazados,
                resueltos,
                pendientes,
                en_proceso: enProceso,
                en_revision: enRevision,
                asignados,
                duplicados,
                atendidos,
                no_atendidos: noAtendidos
            },
            tasas: {
                tasa_aceptacion: total > 0 ? Math.round((aceptados / total) * 100) : 0,
                tasa_rechazo: total > 0 ? Math.round((rechazados / total) * 100) : 0,
                tasa_resolucion: total > 0 ? Math.round((resueltos / total) * 100) : 0,
                tasa_atencion: total > 0 ? Math.round((atendidos / total) * 100) : 0
            },
            por_categoria: porCategoria,
            por_area: porArea,
            por_estado: porEstado,
            por_prioridad: porPrioridad,
            tendencia_diaria: tendenciaDiaria,
            reportes
        });
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Reportes rechazados (falsos) con detalle
// ─────────────────────────────────────────────
const getReportesRechazados = async (req, res, next) => {
    try {
        const { data, error } = await supabase
            .from('reportes')
            .select(`
                *,
                usuarios(id_usuario, nombre, correo),
                categorias(nombre, areas(nombre)),
                estados!inner(nombre, color, codigo),
                analisis_ia(es_valido, prioridad, justificacion, fecha_analisis)
            `)
            .eq('estados.codigo', 'rechazado')
            .order('fecha_creacion', { ascending: false });

        if (error) throw error;

        res.json({
            total: data.length,
            reportes: data
        });
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Generar reporte exportable (JSON estructurado)
// ─────────────────────────────────────────────
const generarReporte = async (req, res, next) => {
    try {
        const { fecha_inicio, fecha_fin, tipo } = req.query;

        // Defaults
        const fin = fecha_fin ? new Date(fecha_fin) : new Date();
        const inicio = fecha_inicio ? new Date(fecha_inicio) : new Date(fin.getTime() - 30 * 24 * 60 * 60 * 1000);

        fin.setHours(23, 59, 59, 999);
        inicio.setHours(0, 0, 0, 0);

        let query = supabase
            .from('reportes')
            .select(`
                id_reporte,
                descripcion,
                direccion,
                fecha_creacion,
                usuarios(nombre, correo),
                categorias(nombre, areas(nombre)),
                estados(nombre, color, codigo),
                analisis_ia(es_valido, prioridad, categoria_sugerida, justificacion),
                asignaciones(funcionario:usuarios(nombre), estado:estados(nombre))
            `)
            .gte('fecha_creacion', inicio.toISOString())
            .lte('fecha_creacion', fin.toISOString());

        // Filtrar por tipo si se especifica
        if (tipo === 'rechazados') {
            query = query.eq('estados.codigo', 'rechazado');
        } else if (tipo === 'resueltos') {
            query = query.eq('estados.codigo', 'resuelto');
        } else if (tipo === 'pendientes') {
            query = query.eq('estados.codigo', 'pendiente');
        }

        const { data, error } = await query.order('fecha_creacion', { ascending: false });
        if (error) throw error;

        // Formatear para exportación
        const reporteExportable = data.map(r => ({
            id: r.id_reporte,
            fecha: r.fecha_creacion,
            descripcion: r.descripcion,
            direccion: r.direccion || 'No proporcionada',
            ciudadano: r.usuarios?.nombre || 'Anónimo',
            correo: r.usuarios?.correo || '-',
            categoria: r.categorias?.nombre || 'Sin categoría',
            area: r.categorias?.areas?.nombre || 'Sin área',
            estado: r.estados?.nombre || 'Sin estado',
            es_valido_ia: r.analisis_ia?.es_valido ?? 'No analizado',
            prioridad_ia: r.analisis_ia?.prioridad || 'No analizado',
            justificacion_ia: r.analisis_ia?.justificacion || 'No analizado',
            funcionario_asignado: r.asignaciones?.[0]?.funcionario?.nombre || 'No asignado',
            estado_asignacion: r.asignaciones?.[0]?.estado?.nombre || '-'
        }));

        res.json({
            titulo: `Reporte de Gestión Municipal`,
            periodo: {
                inicio: inicio.toISOString().substring(0, 10),
                fin: fin.toISOString().substring(0, 10)
            },
            tipo_filtro: tipo || 'todos',
            total_registros: reporteExportable.length,
            generado_en: new Date().toISOString(),
            datos: reporteExportable
        });
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Tendencia mensual (últimos 12 meses)
// ─────────────────────────────────────────────
const getTendenciaMensual = async (req, res, next) => {
    try {
        const hace12Meses = new Date();
        hace12Meses.setMonth(hace12Meses.getMonth() - 12);
        hace12Meses.setDate(1);
        hace12Meses.setHours(0, 0, 0, 0);

        const { data, error } = await supabase
            .from('reportes')
            .select('fecha_creacion, estados(codigo)')
            .gte('fecha_creacion', hace12Meses.toISOString())
            .order('fecha_creacion', { ascending: true });

        if (error) throw error;

        // Agrupar por mes
        const meses = {};
        for (const r of data) {
            const mes = r.fecha_creacion.substring(0, 7); // YYYY-MM
            if (!meses[mes]) {
                meses[mes] = { total: 0, resueltos: 0, rechazados: 0, pendientes: 0 };
            }
            meses[mes].total++;
            if (r.estados?.codigo === 'resuelto') meses[mes].resueltos++;
            if (r.estados?.codigo === 'rechazado') meses[mes].rechazados++;
            if (r.estados?.codigo === 'pendiente') meses[mes].pendientes++;
        }

        res.json(meses);
    } catch (err) {
        next(err);
    }
};

// ─────────────────────────────────────────────
// Conteos rápidos para tarjetas del dashboard
// ─────────────────────────────────────────────
const getConteos = async (req, res, next) => {
    try {
        const hoy = new Date();
        hoy.setHours(0, 0, 0, 0);

        // Total de reportes
        const { count: totalReportes } = await supabase
            .from('reportes')
            .select('*', { count: 'exact', head: true });

        // Reportes hoy
        const { count: reportesHoy } = await supabase
            .from('reportes')
            .select('*', { count: 'exact', head: true })
            .gte('fecha_creacion', hoy.toISOString());

        // Total usuarios ciudadanos
        const { count: totalCiudadanos } = await supabase
            .from('usuarios')
            .select('*', { count: 'exact', head: true })
            .eq('rol', 'ciudadano');

        // Usuarios bloqueados activos
        const { count: usuariosBloqueados } = await supabase
            .from('bloqueos_usuario')
            .select('*', { count: 'exact', head: true })
            .eq('activo', true);

        // Reportes sin atender (pendientes)
        const { count: sinAtender } = await supabase
            .from('reportes')
            .select('*, estados!inner(codigo)', { count: 'exact', head: true })
            .eq('estados.codigo', 'pendiente');

        // Reportes resueltos total
        const { count: totalResueltos } = await supabase
            .from('reportes')
            .select('*, estados!inner(codigo)', { count: 'exact', head: true })
            .eq('estados.codigo', 'resuelto');

        // Reportes rechazados total
        const { count: totalRechazados } = await supabase
            .from('reportes')
            .select('*, estados!inner(codigo)', { count: 'exact', head: true })
            .eq('estados.codigo', 'rechazado');

        // Tasa de resolución
        const tasaResolucion = totalReportes > 0 
            ? Math.round((totalResueltos / totalReportes) * 100) 
            : 0;

        res.json({
            total_reportes: totalReportes || 0,
            reportes_hoy: reportesHoy || 0,
            total_ciudadanos: totalCiudadanos || 0,
            usuarios_bloqueados: usuariosBloqueados || 0,
            sin_atender: sinAtender || 0,
            total_resueltos: totalResueltos || 0,
            total_rechazados: totalRechazados || 0,
            tasa_resolucion: tasaResolucion
        });
    } catch (err) {
        next(err);
    }
};

module.exports = {
    getResumenDiario,
    getEstadisticasHistoricas,
    getReportesRechazados,
    generarReporte,
    getTendenciaMensual,
    getConteos
};
