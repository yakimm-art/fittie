const { onRequest } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const fetch = require("node-fetch");
const admin = require("firebase-admin");

admin.initializeApp();

// Secrets — stored server-side, never exposed to the client
const geminiApiKey = defineSecret("GEMINI_API_KEY");
const elevenLabsApiKey = defineSecret("ELEVENLABS_API_KEY");

// Helper: verify Firebase Auth token from Authorization header
async function verifyAuth(req, res) {
  const auth = req.headers.authorization;
  if (!auth || !auth.startsWith("Bearer ")) {
    res.status(401).json({ error: "Unauthorized" });
    return null;
  }
  try {
    return await admin.auth().verifyIdToken(auth.split("Bearer ")[1]);
  } catch (e) {
    res.status(401).json({ error: "Invalid token" });
    return null;
  }
}

// =============================================================================
// 1. GEMINI TEXT GENERATION (Workout generation, chat fallback)
// =============================================================================
exports.geminiGenerate = onRequest(
  { secrets: [geminiApiKey], maxInstances: 10, timeoutSeconds: 60, cors: true },
  async (req, res) => {
    const user = await verifyAuth(req, res);
    if (!user) return;

    const { prompt, responseMimeType } = req.body;
    if (!prompt) return res.status(400).json({ error: "prompt is required" });

    try {
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      const model = genAI.getGenerativeModel({
        model: "gemini-3-flash-preview",
        generationConfig: responseMimeType ? { responseMimeType } : undefined,
      });

      const result = await model.generateContent(prompt);
      res.json({ text: result.response.text() });
    } catch (e) {
      console.error("Gemini generate error:", e);
      res.status(500).json({ error: "AI generation failed" });
    }
  }
);

// =============================================================================
// 2. GEMINI CHAT (with conversation history)
// =============================================================================
exports.geminiChat = onRequest(
  { secrets: [geminiApiKey], maxInstances: 10, timeoutSeconds: 60, cors: true },
  async (req, res) => {
    const user = await verifyAuth(req, res);
    if (!user) return;

    const { message, history } = req.body;
    if (!message) return res.status(400).json({ error: "message is required" });

    try {
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      const model = genAI.getGenerativeModel({ model: "gemini-3-flash-preview" });

      const chatHistory = (history || []).map((msg) => ({
        role: msg.role === "user" ? "user" : "model",
        parts: [{ text: msg.text }],
      }));

      const chat = model.startChat({ history: chatHistory });
      const result = await chat.sendMessage(message);
      res.json({ text: result.response.text() });
    } catch (e) {
      console.error("Gemini chat error:", e);
      res.status(500).json({ error: "Chat failed" });
    }
  }
);

// =============================================================================
// 3. GEMINI VISION (Gym photo analysis)
// =============================================================================
exports.geminiVision = onRequest(
  { secrets: [geminiApiKey], maxInstances: 5, timeoutSeconds: 120, cors: true },
  async (req, res) => {
    const user = await verifyAuth(req, res);
    if (!user) return;

    const { prompt, imageBase64, mimeType, responseMimeType } = req.body;
    if (!prompt || !imageBase64) {
      return res.status(400).json({ error: "prompt and imageBase64 are required" });
    }

    try {
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      const model = genAI.getGenerativeModel({
        model: "gemini-3-flash-preview",
        generationConfig: responseMimeType ? { responseMimeType } : undefined,
      });

      const result = await model.generateContent([
        { text: prompt },
        { inlineData: { mimeType: mimeType || "image/jpeg", data: imageBase64 } },
      ]);

      res.json({ text: result.response.text() });
    } catch (e) {
      console.error("Gemini vision error:", e);
      res.status(500).json({ error: "Vision analysis failed" });
    }
  }
);

// =============================================================================
// 4. ELEVENLABS TEXT-TO-SPEECH
// =============================================================================
exports.elevenLabsTts = onRequest(
  { secrets: [elevenLabsApiKey], maxInstances: 5, timeoutSeconds: 30, cors: true },
  async (req, res) => {
    const user = await verifyAuth(req, res);
    if (!user) return;

    const { text, voiceId, stability, similarityBoost, style } = req.body;
    if (!text) return res.status(400).json({ error: "text is required" });

    const vid = voiceId || "SOYHLrjzK2X1ezoPC6cr";

    try {
      const response = await fetch(
        `https://api.elevenlabs.io/v1/text-to-speech/${vid}`,
        {
          method: "POST",
          headers: {
            "xi-api-key": elevenLabsApiKey.value(),
            "Content-Type": "application/json",
            accept: "audio/mpeg",
          },
          body: JSON.stringify({
            text,
            model_id: "eleven_turbo_v2_5",
            voice_settings: {
              stability: stability ?? 0.5,
              similarity_boost: similarityBoost ?? 0.8,
              style: style ?? 0.5,
            },
          }),
        }
      );

      if (!response.ok) {
        console.error(`ElevenLabs error: ${response.status}`);
        return res.status(502).json({ error: `TTS failed: ${response.status}` });
      }

      const buffer = await response.buffer();
      res.json({ audioBase64: buffer.toString("base64") });
    } catch (e) {
      console.error("ElevenLabs TTS error:", e);
      res.status(500).json({ error: "TTS generation failed" });
    }
  }
);
