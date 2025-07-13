import React from 'react';
import './HomepageHeaderWLogo.scss';

interface HomepageHeaderWLogoProps {
  headerText: string;
  logo: string;
  logoAltText: string;
  caption: string;
}

const HomepageHeaderWLogo: React.FC<HomepageHeaderWLogoProps> = ({
  headerText, 
  logo, 
  logoAltText, 
  caption
}) => {
  return (
    <div className="homepage-header-w-logo">
      <div className="homepage-header-container-logo">
        <img src={logo} alt={logoAltText} />
      </div>
      <div className="homepage-header-container-header">
        <h1>{headerText}</h1>
      </div>
      <div className="homepage-header-container-caption">
        <p>{caption}</p>
      </div>
    </div>
  );
};

export default HomepageHeaderWLogo; 