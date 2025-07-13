import React from 'react';
import './SecondaryBtn.scss';

interface SecondaryBtnProps {
  text: string;
  onClick: () => void;
}

const SecondaryBtn: React.FC<SecondaryBtnProps> = ({ text, onClick }) => {
  return (
    <button className="secondary-btn" onClick={onClick}>
      {text}
    </button>
  );
};

export default SecondaryBtn; 