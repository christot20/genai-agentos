import httpx
from langchain_core.messages import BaseMessage, HumanMessage, AIMessage
import logging

logger = logging.getLogger(__name__)


def chat_history_to_messages(chat_history: list[dict[str, str]]) -> list[BaseMessage]:
    messages = []

    for msg in chat_history:
        role = msg.get("sender_type")
        content = msg.get("content")

        match role:
            case "user":
                messages.append(HumanMessage(content=content))
            case "master_agent":
                messages.append(AIMessage(content=content))
            case _:
                continue
    return messages


async def get_chat_history(url: str, session_id: str, user_id: str, api_key: str, max_last_messages: int):
    logger.info(f"Getting chat history for session_id: {session_id}, user_id: {user_id}, max_messages: {max_last_messages}")
    
    async with httpx.AsyncClient() as client:
        response = await client.get(
            url,
            headers={"X-API-KEY": api_key},
            params={"session_id": session_id, "user_id": user_id, "per_page": max_last_messages}
        )

        logger.info(f"Chat history response status: {response.status_code}")
        if response.status_code != 200:
            logger.error(f"Chat history request failed: {response.text}")
            response.raise_for_status()
            
        response_data = response.json()
        logger.info(f"Chat history response data: {response_data}")
        
        raw_chat_history = response_data.get("items", [])
        logger.info(f"Raw chat history length: {len(raw_chat_history)}")

    messages = chat_history_to_messages(chat_history=raw_chat_history[::-1])
    logger.info(f"Converted messages length: {len(messages)}")
    return messages
