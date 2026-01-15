import { Link } from 'react-router-dom'
import Mascot from '../components/Mascot'
import './Dashboard.css'

function Dashboard() {
  const currentHour = new Date().getHours()
  const greeting = currentHour < 12 ? 'Good morning' : currentHour < 18 ? 'Good afternoon' : 'Good evening'
  
  return (
    <div className="dashboard animate-fade-in">
      <div className="dashboard-header">
        <div className="greeting">
          <h1>{greeting}! 👋</h1>
          <p>Ready to crush your goals today?</p>
        </div>
        <div className="header-mascot">
          <Mascot mood="happy" size="md" />
        </div>
      </div>

      <div className="quick-actions">
        <Link to="/app/workout" className="action-card primary">
          <div className="action-icon">🏃</div>
          <div className="action-content">
            <h3>Start Workout</h3>
            <p>Generate a personalized routine</p>
          </div>
          <span className="action-arrow">→</span>
        </Link>
        <Link to="/app/state" className="action-card">
          <div className="action-icon">✨</div>
          <div className="action-content">
            <h3>Update State</h3>
            <p>Tell me how you're feeling</p>
          </div>
          <span className="action-arrow">→</span>
        </Link>
      </div>

      <div className="dashboard-grid">
        <section className="current-state card-cute">
          <div className="section-header">
            <h2>🌟 Current State</h2>
            <Link to="/app/state" className="edit-link">Edit</Link>
          </div>
          <div className="state-grid">
            <div className="state-item">
              <div className="state-icon">⚡</div>
              <div className="state-info">
                <span className="state-label">Energy</span>
                <div className="energy-dots">
                  {[1, 2, 3, 4, 5].map(i => (
                    <span key={i} className={`dot ${i <= 3 ? 'active' : ''}`} />
                  ))}
                </div>
              </div>
            </div>
            <div className="state-item">
              <div className="state-icon">🎯</div>
              <div className="state-info">
                <span className="state-label">Pain Points</span>
                <span className="state-value">Lower back</span>
              </div>
            </div>
            <div className="state-item">
              <div className="state-icon">🏠</div>
              <div className="state-info">
                <span className="state-label">Location</span>
                <span className="state-value">Home</span>
              </div>
            </div>
            <div className="state-item">
              <div className="state-icon">🏋️</div>
              <div className="state-info">
                <span className="state-label">Equipment</span>
                <span className="state-value">Dumbbells, Mat</span>
              </div>
            </div>
          </div>
        </section>

        <section className="streak-card card-cute">
          <div className="streak-content">
            <div className="streak-icon">🔥</div>
            <div className="streak-info">
              <span className="streak-number">7</span>
              <span className="streak-label">Day Streak!</span>
            </div>
          </div>
          <p className="streak-message">You're on fire! Keep it up! 💪</p>
        </section>

        <section className="micro-flow card-cute">
          <div className="section-header">
            <h2>🧘 Quick Stretch</h2>
            <span className="badge badge-primary">2 min</span>
          </div>
          <p>Been sitting for a while? Try this quick desk stretch!</p>
          <button className="btn-cute btn-full">
            Start Micro-Flow ✨
          </button>
        </section>

        <section className="recent-activity card-cute">
          <div className="section-header">
            <h2>📊 Recent Activity</h2>
            <Link to="/app/history" className="edit-link">See all</Link>
          </div>
          <div className="activity-list">
            <div className="activity-item">
              <span className="activity-icon">💪</span>
              <div className="activity-info">
                <span className="activity-title">Strength Training</span>
                <span className="activity-meta">Today • 32 min</span>
              </div>
              <span className="activity-badge">✓</span>
            </div>
            <div className="activity-item">
              <span className="activity-icon">🧘</span>
              <div className="activity-info">
                <span className="activity-title">Mobility Flow</span>
                <span className="activity-meta">Yesterday • 20 min</span>
              </div>
              <span className="activity-badge">✓</span>
            </div>
          </div>
        </section>
      </div>

      <section className="motivation-card">
        <Mascot mood="cheering" size="sm" />
        <p>"Every rep counts! You're doing amazing! 🌟"</p>
      </section>
    </div>
  )
}

export default Dashboard
