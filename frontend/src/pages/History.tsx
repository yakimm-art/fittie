import Mascot from '../components/Mascot'
import './History.css'

const mockHistory = [
  { date: 'Today', type: 'workout', title: 'Strength Training', duration: 32, exercises: 5, icon: '💪' },
  { date: 'Today', type: 'state', title: 'State Update', energy: 4, painPoints: [], icon: '✨' },
  { date: 'Yesterday', type: 'workout', title: 'Mobility Flow', duration: 20, exercises: 6, icon: '🧘' },
  { date: 'Yesterday', type: 'state', title: 'State Update', energy: 2, painPoints: ['lower_back'], icon: '📝' },
  { date: 'Jan 13', type: 'workout', title: 'Full Body', duration: 45, exercises: 8, icon: '🏋️' },
  { date: 'Jan 12', type: 'workout', title: 'Cardio Blast', duration: 25, exercises: 4, icon: '🏃' },
]

const achievements = [
  { icon: '🔥', label: '7 Day Streak', unlocked: true },
  { icon: '💪', label: '10 Workouts', unlocked: true },
  { icon: '🏆', label: '100 Exercises', unlocked: false },
  { icon: '⭐', label: 'Early Bird', unlocked: true },
]

function History() {
  return (
    <div className="history-page animate-fade-in">
      <div className="history-header">
        <div>
          <h1>Your Journey 📊</h1>
          <p>Look how far you've come!</p>
        </div>
        <Mascot mood="cheering" size="sm" />
      </div>

      <div className="stats-row">
        <div className="stat-card">
          <div className="stat-icon">🏋️</div>
          <div className="stat-info">
            <span className="stat-value">12</span>
            <span className="stat-label">Workouts</span>
          </div>
        </div>
        <div className="stat-card featured">
          <div className="stat-icon">🔥</div>
          <div className="stat-info">
            <span className="stat-value">7</span>
            <span className="stat-label">Day Streak</span>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon">⏱️</div>
          <div className="stat-info">
            <span className="stat-value">6.5h</span>
            <span className="stat-label">Total Time</span>
          </div>
        </div>
        <div className="stat-card">
          <div className="stat-icon">⚡</div>
          <div className="stat-info">
            <span className="stat-value">3.8</span>
            <span className="stat-label">Avg Energy</span>
          </div>
        </div>
      </div>

      <section className="achievements-section card-cute">
        <h2>🏆 Achievements</h2>
        <div className="achievements-grid">
          {achievements.map((achievement, index) => (
            <div 
              key={index} 
              className={`achievement-card ${achievement.unlocked ? 'unlocked' : 'locked'}`}
            >
              <span className="achievement-icon">{achievement.icon}</span>
              <span className="achievement-label">{achievement.label}</span>
              {!achievement.unlocked && <span className="lock-icon">🔒</span>}
            </div>
          ))}
        </div>
      </section>

      <section className="activity-section card-cute">
        <h2>📅 Recent Activity</h2>
        <div className="activity-timeline">
          {mockHistory.map((item, index) => (
            <div key={index} className="timeline-item">
              <div className="timeline-date">{item.date}</div>
              <div className="timeline-dot" />
              <div className={`timeline-card ${item.type}`}>
                <span className="timeline-icon">{item.icon}</span>
                <div className="timeline-content">
                  <h3>{item.title}</h3>
                  {item.type === 'workout' ? (
                    <p>{item.duration} min • {item.exercises} exercises</p>
                  ) : (
                    <p>
                      Energy: {'⚡'.repeat(item.energy || 0)}
                      {item.painPoints && item.painPoints.length > 0 && 
                        ` • Pain: ${item.painPoints.join(', ')}`
                      }
                    </p>
                  )}
                </div>
                {item.type === 'workout' && (
                  <span className="timeline-badge">✓ Complete</span>
                )}
              </div>
            </div>
          ))}
        </div>
      </section>

      <section className="motivation-section">
        <Mascot mood="happy" size="md" message="You're doing amazing! Keep it up! 🌟" />
      </section>
    </div>
  )
}

export default History
