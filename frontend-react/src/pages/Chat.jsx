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
import { createConversation, getConversationList, createMessage, getMessageList } from '../utils/api';

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
  const [loading, setLoading] = useState(false);
  const chatEndRef = useRef(null);
  const prevMsgCount = useRef(chatMessages.length);

  // On mount, get or create a conversation, then fetch messages
  useEffect(() => {
    async function initConversation() {
      setLoading(true);
      try {
        // Try to get existing conversations
        const convoList = await getConversationList();
        let convoId = null;
        if (convoList.conversations && convoList.conversations.length > 0) {
          convoId = convoList.conversations[0].conversation_id;
        } else {
          // Create a new conversation if none exist
          const created = await createConversation({});
          convoId = created.conversation_id;
        }
        setConversationId(convoId);
        console.log(convoId);
        // Fetch messages for this conversation
        if (convoId) {
          const msgRes = await getMessageList(convoId);
          setChatMessages(msgRes.messages || []);
        }
      } catch (e) {
        setChatMessages([]);
      }
      setLoading(false);
    }
    initConversation();
  }, []);

  const handleSend = async (message) => {
    if (!conversationId) return;
    setLoading(true);
    try {
      await createMessage({ message, conversation_id: conversationId });
      // Refresh messages after sending
      const msgRes = await getMessageList(conversationId);
      setChatMessages(msgRes.messages || []);
    } catch (e) {
      // Optionally show error
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
        )}
        <ChatInput placeholder="What is a good recovery program for someone just out of back surgery" onSend={handleSend} />
      </div>
    </div>
  );
};

export default Chat;