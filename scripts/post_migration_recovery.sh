#!/bin/bash
set -e

echo "=== Current pod: $(hostname) ==="

echo "=== Step 1: environment reinit (always needed after migration) ==="
bash /workspace/scripts/full_reinit.sh

echo "=== Step 2: checking if the bag survived (it should) ==="
BAG=$(ls -d /workspace/CODa_subset/coda_0_subset_* 2>/dev/null | head -1)

if [ -n "$BAG" ]; then
    echo "Bag found: $BAG — no rebuild needed."
    ros2 bag info "$BAG"
else
    echo "Bag missing — rebuilding (fast: images/poses/depth already on /workspace)..."
    cd /workspace/ros2_ws
    ros2 launch daaam_ros dataloader_coda_with_depth.launch.yaml \
      sequence:=0 \
      dataset_path:=/workspace/CODa_subset \
      bag_path:=/workspace/CODa_subset/coda_0_subset \
      depth_source:=3d_raw_estimated
fi

echo "=== Ready ==="
