import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import HomepageHeaderWLogo from '../components/HomepageHeaderWLogo';
import AgentFlowCard from '../components/AgentFlowCard';
import CreateCard from '../components/CreateCard';
import ConfirmModal from '../components/ConfirmModal';
import { getAgentFlows, deleteAgentFlow } from '../utils/api';
import logo from '../assets/logo.svg';
import './AgentFlowsPage.scss';

const AgentFlowsPage = () => {
  const [flows, setFlows] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isConfirmOpen, setIsConfirmOpen] = useState(false);
  const [selectedFlow, setSelectedFlow] = useState(null);
  const [error, setError] = useState(null);
  const navigate = useNavigate();

  useEffect(() => {
    loadFlows();
  }, []);

  const loadFlows = async () => {
    setIsLoading(true);
    setError(null);
    try {
      const data = await getAgentFlows();
      setFlows(data);
    } catch (error) {
      console.error('Failed to load agent flows:', error);
      setError('Failed to load agent flows. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleClose = () => {
    setIsConfirmOpen(false);
    setSelectedFlow(null);
  };

  const handleDelete = (flow) => {
    setSelectedFlow(flow);
    setIsConfirmOpen(true);
  };

  const handleDeleteConfirmed = async () => {
    if (!selectedFlow) return;

    try {
      await deleteAgentFlow(selectedFlow.id);
      await loadFlows();
      handleClose();
      // You could add a toast notification here if you have a toast system
      console.log('Agent Flow deleted successfully');
    } catch (error) {
      console.error('Failed to delete agent flow:', error);
      setError('Failed to delete agent flow. Please try again.');
    }
  };

  const handleEdit = (id) => {
    navigate(`/agent-flows/${id}`);
  };

  const handleCreateNew = () => {
    navigate('/agent-flows/new');
  };

  if (isLoading) {
    return (
      <div className="agent-flows-page">
        <HomepageHeaderWLogo 
          headerText="Agent Flows" 
          logo={logo} 
          logoAltText="GenAI AgentOS Logo" 
          caption="Manage your AI agent workflows and automation flows." 
        />
        <div className="loading-container">
          <div className="loading-spinner"></div>
          <p>Loading agent flows...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="agent-flows-page">
      <HomepageHeaderWLogo 
        headerText="Agent Flows" 
        logo={logo} 
        logoAltText="GenAI AgentOS Logo" 
        caption="Manage your AI agent workflows and automation flows." 
      />
      
      {error && (
        <div className="error-message">
          <p>{error}</p>
          <button onClick={loadFlows} className="retry-btn">Retry</button>
        </div>
      )}

      <div className="agent-flows-container">
        {flows.map(flow => (
          <AgentFlowCard
            key={flow.id}
            flow={flow}
            onEdit={handleEdit}
            onDelete={handleDelete}
          />
        ))}

        <CreateCard
          buttonText="Add Agent Flow"
          onClick={handleCreateNew}
        />
      </div>

      <ConfirmModal
        isOpen={isConfirmOpen}
        description={`Are you sure you want to delete this Agent Flow "${
          selectedFlow?.name || ''
        }"?`}
        onClose={handleClose}
        onConfirm={handleDeleteConfirmed}
      />
    </div>
  );
};

export default AgentFlowsPage; 