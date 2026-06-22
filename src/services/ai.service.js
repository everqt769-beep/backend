const { GoogleGenerativeAI } = require('@google/generative-ai');
const Groq = require('groq-sdk');

// Gemini
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

// Groq
const groq = new Groq({
    apiKey: process.env.GROQ_API_KEY,
});

const GROQ_MODEL =
    process.env.GROQ_MODEL || 'meta-llama/llama-4-scout-17b-16e-instruct';

function safeJsonParse(text) {
    try {
        return JSON.parse(text);
    } catch (err) {
        // Intenta extraer el primer JSON válido si el modelo mete texto extra
        const match = text.match(/\{[\s\S]*\}/);
        if (match) return JSON.parse(match[0]);
        throw err;
    }
}

async function cargarImagenesBase64(imagenesUrls = []) {
    const imageParts = [];

    // Groq soporta hasta 5 imágenes por request
    for (const url of imagenesUrls.slice(0, 5)) {
        try {
            const response = await fetch(url);
            const arrayBuffer = await response.arrayBuffer();
            const buffer = Buffer.from(arrayBuffer);
            const mimeType = response.headers.get('content-type') || 'image/jpeg';

            imageParts.push({
                type: 'image_url',
                image_url: {
                    url: `data:${mimeType};base64,${buffer.toString('base64')}`,
                },
            });
        } catch (err) {
            console.error('Error al obtener imagen para Groq:', err.message);
        }
    }

    return imageParts;
}

async function analizarConGroq(reporte, imagenesUrls = [], categoriasExistentes = [], strikesUsuario = 0) {
    const listaCategorias = categoriasExistentes
        .map(c => `- ${c.nombre} (Área: ${c.areas?.nombre || 'Sin área'})`)
        .join('\n');

    let contextoUsuario = '';
    if (strikesUsuario > 0) {
        contextoUsuario = `
⚠️ ATENCIÓN: Este usuario tiene ${strikesUsuario} strike(s) previo(s) por enviar reportes falsos.
Sé MÁS ESTRICTO al evaluar la veracidad de este reporte.
Analiza con especial cuidado la coherencia entre la descripción, la categoría y las imágenes.
`;
    }

    const prompt = `
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

Devuelve SOLO un JSON con esta estructura exacta:
{
  "es_valido": true o false,
  "prioridad": "alta", "media" o "baja",
  "categoria_sugerida": "Nombre exacto de la categoría",
  "justificacion": "Explicación breve de por qué tomaste esta decisión"
}
`;

    const imageParts = await cargarImagenesBase64(imagenesUrls);

    const completion = await groq.chat.completions.create({
        model: GROQ_MODEL,
        messages: [
            {
                role: 'user',
                content: [
                    { type: 'text', text: prompt },
                    ...imageParts,
                ],
            },
        ],
        temperature: 0.2,
        max_completion_tokens: 400,
        response_format: { type: 'json_object' },
    });

    const content = completion.choices?.[0]?.message?.content || '{}';
    return safeJsonParse(content);
}

async function analizarConGemini(reporte, imagenesUrls = [], categoriasExistentes = [], strikesUsuario = 0) {
    const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });

    const listaCategorias = categoriasExistentes
        .map(c => `- ${c.nombre} (Área: ${c.areas?.nombre || 'Sin área'})`)
        .join('\n');

    let contextoUsuario = '';
    if (strikesUsuario > 0) {
        contextoUsuario = `
⚠️ ATENCIÓN: Este usuario tiene ${strikesUsuario} strike(s) previo(s) por enviar reportes falsos.
Sé MÁS ESTRICTO al evaluar la veracidad de este reporte.
Un usuario reincidente tiene mayor probabilidad de enviar reportes falsos.
Analiza con especial cuidado la coherencia entre la descripción, la categoría y las imágenes.
`;
    }

    const prompt = `
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

    for (const url of imagenesUrls.slice(0, 5)) {
        try {
            const response = await fetch(url);
            const arrayBuffer = await response.arrayBuffer();
            const buffer = Buffer.from(arrayBuffer);
            const mimeType = response.headers.get('content-type') || 'image/jpeg';

            imageParts.push({
                inlineData: {
                    data: buffer.toString('base64'),
                    mimeType,
                },
            });
        } catch (err) {
            console.error('Error al obtener imagen para Gemini:', err.message);
        }
    }

    const result = await model.generateContent({
        contents: [
            {
                role: 'user',
                parts: [
                    { text: prompt },
                    ...imageParts,
                ],
            },
        ],
        generationConfig: {
            responseMimeType: 'application/json',
        },
    });

    const responseText = result.response.text();
    return JSON.parse(responseText);
}

/**
 * Principal: intenta Gemini y si falla usa Groq
 */
const analizarReporte = async (
    reporte,
    imagenesUrls = [],
    categoriasExistentes = [],
    strikesUsuario = 0
) => {
    try {
        return await analizarConGemini(
            reporte,
            imagenesUrls,
            categoriasExistentes,
            strikesUsuario
        );
    } catch (errorGemini) {
        console.error('Gemini falló, usando Groq:', errorGemini.message);

        try {
            return await analizarConGroq(
                reporte,
                imagenesUrls,
                categoriasExistentes,
                strikesUsuario
            );
        } catch (errorGroq) {
            console.error('Groq también falló:', errorGroq.message);
            throw errorGroq;
        }
    }
};

module.exports = {
    analizarReporte,
};