import asyncio
from typing import Annotated
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import OpenAIEmbeddings
from genai_session.session import GenAISession
from genai_session.utils.context import GenAIContext
from dotenv import load_dotenv

AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI0MDFmZGE3NC01OWEwLTQ3YjAtOTJhNC1hZTMzMmRhMmM3OTEiLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6IjkxNWI1Nzg4LWNhMWMtNDk5NS1iYmY0LWU1NmJhZTI2MWNjYSJ9.iUGMW1jBQ_utT_CyeDb-brAwj1sjOBG9_oEDSvFbwwo" # noqa: E501
session = GenAISession(jwt_token=AGENT_JWT)




load_dotenv()

# Load Employee data
CHROMA_PATH = "../../../chroma_db"  # or wherever you saved it
vectordb = Chroma(persist_directory=CHROMA_PATH, embedding_function=OpenAIEmbeddings())

@session.bind(
    name="employee_info",
    description="Agent that retrieves employee info from a vector DB using RAG"
)
async def employee_info(
    agent_context: GenAIContext,
    first_name: Annotated[str, "Employee's first name"],
    last_name: Annotated[str, "Employee's last name"],
    user_query: Annotated[str, "User request such as 'What is my zip code and job title?'"],
):
    agent_context.logger.info("Inside get_employee_info")

    search_text = f"{first_name} {last_name} {user_query}"
    results = vectordb.similarity_search(search_text, k=1)

    if not results:
        return f"No information found for '{first_name} {last_name}'."

    doc = results[0].page_content.lower()
    response_parts = []

    if "zip" in user_query.lower():
        home_zip = doc.split("home_zip_code:")[1].split("|")[0].strip()
        work_zip = doc.split("work_zip_code:")[1].split("|")[0].strip()
        response_parts.append(f"Home zip is {home_zip}, work zip is {work_zip}.")

    if any(word in user_query.lower() for word in ["job", "position", "occupation"]):
        job_title = doc.split("job_title:")[1].split("|")[0].strip()
        response_parts.append(f"Job title is {job_title}.")

    if not response_parts:
        return "I couldn't determine what information you were requesting."

    return f"{first_name} {last_name}'s info:\n" + " ".join(response_parts)

async def main():
    print("Agent started...")
    await session.process_events()

if __name__ == "__main__":
    asyncio.run(main())

