import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Navigation from './merged/components/Navigation';
import Home from './merged/pages/Home';
import SignIn from './merged/pages/SignIn';
import Signup from './merged/pages/Signup';
import IntakeProcess from './merged/pages/IntakeProcess';
import BenefitsOverview from './merged/pages/BenefitsOverview';
import Chat from './merged/pages/Chat';
import './merged/styles/App.scss';
import { authService } from './services/authService';

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const currentUser = authService.getCurrentUser();
  if (!currentUser) {
    return <Navigate to="/signin" replace />;
  }
  return <>{children}</>;
}

function AuthenticatedRoute({ children }: { children: React.ReactNode }) {
  const currentUser = authService.getCurrentUser();
  if (currentUser) {
    return <Navigate to="/chat" replace />;
  }
  return <>{children}</>;
}

function App() {
  const currentUser = authService.getCurrentUser();

  return (
    <Router>
      <div className="App">
        <main className="main-content">
          <Routes>
            <Route path="/" element={currentUser ? <Navigate to="/chat" replace /> : <Home />} />
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
