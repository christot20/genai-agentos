import React, { useState, useRef, useEffect } from 'react';
import { useParams } from 'react-router-dom';
import { CircularProgress } from '@mui/material';
import { FaPiggyBank, FaRegClipboard, FaHeartbeat } from 'react-icons/fa';

import { websocketService } from '@/services/websocketService';
import { FileData, fileService } from '@/services/fileService';
import { useChatHistory } from '@/contexts/ChatHistoryContext';
import { useAuth } from '@/contexts/AuthContext';
import { useChat } from '@/hooks/useChat';
import { ChatHistory, IChat } from '@/types/chat';
import { MainLayoutNew } from '@/components/layout/MainLayoutNew';

// Import new shared components
import ChatInput from '@/components/shared/ChatInput';
import ChatMessage from '@/components/shared/ChatMessage';
import PageHeader from '@/components/shared/PageHeader';
import HomepageHeaderWLogo from '@/components/shared/HomepageHeaderWLogo';
import BenefitCard from '@/components/shared/BenefitCard';

// Import logo - using a placeholder for now
const logo = '/placeholder-logo.svg';

const benefitCards = [
  {
    icon: <FaPiggyBank size={30} />, 
    title: 'Smart Visit Planning',
    description: 'Let AI find the right doctor, book appointments, and manage your schedule.'
  },
  {
    icon: <FaRegClipboard size={30} />,
    title: 'Maximize Your Benefits',
    description: 'Unlock hidden perks like free rides, therapy, and gym access covered by your plan.'
  },
  {
    icon: <FaHeartbeat size={30} />,
    title: 'Custom Recovery Plans',
    description: 'Get daily check-ins, recovery tips, and reminders tailored to your surgery.'
  }
];

