import React, { useState } from 'react';
import '../styles/Home.scss';
import HomepageHeaderWLogo from '../components/HomepageHeaderWLogo';
const logo = '/src/merged/assets/logo.svg';
import InputWLabel from '../components/InputWLabel';
import PrimaryBtn from '../components/PrimaryBtn';
import SecondaryBtn from '../components/SecondaryBtn';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';

const SignIn: React.FC = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();
  const { login, isLoading } = useAuth();

  const handleSignin = async () => {
    if (!username || !password) {
      setError('Please enter both username and password');
      return;
    }

    setError('');
    try {
      await login(username, password);
      navigate('/chat');
    } catch (err: any) {
      setError(err.message || 'Sign in failed');
    }
  };

  return (
    <div className='homepage-container'>
      <HomepageHeaderWLogo 
        headerText="Sign into Navicare" 
        logo={logo} 
        logoAltText="GenAI AgentOS Logo" 
        caption="Please sign in using your existing username and password or create a new account." 
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
          text={isLoading ? "Signing in..." : "Log into Account"} 
          onClick={handleSignin} 
        />
        <SecondaryBtn 
          text="Switch to Sign up" 
          onClick={() => navigate('/signup')} 
        />
      </div>
    </div>
  );
};

export default SignIn; 