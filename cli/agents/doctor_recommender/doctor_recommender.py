import asyncio
import pandas as pd
from typing import Annotated
from genai_session.session import GenAISession
from genai_session.utils.context import GenAIContext
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import OpenAIEmbeddings
from dotenv import load_dotenv

AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4Y2ExNjY0NS05YzM3LTRiYTYtOGVmYS1kZDE4NDY3ZDYyM2EiLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6IjI5OGU3MTUzLWU4NzMtNDBkZC1iZWI1LWI1ZmIzMWMyYTgwZSJ9.3eP49pVW3xCdzOsqUtJv7UVON-Lf1KLpSvl8UaqM50A" # noqa: E501
session = GenAISession(jwt_token=AGENT_JWT)

load_dotenv()

# Load Employee data
CHROMA_PATH = "../../../chroma_db"

embeddings = OpenAIEmbeddings()
vectordb = Chroma(persist_directory=CHROMA_PATH, embedding_function=embeddings)
retriever = vectordb.as_retriever(search_type="similarity", search_kwargs={"k": 10})  # get top 10 docs


@session.bind(
    name="doctor_recommender",
    description="Agent that recommends doctors based on specialization, location, name, or service"
)
async def doctor_recommender(
    agent_context: GenAIContext,
    user_query: Annotated[
        str,
        "User request describing doctor need (e.g. 'I need a cardiologist in NYC' or 'Tell me about Dr. Patel' or 'I'd like a screening for diabetes')"
    ],
):
    agent_context.logger.info("Inside doctor_recommender")

    # Use retriever to get semantically relevant documents
    docs = retriever.get_relevant_documents(user_query)

    if not docs:
        return "Sorry, I couldn't find any doctors matching your request."

    results = []
    for doc in docs:
        content = doc.page_content
        # Optional: you can add lightweight filtering on content based on query here if needed
        results.append(content)

    # Limit results to a max number (like 5)
    results = results[:5]

    return "Here are doctors matching your request:\n\n" + "\n\n".join(results)


async def main():
    print(f"Agent with token '{AGENT_JWT}' started")
    await session.process_events()


if __name__ == "__main__":
    asyncio.run(main())