import asyncio
import pandas as pd
from typing import Annotated
from genai_session.session import GenAISession
from genai_session.utils.context import GenAIContext

AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI4Y2ExNjY0NS05YzM3LTRiYTYtOGVmYS1kZDE4NDY3ZDYyM2EiLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6IjI5OGU3MTUzLWU4NzMtNDBkZC1iZWI1LWI1ZmIzMWMyYTgwZSJ9.3eP49pVW3xCdzOsqUtJv7UVON-Lf1KLpSvl8UaqM50A" # noqa: E501
session = GenAISession(jwt_token=AGENT_JWT)

# Load doctor data
DOCTOR_CSV_PATH = "../../../agent_data/data/practitioners.csv"
df = pd.read_csv(DOCTOR_CSV_PATH)


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
    query = user_query.lower()
    filtered_df = df.copy()

    # Match by doctor name
    name_match = df[df["last_name"].str.lower().apply(lambda x: x in query)]
    if not name_match.empty:
        row = name_match.iloc[0]
        return (
            f"Dr. {row['first_name']} {row['last_name']} is a specialist in {row['specialization']} "
            f"in {row['metro_area']} at {row['office_address']} ({row['office_zip_code']}).\n"
            f"Services: {row['services']}"
        )

    # Match services
    service_keywords = [word for word in query.split()]
    filtered_df = filtered_df[filtered_df["services"].str.lower().apply(
        lambda s: any(word in s for word in service_keywords)
    )]

    # Match specialization
    specialization_match = df["specialization"].str.lower().apply(lambda x: x in query)
    if specialization_match.any():
        specializations = df[specialization_match]["specialization"].str.lower().unique()
        filtered_df = filtered_df[filtered_df["specialization"].str.lower().isin(specializations)]

    # Match location
    location_keywords = [str(z).lower() for z in df["office_zip_code"].unique()] + df["metro_area"].str.lower().unique().tolist()
    matched_locations = [word for word in location_keywords if word in query]
    if matched_locations:
        filtered_df = filtered_df[
            filtered_df["metro_area"].str.lower().isin(matched_locations) |
            filtered_df["office_zip_code"].astype(str).str.lower().isin(matched_locations)
        ]

    if filtered_df.empty:
        return "Sorry, I couldn't find any doctors matching your full request."

    results = [
        f"Dr. {row['first_name']} {row['last_name']} ({row['specialization']}) - {row['office_address']}, {row['office_zip_code']}\nServices: {row['services']}"
        for _, row in filtered_df.iterrows()
    ]

    return "Here are doctors matching your request:\n" + "\n\n".join(results)


async def main():
    print(f"Agent with token '{AGENT_JWT}' started")
    await session.process_events()


if __name__ == "__main__":
    asyncio.run(main())