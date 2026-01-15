import './FittieMascot.css'

interface FittieMascotProps {
  mood?: 'happy' | 'excited' | 'tired' | 'thinking' | 'cheering' | 'wink'
  size?: 'sm' | 'md' | 'lg' | 'xl'
  message?: string
  showDumbbell?: boolean
}

function FittieMascot({ mood = 'happy', size = 'md', message, showDumbbell = true }: FittieMascotProps) {
  const sizeMap = {
    sm: 80,
    md: 120,
    lg: 180,
    xl: 240,
  }
  
  const svgSize = sizeMap[size]

  // Eye expressions based on mood
  const getEyes = () => {
    switch (mood) {
      case 'excited':
        return { left: '◕', right: '◕', extra: '✧' }
      case 'tired':
        return { left: '︶', right: '︶', extra: '' }
      case 'thinking':
        return { left: '・', right: '・', extra: '?' }
      case 'cheering':
        return { left: '★', right: '★', extra: '!' }
      case 'wink':
        return { left: '◕', right: '‿', extra: '♪' }
      default:
        return { left: '◕', right: '◕', extra: '' }
    }
  }

  const eyes = getEyes()

  return (
    <div className={`fittie-container fittie-${size}`}>
      <div className="fittie-wrapper">
        <svg 
          viewBox="0 0 200 220" 
          width={svgSize} 
          height={svgSize * 1.1}
          className="fittie-svg"
        >
          {/* Ears */}
          <ellipse cx="60" cy="45" rx="25" ry="45" fill="#FFB6C1" stroke="#FF69B4" strokeWidth="2"/>
          <ellipse cx="60" cy="45" rx="15" ry="30" fill="#FFC0CB"/>
          <ellipse cx="140" cy="45" rx="25" ry="45" fill="#FFB6C1" stroke="#FF69B4" strokeWidth="2"/>
          <ellipse cx="140" cy="45" rx="15" ry="30" fill="#FFC0CB"/>
          
          {/* Bow */}
          <g transform="translate(100, 35)">
            <ellipse cx="-20" cy="0" rx="18" ry="12" fill="#FF69B4"/>
            <ellipse cx="20" cy="0" rx="18" ry="12" fill="#FF69B4"/>
            <circle cx="0" cy="0" r="8" fill="#FF1493"/>
            <ellipse cx="-20" cy="0" rx="10" ry="6" fill="#FFB6C1" opacity="0.5"/>
            <ellipse cx="20" cy="0" rx="10" ry="6" fill="#FFB6C1" opacity="0.5"/>
          </g>
          
          {/* Head/Body */}
          <ellipse cx="100" cy="120" rx="70" ry="65" fill="#FFB6C1" stroke="#FF69B4" strokeWidth="2"/>
          
          {/* Face white area */}
          <ellipse cx="100" cy="115" rx="50" ry="45" fill="#FFF0F5"/>
          
          {/* Blush */}
          <ellipse cx="55" cy="125" rx="12" ry="8" fill="#FFB6C1" opacity="0.8"/>
          <ellipse cx="145" cy="125" rx="12" ry="8" fill="#FFB6C1" opacity="0.8"/>
          
          {/* Eyes */}
          <g className="fittie-eyes">
            <circle cx="75" cy="105" r="12" fill="#4A3728"/>
            <circle cx="125" cy="105" r="12" fill="#4A3728"/>
            <circle cx="78" cy="102" r="4" fill="white"/>
            <circle cx="128" cy="102" r="4" fill="white"/>
            {mood === 'tired' && (
              <>
                <line x1="65" y1="95" x2="85" y2="95" stroke="#4A3728" strokeWidth="2"/>
                <line x1="115" y1="95" x2="135" y2="95" stroke="#4A3728" strokeWidth="2"/>
              </>
            )}
            {mood === 'wink' && (
              <path d="M 115 105 Q 125 115 135 105" stroke="#4A3728" strokeWidth="3" fill="none"/>
            )}
          </g>
          
          {/* Nose */}
          <ellipse cx="100" cy="125" rx="6" ry="4" fill="#FF69B4"/>
          
          {/* Mouth */}
          <path 
            d={mood === 'tired' ? "M 90 140 Q 100 135 110 140" : "M 85 138 Q 100 155 115 138"} 
            stroke="#4A3728" 
            strokeWidth="2" 
            fill={mood === 'tired' ? "none" : "#FF69B4"}
            strokeLinecap="round"
          />
          
          {/* Dress/Body */}
          <path d="M 50 170 Q 100 160 150 170 L 160 210 Q 100 220 40 210 Z" fill="#FFB6C1" stroke="#FF69B4" strokeWidth="2"/>
          <path d="M 45 205 Q 100 215 155 205" stroke="#FFF0F5" strokeWidth="3" fill="none"/>
          
          {/* Arms */}
          {showDumbbell && (
            <g className="fittie-arm">
              {/* Left arm with dumbbell */}
              <ellipse cx="35" cy="160" rx="15" ry="20" fill="#FFB6C1" stroke="#FF69B4" strokeWidth="2"/>
              {/* Dumbbell */}
              <rect x="10" y="140" width="8" height="25" rx="2" fill="#808080"/>
              <rect x="5" y="138" width="18" height="8" rx="2" fill="#606060"/>
              <rect x="5" y="159" width="18" height="8" rx="2" fill="#606060"/>
            </g>
          )}
          
          {/* Right arm */}
          <ellipse cx="165" cy="160" rx="15" ry="20" fill="#FFB6C1" stroke="#FF69B4" strokeWidth="2"/>
          
          {/* Sparkles for excited mood */}
          {(mood === 'excited' || mood === 'cheering') && (
            <g className="sparkles">
              <text x="170" y="80" fontSize="16" fill="#FFD700">✧</text>
              <text x="25" y="90" fontSize="14" fill="#FFD700">✦</text>
              <text x="175" y="130" fontSize="12" fill="#FF69B4">♪</text>
            </g>
          )}
        </svg>
      </div>
      
      {message && (
        <div className="fittie-bubble">
          <span>{message}</span>
        </div>
      )}
    </div>
  )
}

export default FittieMascot
