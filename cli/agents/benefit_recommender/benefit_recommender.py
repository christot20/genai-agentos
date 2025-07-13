import asyncio
from typing import Annotated
from genai_session.session import GenAISession
from genai_session.utils.context import GenAIContext

AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwNjgzYWE1ZC0wYjE0LTRkZWEtOWJjMS0wM2RmMGQ3N2FmNTciLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6ImQ0Y2QzYTc5LTZmMjYtNGFjMy1iYTA0LTY0MGYxNTIxMGQ1NyJ9.8tePnVAS0gq4oktolAt1W3jTM7nAwCzKXTG7kZN7doY" # noqa: E501
session = GenAISession(jwt_token=AGENT_JWT)


@session.bind(
    name="benefit_recommender",
    description="Agent that looks up work benefits for an employee from a CSV"
)
async def benefit_recommender(
    agent_context: GenAIContext,
    test_arg: Annotated[
        str,
        "This is a test argument. Your agent can have as many parameters as you want. Feel free to rename or adjust it to your needs.",  # noqa: E501
    ],
):
    """Agent that looks up work benefits for an employee from a CSV"""
    return "Hello, World!"


async def main():
    print(f"Agent with token '{AGENT_JWT}' started")
    await session.process_events()

if __name__ == "__main__":
    asyncio.run(main())
