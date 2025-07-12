import asyncio
from typing import Annotated
from genai_session.session import GenAISession
from genai_session.utils.context import GenAIContext
from datetime import datetime

AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI1ZGUzMWIzZS1mNjg5LTQwMGMtYTVhNi1lNzZhYjk2YTRhOWMiLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6IjI5OGU3MTUzLWU4NzMtNDBkZC1iZWI1LWI1ZmIzMWMyYTgwZSJ9.EZfcy0gmXPOtdx4rvWdq_hsiEPM-BHFa8-ekmxspisA" # noqa: E501
session = GenAISession(jwt_token=AGENT_JWT)


@session.bind(
    name="current_date",
    description="Agent that returns current date"
)
async def current_date(
    agent_context
):
    agent_context.logger.info("Inside current_date agent")
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")

async def main():
    print(f"Agent with token '{AGENT_JWT}' started")
    await session.process_events()

if __name__ == "__main__":
    asyncio.run(main())
