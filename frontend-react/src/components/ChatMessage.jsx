import React from 'react';
import './ChatMessage.scss';

const ChatMessage = ({ message, from, sender_type }) => {
  // Handle AI reasoning messages with loading-style formatting
  if (sender_type === 'AI_Reasoning') {
    return (
      <div style={{ color: '#FF535C', textAlign: 'center', margin: 8 }}>
        {formatReasoningMessage(message)}
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