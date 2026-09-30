import os
import subprocess
import urllib.request
from pathlib import Path

# Base directory for models
MODELS_DIR = Path("./offline_models")
MODELS_DIR.mkdir(parents=True, exist_ok=True)

print("="*50)
print("  OFFLINE MODEL SETUP SCRIPT (Python/Windows Friendly)")
print("="*50)

# -------------------------------------------------------------------------
# 1. GEMMA 2B (GGUF format)
# -------------------------------------------------------------------------
print("\n[1] Setting up Gemma 2B...")
GEMMA_OUT = MODELS_DIR / "gemma2b-q4.gguf"

if GEMMA_OUT.exists():
    print(f"✓ Gemma 2B already exists at {GEMMA_OUT}. Skipping.")
else:
    print("Downloading Gemma 2B Q4_K_M GGUF format from HuggingFace...")
    # Directly download the quantized GGUF, which is cross-platform and reliable
    url = "https://huggingface.co/lmstudio-community/gemma-2b-it-GGUF/resolve/main/gemma-2b-it-Q4_K_M.gguf"
    urllib.request.urlretrieve(url, GEMMA_OUT)

gemma_size_mb = GEMMA_OUT.stat().st_size / (1024 * 1024)
print(f"Gemma 2B size on disk: {gemma_size_mb:.1f} MB")
print("Estimated RAM usage: ~2.5 GB")
print("Flutter Plugin: tflite_flutter / local llama runner plugins")

# -------------------------------------------------------------------------
# 2. WHISPER TINY MULTILINGUAL
# -------------------------------------------------------------------------
print("\n[2] Setting up Whisper Tiny Multilingual...")
WHISPER_OUT = MODELS_DIR / "whisper-tiny-multilingual.bin"

if WHISPER_OUT.exists():
    print(f"✓ Whisper Tiny already exists at {WHISPER_OUT}. Skipping.")
else:
    print("Downloading Whisper Tiny GGML format from HuggingFace (whisper.cpp compatible)...")
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-tiny.bin"
    urllib.request.urlretrieve(url, WHISPER_OUT)

whisper_size_mb = WHISPER_OUT.stat().st_size / (1024 * 1024)
print(f"Whisper Tiny size on disk: {whisper_size_mb:.1f} MB")
print("Estimated RAM usage: ~150 MB")
print("Flutter Plugin: whisper_flutter / flutter_whisper")

# -------------------------------------------------------------------------
# 3. NLLB-200 DISTILLED 600M (Translation)
# -------------------------------------------------------------------------
print("\n[3] Setting up NLLB-200 Distilled 600M...")
NLLB_DIR = MODELS_DIR / "nllb-200"

if NLLB_DIR.exists() and any(NLLB_DIR.iterdir()):
    print(f"✓ NLLB-200 already exists at {NLLB_DIR}. Skipping.")
else:
    print("Downloading NLLB-200 via HuggingFace Hub...")
    try:
        from huggingface_hub import snapshot_download
        from transformers import AutoModelForSeq2SeqLM, AutoTokenizer
        
        snapshot_download(repo_id="facebook/nllb-200-distilled-600M", local_dir=NLLB_DIR)
        
        print("Testing Translation...")
        tokenizer = AutoTokenizer.from_pretrained(NLLB_DIR, src_lang="eng_Latn")
        model = AutoModelForSeq2SeqLM.from_pretrained(NLLB_DIR)
        
        text = "Hello, this is a test of the translation model."
        for target_lang, lang_code in [("Hindi", "hin_Deva"), ("Marathi", "mar_Deva"), ("Tamil", "tam_Taml")]:
            inputs = tokenizer(text, return_tensors="pt")
            translated_tokens = model.generate(**inputs, forced_bos_token_id=tokenizer.lang_code_to_id[lang_code], max_length=30)
            translation = tokenizer.batch_decode(translated_tokens, skip_special_tokens=True)[0]
            print(f"English -> {target_lang}: {translation}")
            
    except ImportError:
        print("Required packages for NLLB not found. Installing them via pip...")
        subprocess.check_call(["pip", "install", "huggingface_hub", "transformers", "torch"])
        print("Please rerun this script to complete the NLLB download.")

# Calculate NLLB dir size
nllb_size = sum(f.stat().st_size for f in NLLB_DIR.rglob('*') if f.is_file()) if NLLB_DIR.exists() else 0
nllb_size_mb = nllb_size / (1024 * 1024)
print(f"NLLB-200 size on disk: {nllb_size_mb:.1f} MB")
print("Estimated RAM usage: ~1.2 GB")
print("Flutter Plugin: onnxruntime / pytorch_lite (or accessed via local python backend)")

print("\n" + "="*50)
print("  SETUP COMPLETE")
print("="*50)
print(f"All offline models have been downloaded to {MODELS_DIR.absolute()}")
