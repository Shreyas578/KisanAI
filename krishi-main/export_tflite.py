"""
export_tflite.py
================
Converts the best saved .keras model to TensorFlow Lite with
post-training quantization (DEFAULT optimizations) and verifies it
by running inference on 5 random test images.

Usage:
    python export_tflite.py --output_dir outputs --dataset_root D:/Projects/Krishi
"""

import os
import random
import argparse
import numpy as np
from PIL import Image

import tensorflow as tf
from tensorflow import keras

from dataset_merge import collect_images

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
parser = argparse.ArgumentParser(description="Export Keras model → TFLite")
parser.add_argument("--output_dir",   type=str, default="outputs",
                    help="Folder containing best_model.keras and class_labels.txt")
parser.add_argument("--dataset_root", type=str, required=True,
                    help="Dataset root (needed for verification on real images)")
parser.add_argument("--img_size",     type=int, default=224)
args = parser.parse_args()

BEST_MODEL  = os.path.join(args.output_dir, "best_model.keras")
TFLITE_PATH = os.path.join(args.output_dir, "crop_disease_model.tflite")
LABELS_PATH = os.path.join(args.output_dir, "class_labels.txt")

# ---------------------------------------------------------------------------
# 1. Load class labels
# ---------------------------------------------------------------------------
print("\n[STEP 1] Loading class labels …")
with open(LABELS_PATH, "r") as f:
    class_names = [line.strip() for line in f.readlines()]
print(f"  Found {len(class_names)} classes")

# ---------------------------------------------------------------------------
# 2. Load the best Keras model
# ---------------------------------------------------------------------------
print("[STEP 2] Loading best_model.keras …")
model = keras.models.load_model(BEST_MODEL)
model.summary(line_length=80)

# ---------------------------------------------------------------------------
# 3. Convert to TFLite with post-training quantization
# ---------------------------------------------------------------------------
print("[STEP 3] Converting to TFLite with DEFAULT quantization …")
converter = tf.lite.TFLiteConverter.from_keras_model(model)

# DEFAULT optimizations = dynamic-range quantization:
#   - Weights stored as int8  (saves ~4×)
#   - Activations computed in float32 at runtime
#   - No representative dataset needed
converter.optimizations = [tf.lite.Optimize.DEFAULT]

tflite_model = converter.convert()

with open(TFLITE_PATH, "wb") as f:
    f.write(tflite_model)

tflite_size_mb = os.path.getsize(TFLITE_PATH) / (1024 * 1024)
keras_size_mb  = os.path.getsize(BEST_MODEL)  / (1024 * 1024)
print(f"  Keras model size  : {keras_size_mb:.2f} MB")
print(f"  TFLite model size : {tflite_size_mb:.2f} MB  "
      f"({100*(1-tflite_size_mb/keras_size_mb):.0f}% size reduction)")
print(f"  Saved → {TFLITE_PATH}")

# ---------------------------------------------------------------------------
# 4. Verify the TFLite model on 5 random test images
# ---------------------------------------------------------------------------
print("\n[STEP 4] Verifying TFLite model on 5 random images …")

# Collect dataset to get real images with labels
image_paths, labels_all, _ = collect_images(args.dataset_root)
label2idx  = {name: i for i, name in enumerate(class_names)}
label_ids  = [label2idx[l] for l in labels_all]

# Pick 5 random images
sample_idx = random.sample(range(len(image_paths)), 5)

# Load TFLite interpreter
interpreter = tf.lite.Interpreter(model_path=TFLITE_PATH)
interpreter.allocate_tensors()

input_details  = interpreter.get_input_details()
output_details = interpreter.get_output_details()
IMG_SIZE = (args.img_size, args.img_size)

print(f"\n  {'#':<3}  {'Actual Class':<45}  {'Predicted Class':<45}  {'Confidence':>10}  {'Correct?':>8}")
print("  " + "-"*120)

for rank, idx in enumerate(sample_idx):
    path   = image_paths[idx]
    actual = class_names[label_ids[idx]]

    # Preprocess
    img = Image.open(path).convert("RGB").resize(IMG_SIZE)
    inp = np.array(img, dtype=np.float32)[np.newaxis, ...]  # Expected range [0, 255]

    # Run inference
    interpreter.set_tensor(input_details[0]["index"], inp)
    interpreter.invoke()
    probs = interpreter.get_tensor(output_details[0]["index"])[0]

    pred_idx    = int(np.argmax(probs))
    pred_class  = class_names[pred_idx]
    confidence  = float(probs[pred_idx])
    correct     = "✓" if pred_class == actual else "✗"

    print(f"  {rank+1:<3}  {actual:<45}  {pred_class:<45}  {confidence:>9.1%}  {correct:>8}")

print("\n[DONE] TFLite export and verification complete!")
print(f"  TFLite model : {TFLITE_PATH}")
print(f"  Class labels : {LABELS_PATH}")
print(f"\nNext step: open frontend/index.html in a browser to test the UI.")
