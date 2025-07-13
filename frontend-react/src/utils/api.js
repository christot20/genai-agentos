const API_BASE = 'http://localhost:8001/api';

// Conversation API
export async function createConversation() {
  const res = await fetch(`${API_BASE}/conversation/create`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' }
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json(); // { message, conversation_id }
}

export async function getConversationList() {
  const res = await fetch(`${API_BASE}/conversation/list`, {
    method: 'GET',
    credentials: 'include'
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json(); // { message, conversations: [...] }
}

// Message API
export async function createMessage({ message, conversation_id }) {
  const res = await fetch(`${API_BASE}/message/create`, {
    method: 'POST',
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ message, conversation_id })
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json(); // { message, message_id }
}

export async function getMessageList(conversation_id) {
  const res = await fetch(`${API_BASE}/message/list?conversation_id=${encodeURIComponent(conversation_id)}`, {
    method: 'GET',
    credentials: 'include'
  });
  if (!res.ok) throw new Error(await res.text());
  return await res.json(); // { message, messages: [...] }
}