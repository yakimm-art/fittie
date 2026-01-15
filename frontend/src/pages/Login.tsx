import { useState } from 'react'
import { Link, useNavigate } from 'react-router-dom'
import Mascot from '../components/Mascot'
import './Auth.css'

interface LoginProps {
  onLogin: () => void
}

function Login({ onLogin }: LoginProps) {
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    onLogin()
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
          <Mascot mood="happy" size="md" message="Welcome back! 💖" />
        </div>
        
        <Link to="/" className="auth-logo">
          <span>🏋️</span>
          <span>Fittie</span>
        </Link>
        <h1>Welcome Back!</h1>
        <p>Ready to crush your workout today?</p>

        <form onSubmit={handleSubmit}>
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
              placeholder="••••••••"
              required
            />
          </div>
          <button type="submit" className="btn-primary btn-full">
            Let's Go! 🚀
          </button>
        </form>

        <div className="auth-divider">or continue with</div>
        
        <div className="social-login">
          <button className="social-btn">🍎</button>
          <button className="social-btn">📧</button>
          <button className="social-btn">🔵</button>
        </div>

        <p className="auth-footer">
          New here? <Link to="/signup">Create an account</Link> ✨
        </p>
      </div>
    </div>
  )
}

export default Login
