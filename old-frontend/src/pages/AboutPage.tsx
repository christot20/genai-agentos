import React from 'react';
import { MainLayoutNew } from '@/components/layout/MainLayoutNew';
import '../styles/About.scss';

const AboutPage: React.FC = () => {
  return (
    <MainLayoutNew>
      <div className="about-page">
        <div className="about-header">
          <h1 className="about-title">About GenAI AgentOS</h1>
          <p className="about-subtitle">
            A powerful platform for building, deploying, and managing intelligent AI agents
          </p>
        </div>

        <div className="about-content">
          <section className="about-section">
            <h2 className="section-heading">What is GenAI AgentOS?</h2>
            <p className="section-text">
              GenAI AgentOS is a comprehensive platform that enables developers and organizations 
              to create sophisticated AI agent systems. Our platform provides the tools, infrastructure, 
              and frameworks needed to build intelligent agents that can work together to solve complex problems.
            </p>
          </section>

          <section className="about-section">
            <h2 className="section-heading">Key Features</h2>
            <ul className="feature-list">
              <li className="feature-item">
                <strong>Multi-Agent Systems:</strong> Create and manage multiple AI agents that can collaborate and communicate with each other
              </li>
              <li className="feature-item">
                <strong>Workflow Automation:</strong> Design complex workflows that orchestrate multiple agents and services
              </li>
              <li className="feature-item">
                <strong>Real-time Communication:</strong> Enable agents to communicate in real-time using WebSocket connections
              </li>
              <li className="feature-item">
                <strong>Scalable Infrastructure:</strong> Built on modern cloud-native architecture for high availability and scalability
              </li>
              <li className="feature-item">
                <strong>Developer-Friendly:</strong> Simple APIs and intuitive interfaces for rapid development and deployment
              </li>
              <li className="feature-item">
                <strong>Monitoring & Analytics:</strong> Comprehensive monitoring and analytics to track agent performance and system health
              </li>
            </ul>
          </section>

          <section className="about-section">
            <h2 className="section-heading">Use Cases</h2>
            <p className="section-text">
              GenAI AgentOS is designed to handle a wide range of use cases, from simple chatbots 
              to complex enterprise automation systems. Some common applications include:
            </p>
            <ul className="feature-list">
              <li className="feature-item">Customer service and support automation</li>
              <li className="feature-item">Data processing and analysis pipelines</li>
              <li className="feature-item">Intelligent document processing</li>
              <li className="feature-item">Process automation and workflow management</li>
              <li className="feature-item">AI-powered decision support systems</li>
              <li className="feature-item">Multi-modal AI applications</li>
            </ul>
          </section>

          <section className="about-section">
            <h2 className="section-heading">Technology Stack</h2>
            <p className="section-text">
              Our platform is built using modern, open-source technologies and follows industry 
              best practices for scalability, security, and maintainability.
            </p>
            <p className="section-text">
              The platform includes a React-based frontend, FastAPI backend, PostgreSQL database, 
              Redis for caching, and WebSocket support for real-time communication. We also integrate 
              with various AI/ML services and APIs to provide comprehensive AI capabilities.
            </p>
          </section>
        </div>
      </div>
    </MainLayoutNew>
  );
};

export default AboutPage; 