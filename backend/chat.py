
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import openai
import os
import firebase_admin
from firebase_admin import credentials, firestore

if not firebase_admin._apps:
    cred = credentials.Certificate("firebase-adminsdk.json")
    firebase_admin.initialize_app(cred)

db = firestore.client()
openai.api_key = os.getenv("OPENAI_API_KEY")

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])


class ChatQuery(BaseModel):
    question: str
    department: str = None
    class_: str = None
    subject: str = None


@app.post("/chat")
async def chat(query: ChatQuery):
    q = db.collection("materials")
    if query.department:
        q = q.where("department", "==", query.department)
    if query.class_:
        q = q.where("class", "==", query.class_)
    if query.subject:
        q = q.where("subject", "==", query.subject)
    docs = q.limit(1).stream()
    context_text = next((doc.to_dict().get("text", "") for doc in docs), "")
    if not context_text:
        return {"answer": "No relevant material found."}
    prompt = f"Use this material to answer: {query.question}\nMaterial: {context_text}"
    response = openai.ChatCompletion.create(model="gpt-3.5-turbo", messages=[{"role": "user", "content": prompt}], max_tokens=500)
    return {"answer": response['choices'][0]['message']['content'].strip()}
