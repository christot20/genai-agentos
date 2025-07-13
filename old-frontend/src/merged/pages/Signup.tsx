import React, { useState } from 'react';
import '../styles/Home.scss';
import HomepageHeaderWLogo from '../components/HomepageHeaderWLogo';
const logo = '/src/merged/assets/logo.svg';
import InputWLabel from '../components/InputWLabel';
import PrimaryBtn from '../components/PrimaryBtn';
import SecondaryBtn from '../components/SecondaryBtn';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';

const Signup: React.FC = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();
  const { signup, login, isLoading } = useAuth();

  const handleSignup = async () => {
    if (!username || !password) {
      setError('Please enter both username and password');
      return;
    }

    setError('');
    try {
      await signup(username, password);
      await login(username, password);
      navigate('/chat');
    } catch (err: any) {
      setError(err.message || 'Sign up failed');
    }
  };

  return (
    <div className='homepage-container'>
      <HomepageHeaderWLogo 
        headerText="Sign up for Navicare" 
        logo={logo} 
        logoAltText="GenAI AgentOS Logo" 
        caption="Please sign up using your username and password or click log into account if you already have one." 
      />
      <InputWLabel 
        label="Username" 
        type="text" 
        placeholder="Username" 
        value={username} 
        onChange={setUsername} 
        id="username" 
      />
      <InputWLabel 
        label="Password" 
        type="password" 
        placeholder="Password" 
        value={password} 
        onChange={setPassword} 
        id="password" 
      />
      {error && (
        <div style={{ 
          color: '#FF535C', 
          marginBottom: 12, 
          textAlign: 'center', 
          marginInline: 'auto', 
          width: "fit-content" 
        }}>
          {error}
        </div>
      )}
      <div className='form-btn-container'>
        <PrimaryBtn 
          text={isLoading ? "Signing up..." : "Sign up"} 
          onClick={handleSignup} 
        />
        <SecondaryBtn 
          text="Log into account" 
          onClick={() => navigate('/signin')} 
        />
      </div>
    </div>
  );
};

export default Signup; 