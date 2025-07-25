# main.py – Central FastAPI app entry point

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from upload_material import app as upload_app
# from chatbot import app as chatbot_app  # Uncomment when chatbot.py is ready

app = FastAPI()

# CORS setup to allow Flutter frontend to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount endpoint routers
app.mount("/upload_material", upload_app)
# app.mount("/chat", chatbot_app)  # Mount chatbot when ready

@app.get("/")
def root():
    return {"message": "Smart Class API running 🚀"}
