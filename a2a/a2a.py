from fastapi import FastAPI, HTTPException
from datetime import datetime
import uvicorn
from pydantic import BaseModel
from typing import Optional, Dict, Any, List
import uuid

app = FastAPI(
    title="Current Date A2A Agent",
    description="A2A agent that returns the current date and time"
)

class AgentCard(BaseModel):
    name: str
    description: str
    url: str
    skills: list[dict] = []

class AgentRequest(BaseModel):
    action: str
    parameters: Optional[Dict[str, Any]] = None

class A2AAgentRequest(BaseModel):
    server_url: str

class A2AAgent(BaseModel):
    id: str
    url: str
    name: str
    description: str

# Add root endpoint
@app.get("/")
async def root():
    return {
        "name": "Current Date A2A Agent",
        "status": "running",
        "endpoints": {
            "manifest": "/.well-known/agent.json",
            "invoke": "/invoke"
        }
    }

@app.get("/.well-known/agent.json")
async def agent_manifest():
    return AgentCard(
        name="current_date",
        description="Agent that returns current date",
        url="http://host.docker.internal:9001",
        skills=[{
            "name": "get_current_date",
            "description": "Returns the current date and time"
        }]
    )

@app.post("/invoke")
async def invoke_agent():
    return {
        "result": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    }

@app.post("/api/a2a/agents")
async def handle_agent_request(request: AgentRequest):
    if request.action == "get_current_date":
        return {
            "status": "success",
            "result": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        }
    raise HTTPException(status_code=400, detail=f"Unsupported action: {request.action}")

@app.get("/api/a2a/agents", response_model=List[A2AAgent])
async def get_all_agents():
    # Example response
    return [{
        "id": "current-date-1",
        "url": "http://localhost:9001",
        "name": "current_date",
        "description": "Agent that returns current date"
    }]

@app.get("/api/a2a/agents/{agent_id}", response_model=A2AAgent)
async def get_agent(agent_id: str):
    # Example single agent response
    return {
        "id": agent_id,
        "url": "http://localhost:9001",
        "name": "current_date",
        "description": "Agent that returns current date"
    }

@app.post("/api/a2a/agents", response_model=A2AAgent)
async def add_agent(request: A2AAgentRequest):
    # Generate a unique ID for the agent
    agent_id = str(uuid.uuid4())
    return {
        "id": agent_id,
        "url": request.server_url,
        "name": "current_date",
        "description": "Agent that returns current date"
    }

@app.delete("/api/a2a/agents/{agent_id}")
async def delete_agent(agent_id: str):
    return {"status": "success", "message": f"Agent {agent_id} deleted"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=9001)