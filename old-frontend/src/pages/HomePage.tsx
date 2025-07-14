import React from 'react';
import { useNavigate } from 'react-router-dom';
import HomepageHeaderWLogo from '@/components/shared/HomepageHeaderWLogo';
import '../styles/Home.scss';

const HomePage: React.FC = () => {
  const navigate = useNavigate();

  return (
    <div className='homepage-container'>
      <HomepageHeaderWLogo 
        headerText="Navicare Your Agentic Health Assistant" 
        logo="/placeholder-logo.svg" 
        logoAltText="GenAI AgentOS Logo" 
        caption="Navicare helps you confidently navigate your healthcare journey — from booking doctor visits and using your health benefits to preparing for and recovering from surgery." 
      />
      <div className="homepage-actions">
        <button className="primary-btn" onClick={() => navigate('/signin')}>
          Sign In
        </button>
        <button className="secondary-btn" onClick={() => navigate('/signup')}>
          Sign Up
        </button>
      </div>
    </div>
  );
};

export default HomePage; 