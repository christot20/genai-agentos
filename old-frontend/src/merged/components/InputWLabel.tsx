import React from 'react';
import './InputWLabel.scss';

interface InputWLabelProps {
  label: string;
  type: string;
  placeholder: string;
  value: string;
  onChange: (value: string) => void;
  isRequired?: boolean;
  id: string;
}

const InputWLabel: React.FC<InputWLabelProps> = ({
  label, 
  type, 
  placeholder, 
  value, 
  onChange, 
  isRequired = false, 
  id
}) => {
  return (
    <div className="input-w-label">
      <div className="input-w-label-label">
        <label htmlFor={id}>{label}</label>
      </div>
      <div className="input-w-label-input">
        <input 
          type={type} 
          placeholder={placeholder} 
          value={value} 
          onChange={(e) => onChange(e.target.value)} 
          id={id} 
          required={isRequired} 
          className="input-w-label-input-input"
        />
      </div>
    </div>
  );
};

export default InputWLabel; 