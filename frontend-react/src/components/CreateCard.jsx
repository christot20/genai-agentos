import React from 'react';
import './CreateCard.scss';

const CreateCard = ({ buttonText, onClick }) => {
  return (
    <div className="create-card" onClick={onClick}>
      <div className="create-card-icon">+</div>
      <div className="create-card-text">{buttonText}</div>
    </div>
  );
};

export default CreateCard; 