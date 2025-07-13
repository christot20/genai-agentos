import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Navigation from './components/Navigation';
import Home from './pages/Home';
import SignIn from './pages/SignIn';
import Signup from './pages/Signup';
import IntakeProcess from './pages/IntakeProcess';
import BenefitsOverview from './pages/BenefitsOverview';
import Chat from './pages/Chat';
import './styles/App.scss';
import { useCookies } from 'react-cookie';

function ProtectedRoute({ children }) {
  const [cookies] = useCookies(['access_token']);
  if (!cookies.access_token) {
    return <Navigate to="/signin" replace />;
  }
  return children;
}

function AuthenticatedRoute({ children }) {
  const [cookies] = useCookies(['access_token']);
  if (cookies.access_token) {
    return <Navigate to="/chat" replace />;
  }
  return children;
}

function App() {
  const [cookies] = useCookies(['access_token']);

  return (
    <Router>
      <div className="App">
        <main className="main-content">
          <Routes>
            <Route path="/" element={cookies.access_token ? <Navigate to="/chat" replace /> : <Home />} />
            <Route path="/signin" element={<AuthenticatedRoute><SignIn /></AuthenticatedRoute>} />
            <Route path="/signup" element={<AuthenticatedRoute><Signup /></AuthenticatedRoute>} />
            <Route path="/intakeprocess" element={<ProtectedRoute><IntakeProcess /></ProtectedRoute>} />
            <Route path="/benefitsoverview" element={<ProtectedRoute><BenefitsOverview /></ProtectedRoute>} />
            <Route path="/chat" element={<ProtectedRoute><Chat /></ProtectedRoute>} />
          </Routes>
        </main>
      </div>
    </Router>
  );
}

export default App; 