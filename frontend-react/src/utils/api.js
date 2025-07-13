import { Cookies } from 'react-cookie';
const cookies = new Cookies();
const API_BASE = 'http://localhost:8001/api';

function authHeaders() {
  const token = cookies.get('userId'); // or your actual token cookie name
  return {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${token}`,
  };
}

export async function signup({ email, password, firstName }) {
  const res = await fetch(`${API_BASE}/account/create`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password, firstName }),
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json();
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