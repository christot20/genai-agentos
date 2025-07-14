import { Cookies } from 'react-cookie';

const API_BASE = 'http://localhost:8000/api'; // provided-backend runs on port 8000
const cookies = new Cookies();

function getAuthHeaders() {
  const token = cookies.get('access_token'); // Use access_token from JWT response
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
  };
}

// Helper function to handle API responses
async function handleResponse(response) {
  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(errorText || `HTTP error! status: ${response.status}`);
  }
  return await response.json();
}

// Authentication API functions - using provided-backend endpoints
export async function signup({ email, password, firstName }) {
  const res = await fetch(`${API_BASE}/register`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ 
      username: email, // provided-backend uses username field only
      password: password
      // Note: provided-backend UserCreate schema only has username and password
      // first_name is not part of the registration schema
    }),
  });
  return handleResponse(res);
}

export async function signin({ email, password }) {
  // provided-backend uses form data for login
  const formData = new FormData();
  formData.append('username', email);
  formData.append('password', password);
  
  const res = await fetch(`${API_BASE}/login/access-token`, {
    method: 'POST',
    body: formData,
  });
  const data = await handleResponse(res);
  
  // Store the access token
  if (data.access_token) {
    cookies.set('access_token', data.access_token, { path: '/' });
  }
  
  return data;
}

// Chat API functions - using provided-backend endpoints
export async function createConversation() {
  // provided-backend requires session_id and title for creating chat
  const sessionId = crypto.randomUUID(); // Generate a session ID
  console.log('Creating conversation with session_id:', sessionId);
  const res = await fetch(`${API_BASE}/chats`, {
    method: 'POST',
    headers: getAuthHeaders(),
    body: JSON.stringify({
      session_id: sessionId,
      title: "New Chat" // Must be <= 20 characters
    }),
  });
  const data = await handleResponse(res);
  console.log('Conversation created:', data);
  return data;
}

export async function listConversations() {
  const res = await fetch(`${API_BASE}/chats`, {
    method: 'GET',
    headers: getAuthHeaders(),
  });
  return handleResponse(res);
}

// Message API functions - using provided-backend endpoints
// Note: Message creation is handled via WebSocket, not HTTP endpoints
export async function createMessage(conversationId, message) {
  // provided-backend handles messages via WebSocket
  // This function is kept for compatibility but should use WebSocket instead
  console.warn('createMessage: Messages should be sent via WebSocket, not HTTP');
  throw new Error('Messages must be sent via WebSocket connection');
}

export async function listMessages(conversationId) {
  console.log('Fetching messages for conversation:', conversationId);
  const res = await fetch(`${API_BASE}/chat?session_id=${encodeURIComponent(conversationId)}`, {
    method: 'GET',
    headers: getAuthHeaders(),
  });
  const data = await handleResponse(res);
  console.log('Messages response:', data);
  return data;
}

export async function testAIConnection() {
  // provided-backend doesn't have a test-ai endpoint
  // We'll test by trying to create a simple chat
  try {
    const res = await createConversation();
    return { message: "AI connection test successful", is_success: true };
  } catch (error) {
    return { message: "AI connection test failed", is_success: false, error: error.message };
  }
}

export function logout() {
  cookies.remove('access_token');
}

// WebSocket connection for real-time chat
export function createWebSocketConnection(sessionId = null) {
  const token = cookies.get('access_token');
  if (!token) {
    throw new Error('No access token available');
  }
  
  const wsUrl = sessionId 
    ? `ws://localhost:8000/frontend/ws?token=${token}&session_id=${sessionId}`
    : `ws://localhost:8000/frontend/ws?token=${token}`;
    
  return new WebSocket(wsUrl);
}

// Agent Flow API functions
export async function getAgentFlows() {
  const res = await fetch(`${API_BASE}/agentflows/`, {
    method: 'GET',
    headers: getAuthHeaders(),
  });
  return handleResponse(res);
}

export async function getAgentFlow(id) {
  const res = await fetch(`${API_BASE}/agentflows/${id}`, {
    method: 'GET',
    headers: getAuthHeaders(),
  });
  return handleResponse(res);
}

export async function createAgentFlow(flow) {
  const res = await fetch(`${API_BASE}/agentflows/register`, {
    method: 'POST',
    headers: getAuthHeaders(),
    body: JSON.stringify(flow),
  });
  return handleResponse(res);
}

export async function updateAgentFlow(id, flow) {
  const res = await fetch(`${API_BASE}/agentflows/${id}`, {
    method: 'PATCH',
    headers: getAuthHeaders(),
    body: JSON.stringify(flow),
  });
  return handleResponse(res);
}

export async function deleteAgentFlow(id) {
  const res = await fetch(`${API_BASE}/agentflows/${id}`, {
    method: 'DELETE',
    headers: getAuthHeaders(),
  });
  return handleResponse(res);
} 