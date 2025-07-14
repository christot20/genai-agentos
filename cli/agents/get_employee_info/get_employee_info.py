# import asyncio
# from typing import Annotated
# import pandas as pd
# from genai_session.session import GenAISession
# from genai_session.utils.context import GenAIContext

# AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyYWE2ODY4Mi04YzU4LTRmOGQtYTEwMS02ZmIxZDUxNjc4MDYiLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6IjI5OGU3MTUzLWU4NzMtNDBkZC1iZWI1LWI1ZmIzMWMyYTgwZSJ9.yZZBeSJgLh4BJHGCD5Gm589-Le43fhKWhM6AjyZEo84" # noqa: E501
# session = GenAISession(jwt_token=AGENT_JWT)

# # Load Employee data
# EMPLOYEE_CSV_PATH = "../../../agent_data/data/employees.csv"
# df = pd.read_csv(EMPLOYEE_CSV_PATH)

# @session.bind(
#     name="get_employee_info",
#     description="Agent that retrieves various employee details like job title, zip codes, and more based on user query"
# )
# async def get_employee_info(
#     agent_context: GenAIContext,
#     first_name: Annotated[str, "Employee's first name"],
#     last_name: Annotated[str, "Employee's last name"],
#     user_query: Annotated[str, "User request such as 'What is my zip code and job title?'"],
# ):
#     agent_context.logger.info("Inside get_employee_info")

#     # Find employee (case-insensitive match)
#     employee = df[
#         (df["first_name"].str.lower() == first_name.lower()) &
#         (df["last_name"].str.lower() == last_name.lower())
#     ]

#     if employee.empty:
#         return f"No employee found with name '{first_name} {last_name}'."

#     row = employee.iloc[0]
#     response_parts = []

#     query = user_query.lower()

#     if "zip" in query:
#         response_parts.append(f"Home zip is {row['home_zip_code']}, work zip is {row['work_zip_code']}.")

#     if "job" in query or "position" in query or "occupation" in query:
#         response_parts.append(f"Job title is {row['job_title']}.")

#     if not response_parts:
#         return f"I couldn't determine what information you were requesting. Please ask about zip codes, job title, or other known fields."

#     return f"{first_name} {last_name}'s info:\n" + " ".join(response_parts)


# async def main():
#     print(f"Agent with token '{AGENT_JWT}' started")
#     await session.process_events()

# if __name__ == "__main__":
#     asyncio.run(main())


import asyncio
from typing import Annotated
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import OpenAIEmbeddings
from genai_session.session import GenAISession
from genai_session.utils.context import GenAIContext
from dotenv import load_dotenv

AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIyYWE2ODY4Mi04YzU4LTRmOGQtYTEwMS02ZmIxZDUxNjc4MDYiLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6IjI5OGU3MTUzLWU4NzMtNDBkZC1iZWI1LWI1ZmIzMWMyYTgwZSJ9.yZZBeSJgLh4BJHGCD5Gm589-Le43fhKWhM6AjyZEo84" # noqa: E501
session = GenAISession(jwt_token=AGENT_JWT)

load_dotenv()

# Load Employee data
CHROMA_PATH = "../../../chroma_db"  # or wherever you saved it
vectordb = Chroma(persist_directory=CHROMA_PATH, embedding_function=OpenAIEmbeddings())

@session.bind(
    name="get_employee_info",
    description="Agent that retrieves employee info from a vector DB using RAG"
)
async def get_employee_info(
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

