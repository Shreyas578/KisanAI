"""
train.py
========
End-to-end training pipeline for the Crop Disease Detection model.

Usage:
    python train.py --dataset_root D:/Projects/Krishi

What this script does:
  1. Merges PlantVillage + PlantDoc images into a unified dataset.
  2. Builds a fast tf.data pipeline with augmentation.
  3. Trains MobileNetV3-Small in two phases (feature extraction → fine-tuning).
  4. Saves the best model, plots, confusion matrix, and classification report.
  5. Prints a final summary with accuracy, model size, and class count.
"""

import os
import argparse
import random
import time
import numpy as np
import matplotlib
matplotlib.use("Agg")          # non-interactive backend – safe for servers
import matplotlib.pyplot as plt
import seaborn as sns
from tqdm import tqdm
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, confusion_matrix
from sklearn.utils.class_weight import compute_class_weight

# ── TensorFlow ─────────────────────────────────────────────────────────────
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

# ── Our merge helper ───────────────────────────────────────────────────────
from dataset_merge import collect_images

# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------
parser = argparse.ArgumentParser(description="Crop Disease Classifier – Training")
parser.add_argument("--dataset_root", type=str, required=True,
                    help="Root folder containing PlantVillage/ and PlantDoc-Dataset-master/")
parser.add_argument("--output_dir", type=str, default="outputs",
                    help="Where to save models, plots, etc.")
parser.add_argument("--batch_size", type=int, default=32)
parser.add_argument("--phase1_epochs", type=int, default=7,
                    help="Feature-extraction epochs (frozen base)")
parser.add_argument("--phase2_epochs", type=int, default=13,
                    help="Fine-tuning epochs (last 30 layers unfrozen)")
parser.add_argument("--img_size", type=int, default=224)
parser.add_argument("--seed", type=int, default=42)
args = parser.parse_args()

# ---------------------------------------------------------------------------
# 0. Reproducibility + GPU setup
# ---------------------------------------------------------------------------
random.seed(args.seed)
np.random.seed(args.seed)
tf.random.set_seed(args.seed)

print("\n" + "="*60)
print("  CROP DISEASE DETECTION – TRAINING SCRIPT")
print("="*60)

# Auto-detect GPU; fall back to CPU gracefully
gpus = tf.config.list_physical_devices("GPU")
if gpus:
    try:
        for gpu in gpus:
            tf.config.experimental.set_memory_growth(gpu, True)
        print(f"[GPU] Found {len(gpus)} GPU(s) – training on GPU ✓")
    except RuntimeError as e:
        print(f"[GPU] Memory-growth setup failed: {e}")
else:
    print("[CPU] No GPU detected – training on CPU (will be slow but works)")

os.makedirs(args.output_dir, exist_ok=True)

IMG_SIZE   = (args.img_size, args.img_size)
BATCH      = args.batch_size
AUTOTUNE   = tf.data.AUTOTUNE
BEST_MODEL = os.path.join(args.output_dir, "best_model.keras")

# ---------------------------------------------------------------------------
# 1. Collect & merge dataset
# ---------------------------------------------------------------------------
print("\n[STEP 1] Collecting images from both datasets …")
image_paths, labels, class_names = collect_images(args.dataset_root)
num_classes = len(class_names)

# Convert string labels → integer indices
label2idx = {name: i for i, name in enumerate(class_names)}
label_ids = [label2idx[l] for l in labels]

# ---------------------------------------------------------------------------
# 2. Train / Val / Test split  (80 / 10 / 10)
# ---------------------------------------------------------------------------
print("[STEP 2] Splitting into train / val / test …")
X_tmp, X_test, y_tmp, y_test = train_test_split(
    image_paths, label_ids,
    test_size=0.10, random_state=args.seed, stratify=label_ids
)
X_train, X_val, y_train, y_val = train_test_split(
    X_tmp, y_tmp,
    test_size=0.111,  # 0.111 × 0.90 ≈ 0.10 of total
    random_state=args.seed, stratify=y_tmp
)
print(f"  Train : {len(X_train):,} images")
print(f"  Val   : {len(X_val):,}   images")
print(f"  Test  : {len(X_test):,}  images")

