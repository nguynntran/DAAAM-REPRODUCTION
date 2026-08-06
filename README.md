# DAAAM Reproduction — Test Assignment

Reproducing the DAAAM (Describe Anything, Anywhere, at Any Moment) pipeline on a
motion-verified subset of the CODa dataset, via the official ROS 2 Jazzy + DAAAM-ROS workflow.

**Full report (Google Doc):** [FILL IN link]

## Environment

| Component | Value |
|---|---|
| Provider | RunPod, RTX 4090 (24GB VRAM) |
| OS | Ubuntu 24.04 |
| CUDA / PyTorch | 12.8.1 / 2.8.0 |
| ROS 2 | Jazzy |
| DAAAM commit | `[FILL IN]` |
| DAAAM-ROS commit | `[FILL IN]` |
| Hydra / Spark-DSG commit | `[FILL IN]` |
| FoundationStereo fork | [nicogorlo/FoundationStereo](https://github.com/nicogorlo/FoundationStereo), commit `[FILL IN]` |

Full dependency list: `requirements-frozen.txt`, `environment-coda.yml`.

## Setup

```bash
# 1. After every fresh pod boot — reinstalls ROS 2/rosdep/colcon/conda-init/git-config,
#    all of which live on the ephemeral container disk, not the persistent volume
bash scripts/post_boot_setup.sh

# 2. Build the DAAAM ROS 2 workspace (see main repo's install.sh)
# 3. Apply the open3d patch before running FoundationStereo
python scripts/patch_open3d_ml_import.py
```

## Data

CODa sequence 0, frames **2000–2399** (400 frames, ~40s at 10Hz). Range chosen after
inspecting the pose trajectory — this window shows sustained, consistent motion
(~9m/100 frames), avoiding a near-stationary segment later in the sequence. Full
rationale and evidence in the report, section 4.

```bash
scripts/prepare_coda_subset.sh   # extracts the above range from a full CODa download
```

## Running

**Depth estimation:**
```bash
cd FoundationStereo
python scripts/run_coda_depth_estimation.py \
  --dataset_folder /workspace/CODa_subset \
  --sequence_id 0 \
  --ckpt_dir ./pretrained_models/23-51-11/model_best_bp2.pth \
  --save_format png
```

**Bag creation + run:** `[FILL IN once finalized]`

**Smoke test** (short range, fast iteration): `[FILL IN]`
**Full run:** `[FILL IN]`

## Troubleshooting

Full details with root-cause analysis in the report (section 8). Highlights:
- ROS 2 apt repo, `rosdep`, and `colcon` all live on the pod's ephemeral container
  disk and must be reinstalled after every restart — see `scripts/post_boot_setup.sh`.
- `spark_dsg` and `daaam_ros` both required re-cloning due to incomplete initial clones.
- `open3d` unconditionally imports an unrelated ML-benchmark submodule at load time —
  patched via `scripts/patch_open3d_ml_import.py`.
- FoundationStereo's `requirements.txt` is missing several transitive dependencies
  (`tqdm`, `natsort`, `pandas`, `open3d`'s own extras); installed as surfaced.

## Repository contents

- `scripts/prepare_coda_subset.sh` — CODa subset extraction
- `scripts/patch_open3d_ml_import.py` — open3d import fix
- `scripts/post_boot_setup.sh` — pod environment reinit
- `logs/` — full install/setup logs
- `requirements-frozen.txt`, `environment-coda.yml` — dependency lock files
