import { useRef } from 'react'
import './Mascot.css'

interface MascotProps {
  mood?: 'happy' | 'excited' | 'tired' | 'thinking' | 'cheering' | 'sleeping' | 'wink' | 'determined' | 'proud'
  size?: 'sm' | 'md' | 'lg' | 'xl'
  message?: string
  animate?: boolean
  speaking?: boolean
  viseme?: string // For ElevenLabs lip-sync: 'aa' | 'ee' | 'ih' | 'oh' | 'oo' | 'neutral'
  showHeadband?: boolean // Fitness headband accessory
  showDumbbell?: boolean // Show dumbbell in hand
}

function Mascot({ mood = 'happy', size = 'md', message, animate = true, speaking = false, viseme = 'neutral', showHeadband = false, showDumbbell = false }: MascotProps) {
  const mouthRef = useRef<SVGPathElement>(null)
  
  const sizeClass = {
    sm: 'mascot-sm',
    md: 'mascot-md',
    lg: 'mascot-lg',
    xl: 'mascot-xl',
  }[size]

  // Determine if arms should be raised based on mood
  const isArmRaised = mood === 'cheering' || mood === 'excited' || mood === 'proud' || mood === 'determined'

  // Mouth shapes for lip-sync (ElevenLabs visemes)
  const getMouthPath = () => {
    if (speaking) {
      switch (viseme) {
        case 'aa': return 'M70 145 Q100 175 130 145 Q100 165 70 145' // Open wide
        case 'ee': return 'M72 148 Q100 165 128 148' // Wide smile
        case 'ih': return 'M78 148 Q100 158 122 148' // Slight open
        case 'oh': return 'M85 145 Q100 165 115 145 Q100 158 85 145' // Round
        case 'oo': return 'M90 145 Q100 158 110 145 Q100 152 90 145' // Small round
        default: return 'M78 148 Q100 158 122 148' // Neutral
      }
    }
    
    switch (mood) {
      case 'excited':
      case 'cheering':
      case 'proud':
        return 'M68 140 Q100 175 132 140' // Big open smile
      case 'determined':
        return 'M75 145 Q100 162 125 145' // Confident smile
      case 'tired':
        return 'M80 152 Q100 145 120 152' // Slight frown
      case 'sleeping':
        return 'M85 150 Q100 152 115 150' // Relaxed
      case 'thinking':
        return 'M90 150 Q100 152 110 150' // Small
      case 'wink':
        return 'M72 145 Q100 168 128 145' // Playful smile
      default:
        return 'M72 145 Q100 168 128 145' // Happy smile
    }
  }

  // Eye expressions - bigger, friendlier eyes
  const getEyes = () => {
    switch (mood) {
      case 'excited':
      case 'cheering':
      case 'proud':
        return { leftOpen: true, rightOpen: true, sparkle: true, big: true }
      case 'determined':
        return { leftOpen: true, rightOpen: true, sparkle: true, big: false, determined: true }
      case 'tired':
      case 'sleeping':
        return { leftOpen: false, rightOpen: false, sparkle: false, big: false }
      case 'thinking':
        return { leftOpen: true, rightOpen: true, sparkle: false, big: false }
      case 'wink':
        return { leftOpen: true, rightOpen: false, sparkle: true, big: false }
      default:
        return { leftOpen: true, rightOpen: true, sparkle: true, big: false }
    }
  }

  const eyes = getEyes()
  
  // Eye sizes - much bigger for friendly look (1/4 to 1/3 of head width)
  const eyeRx = eyes.big ? 20 : 17
  const eyeRy = eyes.big ? 24 : 20

  return (
    <div className={`mascot-container ${sizeClass} ${animate ? 'animate' : ''} ${speaking ? 'speaking' : ''} ${isArmRaised ? 'arm-raised' : ''}`}>
      <div className="mascot-wrapper">
        <svg viewBox="-20 0 240 240" className="mascot-svg">
          <defs>
            {/* Gradient for fur - softer, more cartoon-like */}
            <radialGradient id="furGradient" cx="50%" cy="30%" r="70%">
              <stop offset="0%" stopColor="#FFE4EC" />
              <stop offset="100%" stopColor="#FFB6C1" />
            </radialGradient>
            {/* Inner ear gradient */}
            <radialGradient id="earInnerGradient" cx="50%" cy="50%" r="50%">
              <stop offset="0%" stopColor="#FFCDD8" />
              <stop offset="100%" stopColor="#FFB6C1" />
            </radialGradient>
            {/* Body gradient */}
            <radialGradient id="bodyGradient" cx="50%" cy="30%" r="70%">
              <stop offset="0%" stopColor="#FFE4EC" />
              <stop offset="100%" stopColor="#FFAEC0" />
            </radialGradient>
            {/* Headband gradient */}
            <linearGradient id="headbandGradient" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="#FF6B9D" />
              <stop offset="50%" stopColor="#7C5CFF" />
              <stop offset="100%" stopColor="#FF6B9D" />
            </linearGradient>
            {/* Dumbbell gradient */}
            <linearGradient id="dumbbellGradient" x1="0%" y1="0%" x2="0%" y2="100%">
              <stop offset="0%" stopColor="#A0A0A0" />
              <stop offset="50%" stopColor="#707070" />
              <stop offset="100%" stopColor="#505050" />
            </linearGradient>
          </defs>
          
          {/* Left Floppy Ear - rounder, cuter */}
          <ellipse cx="42" cy="55" rx="20" ry="40" fill="url(#furGradient)" stroke="#E8A0B0" strokeWidth="2" transform="rotate(-20 42 55)"/>
          <ellipse cx="42" cy="55" rx="10" ry="25" fill="url(#earInnerGradient)" transform="rotate(-20 42 55)"/>
          
          {/* Right Floppy Ear */}
          <ellipse cx="158" cy="55" rx="20" ry="40" fill="url(#furGradient)" stroke="#E8A0B0" strokeWidth="2" transform="rotate(20 158 55)"/>
          <ellipse cx="158" cy="55" rx="10" ry="25" fill="url(#earInnerGradient)" transform="rotate(20 158 55)"/>
          
          {/* Bow - simpler, cuter */}
          <g transform="translate(100, 32)" className="bow">
            {/* Left bow loop */}
            <ellipse cx="-18" cy="0" rx="15" ry="11" fill="#FF9EC4" stroke="#E8A0B0" strokeWidth="1.5"/>
            <ellipse cx="-18" cy="-2" rx="7" ry="5" fill="#FFD4E5" opacity="0.7"/>
            {/* Right bow loop */}
            <ellipse cx="18" cy="0" rx="15" ry="11" fill="#FF9EC4" stroke="#E8A0B0" strokeWidth="1.5"/>
            <ellipse cx="18" cy="-2" rx="7" ry="5" fill="#FFD4E5" opacity="0.7"/>
            {/* Bow center */}
            <circle cx="0" cy="0" r="7" fill="#FF85A8" stroke="#E8A0B0" strokeWidth="1"/>
          </g>
          
          {/* Head - bigger relative to body (1:1.5 ratio for cute look) */}
          <ellipse cx="100" cy="95" rx="58" ry="52" fill="url(#furGradient)" stroke="#E8A0B0" strokeWidth="2"/>
          
          {/* Fitness Headband */}
          {showHeadband && (
            <g className="headband">
              <path d="M45 75 Q100 60 155 75" stroke="url(#headbandGradient)" strokeWidth="8" fill="none" strokeLinecap="round"/>
              <path d="M45 75 Q100 62 155 75" stroke="#FFD4E5" strokeWidth="2" fill="none" strokeLinecap="round" opacity="0.5"/>
              {/* Sweat drops */}
              <ellipse cx="160" cy="85" rx="3" ry="5" fill="#74C0FC" opacity="0.8" className="sweat-drop"/>
            </g>
          )}
          
          {/* Face highlight - softer muzzle area */}
          <ellipse cx="100" cy="115" rx="30" ry="25" fill="#FFF8FA" opacity="0.9"/>
          
          {/* Blush - rounder, more prominent */}
          <ellipse cx="52" cy="115" rx="10" ry="7" fill="#FF9EC4" opacity="0.6"/>
          <ellipse cx="148" cy="115" rx="10" ry="7" fill="#FF9EC4" opacity="0.6"/>
          
          {/* Eyes - MUCH bigger for friendly, approachable look */}
          <g className="eyes-group">
            {/* Left eye */}
            {eyes.leftOpen ? (
              <g className="eye-left">
                <ellipse cx="72" cy="100" rx={eyeRx} ry={eyeRy} fill="#2D1810"/>
                {/* Big eye shine - key for life and appeal */}
                <ellipse cx="66" cy="92" rx="8" ry="9" fill="white"/>
                <circle cx="78" cy="106" r="4" fill="white" opacity="0.8"/>
              </g>
            ) : (
              <path d="M55 100 Q72 108 89 100" stroke="#2D1810" strokeWidth="3" strokeLinecap="round" fill="none"/>
            )}
            
            {/* Right eye */}
            {eyes.rightOpen ? (
              <g className="eye-right">
                <ellipse cx="128" cy="100" rx={eyeRx} ry={eyeRy} fill="#2D1810"/>
                {/* Big eye shine */}
                <ellipse cx="122" cy="92" rx="8" ry="9" fill="white"/>
                <circle cx="134" cy="106" r="4" fill="white" opacity="0.8"/>
              </g>
            ) : (
              <path d="M111 100 Q128 108 145 100" stroke="#2D1810" strokeWidth="3" strokeLinecap="round" fill="none"/>
            )}
          </g>
          
          {/* Sparkles near eyes - cuter placement */}
          {eyes.sparkle && (
            <g className="sparkles">
              <path d="M48 82 L50 78 L52 82 L56 84 L52 86 L50 90 L48 86 L44 84 Z" fill="#FFD700" className="sparkle"/>
              <path d="M148 82 L150 78 L152 82 L156 84 L152 86 L150 90 L148 86 L144 84 Z" fill="#FFD700" className="sparkle"/>
              {/* Extra sparkles for excited/proud moods */}
              {(mood === 'excited' || mood === 'proud' || mood === 'cheering') && (
                <>
                  <path d="M38 95 L39 92 L40 95 L43 96 L40 97 L39 100 L38 97 L35 96 Z" fill="#FF9EC4" className="sparkle" style={{ animationDelay: '0.3s' }}/>
                  <path d="M160 95 L161 92 L162 95 L165 96 L162 97 L161 100 L160 97 L157 96 Z" fill="#FF9EC4" className="sparkle" style={{ animationDelay: '0.6s' }}/>
                </>
              )}
            </g>
          )}
          
          {/* Determined eyebrows */}
          {eyes.determined && (
            <g className="eyebrows">
              <path d="M58 88 L85 92" stroke="#4A3728" strokeWidth="3" strokeLinecap="round"/>
              <path d="M142 88 L115 92" stroke="#4A3728" strokeWidth="3" strokeLinecap="round"/>
            </g>
          )}
          
          {/* Nose - simple, cute triangle/heart */}
          <ellipse cx="100" cy="125" rx="6" ry="5" fill="#FF6B8A"/>
          
          {/* Mouth - bigger, more expressive */}
          <path 
            ref={mouthRef}
            d={getMouthPath()} 
            fill={speaking ? '#FF6B8A' : 'none'} 
            stroke="#2D1810" 
            strokeWidth="2.5" 
            strokeLinecap="round"
            className="mouth-path"
          />
          
          {/* Body - rounder, simpler, smaller relative to head */}
          <ellipse cx="100" cy="185" rx="38" ry="35" fill="url(#bodyGradient)" stroke="#E8A0B0" strokeWidth="2"/>
          
          {/* Simple belly highlight */}
          <ellipse cx="100" cy="180" rx="22" ry="20" fill="#FFF8FA" opacity="0.5"/>
          
          {/* Arms - short, stubby, cute (mitten-style) */}
          {/* Dumbbell behind left arm when raised */}
          {isArmRaised && showDumbbell && (
            <g className="dumbbell-raised">
              <rect x="15" y="75" width="12" height="40" rx="5" fill="#707070" stroke="#505050" strokeWidth="1"/>
              <rect x="8" y="68" width="26" height="12" rx="4" fill="#505050"/>
              <rect x="8" y="110" width="26" height="12" rx="4" fill="#505050"/>
              {/* Shine */}
              <rect x="18" y="80" width="4" height="30" rx="2" fill="#909090" opacity="0.6"/>
            </g>
          )}
          
          {/* Left arm - raised for excited/cheering moods */}
          <g className={`arm-left ${isArmRaised ? 'raised' : ''}`}>
            {isArmRaised ? (
              <ellipse cx="32" cy="120" rx="16" ry="20" fill="url(#furGradient)" stroke="#E8A0B0" strokeWidth="2" transform="rotate(-50 32 120)"/>
            ) : (
              <>
                <ellipse cx="58" cy="175" rx="14" ry="18" fill="url(#furGradient)" stroke="#E8A0B0" strokeWidth="2" transform="rotate(-15 58 175)"/>
                {/* Dumbbell in resting position */}
                {showDumbbell && (
                  <g transform="translate(38, 178)">
                    <rect x="-5" y="-14" width="10" height="28" rx="4" fill="#707070" stroke="#505050" strokeWidth="1"/>
                    <rect x="-10" y="-18" width="20" height="8" rx="3" fill="#505050"/>
                    <rect x="-10" y="10" width="20" height="8" rx="3" fill="#505050"/>
                  </g>
                )}
              </>
            )}
          </g>
          
          {/* Right arm - also raised for symmetry when cheering */}
          <g className="arm-right">
            {isArmRaised ? (
              <ellipse cx="168" cy="120" rx="16" ry="20" fill="url(#furGradient)" stroke="#E8A0B0" strokeWidth="2" transform="rotate(50 168 120)"/>
            ) : (
              <ellipse cx="142" cy="175" rx="14" ry="18" fill="url(#furGradient)" stroke="#E8A0B0" strokeWidth="2" transform="rotate(15 142 175)"/>
            )}
          </g>
          
          {/* Feet - big, round, grounded (no legs, just feet for cute look) */}
          <ellipse cx="75" cy="218" rx="18" ry="10" fill="url(#furGradient)" stroke="#E8A0B0" strokeWidth="2"/>
          <ellipse cx="125" cy="218" rx="18" ry="10" fill="url(#furGradient)" stroke="#E8A0B0" strokeWidth="2"/>
        </svg>
      </div>
      
      {message && (
        <div className="mascot-bubble">
          <span>{message}</span>
          <div className="bubble-tail" />
        </div>
      )}
    </div>
  )
}

export default Mascot
