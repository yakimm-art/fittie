import { useState, useCallback, useRef } from 'react'

// Viseme types that ElevenLabs can provide
export type Viseme = 'aa' | 'ee' | 'ih' | 'oh' | 'oo' | 'neutral'

interface UseElevenLabsLipSyncReturn {
  speaking: boolean
  viseme: Viseme
  startSpeaking: (audioUrl?: string) => void
  stopSpeaking: () => void
  setViseme: (viseme: Viseme) => void
}

/**
 * Hook for integrating ElevenLabs audio with mascot lip-sync
 * 
 * Usage:
 * 1. Get audio from ElevenLabs API
 * 2. Call startSpeaking() when audio starts
 * 3. Update viseme based on ElevenLabs viseme events (if using their streaming API)
 * 4. Call stopSpeaking() when audio ends
 * 
 * For basic usage without viseme data:
 * - The mascot will animate with a simple speaking animation
 * 
 * For advanced usage with ElevenLabs streaming:
 * - Use their WebSocket API to get real-time viseme data
 * - Call setViseme() with each viseme update
 */
export function useElevenLabsLipSync(): UseElevenLabsLipSyncReturn {
  const [speaking, setSpeaking] = useState(false)
  const [viseme, setViseme] = useState<Viseme>('neutral')
  const audioRef = useRef<HTMLAudioElement | null>(null)
  const visemeIntervalRef = useRef<NodeJS.Timeout | null>(null)

  const startSpeaking = useCallback((audioUrl?: string) => {
    setSpeaking(true)
    
    if (audioUrl) {
      // Play audio if URL provided
      audioRef.current = new Audio(audioUrl)
      audioRef.current.onended = () => {
        setSpeaking(false)
        setViseme('neutral')
      }
      audioRef.current.play().catch(console.error)
    }
    
    // Simple viseme cycling for basic animation (when no real viseme data)
    // Replace this with actual ElevenLabs viseme data when available
    const visemes: Viseme[] = ['aa', 'ee', 'ih', 'oh', 'oo', 'neutral']
    let index = 0
    visemeIntervalRef.current = setInterval(() => {
      setViseme(visemes[index % visemes.length])
      index++
    }, 150)
  }, [])

  const stopSpeaking = useCallback(() => {
    setSpeaking(false)
    setViseme('neutral')
    
    if (audioRef.current) {
      audioRef.current.pause()
      audioRef.current = null
    }
    
    if (visemeIntervalRef.current) {
      clearInterval(visemeIntervalRef.current)
      visemeIntervalRef.current = null
    }
  }, [])

  return {
    speaking,
    viseme,
    startSpeaking,
    stopSpeaking,
    setViseme,
  }
}

export default useElevenLabsLipSync
