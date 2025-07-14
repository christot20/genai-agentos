import React from 'react';
import './ConfirmModal.scss';

const ConfirmModal = ({ isOpen, description, onClose, onConfirm }) => {
  if (!isOpen) return null;

  const handleBackdropClick = (e) => {
    if (e.target === e.currentTarget) {
      onClose();
    }
  };

  return (
    <div className="confirm-modal-backdrop" onClick={handleBackdropClick}>
      <div className="confirm-modal">
        <div className="confirm-modal-header">
          <h3 className="confirm-modal-title">Confirm Action</h3>
        </div>
        
        <div className="confirm-modal-body">
          <p className="confirm-modal-description">{description}</p>
        </div>
        
        <div className="confirm-modal-actions">
          <button className="confirm-modal-btn confirm-modal-btn-secondary" onClick={onClose}>
            Cancel
          </button>
          <button className="confirm-modal-btn confirm-modal-btn-danger" onClick={onConfirm}>
            Delete
          </button>
        </div>
      </div>
    </div>
  );
};

export default ConfirmModal; 