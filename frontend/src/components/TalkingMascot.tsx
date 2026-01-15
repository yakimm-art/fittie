import { useState, useEffect, useRef, useCallback } from 'react'
import './TalkingMascot.css'

interface TalkingMascotProps {
  mood?: 'happy' | 'excited' | 'tired' | 'thinking' | 'cheering' | 'speaking'
  size?: 'sm' | 'md' | 'lg' | 'xl'
  message?: string
  audioSrc?: string
  onSpeechEnd?: () => void
  animate?: boolean
  showPhone?: boolean
}

function TalkingMascot({ 
  mood = 'happy', 
  size = 'md', 
  message, 
  audioSrc,
  onSpeechEnd,
  animate = true,
  showPhone = true
}: TalkingMascotProps) {
  const [isSpeaking, setIsSpeaking] = useState(false)
  const [mouthOpen, setMouthOpen] = useState(false)
  const audioRef = useRef<HTMLAudioElement | null>(null)
  const animationRef = useRef<number | null>(null)
  const analyserRef = useRef<AnalyserNode | null>(null)

  const sizeMap = { sm: 100, md: 160, lg: 220, xl: 300 }
  const svgSize = sizeMap[size]

  const animateMouth = useCallback(() => {
    if (!analyserRef.current) return
    const dataArray = new Uint8Array(analyserRef.current.frequencyBinCount)
    analyserRef.current.getByteFrequencyData(dataArray)
    const average = dataArray.reduce((a, b) => a + b, 0) / dataArray.length
    setMouthOpen(average > 30)
    if (isSpeaking) {
      animationRef.current = requestAnimationFrame(animateMouth)
    }
  }, [isSpeaking])

  const playAudio = useCallback(async () => {
    if (!audioSrc) return
    try {
      const audioContext = new AudioContext()
      const audio = new Audio(audioSrc)
      audioRef.current = audio
      const source = audioContext.createMediaElementSource(audio)
      const analyser = audioContext.createAnalyser()
      analyser.fftSize = 256
      analyserRef.current = analyser
      source.connect(analyser)
      analyser.connect(audioContext.destination)
      audio.onplay = () => { setIsSpeaking(true); animateMouth() }
      audio.onended = () => {
        setIsSpeaking(false)
        setMouthOpen(false)
        if (animationRef.current) cancelAnimationFrame(animationRef.current)
        onSpeechEnd?.()
      }
      await audio.play()
    } catch (error) {
      console.error('Error playing audio:', error)
    }
  }, [audioSrc, animateMouth, onSpeechEnd])

  useEffect(() => {
    if (audioSrc) playAudio()
    return () => {
      if (audioRef.current) audioRef.current.pause()
      if (animationRef.current) cancelAnimationFrame(animationRef.current)
    }
  }, [audioSrc, playAudio])

  const currentMood = isSpeaking ? 'speaking' : mood
  const eyesClosed = currentMood === 'tired'

  return (
    <div className={`talking-mascot talking-mascot-${size} ${animate ? 'animate' : ''} ${isSpeaking ? 'speaking' : ''}`}>
      <div className="mascot-body">
        <svg viewBox="0 0 240 320" width={svgSize} height={svgSize * 1.33} className="mascot-svg">
          {/* Ears */}
          <ellipse cx="70" cy="60" rx="28" ry="55" fill="#FFB6C1" stroke="#E8A0B0" strokeWidth="2"/>
          <ellipse cx="70" cy="60" rx="16" ry="38" fill="#FFC8D4"/>
          <ellipse cx="170" cy="60" rx="28" ry="55" fill="#FFB6C1" stroke="#E8A0B0" strokeWidth="2"/>
          <ellipse cx="170" cy="60" rx="16" ry="38" fill="#FFC8D4"/>
          
          {/* Bow */}
          <g transform="translate(120, 45)" className="bow">
            <ellipse cx="-28" cy="0" rx="24" ry="14" fill="#FFB0C4"/>
            <ellipse cx="28" cy="0" rx="24" ry="14" fill="#FFB0C4"/>
            <circle cx="0" cy="0" r="12" fill="#FF8FAB"/>
            <ellipse cx="-28" cy="-3" rx="14" ry="7" fill="#FFC8D8" opacity="0.6"/>
            <ellipse cx="28" cy="-3" rx="14" ry="7" fill="#FFC8D8" opacity="0.6"/>
            <path d="M -5 10 Q -15 35 -8 50" stroke="#FFB0C4" strokeWidth="8" fill="none" strokeLinecap="round"/>
            <path d="M 5 10 Q 15 35 8 50" stroke="#FFB0C4" strokeWidth="8" fill="none" strokeLinecap="round"/>
          </g>
          
          {/* Head */}
          <ellipse cx="120" cy="130" rx="75" ry="70" fill="#FFB6C1" stroke="#E8A0B0" strokeWidth="2"/>
          <ellipse cx="120" cy="135" rx="55" ry="50" fill="#FFF5F7"/>
          
          {/* Eyes */}
          <g className={`eyes ${eyesClosed ? 'closed' : ''}`}>
            {eyesClosed ? (
              <>
                <path d="M 85 120 Q 95 130 105 120" stroke="#5D4037" strokeWidth="3" fill="none"/>
                <path d="M 135 120 Q 145 130 155 120" stroke="#5D4037" strokeWidth="3" fill="none"/>
              </>
            ) : (
              <>
                <ellipse cx="95" cy="120" rx="16" ry="18" fill="#5D4037"/>
                <ellipse cx="145" cy="120" rx="16" ry="18" fill="#5D4037"/>
                <circle cx="100" cy="114" r="6" fill="white"/>
                <circle cx="150" cy="114" r="6" fill="white"/>
                <circle cx="92" cy="122" r="3" fill="white"/>
                <circle cx="142" cy="122" r="3" fill="white"/>
              </>
            )}
            <path d="M 78 110 L 82 115" stroke="#5D4037" strokeWidth="2"/>
            <path d="M 75 115 L 80 118" stroke="#5D4037" strokeWidth="2"/>
            <path d="M 158 115 L 163 110" stroke="#5D4037" strokeWidth="2"/>
            <path d="M 160 118 L 165 115" stroke="#5D4037" strokeWidth="2"/>
          </g>
          
          {/* Cheeks */}
          <ellipse cx="65" cy="140" rx="14" ry="10" fill="#FFB6C1" opacity="0.7"/>
          <ellipse cx="175" cy="140" rx="14" ry="10" fill="#FFB6C1" opacity="0.7"/>
          
          {/* Nose */}
          <ellipse cx="120" cy="145" rx="8" ry="6" fill="#FF8FAB"/>
          <ellipse cx="118" cy="143" rx="3" ry="2" fill="#FFC8D8" opacity="0.6"/>
          
          {/* Mouth */}
          <g className={`mouth ${mouthOpen ? 'open' : ''}`}>
            {mouthOpen ? (
              <ellipse cx="120" cy="162" rx="10" ry="8" fill="#FF6B8A"/>
            ) : (
              <path d="M 110 158 Q 120 168 130 158" stroke="#5D4037" strokeWidth="2" fill="none"/>
            )}
          </g>
          
          {/* Body */}
          <ellipse cx="120" cy="215" rx="45" ry="40" fill="#FFB6C1" stroke="#E8A0B0" strokeWidth="2"/>
          
          {/* Dress */}
          <path d="M 75 210 Q 120 200 165 210 L 175 250 Q 120 265 65 250 Z" fill="#FFB0C4" stroke="#E8A0B0" strokeWidth="2"/>
          <path d="M 68 248 Q 85 258 120 260 Q 155 258 172 248" stroke="#FFF5F7" strokeWidth="4" fill="none" strokeLinecap="round"/>
          <path d="M 72 252 Q 90 262 120 264 Q 150 262 168 252" stroke="#FFC8D8" strokeWidth="2" fill="none" strokeLinecap="round"/>
          <rect x="80" y="205" width="80" height="8" rx="4" fill="#FF8FAB"/>
          
          {/* Left arm with dumbbell */}
          <g className="arm-left">
            <ellipse cx="65" cy="210" rx="18" ry="22" fill="#FFB6C1" stroke="#E8A0B0" strokeWidth="2"/>
            <g transform="translate(40, 185) rotate(-15)">
              <rect x="0" y="10" width="35" height="6" rx="3" fill="#808080"/>
              <rect x="-5" y="5" width="12" height="16" rx="3" fill="#606060"/>
              <rect x="28" y="5" width="12" height="16" rx="3" fill="#606060"/>
            </g>
          </g>
          
          {/* Right arm with phone */}
          <g className="arm-right">
            <ellipse cx="175" cy="210" rx="18" ry="22" fill="#FFB6C1" stroke="#E8A0B0" strokeWidth="2"/>
            {showPhone && (
              <g transform="translate(185, 175)">
                <rect x="0" y="0" width="28" height="50" rx="4" fill="#2D2D2D" stroke="#1a1a1a" strokeWidth="1"/>
                <rect x="2" y="4" width="24" height="40" rx="2" fill="#E8F4FD"/>
                <path d="M 14 18 C 10 14 6 18 14 26 C 22 18 18 14 14 18" fill="#FF6B8A"/>
                <path d="M 6 30 L 10 30 L 12 25 L 14 35 L 16 28 L 18 30 L 22 30" stroke="#FF6B8A" strokeWidth="1.5" fill="none"/>
              </g>
            )}
          </g>
          
          {/* Legs */}
          <rect x="95" y="255" width="20" height="45" rx="8" fill="#5D5D5D"/>
          <rect x="125" y="255" width="20" height="45" rx="8" fill="#5D5D5D"/>
          
          {/* Feet */}
          <ellipse cx="105" cy="305" rx="15" ry="10" fill="#FFB6C1" stroke="#E8A0B0" strokeWidth="2"/>
          <ellipse cx="135" cy="305" rx="15" ry="10" fill="#FFB6C1" stroke="#E8A0B0" strokeWidth="2"/>
          
          {/* Sparkles */}
          {(currentMood === 'excited' || currentMood === 'cheering' || isSpeaking) && (
            <g className="sparkles">
              <text x="190" y="90" fontSize="18" fill="#FFD700">✧</text>
              <text x="35" y="100" fontSize="16" fill="#FFD700">✦</text>
              <text x="200" y="150" fontSize="14" fill="#FF69B4">♪</text>
              <text x="25" y="160" fontSize="12" fill="#FF69B4">♫</text>
            </g>
          )}
        </svg>
      </div>
      
      {message && (
        <div className="speech-bubble">
          <span className="bubble-text">{message}</span>
          <div className="bubble-pointer" />
        </div>
      )}
    </div>
  )
}

export default TalkingMascot
