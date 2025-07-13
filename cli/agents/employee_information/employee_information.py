import asyncio
import pandas as pd
from typing import Annotated
from genai_session.session import GenAISession
from genai_session.utils.context import GenAIContext

AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhODVjNjY4Yi01NzRjLTRkN2EtYWJjNS0xYjI4MTY2MzQ1YjgiLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6IjI5OGU3MTUzLWU4NzMtNDBkZC1iZWI1LWI1ZmIzMWMyYTgwZSJ9.EKNLRMNPPqJaa8z9TW8cEeYJH4tnDnSbz4tESao0Eqk" # noqa: E501
session = GenAISession(jwt_token=AGENT_JWT)

# Load Employee data
EMPLOYEE_CSV_PATH = "../../../agent_data/data/employees.csv"
df = pd.read_csv(EMPLOYEE_CSV_PATH)

@session.bind(
    name="employee_information",
    description="Agent that retrieves employee information from a CSV"
)
async def employee_zip_information(
    agent_context: GenAIContext,
    first_name: Annotated[str, "First name of the employee"],
    last_name: Annotated[str, "Last name of the employee"],
    user_query: Annotated[str, "User requesting desired information (e.g. 'What is my zip code?'"],
):
    agent_context.logger.info("Inside get_zip_codes")
    # Find employee (case-insensitive match)
    employee = df[
        (df["first_name"].str.lower() == first_name.lower()) &
        (df["last_name"].str.lower() == last_name.lower())
    ]

    # Make sure we found the employee before trying to access the row
    if employee.empty:
        return f"No employee found with name '{first_name} {last_name}'."

    row = employee.iloc[0]

    return f"{first_name} {last_name}'s home zip is {row['home_zip_code']}, work zip is {row['work_zip_code']}."
    

@session.bind(
    name="get_job_title",
    description="Agent that looks up the job title for an employee from a CSV"
)
async def get_job_title(
    agent_context: GenAIContext,
    first_name: Annotated[str, "Employee's first name"],
    last_name: Annotated[str, "Employee's last name"],
    user_query: Annotated[str, "User requesting desired information (e.g. 'What is my job title?' or 'What is my current occupation/position"],
):
    agent_context.logger.info("Inside get_job_title")
    # Find employee (case-insensitive match)
    employee = df[
        (df["first_name"].str.lower() == first_name.lower()) &
        (df["last_name"].str.lower() == last_name.lower())
    ]

    # Make sure we found the employee before trying to access the row
    if employee.empty:
        return f"No employee found with name '{first_name} {last_name}'."

    row = employee.iloc[0]

    return f"{first_name} {last_name}'s job title is {row['job_title']}."


async def main():
    print(f"Agent with token '{AGENT_JWT}' started")
    await session.process_events()

if __name__ == "__main__":
    asyncio.run(main())
