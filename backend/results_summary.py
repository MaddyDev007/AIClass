# results_summary.py — FastAPI endpoint for result analytics

from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from firebase_admin import credentials, firestore, initialize_app
import firebase_admin
import statistics

# Initialize Firebase once
if not firebase_admin._apps:
    cred = credentials.Certificate("firebase-adminsdk.json")
    initialize_app(cred)

db = firestore.client()
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/results_summary")
async def results_summary(quiz_id: str = Query(...)):
    results_ref = db.collection("results").document(quiz_id).collection("students")
    docs = results_ref.stream()

    scores = []
    for doc in docs:
        data = doc.to_dict()
        if 'score' in data:
            scores.append(data['score'])

    if not scores:
        return {"message": "No results available for this quiz."}

    summary = {
        "quiz_id": quiz_id,
        "total_attempts": len(scores),
        "highest": max(scores),
        "lowest": min(scores),
        "average": round(statistics.mean(scores), 2),
        "scores": scores,
    }

    return summary