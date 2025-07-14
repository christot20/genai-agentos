import asyncio
from typing import Annotated
from genai_session.session import GenAISession
from genai_session.utils.context import GenAIContext
from langchain_community.vectorstores import Chroma
from langchain.embeddings import OpenAIEmbeddings
import re
from dateutil.parser import parse as date_parse
from dotenv import load_dotenv


AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4M2EzNjQ3YS1lNGFmLTRkNTUtOWE4NC01ZjE2MzUyMjA5NjgiLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6IjkxNWI1Nzg4LWNhMWMtNDk5NS1iYmY0LWU1NmJhZTI2MWNjYSJ9.hesz2-yYVZu5zgzx3AqQ1ZPolLkIbvu_ntZn4QDO68M" # noqa: E501
session = GenAISession(jwt_token=AGENT_JWT)

load_dotenv()

# Load Employee data
CHROMA_PATH = "../../../chroma_db"  # or wherever you saved it

# Initialize Chroma vectorstore & retriever once (outside handler)
embeddings = OpenAIEmbeddings()
vectordb = Chroma(persist_directory=CHROMA_PATH, embedding_function=embeddings)
retriever = vectordb.as_retriever(search_type="similarity", search_kwargs={"k": 10})  # tweak k as needed

@session.bind(
    name="schedule_doctor",
    description="Agent that finds available doctor appointments based on specialization, name, date, time, or appointment type."
)
async def doctor_scheduler(
    agent_context: GenAIContext,
    user_query: Annotated[
        str,
        "User request describing a desired appointment, such as 'Book a dermatologist for June 18', 'Do you have Dr. Wu available this Friday?', or 'I need a follow-up on 2024-07-22 at 10am'"
    ],
):
    agent_context.logger.info("Inside doctor_scheduler")

    # Retrieve top relevant docs from Chroma based on user query
    docs = retriever.get_relevant_documents(user_query)

    # Filter available appointments from retrieved docs
    available_appointments = []
    for doc in docs:
        # doc.page_content is a string like:
        # "doctor_id: 1 | first_name: John | last_name: Wu | specialization: Dermatology | appointment_date: 2024-07-18 | appointment_time: 10:00 AM | appointment_type: follow-up | availability_status: available"
        content = doc.page_content.lower()

        if "availability_status: available" not in content:
            continue

        # Check if user query terms match this appointment record (name, specialization, date, time, type)
        if any(term in content for term in user_query.lower().split()):
            available_appointments.append(doc.page_content)

    if not available_appointments:
        return "Sorry, no available appointments match your request."

    # Return top 5 matching appointments (you can parse nicer if you want)
    return "Available appointments:\n" + "\n".join(available_appointments[:5])


async def main():
    print(f"Agent with token '{AGENT_JWT}' started")
    await session.process_events()

if __name__ == "__main__":
    asyncio.run(main())
