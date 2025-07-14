import asyncio
import pandas as pd
from typing import Annotated
from genai_session.session import GenAISession
from genai_session.utils.context import GenAIContext
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import OpenAIEmbeddings
from dotenv import load_dotenv

AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIwNDMyOWZmZS0wMTg3LTQ4OTYtYjQ5Mi1hZGY5MDRkZTJjM2QiLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6IjkxNWI1Nzg4LWNhMWMtNDk5NS1iYmY0LWU1NmJhZTI2MWNjYSJ9.cxTQFlaIn_54sGCebHgblTGvpxUcAkc1r7k_ix62i80" # noqa: E501
session = GenAISession(jwt_token=AGENT_JWT)



load_dotenv()

CHROMA_PATH = "../../../chroma_db"
embeddings = OpenAIEmbeddings()
vectordb = Chroma(persist_directory=CHROMA_PATH, embedding_function=embeddings)
retriever = vectordb.as_retriever(search_type="similarity", search_kwargs={"k": 5})


@session.bind(
    name="recommend_benefit",
    description="Agent that looks up work benefits for an employee from a vector DB"
)
async def recommend_benefit(
    agent_context: GenAIContext,
    first_name: Annotated[str, "First name of the employee"],
    last_name: Annotated[str, "Last name of the employee"],
    user_query: Annotated[str, "User requesting their work benefits (e.g. 'What are my work benefits' or 'What are my employee benefits?')"],
):
    agent_context.logger.info("Inside benefit_recommender")

    # Compose a query to search by employee name and benefits context
    query = f"employee {first_name} {last_name} benefits"

    docs = retriever.get_relevant_documents(query)

    if not docs:
        return f"No benefits info found for {first_name} {last_name}."

    # Parse and find the correct employee in the retrieved documents
    for doc in docs:
        content = doc.page_content.lower()
        if first_name.lower() in content and last_name.lower() in content:
            # Assuming content has a 'work_benefits' field in "work_benefits: <info>" format
            for part in content.split("|"):
                if "work_benefits:" in part:
                    benefits = part.split("work_benefits:")[1].strip()
                    return f"{first_name} {last_name}'s eligible benefits are: {benefits}"

    return f"No benefits info found for {first_name} {last_name}."


async def main():
    print(f"Agent with token '{AGENT_JWT}' started")
    await session.process_events()


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())

