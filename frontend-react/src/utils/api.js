const API_BASE = 'http://localhost:8001/api'; // Change to your backend URL
import { Cookies } from 'react-cookie';
const cookies = new Cookies();

function getAuthHeaders() {
  const token = cookies.get('userId'); // or your actual token cookie name
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

export async function signup({ email, password, firstName }) {
  const res = await fetch(`${API_BASE}/account/create`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, firstName }),
  });
  return handleResponse(res);
}

export async function signin({ email, password }) {
  const res = await fetch(`${API_BASE}/account/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password }),
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json();
}
// Conversation API
export async function createConversation() {
  const res = await fetch(`${API_BASE}/conversation/create`, {
    method: 'POST',
    credentials: 'include',
    headers: authHeaders()
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json(); // { message, conversation_id }
}

export async function getConversationList() {
  const res = await fetch(`${API_BASE}/conversation/list`, {
    method: 'GET',
    credentials: 'include',
    headers: authHeaders()
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json(); // { message, conversations: [...] }
}

// Message API
export async function createMessage({ message, conversation_id }) {
  const res = await fetch(`${API_BASE}/message/create`, {
    method: 'POST',
    credentials: 'include',
    headers: authHeaders(),
    body: JSON.stringify({ message, conversation_id })
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json(); // { message, message_id }
}

export async function getMessageList(conversation_id) {
  const res = await fetch(`${API_BASE}/message/list?conversation_id=${encodeURIComponent(conversation_id)}`, {
    method: 'GET',
    credentials: 'include',
    headers: authHeaders()
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json(); // { message, messages: [...] }
}
  return handleResponse(res);
}

// Conversation API functions
export async function createConversation() {
  const res = await fetch(`${API_BASE}/conversation/create`, {
    method: 'POST',
    headers: getAuthHeaders(),
  });
  return handleResponse(res);
}

export async function listConversations() {
  const res = await fetch(`${API_BASE}/conversation/list`, {
    method: 'GET',
    headers: getAuthHeaders(),
  });
  return handleResponse(res);
}

// Message API functions
export async function createMessage(conversationId, message) {
  const res = await fetch(`${API_BASE}/message/create`, {
    method: 'POST',
    headers: getAuthHeaders(),
    body: JSON.stringify({
      conversation_id: conversationId,
      message: message
    }),
  });
  return handleResponse(res);
}

export async function listMessages(conversationId) {
  const res = await fetch(`${API_BASE}/message/list`, {
    method: 'GET',
    headers: getAuthHeaders(),
  });
  return handleResponse(res);
}

export async function testAIConnection() {
  const res = await fetch(`${API_BASE}/message/test-ai`, {
    method: 'POST',
    headers: getAuthHeaders(),
  });
  return handleResponse(res);
} 