# ---------------------------------------------------------------------------
# 3. Class weights for imbalance handling
# ---------------------------------------------------------------------------
print("[STEP 3] Computing class weights …")
cw_array = compute_class_weight("balanced",
                                 classes=np.arange(num_classes),
                                 y=np.array(y_train))
class_weight_dict = {i: float(w) for i, w in enumerate(cw_array)}
print(f"  Class weight range: {min(cw_array):.3f} – {max(cw_array):.3f}")

# ---------------------------------------------------------------------------
# 4. tf.data pipeline helpers
# ---------------------------------------------------------------------------
print("[STEP 4] Building tf.data pipelines …")

def load_and_preprocess(path, label):
    """Read JPEG/PNG → decode → resize."""
    raw = tf.io.read_file(path)
    img = tf.image.decode_image(raw, channels=3, expand_animations=False)
    img = tf.image.resize(img, IMG_SIZE)
    img = tf.cast(img, tf.float32)  # MobileNetV3 built-in preprocessing expects [0, 255]
    return img, label

# Augmentation layers – applied ONLY on the training set
augment = keras.Sequential([
    layers.RandomFlip("horizontal_and_vertical"),
    layers.RandomRotation(0.083),          # 30° = 30/360 ≈ 0.083
    layers.RandomZoom(0.20),
    layers.RandomBrightness(0.20),
    layers.RandomContrast(0.20),
    # Saturation shift via random hue ≈ saturation effect for real-world imgs
    layers.Lambda(lambda x: tf.image.random_saturation(x, 0.8, 1.2)),
], name="augmentation")

def make_dataset(paths, labels, training=False):
    """Build a fast, cached, prefetched tf.data.Dataset."""
    ds = tf.data.Dataset.from_tensor_slices((paths, labels))
    ds = ds.map(load_and_preprocess, num_parallel_calls=AUTOTUNE)
    if training:
        ds = ds.shuffle(buffer_size=min(1000, len(paths)), seed=args.seed)
    ds = ds.batch(BATCH)
    if training:
        # Apply augmentation after batching (faster on GPU)
        ds = ds.map(lambda x, y: (augment(x, training=True), y),
                    num_parallel_calls=AUTOTUNE)
    # Removed ds.cache() here because caching 45,000+ 224x224 images takes ~27GB of RAM and causes the process to crash silently (OOM).
    ds = ds.prefetch(AUTOTUNE)
    return ds

train_ds = make_dataset(X_train, y_train, training=True)
val_ds   = make_dataset(X_val,   y_val,   training=False)
test_ds  = make_dataset(X_test,  y_test,  training=False)

# ---------------------------------------------------------------------------
# 5. Model construction
# ---------------------------------------------------------------------------
print("[STEP 5] Building MobileNetV3-Small model …")

def build_model(num_classes: int, img_size=(224, 224)):
    """
    MobileNetV3-Small (ImageNet pretrained) + custom classification head.
    We use include_preprocessing=True so the model handles normalization
    internally when used standalone; during training we pass [0,1] images
    which MobileNetV3 pre-processing expects anyway.
    """
    base = keras.applications.MobileNetV3Small(
        input_shape=(*img_size, 3),
        include_top=False,
        weights="imagenet",
        include_preprocessing=True,  # applies built-in rescaling/normalization
    )
    # Phase 1: freeze the entire base
    base.trainable = False

    inputs = keras.Input(shape=(*img_size, 3), name="image_input")
    x = base(inputs, training=False)
    x = layers.GlobalAveragePooling2D(name="gap")(x)
    x = layers.Dense(256, activation="relu", name="dense_256")(x)
    x = layers.Dropout(0.4, name="dropout")(x)
    outputs = layers.Dense(num_classes, activation="softmax", name="predictions")(x)

    model = keras.Model(inputs, outputs, name="CropDisease_MobileNetV3Small")
    return model, base

model, base_model = build_model(num_classes)
model.summary(line_length=90)
print(f"\n  Total parameters    : {model.count_params():,}")
print(f"  Trainable params    : {sum(p.numpy().size for p in model.trainable_weights):,}")

# ---------------------------------------------------------------------------
# 6. Metrics
# ---------------------------------------------------------------------------
top3_acc = keras.metrics.SparseTopKCategoricalAccuracy(k=3, name="top3_accuracy")

