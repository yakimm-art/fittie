import { useState } from 'react'
import Mascot from '../components/Mascot'
import './State.css'

const BODY_PARTS = [
  { id: 'lower_back', label: 'Lower Back', icon: '🔙' },
  { id: 'upper_back', label: 'Upper Back', icon: '⬆️' },
  { id: 'knees', label: 'Knees', icon: '🦵' },
  { id: 'shoulders', label: 'Shoulders', icon: '💪' },
  { id: 'neck', label: 'Neck', icon: '🦒' },
  { id: 'hips', label: 'Hips', icon: '🦴' },
  { id: 'ankles', label: 'Ankles', icon: '🦶' },
  { id: 'wrists', label: 'Wrists', icon: '✋' },
]

const EQUIPMENT = [
  { id: 'dumbbells', label: 'Dumbbells', icon: '🏋️' },
  { id: 'resistance_bands', label: 'Bands', icon: '🎗️' },
  { id: 'yoga_mat', label: 'Yoga Mat', icon: '🧘' },
  { id: 'pull_up_bar', label: 'Pull-up Bar', icon: '🏗️' },
  { id: 'kettlebell', label: 'Kettlebell', icon: '🔔' },
  { id: 'bench', label: 'Bench', icon: '🪑' },
]

const LOCATIONS = [
  { id: 'home', label: 'Home', icon: '🏠' },
  { id: 'gym', label: 'Gym', icon: '🏋️' },
  { id: 'office', label: 'Office', icon: '🏢' },
  { id: 'outdoor', label: 'Outdoor', icon: '🌳' },
]

function State() {
  const [energyLevel, setEnergyLevel] = useState(3)
  const [painPoints, setPainPoints] = useState<string[]>([])
  const [equipment, setEquipment] = useState<string[]>(['dumbbells', 'yoga_mat'])
  const [location, setLocation] = useState('home')
  const [saved, setSaved] = useState(false)

  const togglePain = (part: string) => {
    setPainPoints(prev => 
      prev.includes(part) ? prev.filter(p => p !== part) : [...prev, part]
    )
  }

  const toggleEquipment = (item: string) => {
    setEquipment(prev => 
      prev.includes(item) ? prev.filter(e => e !== item) : [...prev, item]
    )
  }

  const handleSave = () => {
    setSaved(true)
    setTimeout(() => setSaved(false), 2000)
  }

  const getMascotMood = () => {
    if (energyLevel <= 2) return 'tired'
    if (energyLevel >= 4) return 'excited'
    return 'happy'
  }

  const getMascotMessage = () => {
    if (energyLevel <= 2) return "Taking it easy today? That's okay! 💖"
    if (energyLevel >= 4) return "Wow, you're full of energy! 🔥"
    return "Looking good! Let's do this! ✨"
  }

  return (
    <div className="state-page animate-fade-in">
      <div className="state-header">
        <div>
          <h1>How Are You Feeling? ✨</h1>
          <p>Help me personalize your workout</p>
        </div>
        <Mascot mood={getMascotMood()} size="md" message={getMascotMessage()} />
      </div>

      <div className="state-form">
        <section className="form-section card-cute">
          <h2>
            <span className="section-icon">⚡</span>
            Energy Level
          </h2>
          <div className="energy-selector">
            {[1, 2, 3, 4, 5].map(level => (
              <button
                key={level}
                className={`energy-btn ${energyLevel === level ? 'active' : ''}`}
                onClick={() => setEnergyLevel(level)}
              >
                <span className="energy-emoji">
                  {level === 1 && '😴'}
                  {level === 2 && '😐'}
                  {level === 3 && '🙂'}
                  {level === 4 && '😊'}
                  {level === 5 && '🔥'}
                </span>
                <span className="energy-label">
                  {level === 1 && 'Exhausted'}
                  {level === 2 && 'Low'}
                  {level === 3 && 'Okay'}
                  {level === 4 && 'Good'}
                  {level === 5 && 'Amazing!'}
                </span>
              </button>
            ))}
          </div>
        </section>

        <section className="form-section card-cute">
          <h2>
            <span className="section-icon">🩹</span>
            Any Pain or Discomfort?
          </h2>
          <p className="section-hint">Select areas to avoid during workout</p>
          <div className="pain-grid">
            {BODY_PARTS.map(part => (
              <button
                key={part.id}
                className={`pain-btn ${painPoints.includes(part.id) ? 'active' : ''}`}
                onClick={() => togglePain(part.id)}
              >
                <span className="pain-icon">{part.icon}</span>
                <span className="pain-label">{part.label}</span>
                {painPoints.includes(part.id) && <span className="pain-badge">⚠️</span>}
              </button>
            ))}
          </div>
        </section>

        <section className="form-section card-cute">
          <h2>
            <span className="section-icon">🏋️</span>
            Available Equipment
          </h2>
          <div className="equipment-grid">
            {EQUIPMENT.map(item => (
              <button
                key={item.id}
                className={`equipment-btn ${equipment.includes(item.id) ? 'active' : ''}`}
                onClick={() => toggleEquipment(item.id)}
              >
                <span className="equipment-icon">{item.icon}</span>
                <span className="equipment-label">{item.label}</span>
                {equipment.includes(item.id) && <span className="equipment-check">✓</span>}
              </button>
            ))}
          </div>
        </section>

        <section className="form-section card-cute">
          <h2>
            <span className="section-icon">📍</span>
            Where Are You?
          </h2>
          <div className="location-grid">
            {LOCATIONS.map(loc => (
              <button
                key={loc.id}
                className={`location-btn ${location === loc.id ? 'active' : ''}`}
                onClick={() => setLocation(loc.id)}
              >
                <span className="location-icon">{loc.icon}</span>
                <span className="location-label">{loc.label}</span>
              </button>
            ))}
          </div>
        </section>

        <button 
          className={`btn-primary save-btn ${saved ? 'saved' : ''}`} 
          onClick={handleSave}
        >
          {saved ? '✓ Saved! Fittie is ready!' : 'Save My State 💖'}
        </button>
      </div>
    </div>
  )
}

export default State
