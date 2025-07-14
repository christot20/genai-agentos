import React, { useState, useEffect } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import HomepageHeaderWLogo from '../components/HomepageHeaderWLogo';
import PrimaryBtn from '../components/PrimaryBtn';
import SecondaryBtn from '../components/SecondaryBtn';
import { getAgentFlow, createAgentFlow, updateAgentFlow } from '../utils/api';
import logo from '../assets/logo.svg';
import './AgentFlowEditPage.scss';

const AgentFlowEditPage = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const isNewFlow = id === 'new';
  
  const [flowName, setFlowName] = useState('');
  const [flowDescription, setFlowDescription] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!isNewFlow) {
      loadFlow();
    }
  }, [id]);

  const loadFlow = async () => {
    setIsLoading(true);
    try {
      const flow = await getAgentFlow(id);
      setFlowName(flow.name);
      setFlowDescription(flow.description);
    } catch (error) {
      console.error('Failed to load flow:', error);
      setError('Failed to load flow details');
    } finally {
      setIsLoading(false);
    }
  };

  const handleSave = async () => {
    if (!flowName.trim()) {
      setError('Flow name is required');
      return;
    }

    setIsLoading(true);
    setError(null);

    try {
      const flowData = {
        name: flowName,
        description: flowDescription,
        flow: [] // Empty flow for now - would be populated with actual flow data
      };

      if (isNewFlow) {
        await createAgentFlow(flowData);
      } else {
        await updateAgentFlow(id, flowData);
      }

      navigate('/agent-flows');
    } catch (error) {
      console.error('Failed to save flow:', error);
      setError('Failed to save flow. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  const handleCancel = () => {
    navigate('/agent-flows');
  };

  if (isLoading && !isNewFlow) {
    return (
      <div className="agent-flow-edit-page">
        <HomepageHeaderWLogo 
          headerText={isNewFlow ? "New Agent Flow" : "Edit Agent Flow"} 
          logo={logo} 
          logoAltText="GenAI AgentOS Logo" 
          caption="Configure your AI agent workflow." 
        />
        <div className="loading-container">
          <div className="loading-spinner"></div>
          <p>Loading flow details...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="agent-flow-edit-page">
      <HomepageHeaderWLogo 
        headerText={isNewFlow ? "New Agent Flow" : "Edit Agent Flow"} 
        logo={logo} 
        logoAltText="GenAI AgentOS Logo" 
        caption="Configure your AI agent workflow." 
      />
      
      {error && (
        <div className="error-message">
          <p>{error}</p>
        </div>
      )}

      <div className="flow-edit-container">
        <div className="flow-edit-form">
          <div className="form-group">
            <label htmlFor="flowName" className="form-label">Flow Name</label>
            <input
              type="text"
              id="flowName"
              className="form-input"
              value={flowName}
              onChange={(e) => setFlowName(e.target.value)}
              placeholder="Enter flow name"
              disabled={isLoading}
            />
          </div>

          <div className="form-group">
            <label htmlFor="flowDescription" className="form-label">Description</label>
            <textarea
              id="flowDescription"
              className="form-textarea"
              value={flowDescription}
              onChange={(e) => setFlowDescription(e.target.value)}
              placeholder="Enter flow description"
              rows="4"
              disabled={isLoading}
            />
          </div>

          <div className="form-actions">
            <SecondaryBtn text="Cancel" onClick={handleCancel} />
            <PrimaryBtn text={isLoading ? "Saving..." : "Save Flow"} onClick={handleSave} />
          </div>
        </div>

        <div className="flow-edit-placeholder">
          <div className="placeholder-content">
            <h3>Flow Builder</h3>
            <p>This is where the visual flow builder would be implemented.</p>
            <p>You can drag and drop agents to create your workflow.</p>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AgentFlowEditPage; 