from fastapi import APIRouter, HTTPException, Header
from pydantic import BaseModel
from typing import Optional, List
import json
import os
import yaml
import random
from .monitor import get_system_stats
from .validator import ActivityValidator

router = APIRouter()
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
validator = ActivityValidator(os.path.join(BASE_DIR, 'tasks.yaml'))
QUESTIONS_FILE = os.path.join(BASE_DIR, 'questions.yaml')
DATA_DIR = os.path.join(BASE_DIR, 'data')

if not os.path.exists(DATA_DIR):
    os.makedirs(DATA_DIR)

class ValidationRequest(BaseModel):
    activity_id: str
    user_input: Optional[str] = None

class QuizRequest(BaseModel):
    question_idx: int
    answer: str

def get_student_file(student_id: str):
    # Sanatiza o student_id para evitar path traversal
    safe_id = "".join([c for c in student_id if c.isalnum() or c in ('-', '_')]).strip()
    return os.path.join(DATA_DIR, f"progress_{safe_id}.json")

def load_progress(student_id: str):
    path = get_student_file(student_id)
    if os.path.exists(path):
        with open(path, 'r') as f:
            return json.load(f)
    return {}

def save_progress(student_id: str, progress):
    path = get_student_file(student_id)
    with open(path, 'w') as f:
        json.dump(progress, f)

def load_questions():
    if os.path.exists(QUESTIONS_FILE):
        with open(QUESTIONS_FILE, 'r', encoding='utf-8') as f:
            return yaml.safe_load(f).get('questions', [])
    return []

@router.get("/quiz")
async def get_quiz():
    all_questions = load_questions()
    if not all_questions:
        return []
    
    # Seleciona 10 questões aleatórias
    selected = random.sample(all_questions, min(10, len(all_questions)))
    
    # Adicionamos um ID temporário para validação sem expor o índice original do arquivo
    safe_questions = []
    for idx, q in enumerate(selected):
        safe_questions.append({
            "id": idx,
            "question": q["question"],
            "options": q["options"],
            "correct_hidden": q["correct"] # Será usado para conferência no final
        })
    return safe_questions

@router.post("/quiz/validate")
async def validate_quiz(req: List[dict]):
    # O frontend enviará a lista completa de respostas no final
    results = []
    correct_count = 0
    
    for item in req:
        is_correct = item['user_answer'] == item['correct_answer']
        if is_correct:
            correct_count += 1
        results.append({
            "question": item['question'],
            "is_correct": is_correct,
            "correct_answer": item['correct_answer'],
            "user_answer": item['user_answer']
        })
        
    return {
        "score": correct_count,
        "total": len(req),
        "details": results
    }

@router.get("/stats")
async def stats():
    return get_system_stats()

@router.get("/prerequisites")
async def get_prerequisites():
    return validator.get_prerequisites_status()

@router.get("/activities")
async def get_activities(x_student_id: str = Header(None)):
    if not x_student_id:
        raise HTTPException(status_code=400, detail="Student ID missing")
    
    progress = load_progress(x_student_id)
    enriched_activities = []
    for activity in validator.activities:
        act_copy = activity.copy()
        act_copy['status'] = progress.get(activity['id'], 'pending')
        enriched_activities.append(act_copy)
    return enriched_activities

@router.post("/validate")
async def validate_activity(req: ValidationRequest, x_student_id: str = Header(None)):
    if not x_student_id:
        raise HTTPException(status_code=400, detail="Student ID missing")
        
    success, message = validator.validate(req.activity_id, req.user_input)
    
    progress = load_progress(x_student_id)
    progress[req.activity_id] = 'success' if success else 'failed'
    save_progress(x_student_id, progress)
    
    return {"success": success, "message": message}

@router.post("/reset")
async def reset_all(x_student_id: str = Header(None)):
    if x_student_id:
        path = get_student_file(x_student_id)
        if os.path.exists(path):
            os.remove(path)
    return {"message": "Progresso resetado com sucesso."}
