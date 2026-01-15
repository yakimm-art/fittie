import { useState, useCallback } from 'react'

interface ElevenLabsConfig {
  apiKey: string
  voiceId?: string // Default: Rachel (21m00Tcm4TlvDq8ikWAM)
  stability?: number
  similarityBoost?: number
}

interface UseElevenLabsReturn {
  speak: (text: string) => Promise<string | null>
  isLoading: boolean
  error: string | null
  audioUrl: string | null
}

// Fittie's recommended voices
export const FITTIE_VOICES = {
  rachel: '21m00Tcm4TlvDq8ikWAM', // Calm, clear - default
  bella: 'EXAVITQu4vr4xnSDxMaL',  // Energetic, motivating
  elli: 'MF3mGyEYCl7XYWbV9V6O',   // Young, friendly
  charlotte: 'XB0fDUnXU5powFXDhCwa', // Warm, supportive
}

export function useElevenLabs(config: ElevenLabsConfig): UseElevenLabsReturn {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const [audioUrl, setAudioUrl] = useState<string | null>(null)

  const {
    apiKey,
    voiceId = FITTIE_VOICES.rachel,
    stability = 0.5,
    similarityBoost = 0.75,
  } = config

  const speak = useCallback(async (text: string): Promise<string | null> => {
    if (!apiKey) {
      setError('ElevenLabs API key is required')
      return null
    }

    setIsLoading(true)
    setError(null)

    try {
      const response = await fetch(
        `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}/stream`,
        {
          method: 'POST',
          headers: {
            'xi-api-key': apiKey,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            text,
            voice_settings: {
              stability,
              similarity_boost: similarityBoost,
            },
          }),
        }
      )

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}))
        throw new Error(errorData.detail?.message || `API error: ${response.status}`)
      }

      const audioBlob = await response.blob()
      const url = URL.createObjectURL(audioBlob)
      setAudioUrl(url)
      return url
    } catch (err) {
      const message = err instanceof Error ? err.message : 'Failed to generate speech'
      setError(message)
      return null
    } finally {
      setIsLoading(false)
    }
  }, [apiKey, voiceId, stability, similarityBoost])

  return { speak, isLoading, error, audioUrl }
}

// Coaching phrases for Fittie mascot
export const FITTIE_PHRASES = {
  greeting: [
    "Hey there! Ready to crush it today?",
    "Welcome back! Let's get moving!",
    "Hi friend! Time to feel amazing!",
  ],
  encouragement: [
    "You're doing amazing! Keep it up!",
    "Great form! Focus on your breathing.",
    "Perfect! You've got this!",
    "Awesome work! Three more reps!",
  ],
  completion: [
    "Woohoo! You did it! I'm so proud of you!",
    "Amazing workout! You're getting stronger every day!",
    "That was incredible! Rest up, champion!",
  ],
  rest: [
    "Take a breather. You've earned it!",
    "Nice work! Catch your breath.",
    "Great set! Rest for a moment.",
  ],
}

export function getRandomPhrase(category: keyof typeof FITTIE_PHRASES): string {
  const phrases = FITTIE_PHRASES[category]
  return phrases[Math.floor(Math.random() * phrases.length)]
}
