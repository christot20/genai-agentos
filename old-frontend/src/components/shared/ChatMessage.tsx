import React from 'react';
import './ChatMessage.scss';

interface ChatMessageProps {
  from: 'user' | 'ai';
  message: string;
  sender_type?: string;
  timestamp?: string;
}

const ChatMessage: React.FC<ChatMessageProps> = ({ 
  from, 
  message, 
  sender_type,
  timestamp 
}) => {
  const formatTime = (timestamp?: string) => {
    if (!timestamp) return '';
    const date = new Date(timestamp);
    return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  return (
    <div className={`chat-message ${from}`}>
      <div className="message-avatar">
        {from === 'user' ? 'U' : 'AI'}
      </div>
      <div className="message-content">
        <div>{message}</div>
        {timestamp && (
          <div className="message-timestamp">
            {formatTime(timestamp)}
          </div>
        )}
      </div>
    </div>
  );
};

export default ChatMessage; 