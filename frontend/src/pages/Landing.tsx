import { Link } from 'react-router-dom'
import Mascot from '../components/Mascot'
import './Landing.css'

function Landing() {
  return (
    <div className="landing">
      <header className="landing-header">
        <div className="container header-content">
          <Link to="/" className="logo">
            <span className="logo-icon">🏋️</span>
            <span className="logo-text">Fittie</span>
          </Link>
          <nav className="header-nav">
            <Link to="/login">Login</Link>
            <Link to="/signup" className="btn-primary">Get Started ✨</Link>
          </nav>
        </div>
      </header>

      <section className="hero">
        <div className="container hero-content">
          <div className="hero-text">
            <div className="hero-badge">✨ Your AI Fitness Buddy</div>
            <h1>Meet <span className="gradient-text">Fittie</span>, Your Cutest Workout Companion!</h1>
            <p>Personalized workouts that adapt to how you feel. Voice coaching. Real-time form feedback. All wrapped in a friendly experience!</p>
            <div className="hero-actions">
              <Link to="/signup" className="btn-primary btn-lg">
                Start Training 💪
              </Link>
              <Link to="/login" className="btn-secondary btn-lg">
                I have an account
              </Link>
            </div>
            <div className="hero-stats">
              <div className="stat">
                <span className="stat-number">2s</span>
                <span className="stat-label">Routine Generation</span>
              </div>
              <div className="stat">
                <span className="stat-number">100%</span>
                <span className="stat-label">Personalized</span>
              </div>
              <div className="stat">
                <span className="stat-number">∞</span>
                <span className="stat-label">Motivation</span>
              </div>
            </div>
          </div>
          <div className="hero-mascot">
            <div className="mascot-glow" />
            <Mascot mood="excited" size="xl" message="Let's get fit together! 💖" />
            <div className="floating-elements">
              <span className="float-item" style={{ top: '10%', left: '10%' }}>💪</span>
              <span className="float-item" style={{ top: '20%', right: '15%' }}>⭐</span>
              <span className="float-item" style={{ bottom: '30%', left: '5%' }}>🎯</span>
              <span className="float-item" style={{ bottom: '20%', right: '10%' }}>✨</span>
            </div>
          </div>
        </div>
        <div className="hero-wave">
          <svg viewBox="0 0 1440 120" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M0 120L60 105C120 90 240 60 360 45C480 30 600 30 720 37.5C840 45 960 60 1080 67.5C1200 75 1320 75 1380 75L1440 75V120H1380C1320 120 1200 120 1080 120C960 120 840 120 720 120C600 120 480 120 360 120C240 120 120 120 60 120H0Z" fill="white"/>
          </svg>
        </div>
      </section>

      <section className="features">
        <div className="container">
          <div className="section-header">
            <span className="section-badge">✨ Features</span>
            <h2>Everything You Need to <span className="gradient-text">Succeed</span></h2>
            <p>Fittie adapts to you, not the other way around!</p>
          </div>
          <div className="feature-grid">
            <div className="feature-card">
              <div className="feature-icon">🎯</div>
              <h3>Smart Routines</h3>
              <p>Workouts that adapt to your energy, pain points, and available equipment</p>
            </div>
            <div className="feature-card featured">
              <div className="feature-icon">🎨</div>
              <h3>Morphic UI</h3>
              <p>The app transforms based on your mood - calming when tired, energetic when pumped!</p>
              <span className="feature-badge">✨ Magic</span>
            </div>
            <div className="feature-card">
              <div className="feature-icon">🎙️</div>
              <h3>Voice Coach</h3>
              <p>Hands-free guidance and motivation during your workout</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">📹</div>
              <h3>Form Analysis</h3>
              <p>Real-time feedback on your exercise form using AI vision</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">🔄</div>
              <h3>Desk-to-Gym Flow</h3>
              <p>Seamlessly continue your session from laptop to phone</p>
            </div>
            <div className="feature-card">
              <div className="feature-icon">🛡️</div>
              <h3>Safety First</h3>
              <p>Every exercise validated for your current physical state</p>
            </div>
          </div>
        </div>
      </section>

      <section className="how-it-works">
        <div className="container">
          <div className="section-header">
            <span className="section-badge">🚀 How It Works</span>
            <h2>Three Steps to <span className="gradient-text">Fitness</span></h2>
          </div>
          <div className="steps">
            <div className="step">
              <div className="step-number">1</div>
              <div className="step-icon">📝</div>
              <h3>Tell Fittie How You Feel</h3>
              <p>Energy level, any pain points, available equipment</p>
            </div>
            <div className="step-arrow">→</div>
            <div className="step">
              <div className="step-number">2</div>
              <div className="step-icon">✨</div>
              <h3>Get Your Perfect Routine</h3>
              <p>AI generates a safe, personalized workout in seconds</p>
            </div>
            <div className="step-arrow">→</div>
            <div className="step">
              <div className="step-number">3</div>
              <div className="step-icon">💪</div>
              <h3>Train with Your Buddy</h3>
              <p>Voice coaching guides you through every rep</p>
            </div>
          </div>
        </div>
      </section>

      <section className="cta">
        <div className="container">
          <div className="cta-card">
            <Mascot mood="cheering" size="lg" />
            <h2>Ready to Start Your Journey?</h2>
            <p>Join thousands of happy users training with Fittie!</p>
            <Link to="/signup" className="btn-primary btn-lg">
              Let's Go! 🚀
            </Link>
          </div>
        </div>
      </section>

      <footer className="landing-footer">
        <div className="container">
          <div className="footer-content">
            <div className="footer-brand">
              <span className="logo-icon">🏋️</span>
              <span>Fittie</span>
            </div>
            <p>Built with 💖 for Dreamflow Buildathon 2026</p>
          </div>
        </div>
      </footer>
    </div>
  )
}

export default Landing
