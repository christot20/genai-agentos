import asyncio
from typing import Annotated
from genai_session.session import GenAISession
from genai_session.utils.context import GenAIContext

import pandas as pd

AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJlMGM5MDgwOC1hMTJmLTQzM2UtYWJkYy0wMjI0NDZlMzI4NTkiLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6IjQ2OGU2Yjc1LWRiMDUtNGYzNi04ZjkxLWM5NmY4NzIwZjQxZSJ9.C2aE7wUm1KzBxPC4ftyv2ofum5cPlUhWhkWgY1sMoD0" # noqa: E501
session = GenAISession(jwt_token=AGENT_JWT)



# Load Employee data
EMPLOYEE_CSV_PATH = "../../../agent_data/data/employees.csv"
df = pd.read_csv(EMPLOYEE_CSV_PATH)


@session.bind(
    name="benefit_recommend",
    description="Recommend benefits for a person based on what benefits they have."
)
async def benefit_recommend(
        agent_context: GenAIContext,
        first_name: Annotated[str, "First name of the employee"],
        last_name: Annotated[str, "Last name of the employee"],
        user_query: Annotated[
            str, "User requesting their work benefits (e.g. 'What are my work benefits' or 'What are my employee benefits?')"],
):
    agent_context.logger.info("Inside benefit_recommender")
    # Find employee (case-insensitive match)
    employee = df[
        (df["first_name"].str.lower() == first_name.lower()) &
        (df["last_name"].str.lower() == last_name.lower())
        ]

    # Make sure we found the employee before trying to access the row
    if employee.empty:
        return f"No employee found with name '{first_name} {last_name}'."

    # Now it's safe to access the first (and hopefully only) match
    row = employee.iloc[0]

    if "benefits" in user_query.lower():
        return f"{first_name} {last_name}'s eligible benefits are {row['work_benefits']}."


async def main():
    print(f"Agent with token '{AGENT_JWT}' started")
    await session.process_events()


if __name__ == "__main__":
    asyncio.run(main())

