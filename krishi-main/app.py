import os
import io
import json
import requests
import librosa
import numpy as np
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from transformers import pipeline, AutoModelForSeq2SeqLM, AutoTokenizer
from pathlib import Path

app = FastAPI(title="Agritech Disease AI Backend")

# Allow CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

MODELS_DIR = Path("./offline_models")
OLLAMA_URL = "http://localhost:11434/api/generate"

# Globals for lazy loading
stt_pipeline = None
translator_model = None
translator_tokenizer = None

def load_stt():
    global stt_pipeline
    if stt_pipeline is None:
        print("Loading Whisper Tiny...")
        # Since we downloaded the ggml bin for flutter, we can just load the hf version here
        # or we could use the local dir if we fully downloaded it.
        # For simplicity, we use the hf pipeline which caches locally.
        stt_pipeline = pipeline("automatic-speech-recognition", model="openai/whisper-tiny")

def load_nllb():
    global translator_model, translator_tokenizer
    if translator_model is None:
        print("Loading NLLB-200...")
        model_path = MODELS_DIR / "nllb-200"
        if not model_path.exists():
            raise HTTPException(status_code=500, detail="NLLB model not found. Run setup_offline_models.py first.")
        translator_tokenizer = AutoTokenizer.from_pretrained(model_path, src_lang="eng_Latn")
        translator_model = AutoModelForSeq2SeqLM.from_pretrained(model_path)

@app.post("/api/stt")
async def speech_to_text(audio: UploadFile = File(...)):
    """Convert uploaded audio file to text using Whisper"""
    try:
        load_stt()
        # Read file
        contents = await audio.read()
        
        # We need to process it to numpy array for transformers
        # librosa can read from memory buffer
        audio_data, sr = librosa.load(io.BytesIO(contents), sr=16000)
        
        result = stt_pipeline(audio_data)
        return {"text": result["text"].strip()}
    except Exception as e:
        print(f"STT Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/api/llm")
async def get_precautions(disease: str = Form(...), query: str = Form(None)):
    """Ask Gemma (via Ollama) for precautions or answer a query"""
    if query:
        prompt = f"The user has a question about crop diseases. Answer it concisely. Question: {query}"
    else:
        prompt = f"Provide 3 short, actionable precautions or treatments for the crop disease: '{disease}'. Keep it very concise and plain text without formatting."

    try:
        response = requests.post(OLLAMA_URL, json={
            "model": "gemma:2b",
            "prompt": prompt,
            "stream": False
        })
        if response.status_code != 200:
            raise Exception(f"Ollama error: {response.text}")
            
        data = response.json()
        return {"response": data["response"].strip()}
    except Exception as e:
        print(f"LLM Error: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to reach Ollama: {str(e)}")

@app.post("/api/translate")
async def translate_text(text: str = Form(...), target_lang: str = Form(...)):
    """Translate text using NLLB-200"""
    # Map friendly names to NLLB language codes
    lang_map = {
        "hi": "hin_Deva",
        "mr": "mar_Deva",
        "ta": "tam_Taml",
        "en": "eng_Latn"
    }
    
    code = lang_map.get(target_lang)
    if not code:
        raise HTTPException(status_code=400, detail="Unsupported language")
        
    if code == "eng_Latn":
        return {"translatedText": text}
        
    try:
        load_nllb()
        inputs = translator_tokenizer(text, return_tensors="pt")
        translated_tokens = translator_model.generate(
            **inputs, 
            forced_bos_token_id=translator_tokenizer.lang_code_to_id[code],
            max_length=200
        )
        translation = translator_tokenizer.batch_decode(translated_tokens, skip_special_tokens=True)[0]
        return {"translatedText": translation}
    except Exception as e:
        print(f"Translation Error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True)