# ---------------------------------------------------------------------------
# 7. Callbacks (shared across both phases)
# ---------------------------------------------------------------------------
def make_callbacks(monitor="val_accuracy"):
    checkpoint = keras.callbacks.ModelCheckpoint(
        filepath=BEST_MODEL,
        monitor=monitor,
        save_best_only=True,
        verbose=1,
        mode="max",
    )
    early_stop = keras.callbacks.EarlyStopping(
        monitor=monitor,
        patience=5,
        restore_best_weights=True,
        verbose=1,
    )
    reduce_lr = keras.callbacks.ReduceLROnPlateau(
        monitor=monitor,
        factor=0.3,
        patience=3,
        min_lr=1e-7,
        verbose=1,
    )
    csv_log = keras.callbacks.CSVLogger(
        os.path.join(args.output_dir, "training_log.csv"),
        append=True,
    )
    return [checkpoint, early_stop, reduce_lr, csv_log]

# ---------------------------------------------------------------------------
# 8. Phase 1 – Feature extraction (frozen base, only top layers trained)
# ---------------------------------------------------------------------------
print("\n" + "="*60)
print("  PHASE 1 – Feature Extraction (base frozen)")
print("  Epochs : up to", args.phase1_epochs)
print("  LR     : 1e-3")
print("="*60)

model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=1e-3),
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy", top3_acc],
)

t0 = time.time()
history1 = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=args.phase1_epochs,
    class_weight=class_weight_dict,
    callbacks=make_callbacks(),
    verbose=1,
)
print(f"  Phase 1 completed in {(time.time()-t0)/60:.1f} min")

# ---------------------------------------------------------------------------
# 9. Phase 2 – Fine-tuning (unfreeze last 30 layers of base)
# ---------------------------------------------------------------------------
print("\n" + "="*60)
print("  PHASE 2 – Fine-tuning (last 30 layers of base unfrozen)")
print("  Epochs : up to", args.phase2_epochs)
print("  LR     : 1e-5")
print("="*60)

# Unfreeze only the last 30 layers of the base model to avoid
# destroying the low-level ImageNet features learned earlier.
base_model.trainable = True
for layer in base_model.layers[:-30]:
    layer.trainable = False

trainable_count = sum(1 for l in base_model.layers if l.trainable)
print(f"  Unfrozen base layers: {trainable_count} / {len(base_model.layers)}")

# Very low LR critical here – avoid catastrophic forgetting
model.compile(
    optimizer=keras.optimizers.Adam(learning_rate=1e-5),
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy", top3_acc],
)

history2 = model.fit(
    train_ds,
    validation_data=val_ds,
    epochs=args.phase1_epochs + args.phase2_epochs,
    initial_epoch=len(history1.history["loss"]),
    class_weight=class_weight_dict,
    callbacks=make_callbacks(),
    verbose=1,
)
print(f"  Phase 2 completed in {(time.time()-t0)/60:.1f} min total")

# ---------------------------------------------------------------------------
# 10. Load best checkpoint & evaluate on test set
# ---------------------------------------------------------------------------
print("\n[STEP 10] Loading best checkpoint …")
best_model = keras.models.load_model(BEST_MODEL)

print("[STEP 10] Evaluating on test set …")
test_loss, test_acc, test_top3 = best_model.evaluate(test_ds, verbose=1)
print(f"  Test Accuracy   : {test_acc*100:.2f}%")
print(f"  Test Top-3 Acc  : {test_top3*100:.2f}%")
print(f"  Test Loss       : {test_loss:.4f}")

# ---------------------------------------------------------------------------
# 11. Classification report
# ---------------------------------------------------------------------------
print("[STEP 11] Generating classification report …")
y_pred_probs = best_model.predict(test_ds, verbose=1)
y_pred       = np.argmax(y_pred_probs, axis=1)
y_true       = np.concatenate([y for _, y in test_ds], axis=0)

report = classification_report(y_true, y_pred,
                                target_names=class_names,
                                zero_division=0)
print("\nCLASSIFICATION REPORT:\n")
print(report)

# Save report to file
with open(os.path.join(args.output_dir, "classification_report.txt"), "w") as f:
    f.write(report)

