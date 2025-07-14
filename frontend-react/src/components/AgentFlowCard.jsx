import React from 'react';
import './AgentFlowCard.scss';

const AgentFlowCard = ({ flow, onEdit, onDelete }) => {
  const handleDelete = (e) => {
    e.stopPropagation();
    onDelete(flow.id);
  };

  const handleEdit = (e) => {
    e.stopPropagation();
    onEdit(flow.id);
  };

  return (
    <div className="agent-flow-card">
      <div className="agent-flow-card-header">
        <div className="agent-flow-card-badge">Flow</div>
        <div className="agent-flow-card-status">
          {flow.is_active ? 'Active' : 'Inactive'}
        </div>
      </div>
      
      <div className="agent-flow-card-title">
        {flow.name.replace(/_/g, ' ')}
      </div>
      
      <div className="agent-flow-card-description">
        {flow.description}
      </div>
      
      <div className="agent-flow-card-meta">
        <div className="agent-flow-card-created">
          <span className="agent-flow-card-label">Created:</span>
          <span className="agent-flow-card-date">
            {new Date(flow.created_at).toLocaleDateString()}
          </span>
        </div>
        <div className="agent-flow-card-agents">
          <span className="agent-flow-card-label">Agents:</span>
          <span className="agent-flow-card-count">{flow.flow.length}</span>
        </div>
      </div>
      
      <div className="agent-flow-card-actions">
        <button className="agent-flow-card-btn agent-flow-card-btn-primary" onClick={handleEdit}>
          Open Flow
        </button>
        <button className="agent-flow-card-btn agent-flow-card-btn-danger" onClick={handleDelete}>
          Delete
        </button>
      </div>
    </div>
  );
};

export default AgentFlowCard; 