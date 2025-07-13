import asyncio
import pandas as pd
import re
from dateutil.parser import parse as date_parse
from typing import Annotated
from genai_session.session import GenAISession
from genai_session.utils.context import GenAIContext

AGENT_JWT = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhMTQ0ZWNhNi0yYTk4LTQyOGMtYjc0ZS1iNjk4YzEyY2JjMjUiLCJleHAiOjI1MzQwMjMwMDc5OSwidXNlcl9pZCI6IjI5OGU3MTUzLWU4NzMtNDBkZC1iZWI1LWI1ZmIzMWMyYTgwZSJ9.AXZjEZQmzpvg40DMSYkUQw1QQSSzj2Elv2CKKl6V5BA" # noqa: E501
session = GenAISession(jwt_token=AGENT_JWT)

# Load schedule data
SCHEDULE_CSV_PATH = "../../../agent_data/data/schedules.csv"
df = pd.read_csv(SCHEDULE_CSV_PATH)

# Convert appointment_date to datetime for easier handling
df["appointment_date"] = pd.to_datetime(df["appointment_date"], errors="coerce")


@session.bind(
    name="doctor_scheduler",
    description="Agent that finds available doctor appointments based on specialization, name, date, time, or appointment type."
)
async def doctor_scheduler(
    agent_context: GenAIContext,
    user_query: Annotated[
        str,
        "User request describing a desired appointment, such as 'Book a dermatologist for June 18', 'Do you have Dr. Wu available this Friday?', or 'I need a follow-up on 2024-07-22 at 10am'"
    ],
):
    query = user_query.lower()
    filtered_df = df[df["availability_status"].str.lower() == "available"]

    # Match doctor name
    name_filtered = filtered_df[
        filtered_df["last_name"].str.lower().apply(lambda x: x in query)
    ]
    if not name_filtered.empty:
        filtered_df = name_filtered

    # Match specialization
    specialization_filtered = filtered_df[
        filtered_df["specialization"].str.lower().apply(lambda x: x in query)
    ]
    if not specialization_filtered.empty:
        filtered_df = specialization_filtered

    # Match appointment type
    type_filtered = filtered_df[
        filtered_df["appointment_type"].str.lower().apply(lambda x: x in query)
    ]
    if not type_filtered.empty:
        filtered_df = type_filtered

    # Match date and/or time if any

    date_match = re.search(r"\b(?:on\s+)?(\d{4}-\d{2}-\d{2})\b", query)
    time_match = re.search(r"\b(\d{1,2}(:\d{2})?\s*(am|pm)?)\b", query)

    if date_match:
        try:
            date_obj = date_parse(date_match.group(1)).date()
            filtered_df = filtered_df[filtered_df["appointment_date"].dt.date == date_obj]
        except Exception:
            pass

    if time_match:
        time_str = time_match.group(1)
        filtered_df = filtered_df[filtered_df["appointment_time"].str.contains(time_str, case=False, na=False)]

    if filtered_df.empty:
        return "Sorry, no available appointments match your request."

    results = [
        f"Dr. {row['first_name']} {row['last_name']} ({row['specialization']}) — {row['appointment_date'].date()} at {row['appointment_time']} for {row['appointment_type']}"
        for _, row in filtered_df.iterrows()
    ]

    return "Available appointments:\n" + "\n".join(results[:5])  # Return up to 5 options


async def main():
    print(f"Agent with token '{AGENT_JWT}' started")
    await session.process_events()

if __name__ == "__main__":
    asyncio.run(main())