# ---------------------------------------------------------------------------
# 12. Confusion matrix
# ---------------------------------------------------------------------------
print("[STEP 12] Saving confusion matrix …")
cm = confusion_matrix(y_true, y_pred)

fig_size = max(20, num_classes // 2)
fig, ax = plt.subplots(figsize=(fig_size, fig_size))
sns.heatmap(cm, annot=(num_classes <= 20),  # skip annotations if too many classes
            fmt="d", cmap="YlOrRd",
            xticklabels=class_names, yticklabels=class_names,
            ax=ax, linewidths=0.3)
ax.set_xlabel("Predicted", fontsize=12)
ax.set_ylabel("Actual", fontsize=12)
ax.set_title("Confusion Matrix – Crop Disease Classifier", fontsize=14)
plt.xticks(rotation=90, fontsize=7)
plt.yticks(rotation=0,  fontsize=7)
plt.tight_layout()
cm_path = os.path.join(args.output_dir, "confusion_matrix.png")
plt.savefig(cm_path, dpi=150)
plt.close()
print(f"  Saved → {cm_path}")

# ---------------------------------------------------------------------------
# 13. Training history plot (accuracy + loss)
# ---------------------------------------------------------------------------
print("[STEP 13] Saving training history plot …")

# Merge both phase histories
def merge_hist(h1, h2, key):
    return h1.history.get(key, []) + h2.history.get(key, [])

acc     = merge_hist(history1, history2, "accuracy")
val_acc = merge_hist(history1, history2, "val_accuracy")
loss    = merge_hist(history1, history2, "loss")
val_loss= merge_hist(history1, history2, "val_loss")
epochs  = range(1, len(acc) + 1)

phase_boundary = len(history1.history["loss"])

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))
fig.suptitle("Crop Disease Model – Training History", fontsize=16)

# Accuracy
ax1.plot(epochs, acc,     "b-o", markersize=3, label="Train Accuracy")
ax1.plot(epochs, val_acc, "r-o", markersize=3, label="Val Accuracy")
ax1.axvline(x=phase_boundary, color="gray", linestyle="--", label="Phase 1→2")
ax1.set_title("Accuracy")
ax1.set_xlabel("Epoch")
ax1.set_ylabel("Accuracy")
ax1.legend()
ax1.grid(True, alpha=0.3)

# Loss
ax2.plot(epochs, loss,     "b-o", markersize=3, label="Train Loss")
ax2.plot(epochs, val_loss, "r-o", markersize=3, label="Val Loss")
ax2.axvline(x=phase_boundary, color="gray", linestyle="--", label="Phase 1→2")
ax2.set_title("Loss")
ax2.set_xlabel("Epoch")
ax2.set_ylabel("Loss")
ax2.legend()
ax2.grid(True, alpha=0.3)

plt.tight_layout()
hist_path = os.path.join(args.output_dir, "training_history.png")
plt.savefig(hist_path, dpi=150)
plt.close()
print(f"  Saved → {hist_path}")

# ---------------------------------------------------------------------------
# 14. Save class labels (MUST match model output index order)
# ---------------------------------------------------------------------------
labels_path = os.path.join(args.output_dir, "class_labels.txt")
with open(labels_path, "w") as f:
    for name in class_names:
        f.write(name + "\n")
print(f"  Class labels saved → {labels_path}")

# ---------------------------------------------------------------------------
# 15. Final summary
# ---------------------------------------------------------------------------
model_size_mb = os.path.getsize(BEST_MODEL) / (1024 * 1024)
val_acc_final = max(history1.history["val_accuracy"] + history2.history.get("val_accuracy", []))

print("\n" + "="*60)
print("  TRAINING COMPLETE – FINAL SUMMARY")
print("="*60)
print(f"  Best Val Accuracy  : {val_acc_final*100:.2f}%")
print(f"  Test Accuracy      : {test_acc*100:.2f}%")
print(f"  Test Top-3 Accuracy: {test_top3*100:.2f}%")
print(f"  Number of Classes  : {num_classes}")
print(f"  Best Model Path    : {BEST_MODEL}")
print(f"  Model Size (.keras): {model_size_mb:.1f} MB")
print(f"  Class Labels Path  : {labels_path}")
print("="*60)
print("\nNext step: run export_tflite.py to convert to .tflite")
print("  python export_tflite.py --output_dir", args.output_dir)
