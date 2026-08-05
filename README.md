# DAAAM Reproduction

Reproducing the DAAAM pipeline on a CODa dataset subset, following the ROS 2 workflow
from MIT-SPARK/DAAAM and MIT-SPARK/DAAAM-ROS.

**Full report (Google Doc):** [FILL IN LINK]

## Environment
- RunPod, `runpod/pytorch:1.0.2-cu1281-torch280-ubuntu2404` (Ubuntu 24.04, CUDA 12.8.1, PyTorch 2.8.0)
- NVIDIA RTX 4090, 24GB VRAM
- ROS 2 Jazzy

## Pinned commit SHAs
[PASTE OUTPUT FROM THE LOOP ABOVE]

## Setup
```bash
# ROS 2 Jazzy
sudo apt install -y ros-jazzy-ros-base ros-dev-tools

# rosdep (required once per fresh container)
sudo rosdep init && rosdep update

# DAAAM workspace
mkdir -p /workspace/ros2_ws/src && cd /workspace/ros2_ws/src
git clone https://github.com/MIT-SPARK/DAAAM.git daaam
git config --global url."https://github.com/".insteadOf "git@github.com:"
bash daaam/install/install.sh
```

## Dataset
CODa sequence 0, via [ut-amrl/coda-devkit](https://github.com/ut-amrl/coda-devkit).
Subset used: [FILL IN once bag is created — frame range + rationale]

## Smoke test / full run
[FILL IN once launch commands are finalized]

## Troubleshooting
| Error | Cause | Fix |
|---|---|---|
| `Permission denied (publickey)` on SSH login | Key saved to `~/` instead of `~/.ssh/` | Moved key, `chmod 600` |
| `git@github.com: Permission denied (publickey)` cloning dependency repos | Manifest uses SSH URLs; no GitHub-registered key on the pod | `git config --global url."https://github.com/".insteadOf "git@github.com:"` |
| `rosdep` "not yet been initialized" | One-time-per-machine init step missed | `sudo rosdep init && rosdep update` |
| "Your Pod's GPUs are no longer available" | Shared GPU reclaimed while pod was stopped | Used RunPod's automatic data migration to a new pod |

_Last updated: Wed Aug  5 15:15:54 UTC 2026_
