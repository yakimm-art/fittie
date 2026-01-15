import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Mascot from '../components/Mascot'
import './Auth.css'

interface SignupProps {
  onSignup: () => void
}

function Signup({ onSignup }: SignupProps) {
  const navigate = useNavigate()
  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    onSignup()
    navigate('/app')
  }

  return (
    <div className="auth-page">
      <span className="auth-decoration">💪</span>
      <span className="auth-decoration">⭐</span>
      <span className="auth-decoration">🎯</span>
      <span className="auth-decoration">✨</span>
      
      <div className="auth-card">
        <div className="auth-mascot">
          <Mascot mood="excited" size="md" message="Let's get started! 🎉" />
        </div>
        
        <Link to="/" className="auth-logo">
          <span>🏋️</span>
          <span>Fittie</span>
        </Link>
        <h1>Join the Fun!</h1>
        <p>Your fitness journey starts here</p>

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Your Name</label>
            <input
              type="text"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="What should we call you?"
              required
            />
          </div>
          <div className="form-group">
            <label>Email</label>
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="you@example.com"
              required
            />
          </div>
          <div className="form-group">
            <label>Password</label>
            <input
              type="password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              placeholder="Make it strong 💪"
              required
            />
          </div>
          <button type="submit" className="btn-primary btn-full">
            Create Account ✨
          </button>
        </form>

        <div className="auth-divider">or continue with</div>
        
        <div className="social-login">
          <button className="social-btn">🍎</button>
          <button className="social-btn">📧</button>
          <button className="social-btn">🔵</button>
        </div>

        <p className="auth-footer">
          Already have an account? <Link to="/login">Sign in</Link>
        </p>
      </div>
    </div>
  )
}

export default Signup
