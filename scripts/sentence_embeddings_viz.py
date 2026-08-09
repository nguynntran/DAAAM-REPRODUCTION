import sys
import glob
import yaml
import numpy as np
import matplotlib.pyplot as plt
from pathlib import Path

def main():
    ann_dir = sys.argv[1]
    out_dir = Path(sys.argv[2])
    out_dir.mkdir(parents=True, exist_ok=True)

    descriptions = []
    semantic_ids = []
    for f in sorted(glob.glob(f"{ann_dir}/*.yaml")):
        with open(f) as fh:
            data = yaml.safe_load(fh)
        for ann in data.get("annotations", []):
            if not ann.get("is_full_image", False):
                descriptions.append(ann["description"])
                semantic_ids.append(ann["semantic_id"])

    print(f"collected {len(descriptions)} descriptions")

    from sentence_transformers import SentenceTransformer
    model_name = "sentence-transformers/all-MiniLM-L6-v2"
    model = SentenceTransformer(model_name)
    embeddings = model.encode(descriptions, show_progress_bar=True)
    print(f"embedding dim: {embeddings.shape[1]}")
    print(f"n embeddings: {embeddings.shape[0]}")

    from sklearn.decomposition import PCA
    pca = PCA(n_components=2, random_state=0)
    proj = pca.fit_transform(embeddings)
    explained = pca.explained_variance_ratio_
    print(f"PCA explained variance: {explained[0]:.3f} + {explained[1]:.3f} = {sum(explained):.3f}")

    fig, ax = plt.subplots(figsize=(10, 8))
    unique_ids = sorted(set(semantic_ids))
    cmap = plt.colormaps.get_cmap("tab20")
    id_to_color = {sid: cmap(i) for i, sid in enumerate(unique_ids)}
    for sid in unique_ids:
        idxs = [i for i, s in enumerate(semantic_ids) if s == sid]
        ax.scatter(proj[idxs, 0], proj[idxs, 1], label=f"id={sid}",
                   color=id_to_color[sid], s=40, alpha=0.8)
    ax.set_title(f"2D PCA of {model_name} embeddings, n={len(descriptions)}, "
                 f"dim={embeddings.shape[1]}, explained_var={sum(explained):.2f}")
    ax.set_xlabel("PC1")
    ax.set_ylabel("PC2")
    if len(unique_ids) <= 20:
        ax.legend(fontsize=6, ncol=2, loc="best")
    plt.tight_layout()
    out_path = out_dir / "sentence_embeddings_pca.png"
    plt.savefig(out_path, dpi=150)
    print(f"saved plot to {out_path}")

    with open(out_dir / "sentence_embeddings_stats.txt", "w") as f:
        f.write(f"Model: {model_name}\n")
        f.write(f"Descriptions embedded: {len(descriptions)}\n")
        f.write(f"Embedding dimensionality: {embeddings.shape[1]}\n")
        f.write(f"PCA 2D explained variance: {sum(explained):.4f}\n")
        f.write(f"Unique tracked objects: {len(unique_ids)}\n")

if __name__ == "__main__":
    main()
