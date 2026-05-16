import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/comentario.dart';
import '../../providers/reportes_provider.dart';

/// Widget de sección de comentarios de un reporte.
///
/// Muestra la cadena de comentarios y un campo para
/// agregar nuevos. Soporta tipos público/interno/oficial.
class ComentariosWidget extends StatefulWidget {
  final List<Comentario> comentarios;
  final String reporteId;
  final String rolUsuario;

  const ComentariosWidget({
    super.key,
    required this.comentarios,
    required this.reporteId,
    required this.rolUsuario,
  });

  @override
  State<ComentariosWidget> createState() => _ComentariosWidgetState();
}

class _ComentariosWidgetState extends State<ComentariosWidget> {
  final _textCtrl = TextEditingController();
  String _tipoSeleccionado = 'publico';
  bool _enviando = false;

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviarComentario() async {
    if (_textCtrl.text.trim().isEmpty) return;
    setState(() => _enviando = true);

    final provider = context.read<ReportesProvider>();
    await provider.agregarComentario(
      reporteId: widget.reporteId,
      texto: _textCtrl.text.trim(),
      tipo: _tipoSeleccionado,
    );

    _textCtrl.clear();
    setState(() => _enviando = false);
  }

  @override
  Widget build(BuildContext context) {
    final esFuncionario =
        widget.rolUsuario == 'funcionario' || widget.rolUsuario == 'admin';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Comentarios',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // ── Lista de comentarios ──
        if (widget.comentarios.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Aún no hay comentarios',
                style: TextStyle(color: AppColors.textHint, fontSize: 13),
              ),
            ),
          )
        else
          ...widget.comentarios.map((c) => _buildComentarioItem(c)),
        const SizedBox(height: 16),
        // ── Selector de tipo (solo funcionarios) ──
        if (esFuncionario) ...[
          Row(
            children: [
              _buildTipoChip('publico', '💬 Público'),
              const SizedBox(width: 8),
              _buildTipoChip('interno', '🔒 Interno'),
              const SizedBox(width: 8),
              _buildTipoChip('respuesta_oficial', '📋 Oficial'),
            ],
          ),
          const SizedBox(height: 8),
        ],
        // ── Input de comentario ──
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textCtrl,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 13),
                maxLines: 2,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Escribe un comentario...',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _enviando ? null : _enviarComentario,
              icon: _enviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.primary),
                    )
                  : Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                    ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComentarioItem(Comentario c) {
    final esOficial = c.esRespuestaOficial;
    final esInterno = c.esInterno;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: esOficial
            ? AppColors.primary.withOpacity(0.08)
            : esInterno
                ? AppColors.warning.withOpacity(0.06)
                : AppColors.surfaceLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(10),
        border: esOficial
            ? Border.all(color: AppColors.primary.withOpacity(0.2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _getRolColor(c.rolUsuario).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    c.nombreUsuario.isNotEmpty
                        ? c.nombreUsuario[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: _getRolColor(c.rolUsuario),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.nombreUsuario,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _getTipoLabel(c.tipo),
                      style: TextStyle(
                        fontSize: 10,
                        color: _getRolColor(c.rolUsuario),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                c.fecha != null
                    ? DateFormat('dd/MM HH:mm').format(c.fecha!)
                    : '',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            c.texto,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipoChip(String tipo, String label) {
    final selected = _tipoSeleccionado == tipo;
    return GestureDetector(
      onTap: () => setState(() => _tipoSeleccionado = tipo),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.2)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: selected ? AppColors.primary : AppColors.textHint,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Color _getRolColor(String rol) {
    switch (rol) {
      case 'funcionario':
        return AppColors.info;
      case 'admin':
        return AppColors.error;
      default:
        return AppColors.secondary;
    }
  }

  String _getTipoLabel(String tipo) {
    switch (tipo) {
      case 'interno':
        return '🔒 Nota interna';
      case 'respuesta_oficial':
        return '📋 Respuesta oficial';
      default:
        return 'Comentario';
    }
  }
}
