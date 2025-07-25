
from fastapi import FastAPI, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
import pdfplumber, tempfile, openai, os
import firebase_admin
from firebase_admin import credentials, firestore
from parser import parse_mcqs
from extract_questions import extract_2mark_questions, extract_16mark_questions
app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

cred = credentials.Certificate("firebase-adminsdk.json")
firebase_admin.initialize_app(cred)
db = firestore.client()
openai.api_key = os.getenv("OPENAI_API_KEY")

@app.post("/upload_material")
async def upload_material(department: str = Form(...), class_: str = Form(...), subject: str = Form(...), file: UploadFile = File(...)):
    with tempfile.NamedTemporaryFile(delete=False) as tmp:
        tmp.write(await file.read())
        tmp_path = tmp.name
    with pdfplumber.open(tmp_path) as pdf:
        text = "\n".join([page.extract_text() or "" for page in pdf.pages])
    os.remove(tmp_path)
    
    prompt = f"""Based on the lesson content, create 5 MCQs (4 options, correct answer), 5 2-mark Qs, and 3 16-mark Qs.\n{text}"""
    response = openai.ChatCompletion.create(model="gpt-3.5-turbo", messages=[{"role": "user", "content": prompt}], max_tokens=1000)
    gpt_output = response['choices'][0]['message']['content']
    material_data = {
        "department": department, "class": class_, "subject": subject,
        "text": text,
        "2marks": extract_2mark_questions(gpt_output),
        "16marks": extract_16mark_questions(gpt_output)
    }
    db.collection("materials").add(material_data)
    quiz_data = {
        "department": department, "class": class_, "subject": subject,
        "questions": parse_mcqs(gpt_output)
    }
    db.collection("quizzes").add(quiz_data)
    return {"message": "Material uploaded and quiz generated."}
