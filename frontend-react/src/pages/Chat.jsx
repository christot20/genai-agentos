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
import { createConversation, listConversations, createMessage, listMessages } from '../utils/api';

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
          convoId = convoList.conversations[0].conversation_id;
          setConversations(convoList.conversations);
        } else {
          // Create a new conversation if none exist
          const created = await createConversation();
          convoId = created.conversation_id;
        }
        setConversationId(convoId);
        console.log('Selected conversation ID:', convoId);
        
        // Fetch messages for this conversation
        if (convoId) {
          const msgRes = await listMessages(convoId);
          console.log('Messages response:', msgRes);
          setChatMessages(msgRes.messages || []);
          setConversationTitle(msgRes.conversation_title || 'New Chat');
        }
      } catch (e) {
        console.error('Error initializing conversation:', e);
        setChatMessages([]);
      }
      setLoading(false);
    }
    initConversation();
  }, []);

  const handleSend = async (message) => {
    if (!conversationId) return;
    
    // Immediately add user message to the chat
    const userMessage = {
      message_id: `temp-${Date.now()}`,
      message: message,
      sender_type: 'User',
      timestamp: new Date().toISOString()
    };
    
    setChatMessages(prev => [...prev, userMessage]);
    setLoading(true);
    
    try {
      console.log('Sending message:', message, 'to conversation:', conversationId);
      await createMessage(conversationId, message);
      
      // Add a small delay to ensure AI response is processed
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      // Try to get updated messages with retries
      let msgRes = null;
      let retryCount = 0;
      const maxRetries = 5;
      
      while (retryCount < maxRetries) {
        msgRes = await listMessages(conversationId);
        console.log(`Retry ${retryCount + 1}: Updated messages:`, msgRes);
        
        // Check if we have both user and AI messages
        const messages = msgRes.messages || [];
        const userMessages = messages.filter(msg => msg.sender_type === 'User');
        const aiMessages = messages.filter(msg => msg.sender_type === 'AI');
        
        // If we have the same number of AI responses as user messages, we're done
        if (aiMessages.length >= userMessages.length) {
          break;
        }
        
        // Wait a bit more and retry
        await new Promise(resolve => setTimeout(resolve, 1000));
        retryCount++;
      }
      
      setChatMessages(msgRes.messages || []);
      setConversationTitle(msgRes.conversation_title || 'New Chat');
    } catch (e) {
      console.error('Error sending message:', e);
      // Remove the temporary user message if there was an error
      setChatMessages(prev => prev.filter(msg => msg.message_id !== userMessage.message_id));
      // Optionally show error to user
    }
    setLoading(false);
  };

  const handleConversationSelect = async (convoId) => {
    setLoading(true);
    try {
      setConversationId(convoId);
      const msgRes = await listMessages(convoId);
      setChatMessages(msgRes.messages || []);
      setConversationTitle(msgRes.conversation_title || 'Chat');
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
      <div style={{ flex: 1, paddingLeft: 24 }}>
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
                        key={conv.conversation_id}
                        onClick={() => handleConversationSelect(conv.conversation_id)}
                        style={{
                          padding: '4px 8px',
                          fontSize: '12px',
                          border: '1px solid #ddd',
                          borderRadius: '4px',
                          background: conv.conversation_id === conversationId ? '#007bff' : '#fff',
                          color: conv.conversation_id === conversationId ? '#fff' : '#333',
                          cursor: 'pointer'
                        }}
                      >
                        {conv.first_message ? conv.first_message.substring(0, 20) + '...' : 'New Chat'}
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
              {chatMessages.map((msg, i) => (
                <ChatMessage key={msg.message_id || i} from={msg.sender_type === 'User' ? 'user' : 'ai'} message={msg.message} />
              ))}
              {loading && <div style={{ color: '#FF535C', textAlign: 'center', margin: 8 }}>Loading...</div>}
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