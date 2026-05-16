const { GoogleGenerativeAI } = require('@google/generative-ai');

// Inicializamos el SDK clásico
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

/**
 * Función para analizar un reporte usando Gemini
 * @param {Object} reporte - Objeto completo del reporte.
 * @param {Array} imagenesUrls - Array de URLs de imágenes adjuntas.
 * @returns {Object} Resultado del análisis
 */
const analizarReporte = async (reporte, imagenesUrls = []) => {
    try {
        // 1. CORRECCIÓN: Usamos gemini-1.5-flash, totalmente compatible con tu SDK
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

        let prompt = `
Eres un sistema de Inteligencia Artificial para el backend de una app de reportes vecinales.
Tu trabajo es analizar la denuncia del vecino y las imágenes proporcionadas (si las hay) para clasificarla correctamente.
Esto es para uso exclusivo de los administradores y para evitar bromas.

Datos del reporte original:
${JSON.stringify(reporte, null, 2)}

Devuelve un objeto con la siguiente estructura:
{
    "es_valido": true o false, // false si parece una broma, exageración absurda o no es una denuncia real
    "prioridad": "alta", "media" o "baja",
    "categoria_sugerida": "Nombre de la categoría (puedes sugerir una nueva si las típicas no encajan, ej: 'Seguridad', 'Infraestructura', 'Limpieza', etc.)"
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
                
                // Formato 'Part' que requiere el SDK
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

        // 2. CORRECCIÓN: Estructura estricta { role, parts } para evitar el error 400
        const result = await model.generateContent({
            contents: [{
                role: "user",
                parts: [
                    { text: prompt }, // El texto debe ir dentro de un objeto con la propiedad 'text'
                    ...imageParts     // Las imágenes ya están estructuradas correctamente
                ]
            }],
            generationConfig: {
                responseMimeType: "application/json"
            }
        });

        const responseText = result.response.text();

        // Convertimos el JSON limpio directamente a objeto
        return JSON.parse(responseText);

    } catch (error) {
        console.error("Error al analizar reporte con Gemini:", error);
        throw error;
    }
}

module.exports = {
    analizarReporte
};
