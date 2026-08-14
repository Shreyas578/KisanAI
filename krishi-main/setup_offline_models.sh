#!/bin/bash
# setup_offline_models.sh
# Downloads and prepares offline AI models (Gemma 2B, Whisper Tiny, NLLB-200) for the Flutter app.
# Run this script to download them to ./offline_models directory.

set -e

# Base directory for models
MODELS_DIR="./offline_models"
mkdir -p "$MODELS_DIR"

echo "=================================================="
echo "  OFFLINE MODEL SETUP SCRIPT"
echo "=================================================="

# Check for required tools
for cmd in python3 pip3 wget git; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed."
        exit 1
    fi
done

# -------------------------------------------------------------------------
# 1. GEMMA 2B (from Ollama to GGUF)
# -------------------------------------------------------------------------
echo -e "\n[1] Setting up Gemma 2B..."
GEMMA_OUT="$MODELS_DIR/gemma2b-q4.gguf"

if [ -f "$GEMMA_OUT" ]; then
    echo "✓ Gemma 2B already exists at $GEMMA_OUT. Skipping."
else
    echo "Downloading llama.cpp for conversion..."
    if [ ! -d "$MODELS_DIR/llama.cpp" ]; then
        git clone https://github.com/ggerganov/llama.cpp "$MODELS_DIR/llama.cpp"
        cd "$MODELS_DIR/llama.cpp"
        pip3 install -r requirements.txt
        make
        cd ../..
    fi

    # Assuming Ollama stores the models in default paths
    # Note: Exporting from Ollama blobs directly requires specific handling depending on the OS
    # As an alternative that always works cross-platform, we download the GGUF directly from huggingface
    echo "Downloading Gemma 2B Q4_K_M GGUF format..."
    wget -nc -O "$GEMMA_OUT" "https://huggingface.co/lmstudio-community/gemma-2b-it-GGUF/resolve/main/gemma-2b-it-Q4_K_M.gguf"
fi

GEMMA_SIZE=$(ls -lh "$GEMMA_OUT" | awk '{print $5}')
echo "Gemma 2B size on disk: $GEMMA_SIZE"
echo "Estimated RAM usage: ~2.5 GB"
echo "Flutter Plugin: tflite_flutter / local llama runner plugins"

# -------------------------------------------------------------------------
# 2. WHISPER TINY MULTILINGUAL
# -------------------------------------------------------------------------
echo -e "\n[2] Setting up Whisper Tiny Multilingual..."
WHISPER_OUT="$MODELS_DIR/whisper-tiny-multilingual.bin"

if [ -f "$WHISPER_OUT" ]; then
    echo "✓ Whisper Tiny already exists at $WHISPER_OUT. Skipping."
else
    echo "Downloading whisper.cpp..."
    if [ ! -d "$MODELS_DIR/whisper.cpp" ]; then
        git clone https://github.com/ggerganov/whisper.cpp "$MODELS_DIR/whisper.cpp"
    fi
    cd "$MODELS_DIR/whisper.cpp"
    echo "Running whisper.cpp conversion/download script..."
    bash ./models/download-ggml-model.sh tiny
    cp ./models/ggml-tiny.bin "../whisper-tiny-multilingual.bin"
    cd ../..
fi

WHISPER_SIZE=$(ls -lh "$WHISPER_OUT" | awk '{print $5}')
echo "Whisper Tiny size on disk: $WHISPER_SIZE"
echo "Estimated RAM usage: ~150 MB"
echo "Flutter Plugin: whisper_flutter / flutter_whisper"

# -------------------------------------------------------------------------
# 3. NLLB-200 DISTILLED 600M (Translation)
# -------------------------------------------------------------------------
echo -e "\n[3] Setting up NLLB-200 Distilled 600M..."
NLLB_DIR="$MODELS_DIR/nllb-200"

if [ -d "$NLLB_DIR" ] && [ "$(ls -A $NLLB_DIR)" ]; then
    echo "✓ NLLB-200 already exists at $NLLB_DIR. Skipping."
else
    echo "Downloading NLLB-200 Distilled 600M via Python huggingface_hub..."
    pip3 install huggingface_hub transformers torch
    python3 -c "
from huggingface_hub import snapshot_download
from transformers import AutoModelForSeq2SeqLM, AutoTokenizer
model_id = 'facebook/nllb-200-distilled-600M'
save_dir = '$NLLB_DIR'
print('Downloading to', save_dir)
snapshot_download(repo_id=model_id, local_dir=save_dir)
print('Testing Translation...')
tokenizer = AutoTokenizer.from_pretrained(save_dir, src_lang='eng_Latn')
model = AutoModelForSeq2SeqLM.from_pretrained(save_dir)

text = 'Hello, this is a test of the translation model.'

for target_lang, lang_code in [('Hindi', 'hin_Deva'), ('Marathi', 'mar_Deva'), ('Tamil', 'tam_Taml')]:
    inputs = tokenizer(text, return_tensors='pt')
    translated_tokens = model.generate(**inputs, forced_bos_token_id=tokenizer.lang_code_to_id[lang_code], max_length=30)
    translation = tokenizer.batch_decode(translated_tokens, skip_special_tokens=True)[0]
    print(f'English -> {target_lang}: {translation}')
"
fi

NLLB_SIZE=$(du -sh "$NLLB_DIR" | awk '{print $1}')
echo "NLLB-200 size on disk: $NLLB_SIZE"
echo "Estimated RAM usage: ~1.2 GB"
echo "Flutter Plugin: onnxruntime / pytorch_lite (or accessed via local python backend)"

# -------------------------------------------------------------------------
# SUMMARY
# -------------------------------------------------------------------------
echo -e "\n=================================================="
echo "  SETUP COMPLETE"
echo "=================================================="
echo "All offline models have been downloaded to $MODELS_DIR"
