const { GoogleGenerativeAI } = require('@google/generative-ai');

// Inicializamos el SDK clásico
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

/**
 * Función para analizar un reporte usando Gemini
 * @param {Object} reporte - Objeto completo del reporte.
 * @param {Array} imagenesUrls - Array de URLs de imágenes adjuntas.
 * @param {Array} categoriasExistentes - Lista de categorías que ya existen en la BD.
 * @param {number} strikesUsuario - Cantidad de strikes previos del usuario (0 = nuevo).
 * @returns {Object} Resultado del análisis
 */
const analizarReporte = async (reporte, imagenesUrls = [], categoriasExistentes = [], strikesUsuario = 0) => {
    try {
        const model = genAI.getGenerativeModel({ model: "gemini-2.5-flash" });

        // Construimos la lista de categorías para que la IA las conozca
        const listaCategorias = categoriasExistentes.map(c => `- ${c.nombre} (Área: ${c.areas?.nombre || 'Sin área'})`).join('\n');

        // Contexto adicional sobre el historial del usuario
        let contextoUsuario = '';
        if (strikesUsuario > 0) {
            contextoUsuario = `
⚠️ ATENCIÓN: Este usuario tiene ${strikesUsuario} strike(s) previo(s) por enviar reportes falsos.
Sé MÁS ESTRICTO al evaluar la veracidad de este reporte.
Un usuario reincidente tiene mayor probabilidad de enviar reportes falsos.
Analiza con especial cuidado la coherencia entre la descripción, la categoría y las imágenes.
`;
        }

        let prompt = `
Eres un sistema de Inteligencia Artificial para el backend de una app de reportes vecinales.
Tu trabajo es analizar la denuncia del vecino y las imágenes proporcionadas (si las hay) para clasificarla correctamente.
Esto es para uso exclusivo de los administradores y para evitar bromas.

${contextoUsuario}

Datos del reporte original:
${JSON.stringify(reporte, null, 2)}

Estas son las categorías que YA EXISTEN en el sistema:
${listaCategorias}

REGLAS IMPORTANTES:
1. Si la categoría actual del vecino es correcta, devuelve ESE MISMO nombre exacto en "categoria_sugerida".
2. Si necesitas cambiar la categoría, usa PREFERIBLEMENTE una de las categorías existentes (copia el nombre exacto).
3. Solo sugiere una categoría NUEVA si ninguna de las existentes encaja para nada.
4. Si el reporte es una broma o no es real, marca es_valido como false.
5. Si las imágenes no coinciden con la descripción, marca es_valido como false.
6. Si la descripción es vaga, incoherente o claramente falsa, marca es_valido como false.

Devuelve un JSON con esta estructura exacta:
{
    "es_valido": true o false,
    "prioridad": "alta", "media" o "baja",
    "categoria_sugerida": "Nombre exacto de la categoría",
    "justificacion": "Explicación breve de por qué tomaste esta decisión"
}
`;

        const imageParts = [];

        // Descarga y conversión de imágenes a Base64
        for (const url of imagenesUrls) {
            try {
                const response = await fetch(url);
                const arrayBuffer = await response.arrayBuffer();
                const buffer = Buffer.from(arrayBuffer);
                const mimeType = response.headers.get('content-type') || 'image/jpeg';

                imageParts.push({
                    inlineData: {
                        data: buffer.toString("base64"),
                        mimeType
                    }
                });
            } catch (err) {
                console.error("Error al obtener imagen para Gemini:", err.message);
            }
        }

        const result = await model.generateContent({
            contents: [{
                role: "user",
                parts: [
                    { text: prompt },
                    ...imageParts
                ]
            }],
            generationConfig: {
                responseMimeType: "application/json"
            }
        });

        const responseText = result.response.text();
        return JSON.parse(responseText);

    } catch (error) {
        console.error("Error al analizar reporte con Gemini:", error);
        throw error;
    }
}

module.exports = {
    analizarReporte
};
