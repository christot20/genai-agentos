#!/usr/bin/env python3
import requests
import json
import time

# API base URL
API_BASE = 'http://localhost:8001/api'

def test_api():
    print("Testing API endpoints...")
    
    # Step 1: Create a user account
    print("\n1. Creating user account...")
    signup_data = {
        "email": "test@example.com",
        "password": "TestPass123!",
        "firstName": "Test"
    }
    
    signup_response = requests.post(f"{API_BASE}/account/create", json=signup_data)
    print(f"Signup response: {signup_response.status_code}")
    
    if signup_response.status_code != 200:
        print(f"Signup failed: {signup_response.text}")
        return
    
    # Step 2: Login to get token
    print("\n2. Logging in...")
    login_data = {
        "email": "test@example.com",
        "password": "TestPass123!"
    }
    
    login_response = requests.post(f"{API_BASE}/account/login", json=login_data)
    print(f"Login response: {login_response.status_code}")
    
    if login_response.status_code != 200:
        print(f"Login failed: {login_response.text}")
        return
    
    login_result = login_response.json()
    token = login_result.get('access_token')
    print(f"Got token: {token[:50]}...")
    
    # Step 3: Create a conversation
    print("\n3. Creating conversation...")
    headers = {'Authorization': f'Bearer {token}'}
    
    conv_response = requests.post(f"{API_BASE}/conversation/create", headers=headers)
    print(f"Conversation creation response: {conv_response.status_code}")
    
    if conv_response.status_code != 200:
        print(f"Conversation creation failed: {conv_response.text}")
        return
    
    conv_result = conv_response.json()
    conversation_id = conv_result.get('conversation_id')
    print(f"Created conversation: {conversation_id}")
    
    # Step 4: Send a message
    print("\n4. Sending message...")
    message_data = {
        "conversation_id": conversation_id,
        "message": "Hello! Can you help me with a health question?"
    }
    
    message_response = requests.post(f"{API_BASE}/message/create", headers=headers, json=message_data)
    print(f"Message creation response: {message_response.status_code}")
    
    if message_response.status_code != 201:
        print(f"Message creation failed: {message_response.text}")
        return
    
    message_result = message_response.json()
    print(f"Message created: {message_result}")
    
    # Step 5: Wait a bit and get messages
    print("\n5. Waiting for AI response...")
    time.sleep(3)
    
    messages_response = requests.get(f"{API_BASE}/message/list?conversation_id={conversation_id}", headers=headers)
    print(f"Messages response: {messages_response.status_code}")
    
    if messages_response.status_code == 200:
        messages_result = messages_response.json()
        print(f"Messages: {json.dumps(messages_result, indent=2)}")
    else:
        print(f"Failed to get messages: {messages_response.text}")

if __name__ == "__main__":
    test_api() 