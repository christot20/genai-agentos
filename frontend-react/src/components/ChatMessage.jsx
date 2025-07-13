import React from 'react';
import './ChatMessage.scss';

const ChatMessage = ({ message, from, sender_type }) => {
  // Handle AI reasoning messages differently
  if (sender_type === 'AI_Reasoning') {
    return (
      <div className="chat-message chat-message-reasoning">
        <div className="reasoning-header">
          <span className="reasoning-icon">🧠</span>
          <span className="reasoning-title">Agent Reasoning</span>
        </div>
        <div className="reasoning-content">
          {formatReasoningMessage(message)}
        </div>
      </div>
    );
  }

  return (
    <div className={`chat-message ${from === 'user' ? 'chat-message-user' : 'chat-message-ai'}`}> 
      {message}
    </div>
  );
};

// Helper function to format reasoning message with markdown-like formatting
const formatReasoningMessage = (message) => {
  if (!message) return '';
  
  // Convert markdown-style formatting to HTML
  let formattedMessage = message
    // Bold text
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    // Emojis and basic formatting
    .replace(/\n/g, '<br>');
  
  return <div dangerouslySetInnerHTML={{ __html: formattedMessage }} />;
};

export default ChatMessage; 