import React, { useState } from 'react';
import '../styles/Home.scss';
import HomepageHeaderWLogo from '../components/HomepageHeaderWLogo';
import logo from '../assets/logo.svg';
import InputWLabel from '../components/InputWLabel';
import PrimaryBtn from '../components/PrimaryBtn';
import SecondaryBtn from '../components/SecondaryBtn';
import { useNavigate } from 'react-router-dom';
import { signup, signin } from '../utils/api';
import { setCookie } from '../utils/cookies';

const Signup = () => {
  const [firstName, setFirstName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSignup = async () => {
    try {
      const result = await signup({ email, password, firstName });
      // After successful signup, automatically login to get the token
      const loginResult = await signin({ email, password });
      setCookie('access_token', loginResult.access_token); // Use access_token
      navigate('/chat');
    } catch (err) {
      setError(err.message || 'Sign up failed');
    }
  };

  return (
    <div className='homepage-container'style={{paddingLeft:"82px", marginTop:"110px"}}>
      <HomepageHeaderWLogo headerText="Sign up for Navicare" logo={logo} logoAltText="GenAI AgentOS Logo" caption="Please sign up using your first name, email, and password or click log into account if you already have one." />
      <InputWLabel label="Username" type="text" placeholder="Username" value={firstName} onChange={setFirstName} id="firstName" />
      <InputWLabel label="Email" type="email" placeholder="Email" value={email} onChange={setEmail} id="email" />
      <InputWLabel label="Password" type="password" placeholder="Password" value={password} onChange={setPassword} id="password" />
      {error && <div style={{ color: '#FF535C', marginBottom: 12, textAlign: 'center', marginInline: 'auto', width:"fit-content" }}>{error}</div>}
      <div className='form-btn-container'>
      <PrimaryBtn text="Sign up" onClick={handleSignup} />
      <SecondaryBtn text="Log into account" onClick={() => {navigate('/signin')}} />
      </div>
    </div>
  );
};

export default Signup; 