"""
dataset_merge.py
================
Responsible for:
  1. Scanning PlantVillage (38 classes) and PlantDoc (28 classes) folders.
  2. Building a canonical class-name mapping so overlapping concepts share
     a single unified label.
  3. Returning (image_paths, labels, class_names) ready for tf.data ingestion.

Run standalone to inspect the merged label set:
    python dataset_merge.py --dataset_root D:/Projects/Krishi
"""

import os
import argparse

# ---------------------------------------------------------------------------
# CANONICAL MAPPING
# ---------------------------------------------------------------------------
# PlantDoc uses human-readable names like "Tomato Early blight leaf".
# PlantVillage uses snake_case like "Tomato___Early_blight".
# We map BOTH to a single canonical label string.
# Keys = PlantDoc folder names (lowercased)
# Values = canonical label (used as the unified class name throughout training)

PLANTDOC_TO_CANONICAL = {
    # Apple
    "apple scab leaf":                          "Apple___Apple_scab",
    "apple leaf":                               "Apple___healthy",
    "apple rust leaf":                          "Apple___Cedar_apple_rust",
    # Bell pepper
    "bell_pepper leaf":                         "Pepper,_bell___healthy",
    "bell_pepper leaf spot":                    "Pepper,_bell___Bacterial_spot",
    # Blueberry
    "blueberry leaf":                           "Blueberry___healthy",
    # Cherry
    "cherry leaf":                              "Cherry_(including_sour)___healthy",
    # Corn
    "corn gray leaf spot":                      "Corn_(maize)___Cercospora_leaf_spot Gray_leaf_spot",
    "corn leaf blight":                         "Corn_(maize)___Northern_Leaf_Blight",
    "corn rust leaf":                           "Corn_(maize)___Common_rust_",
    # Peach
    "peach leaf":                               "Peach___healthy",
    # Potato
    "potato leaf early blight":                 "Potato___Early_blight",
    "potato leaf late blight":                  "Potato___Late_blight",
    # Raspberry
    "raspberry leaf":                           "Raspberry___healthy",
    # Soybean
    "soyabean leaf":                            "Soybean___healthy",
    # Squash
    "squash powdery mildew leaf":               "Squash___Powdery_mildew",
    # Strawberry
    "strawberry leaf":                          "Strawberry___healthy",
    # Tomato
    "tomato early blight leaf":                 "Tomato___Early_blight",
    "tomato septoria leaf spot":                "Tomato___Septoria_leaf_spot",
    "tomato leaf":                              "Tomato___healthy",
    "tomato leaf bacterial spot":               "Tomato___Bacterial_spot",
    "tomato leaf late blight":                  "Tomato___Late_blight",
    "tomato leaf mosaic virus":                 "Tomato___Tomato_mosaic_virus",
    "tomato leaf yellow virus":                 "Tomato___Tomato_Yellow_Leaf_Curl_Virus",
    "tomato mold leaf":                         "Tomato___Leaf_Mold",
    "tomato two spotted spider mites leaf":     "Tomato___Spider_mites Two-spotted_spider_mite",
    # Grape
    "grape leaf":                               "Grape___healthy",
    "grape leaf black rot":                     "Grape___Black_rot",
}
# NOTE: PlantDoc classes NOT in PlantVillage (no match found):
#   None – all 28 PlantDoc classes map to a PlantVillage equivalent above.
#   PlantVillage-only classes that PlantDoc doesn't cover are kept as-is.


def collect_images(dataset_root: str):
    """
    Scan both dataset folders, apply the canonical mapping, and return:
      - image_paths : list[str]  – absolute paths to every image file
      - labels      : list[str]  – canonical class name for each image
      - class_names : list[str]  – sorted list of unique class names (index = model output index)
    """
    pv_root   = os.path.join(dataset_root, "PlantVillage")
    pv_train  = os.path.join(pv_root, "train")
    pd_root   = os.path.join(dataset_root, "PlantDoc-Dataset-master")
    pd_train  = os.path.join(pd_root, "train")
    pd_test   = os.path.join(pd_root, "test")

    IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".bmp", ".JPG", ".JPEG", ".PNG"}

    image_paths: list[str] = []
    labels:      list[str] = []

    # -----------------------------------------------------------------------
    # 1. Ingest PlantVillage (train + val folders both used; we re-split later)
    # -----------------------------------------------------------------------
    for split in ("train", "val"):
        split_dir = os.path.join(pv_root, split)
        if not os.path.isdir(split_dir):
            print(f"[WARN] PlantVillage split not found: {split_dir}")
            continue
        for class_folder in sorted(os.listdir(split_dir)):
            class_path = os.path.join(split_dir, class_folder)
            if not os.path.isdir(class_path):
                continue
            canonical = class_folder  # PV class names ARE the canonical names
            for fname in os.listdir(class_path):
                if os.path.splitext(fname)[1] in IMAGE_EXTS:
                    image_paths.append(os.path.join(class_path, fname))
                    labels.append(canonical)

    # -----------------------------------------------------------------------
    # 2. Ingest PlantDoc (train + test splits)
    # -----------------------------------------------------------------------
    for split_dir in (pd_train, pd_test):
        if not os.path.isdir(split_dir):
            print(f"[WARN] PlantDoc split not found: {split_dir}")
            continue
        for class_folder in sorted(os.listdir(split_dir)):
            class_path = os.path.join(split_dir, class_folder)
            if not os.path.isdir(class_path):
                continue
            key = class_folder.lower()
            canonical = PLANTDOC_TO_CANONICAL.get(key, class_folder)  # fallback = raw name
            if key not in PLANTDOC_TO_CANONICAL:
                print(f"[WARN] PlantDoc class '{class_folder}' has no explicit mapping – keeping as-is")
            for fname in os.listdir(class_path):
                if os.path.splitext(fname)[1] in IMAGE_EXTS:
                    image_paths.append(os.path.join(class_path, fname))
                    labels.append(canonical)

    # -----------------------------------------------------------------------
    # 3. Build sorted class list (this ordering MUST match class_labels.txt)
    # -----------------------------------------------------------------------
    class_names = sorted(set(labels))

    print(f"\n{'='*60}")
    print(f"  MERGED DATASET SUMMARY")
    print(f"{'='*60}")
    print(f"  Total images : {len(image_paths):,}")
    print(f"  Total classes: {len(class_names)}")
    print(f"\n  CLASS LIST (index → canonical name):")
    for idx, name in enumerate(class_names):
        count = labels.count(name)
        print(f"    [{idx:02d}]  {name:<55} ({count} images)")
    print(f"{'='*60}\n")

    return image_paths, labels, class_names


# ---------------------------------------------------------------------------
# CLI entry-point – run standalone to inspect the merged label set
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Dataset merge inspector")
    parser.add_argument("--dataset_root", type=str, required=True,
                        help="Root folder containing PlantVillage/ and PlantDoc-Dataset-master/")
    args = parser.parse_args()
    collect_images(args.dataset_root)
