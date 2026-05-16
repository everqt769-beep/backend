const { GoogleGenerativeAI } = require('@google/generative-ai');

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

/**
 * Función para analizar un reporte usando Gemini
 * @param {Object} reporte - Objeto completo del reporte.
 * @param {Array} imagenesUrls - Array de URLs de imágenes adjuntas.
 * @returns {Object} Resultado del análisis
 */
const analizarReporte = async (reporte, imagenesUrls = []) => {
    try {
        const model = genAI.getGenerativeModel({ model: "gemini-3-flash" });

        let prompt = `
Eres un sistema de Inteligencia Artificial para el backend de una app de reportes vecinales.
Tu trabajo es analizar la denuncia del vecino y las imágenes proporcionadas (si las hay) para clasificarla correctamente.
Esto es para uso exclusivo de los administradores y para evitar bromas.

Datos del reporte original:
${JSON.stringify(reporte, null, 2)}

Devuelve un JSON estrictamente válido, sin markdown ni comillas triples. La estructura debe ser exactamente esta:
{
    "es_valido": true o false, // false si parece una broma, exageración absurda o no es una denuncia real
    "prioridad": "alta", "media" o "baja",
    "categoria_sugerida": "Nombre de la categoría (puedes sugerir una nueva si las típicas no encajan, ej: 'Seguridad', 'Infraestructura', 'Limpieza', etc.)"
}
`;

        const imageParts = [];

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

        const result = await model.generateContent([prompt, ...imageParts]);
        const responseText = result.response.text();

        const cleanJson = responseText.replace(/```json/gi, '').replace(/```/gi, '').trim();
        return JSON.parse(cleanJson);

    } catch (error) {
        console.error("Error al analizar reporte con Gemini:", error);
        throw error;
    }
}

module.exports = {
    analizarReporte
};
