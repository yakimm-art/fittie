const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const { GoogleGenerativeAI } = require("@google/generative-ai");
const fetch = require("node-fetch");

// Secrets — stored server-side, never exposed to the client
const geminiApiKey = defineSecret("GEMINI_API_KEY");
const elevenLabsApiKey = defineSecret("ELEVENLABS_API_KEY");

// =============================================================================
// 1. GEMINI TEXT GENERATION (Workout generation, chat, fallback)
// =============================================================================
exports.geminiGenerate = onCall(
  { secrets: [geminiApiKey], maxInstances: 10, timeoutSeconds: 60 },
  async (request) => {
    // Require authentication
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be logged in.");
    }

    const { prompt, responseMimeType } = request.data;
    if (!prompt) {
      throw new HttpsError("invalid-argument", "prompt is required.");
    }

    try {
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      const model = genAI.getGenerativeModel({
        model: "gemini-2.0-flash",
        generationConfig: responseMimeType
          ? { responseMimeType }
          : undefined,
      });

      const result = await model.generateContent(prompt);
      const text = result.response.text();
      return { text };
    } catch (e) {
      console.error("Gemini generate error:", e);
      throw new HttpsError("internal", "AI generation failed.");
    }
  }
);

// =============================================================================
// 2. GEMINI CHAT (with conversation history)
// =============================================================================
exports.geminiChat = onCall(
  { secrets: [geminiApiKey], maxInstances: 10, timeoutSeconds: 60 },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be logged in.");
    }

    const { message, history } = request.data;
    if (!message) {
      throw new HttpsError("invalid-argument", "message is required.");
    }

    try {
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });

      // Build chat history from client-provided messages
      const chatHistory = (history || []).map((msg) => ({
        role: msg.role === "user" ? "user" : "model",
        parts: [{ text: msg.text }],
      }));

      const chat = model.startChat({ history: chatHistory });
      const result = await chat.sendMessage(message);
      const text = result.response.text();
      return { text };
    } catch (e) {
      console.error("Gemini chat error:", e);
      throw new HttpsError("internal", "Chat failed.");
    }
  }
);

// =============================================================================
// 3. GEMINI VISION (Gym photo analysis)
// =============================================================================
exports.geminiVision = onCall(
  {
    secrets: [geminiApiKey],
    maxInstances: 5,
    timeoutSeconds: 120,
    // Allow larger payloads for images
    enforceAppCheck: false,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be logged in.");
    }

    const { prompt, imageBase64, mimeType, responseMimeType } = request.data;
    if (!prompt || !imageBase64) {
      throw new HttpsError(
        "invalid-argument",
        "prompt and imageBase64 are required."
      );
    }

    try {
      const genAI = new GoogleGenerativeAI(geminiApiKey.value());
      const model = genAI.getGenerativeModel({
        model: "gemini-2.0-flash",
        generationConfig: responseMimeType
          ? { responseMimeType }
          : undefined,
      });

      const result = await model.generateContent([
        { text: prompt },
        {
          inlineData: {
            mimeType: mimeType || "image/jpeg",
            data: imageBase64,
          },
        },
      ]);

      const text = result.response.text();
      return { text };
    } catch (e) {
      console.error("Gemini vision error:", e);
      throw new HttpsError("internal", "Vision analysis failed.");
    }
  }
);

// =============================================================================
// 4. ELEVENLABS TEXT-TO-SPEECH
// =============================================================================
exports.elevenLabsTts = onCall(
  {
    secrets: [elevenLabsApiKey],
    maxInstances: 5,
    timeoutSeconds: 30,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "You must be logged in.");
    }

    const { text, voiceId, stability, similarityBoost, style } = request.data;
    if (!text) {
      throw new HttpsError("invalid-argument", "text is required.");
    }

    const vid = voiceId || "SOYHLrjzK2X1ezoPC6cr"; // Fittie's default voice

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
        throw new HttpsError("internal", `TTS failed: ${response.status}`);
      }

      const buffer = await response.buffer();
      const audioBase64 = buffer.toString("base64");
      return { audioBase64 };
    } catch (e) {
      if (e instanceof HttpsError) throw e;
      console.error("ElevenLabs TTS error:", e);
      throw new HttpsError("internal", "TTS generation failed.");
    }
  }
);
