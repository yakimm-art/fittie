import { Routes, Route, Navigate } from 'react-router-dom'
import { useState } from 'react'
import Landing from './pages/Landing'
import Login from './pages/Login'
import Signup from './pages/Signup'
import Dashboard from './pages/Dashboard'
import Workout from './pages/Workout'
import State from './pages/State'
import History from './pages/History'
import Layout from './components/Layout'

function App() {
  const [isAuthenticated, setIsAuthenticated] = useState(false)

  const login = () => setIsAuthenticated(true)
  const logout = () => setIsAuthenticated(false)

  return (
    <Routes>
      {/* Public routes */}
      <Route path="/" element={<Landing />} />
      <Route path="/login" element={<Login onLogin={login} />} />
      <Route path="/signup" element={<Signup onSignup={login} />} />

      {/* Protected routes */}
      <Route
        path="/app"
        element={
          isAuthenticated ? (
            <Layout onLogout={logout} />
          ) : (
            <Navigate to="/login" replace />
          )
        }
      >
        <Route index element={<Dashboard />} />
        <Route path="workout" element={<Workout />} />
        <Route path="state" element={<State />} />
        <Route path="history" element={<History />} />
      </Route>
    </Routes>
  )
}

export default App
