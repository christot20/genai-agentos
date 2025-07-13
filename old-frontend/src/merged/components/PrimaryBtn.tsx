import React from 'react';
import './PrimaryBtn.scss';

interface PrimaryBtnProps {
  text: string;
  onClick: () => void;
}

const PrimaryBtn: React.FC<PrimaryBtnProps> = ({ text, onClick }) => {
  return (
    <button className="primary-btn" onClick={onClick}>
      {text}
    </button>
  );
};

export default PrimaryBtn; 