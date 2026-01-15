import { useState } from 'react'
import Mascot from '../components/Mascot'
import './Workout.css'

interface Exercise {
  name: string
  sets: number
  reps: number
  restSeconds: number
  icon: string
}

function Workout() {
  const [isGenerating, setIsGenerating] = useState(false)
  const [routine, setRoutine] = useState<Exercise[] | null>(null)
  const [duration, setDuration] = useState(30)
  const [goals, setGoals] = useState<string[]>(['strength'])
  const [activeExercise, setActiveExercise] = useState<number | null>(null)

  const goalOptions = [
    { id: 'strength', label: 'Strength', icon: '💪' },
    { id: 'mobility', label: 'Mobility', icon: '🧘' },
    { id: 'cardio', label: 'Cardio', icon: '🏃' },
    { id: 'balance', label: 'Balance', icon: '⚖️' },
  ]

  const toggleGoal = (goal: string) => {
    setGoals(prev => 
      prev.includes(goal) 
        ? prev.filter(g => g !== goal)
        : [...prev, goal]
    )
  }

  const generateRoutine = async () => {
    setIsGenerating(true)
    // Simulate API call
    setTimeout(() => {
      setRoutine([
        { name: 'Goblet Squat', sets: 3, reps: 12, restSeconds: 60, icon: '🏋️' },
        { name: 'Push-up', sets: 3, reps: 10, restSeconds: 45, icon: '💪' },
        { name: 'Dumbbell Row', sets: 3, reps: 10, restSeconds: 60, icon: '🏋️' },
        { name: 'Plank', sets: 3, reps: 30, restSeconds: 30, icon: '🧘' },
        { name: 'Cat-Cow Stretch', sets: 2, reps: 10, restSeconds: 30, icon: '🐱' },
      ])
      setIsGenerating(false)
    }, 1500)
  }

  return (
    <div className="workout-page animate-fade-in">
      {!routine ? (
        <>
          <div className="workout-header">
            <div>
              <h1>Let's Build Your Workout! 💪</h1>
              <p>Tell me what you're in the mood for</p>
            </div>
            <Mascot mood="thinking" size="sm" />
          </div>

          <div className="workout-config card-cute">
            <div className="config-section">
              <label>
                <span className="config-icon">⏱️</span>
                How much time do you have?
              </label>
              <div className="duration-selector">
                {[15, 30, 45, 60].map(mins => (
                  <button
                    key={mins}
                    className={`duration-btn ${duration === mins ? 'active' : ''}`}
                    onClick={() => setDuration(mins)}
                  >
                    {mins} min
                  </button>
                ))}
              </div>
            </div>

            <div className="config-section">
              <label>
                <span className="config-icon">🎯</span>
                What's your focus today?
              </label>
              <div className="goal-grid">
                {goalOptions.map(goal => (
                  <button
                    key={goal.id}
                    className={`goal-card ${goals.includes(goal.id) ? 'active' : ''}`}
                    onClick={() => toggleGoal(goal.id)}
                  >
                    <span className="goal-icon">{goal.icon}</span>
                    <span className="goal-label">{goal.label}</span>
                    {goals.includes(goal.id) && <span className="goal-check">✓</span>}
                  </button>
                ))}
              </div>
            </div>

            <button 
              className="btn-primary generate-btn"
              onClick={generateRoutine}
              disabled={isGenerating || goals.length === 0}
            >
              {isGenerating ? (
                <>
                  <span className="spinner" />
                  Fittie is thinking...
                </>
              ) : (
                <>Generate My Routine ✨</>
              )}
            </button>
          </div>
        </>
      ) : (
        <>
          <div className="routine-header">
            <div>
              <h1>Your Routine is Ready! 🎉</h1>
              <p>{routine.length} exercises • ~{duration} minutes</p>
            </div>
            <button className="btn-secondary" onClick={() => setRoutine(null)}>
              ← New Routine
            </button>
          </div>

          <div className="routine-mascot">
            <Mascot mood="excited" size="md" message="You've got this! Let's go! 💖" />
          </div>

          <div className="exercise-list">
            {routine.map((exercise, index) => (
              <div 
                key={index} 
                className={`exercise-card ${activeExercise === index ? 'active' : ''}`}
                onClick={() => setActiveExercise(activeExercise === index ? null : index)}
              >
                <div className="exercise-number">{index + 1}</div>
                <div className="exercise-icon">{exercise.icon}</div>
                <div className="exercise-info">
                  <h3>{exercise.name}</h3>
                  <p>{exercise.sets} sets × {exercise.reps} {exercise.reps > 10 ? 'sec' : 'reps'}</p>
                </div>
                <div className="exercise-rest">
                  <span className="rest-icon">⏱️</span>
                  <span>{exercise.restSeconds}s rest</span>
                </div>
              </div>
            ))}
          </div>

          <div className="workout-actions">
            <button className="btn-primary start-btn">
              🎬 Start Workout with Voice Coach
            </button>
            <button className="btn-secondary">
              📋 Save for Later
            </button>
          </div>
        </>
      )}
    </div>
  )
}

export default Workout
