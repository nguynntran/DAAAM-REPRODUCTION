# DAAAM Reproduction — CODa Dataset

Reproduction of the DAAAM (Describe Anything, Anywhere, at Any Moment) pipeline on a
400-frame subset of CODa sequence 0, using the official ROS 2 Jazzy + DAAAM-ROS
workflow. Full write-up: **https://docs.google.com/document/d/1aY1fZZK60wYN0RRbI_gNk5RghVUDT0m2Kb66nqR-hBs/edit?usp=sharing**.

## Status

Pipeline runs end-to-end: depth estimation, segmentation, tracking, assignment, DAM
grounding, and dense semantically-labeled mesh reconstruction all confirmed working.
**Known limitation:** the DSG `OBJECTS` layer is empty in every run — root-caused to a
likely version mismatch between the checked-out Hydra/Khronos config and the built
Hydra source, not fully resolved. Full detail in the report, Task 1.9 and 1.10.

## Prerequisites

- NVIDIA GPU, 24GB+ VRAM, CUDA 12.x
- Ubuntu 24.04, ROS 2 Jazzy
- ~30GB free disk for the workspace/build (container disk, separate from dataset
  storage)

## Quick setup (fresh machine/pod)

```bash
mkdir -p /workspace/ros2_ws/src && cd /workspace/ros2_ws/src
git clone https://github.com/MIT-SPARK/DAAAM.git daaam
bash daaam/install/install.sh   # patched to skip semantic_inference — see patches/

git clone <this-repo-url> daaam-reproduction
bash daaam-reproduction/scripts/full_reinit.sh
```
`full_reinit.sh` is idempotent — safe to re-run after any environment reset (e.g. a
cloud pod migration/restart wipes everything outside a persistent volume).

## Apply this repo's code patches

The following patches must be applied to the upstream `daaam_ros`/`daaam` clones
(not part of `full_reinit.sh`, since they modify vendored source, not dependencies):
```bash
cd /workspace/ros2_ws/src/daaam_ros
git apply /path/to/daaam-reproduction/patches/daaam_ros_fixes_20260807.diff
git apply /path/to/daaam-reproduction/patches/daaam_ros_semantic_integrator_fix.diff
```
See each `.diff` file's accompanying note in the report (Task 1.8) for what it fixes
and why.

## Data preparation (smoke test)

Prepare a small subset first to validate the install quickly:
```bash
python scripts/download_split.py -d ./data -t sequence -se 0
python scripts/run_coda_depth_estimation.py \
  --dataset_folder /workspace/CODa_subset \
  --sequence_id 0 \
  --ckpt_dir ./pretrained_models/23-51-11/model_best_bp2.pth \
  --save_format png
```

## Run — smoke test (short, for fast iteration)

```bash
source /opt/ros/jazzy/setup.bash
source /workspace/ros2_ws/install/setup.bash
cd /workspace/ros2_ws
ros2 launch daaam_ros coda_daaam_hydra.launch.yaml \
  scene:=coda_0_subset sam_model:=fastsam/FastSAM-x.pt --max-frames 50
```
(In a second terminal: `ros2 bag play <bag_path> --qos-profile-overrides-path
~/.tf_overrides.yaml < /dev/null` — see `patches/` for the required `.tf_overrides.yaml`
content, without which playback hangs on a known `rosbag2` QoS bug.)

## Run — full run (used for this reproduction's results)

```bash
source /opt/ros/jazzy/setup.bash
source /workspace/ros2_ws/install/setup.bash
cd /workspace/ros2_ws
ros2 launch daaam_ros coda_daaam_hydra.launch.yaml \
  scene:=coda_0_subset sam_model:=fastsam/FastSAM-x.pt \
  2>&1 | tee launch_run_$(date +%Y%m%d_%H%M%S).log
```
Full 400-frame CODa subset (sequence 0, frames 2000-2399), bag playback in a second
terminal as above. Expect ~1-2 minutes wall-clock for 400 frames.

## Repository structure

```
scripts/full_reinit.sh          — full environment recovery/setup, idempotent
patches/                        — upstream code changes, one .diff per fix, documented
results/section3_diagrams/      — model/module architecture & logic diagrams + analysis
results/viz_samples/            — per-stage input/output visualization examples
results/run_*/                  — output artifacts from confirmed runs (dsg.json, etc.)
requirements-frozen.txt         — pinned Python dependency versions
environment-coda.yml            — conda environment file
```

## Troubleshooting

See the report's error table (Task 1.8) for 27 documented issues encountered and
fixed, each with root cause and confirmation method. Most common: after any
environment reset, re-run `full_reinit.sh` before attempting to launch.

## Note on `requirements-frozen.txt`

This file reflects the environment as of the initial working setup (2026-08-07).
Several additional pip packages were installed during later debugging sessions
(fully documented in the report's Task 1.8 error table, rows 14-23) but not
re-frozen into this file due to time constraints on a subsequent GPU-less pod
before submission. `scripts/full_reinit.sh` is the authoritative, complete, and
tested source of truth for every dependency needed — use it rather than this file
if reproducing from scratch.