const ChatPageNew = () => {
  const [messages, setMessages] = useState<ChatHistory['items']>([]);
  const [files, setFiles] = useState<FileData[]>([]);
  const [loading, setLoading] = useState(false);
  const [conversations, setConversations] = useState<IChat[]>([]);
  const [conversationId, setConversationId] = useState<string | null>(null);
  const [conversationTitle, setConversationTitle] = useState('');
  const chatEndRef = useRef<HTMLDivElement>(null);
  const prevMsgCount = useRef(messages.length);

  const { id } = useParams();
  const { clearMessages, setChats } = useChatHistory();
  const { user } = useAuth();
  const { getChatHistory, isLoading, getChatsList } = useChat();

  useEffect(() => {
    // Only connect if user is authenticated
    if (!user) {
      websocketService.disconnect();
      return;
    }

    if (id && id !== 'new') {
      setConversationId(id);
      getChatHistory(id)
        .then(res => {
          setMessages(res.items);
        })
        .catch(() => {
          setMessages([]);
        });

      fileService
        .getFilesByRequestId(id)
        .then(res => {
          setFiles(res);
        })
        .catch(() => {
          setFiles([]);
        });
    } else {
      // For new chat, try to get existing conversations
      getChatsList().then(res => {
        setConversations(res.chats || []);
        if (res.chats && res.chats.length > 0) {
          setConversationId(res.chats[0].session_id);
          setConversationTitle('Chat');
        }
      });
    }

    // Cleanup function
    return () => {
      websocketService.disconnect();
      clearMessages();
      setMessages([]);
    };
  }, [user, clearMessages, id, getChatHistory, getChatsList, setChats]);

  // Auto-scroll to bottom when new messages arrive
  useEffect(() => {
    if (messages.length > prevMsgCount.current) {
      if (chatEndRef.current) {
        chatEndRef.current?.parentElement?.scrollTo({
          top: chatEndRef.current.offsetTop,
          behavior: 'smooth'
        });
      }
    }
    prevMsgCount.current = messages.length;
  }, [messages]);

  const handleSend = async (message: string) => {
    if (!conversationId) return;
    
    // Add user message immediately
    const userMessage = {
      request_id: `temp-${Date.now()}`,
      content: message,
      sender_type: 'user',
      created_at: new Date().toISOString()
    };
    
    setMessages(prev => [...prev, userMessage]);
    setLoading(true);
    
    try {
      // Send message via WebSocket or API
      // This would need to be implemented based on your backend
      console.log('Sending message:', message);
      
      // For now, simulate AI response
      setTimeout(() => {
        const aiMessage = {
          request_id: `ai-${Date.now()}`,
          content: `I received your message: "${message}". This is a simulated response.`,
          sender_type: 'ai',
          created_at: new Date().toISOString()
        };
        setMessages(prev => [...prev, aiMessage]);
        setLoading(false);
      }, 1000);
      
    } catch (e) {
      console.error('Error sending message:', e);
      setLoading(false);
    }
  };

  const handleConversationSelect = async (convoId: string) => {
    setLoading(true);
    try {
      setConversationId(convoId);
      const res = await getChatHistory(convoId);
      setMessages(res.items);
      setConversationTitle('Chat');
    } catch (e) {
      console.error('Error switching conversation:', e);
    }
    setLoading(false);
  };

  const chatActive = messages.length > 0;

  return (
    <MainLayoutNew currentPage="AgentOS Chat">
      <div style={{ display: 'flex' }}>
        <div style={{ flex: 1, paddingLeft: 24 }}>
          <PageHeader title="Chat" />
          {!chatActive && (
            <>
              <div className='chat-container' style={{ width: 'fit-content', margin: '32px auto 0 auto' }}>
                <HomepageHeaderWLogo
                  headerText="Chat"
                  logo={logo}
                  logoAltText="GenAI AgentOS Logo"
                  caption="Ask me anything about your care journey from booking doctors and using benefits to planning surgery and recovery."
                />
              </div>
              <div style={{ display: 'flex', gap: 32, justifyContent: 'center', margin: '32px 0', flexWrap: 'wrap' }}>
                {benefitCards.map((card, i) => (
                  <BenefitCard key={i} {...card} />
                ))}
              </div>
            </>
          )}
          {chatActive && (
            <>
              {conversations.length > 1 && (
                <div style={{ marginTop: '8px' }}>
                  <small style={{ color: '#666' }}>Other conversations:</small>
                  <div style={{ display: 'flex', gap: '8px', marginTop: '4px', flexWrap: 'wrap' }}>
                    {conversations.slice(0, 3).map((conv) => (
                      <button
                        key={conv.session_id}
                        onClick={() => handleConversationSelect(conv.session_id)}
                        style={{
                          padding: '4px 8px',
                          fontSize: '12px',
                          border: '1px solid #ddd',
                          borderRadius: '4px',
                          background: conv.session_id === conversationId ? '#007bff' : '#fff',
                          color: conv.session_id === conversationId ? '#fff' : '#333',
                          cursor: 'pointer'
                        }}
                      >
                        {conv.title ? conv.title.substring(0, 20) + '...' : 'New Chat'}
                      </button>
                    ))}
                  </div>
                </div>
              )}
              
              {/* Chat Messages */}
              <div
                className="chat-messages-scrollable"
                style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: 0,
                  margin: '32px auto',
                  maxWidth: 760,
                  minHeight: 300,
                  maxHeight: 400,
                  overflowY: 'auto',
                  width: '100%'
                }}
              >
                {messages.map((msg, i) => (
                  <ChatMessage 
                    key={msg.request_id || i} 
                    from={msg.sender_type === 'user' ? 'user' : 'ai'} 
                    message={msg.content} 
                    sender_type={msg.sender_type}
                    timestamp={msg.created_at}
                  />
                ))}
                <div ref={chatEndRef} />
              </div>
            </>
          )}
          <ChatInput 
            placeholder="What is a good recovery program for someone just out of back surgery" 
            onSend={handleSend} 
          />
        </div>
      </div>
    </MainLayoutNew>
  );
};

export default ChatPageNew; 