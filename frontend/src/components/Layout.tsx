import { Outlet, NavLink, useNavigate } from 'react-router-dom'
import { useState } from 'react'
import './Layout.css'

interface LayoutProps {
  onLogout: () => void
}

function Layout({ onLogout }: LayoutProps) {
  const navigate = useNavigate()
  const [theme, setTheme] = useState<'default' | 'zen' | 'power'>('default')

  const handleLogout = () => {
    onLogout()
    navigate('/')
  }

  const cycleTheme = () => {
    const themes: ('default' | 'zen' | 'power')[] = ['default', 'zen', 'power']
    const currentIndex = themes.indexOf(theme)
    const nextTheme = themes[(currentIndex + 1) % themes.length]
    setTheme(nextTheme)
  }

  return (
    <div className={`layout theme-${theme}`}>
      <nav className="navbar">
        <div className="nav-brand">
          <span className="brand-icon">🏋️</span>
          <span className="brand-text">Fittie</span>
        </div>
        <div className="nav-links">
          <NavLink to="/app" end>
            <span className="nav-icon">🏠</span>
            <span>Home</span>
          </NavLink>
          <NavLink to="/app/workout">
            <span className="nav-icon">💪</span>
            <span>Workout</span>
          </NavLink>
          <NavLink to="/app/state">
            <span className="nav-icon">✨</span>
            <span>My State</span>
          </NavLink>
          <NavLink to="/app/history">
            <span className="nav-icon">📊</span>
            <span>History</span>
          </NavLink>
        </div>
        <div className="nav-actions">
          <button className="theme-toggle" onClick={cycleTheme} title="Change theme">
            {theme === 'default' && '🎨'}
            {theme === 'zen' && '🧘'}
            {theme === 'power' && '🔥'}
          </button>
          <button className="btn-secondary btn-sm" onClick={handleLogout}>
            Logout
          </button>
        </div>
      </nav>
      <main className="main-content">
        <Outlet />
      </main>
      <nav className="mobile-nav">
        <NavLink to="/app" end>
          <span>🏠</span>
          <span>Home</span>
        </NavLink>
        <NavLink to="/app/workout">
          <span>💪</span>
          <span>Workout</span>
        </NavLink>
        <NavLink to="/app/state">
          <span>✨</span>
          <span>State</span>
        </NavLink>
        <NavLink to="/app/history">
          <span>📊</span>
          <span>History</span>
        </NavLink>
      </nav>
    </div>
  )
}

export default Layout
