import React, { useState, useRef, useEffect } from 'react';
import ChatModal from '../components/ChatModal';
import BenefitCard from '../components/BenefitCard';
import { FaPiggyBank, FaRegClipboard, FaHeartbeat } from 'react-icons/fa';
import logo from '../assets/logo.svg';
import PageHeader from '../components/PageHeader';
import HomepageHeaderWLogo from '../components/HomepageHeaderWLogo';
import ChatInput from '../components/ChatInput';
import ChatMessage from '../components/ChatMessage';
import './ChatPageCustom.scss';
import { createConversation, listConversations, listMessages } from '../utils/api';
import websocketService from '../utils/websocketService';

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

const Chat = () => {
  const [chatMessages, setChatMessages] = useState([]);
  const [conversationId, setConversationId] = useState(null);
  const [conversationTitle, setConversationTitle] = useState('');
  const [loading, setLoading] = useState(false);
  const [conversations, setConversations] = useState([]);
  const chatEndRef = useRef(null);
  const prevMsgCount = useRef(chatMessages.length);

  // On mount, get or create a conversation, then fetch messages
  useEffect(() => {
    async function initConversation() {
      setLoading(true);
      try {
        // Try to get existing conversations
        const convoList = await listConversations();
        console.log('Conversations:', convoList);
        
        let convoId = null;
        if (convoList.conversations && convoList.conversations.length > 0) {
          convoId = convoList.conversations[0].session_id; // provided-backend uses session_id
          setConversations(convoList.conversations);
        } else {
          // Create a new conversation if none exist
          const created = await createConversation();
          convoId = created.session_id; // provided-backend uses session_id
        }
        setConversationId(convoId);
        console.log('Selected conversation ID:', convoId);
        
        // Fetch messages for this conversation
        if (convoId) {
          const msgRes = await listMessages(convoId);
          console.log('Messages response:', msgRes);
          // provided-backend returns paginated results with items array
          // Map the backend message format to frontend format
          const mappedMessages = (msgRes.items || []).map(msg => ({
            message_id: msg.request_id,
            message: msg.content,
            sender_type: msg.sender_type === 'user' ? 'User' : 'AI', // Map backend enum to frontend format
            timestamp: msg.created_at
          }));
          setChatMessages(mappedMessages);
          // For now, use a default title since the backend doesn't return conversation_title
          setConversationTitle('Chat');
        }

        // Connect to WebSocket with the conversation ID
        if (convoId) {
          try {
            websocketService.connect(convoId);
            
            // Add message handler for WebSocket responses
            websocketService.addMessageHandler(handleWebSocketMessage);
          } catch (error) {
            console.error('Failed to connect to WebSocket:', error);
            // Continue without WebSocket - user can still send messages but won't get real-time responses
          }
        }
      } catch (e) {
        console.error('Error initializing conversation:', e);
        setChatMessages([]);
      }
      setLoading(false);
    }
    initConversation();

    // Cleanup WebSocket connection on unmount
    return () => {
      websocketService.removeMessageHandler(handleWebSocketMessage);
      websocketService.disconnect();
    };
  }, []);

  // Handle WebSocket messages from the backend
  const handleWebSocketMessage = (data) => {
    console.log('WebSocket message received:', data);
    
    if (data.type === 'agent_response' && data.response) {
      const response = data.response;
      
      // Add AI response to chat
      let messageContent = '';
      
      // Extract the actual response text from the nested structure
      if (typeof response.response === 'string') {
        messageContent = response.response;
      } else if (typeof response.response === 'object' && response.response !== null) {
        // If response is an object, try to extract the content
        if (response.response.content) {
          messageContent = response.response.content;
        } else if (response.response.response) {
          messageContent = response.response.response;
        } else {
          // Fallback: stringify the response object
          messageContent = JSON.stringify(response.response);
        }
      } else {
        messageContent = String(response.response);
      }
      
      const aiMessage = {
        message_id: response.request_id || `ai-${Date.now()}`,
        message: messageContent,
        sender_type: 'AI', // WebSocket responses are always from AI
        timestamp: new Date().toISOString()
      };
      
      setChatMessages(prev => [...prev, aiMessage]);
      setLoading(false);
    } else if (data.error) {
      console.error('WebSocket error:', data.error);
      setLoading(false);
    } else {
      console.log('Unknown WebSocket message format:', data);
    }
  };

  const handleSend = async (message) => {
    if (!conversationId) return;
    
    // Immediately add user message to the chat
    const userMessage = {
      message_id: `temp-${Date.now()}`,
      message: message,
      sender_type: 'User', // Frontend uses 'User', backend uses 'user'
      timestamp: new Date().toISOString()
    };
    
    setChatMessages(prev => [...prev, userMessage]);
    setLoading(true);
    
    try {
      console.log('Sending message via WebSocket:', message);
      
      // Send message via WebSocket
      try {
        websocketService.sendMessage(
          message,
          'genai', // provider - default provider created by backend
          'default', // llm_name - default config created by backend
          [] // files array
        );
        
        // The AI response will be handled by the WebSocket message handler
        // No need to poll for messages since WebSocket provides real-time updates
      } catch (error) {
        console.error('Failed to send message via WebSocket:', error);
        // Fallback: try to poll for messages after a delay
        setTimeout(async () => {
          try {
            const msgRes = await listMessages(conversationId);
            // Map the backend message format to frontend format
            const mappedMessages = (msgRes.items || []).map(msg => ({
              message_id: msg.request_id,
              message: msg.content,
              sender_type: msg.sender_type === 'user' ? 'User' : 'AI', // Map backend enum to frontend format
              timestamp: msg.created_at
            }));
            setChatMessages(mappedMessages);
            setLoading(false);
          } catch (pollError) {
            console.error('Failed to poll for messages:', pollError);
            setLoading(false);
          }
        }, 2000);
      }
      
    } catch (e) {
      console.error('Error sending message:', e);
      // Remove the temporary user message if there was an error
      setChatMessages(prev => prev.filter(msg => msg.message_id !== userMessage.message_id));
      setLoading(false);
    }
  };

  const handleConversationSelect = async (convoId) => {
    setLoading(true);
    try {
      // Disconnect current WebSocket connection
      websocketService.disconnect();
      
      setConversationId(convoId);
      const msgRes = await listMessages(convoId);
      // Map the backend message format to frontend format
      const mappedMessages = (msgRes.items || []).map(msg => ({
        message_id: msg.request_id,
        message: msg.content.replaceAll("*", ''),
        sender_type: msg.sender_type === 'user' ? 'User' : 'AI', // Map backend enum to frontend format
        timestamp: msg.created_at
      }));
      setChatMessages(mappedMessages);
      setConversationTitle('Chat');
      
      // Connect to WebSocket with the new conversation ID
      try {
        websocketService.connect(convoId);
      } catch (error) {
        console.error('Failed to connect to WebSocket for new conversation:', error);
      }
    } catch (e) {
      console.error('Error switching conversation:', e);
    }
    setLoading(false);
  };

  useEffect(() => {
    if (chatMessages.length > prevMsgCount.current) {
      if (chatEndRef.current) {
        chatEndRef.current?.parentNode?.scrollTo({
          top: chatEndRef.current.offsetTop,
          behavior: 'smooth'
        });
      }
    }
    prevMsgCount.current = chatMessages.length;
  }, [chatMessages]);

  const chatActive = chatMessages.length > 0;

  return (
    <div style={{ display: 'flex' }}>
      <ChatModal />
      <div style={{ flex: 1, paddingLeft: 24, marginTop:"24px" }}>
        <PageHeader />
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
            <div style={{ display: 'flex', gap: 32, justifyContent: 'center', margin: '32px 0' }}>
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
                maxHeight: '60dvh',
                overflowY: 'auto',
                width: '100%'
              }}
            >
              {chatMessages.map((msg, i) => (
                <ChatMessage 
                  key={msg.message_id || i} 
                  from={msg.sender_type === 'User' ? 'user' : 'ai'} 
                  message={msg.message.replaceAll("*","")} 
                  sender_type={msg.sender_type}
                />
              ))}
              <div ref={chatEndRef} />
            </div>
          </>
        )}
        <ChatInput placeholder="What is a good recovery program for someone just out of back surgery" onSend={handleSend} />
      </div>
    </div>
  );
};

export default Chat;