#!/bin/bash
set -e
echo "=== ROS 2 base ==="
sudo apt update && sudo apt install -y curl
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
sudo apt update
sudo apt install -y ros-jazzy-ros-base python3-rosdep python3-colcon-common-extensions
sudo rosdep init || true
rosdep update
source /opt/ros/jazzy/setup.bash
source /workspace/ros2_ws/install/setup.bash

echo "=== DAAAM's own pip dependency chain (SAM2, DAM, etc.) ==="
cd /workspace/ros2_ws/src
bash daaam/install/install.sh

echo "=== [2026-08-07 session] cvxpy/qdldl (AssignmentService QP solver) ==="
pip install qdldl --break-system-packages
pip install "cvxpy<1.8" --break-system-packages

echo "=== [2026-08-07 session] gradio chain (GroundingService -> dam/services.py 'import gradio') ==="
pip install gradio_client --break-system-packages
pip install brotli fastapi groovy hf-gradio orjson pydub python-multipart \
  safehttpx semantic-version starlette tomlkit typer uvicorn --break-system-packages

echo "=== [2026-08-07 session] langchain chain (mmllm/services.py — all 3 LLM providers imported eagerly) ==="
pip install langchain_core langchain_openai --break-system-packages
pip install langchain_google_genai langchain_anthropic --break-system-packages

echo "=== [2026-08-07 session] hf_transfer (DAM model download from HuggingFace) ==="
pip install hf_transfer --break-system-packages

echo "=== [2026-08-07 session] sentencepiece (DAM's LlamaTokenizer) ==="
pip install sentencepiece --break-system-packages

echo "=== spark_dsg ==="
pip install /workspace/ros2_ws/src/spark_dsg

echo "=== FoundationStereo base requirements + open3d ==="
cd /workspace/FoundationStereo
pip install -r requirements.txt --no-build-isolation --no-deps

echo "=== FoundationStereo extra deps discovered via troubleshooting ==="
pip install tqdm antlr4-python3-runtime==4.9.3 natsort matplotlib pandas huggingface_hub rerun-sdk
pip install --ignore-installed plotly dash flask werkzeug addict configargparse pyquaternion
echo "=== open3d.ml patch ==="
python3 - << 'PYEOF'
path = "/usr/local/lib/python3.12/dist-packages/open3d/__init__.py"
with open(path) as f:
    lines = f.readlines()
for i, l in enumerate(lines):
    if l.strip() == "import open3d.ml":
        lines[i] = "try:\n    import open3d.ml\nexcept ImportError:\n    pass\n"
        break
with open(path, "w") as f:
    f.writelines(lines)
PYEOF

echo "=== Pin numpy/scipy/opencv/setuptools LAST so nothing re-bumps them ==="
pip install "numpy==1.26.4" "scipy<1.17" "opencv-python<5" "setuptools<80" \
  --no-deps --break-system-packages

echo "=== Shell env, git, TF override ==="
grep -q "source /opt/ros/jazzy/setup.bash" ~/.bashrc || echo 'source /opt/ros/jazzy/setup.bash' >> ~/.bashrc
grep -q "source /workspace/ros2_ws/install/setup.bash" ~/.bashrc || echo 'source /workspace/ros2_ws/install/setup.bash' >> ~/.bashrc
grep -q "miniconda3/etc/profile.d/conda.sh" ~/.bashrc || echo 'source /workspace/miniconda3/etc/profile.d/conda.sh' >> ~/.bashrc
git config --global user.email "150054667+nguynntran@users.noreply.github.com"
git config --global user.name "nguynntran"
git config --global credential.helper store
cat > ~/.tf_overrides.yaml << 'TFEOF'
/tf_static:
  history: keep_last
  depth: 1
  reliability: reliable
  durability: transient_local
TFEOF

echo "=== Verification ==="
python3 -c "import numpy; print('numpy', numpy.__version__)"
python3 -c "import scipy; print('scipy', scipy.__version__)"
python3 -c "import cv2; print('opencv', cv2.__version__)"
python3 -c "import spark_dsg; print('spark_dsg ok')"
python3 -c "import open3d; print('open3d ok')"
python3 -c "import cv_bridge; print('cv_bridge ok')"
python3 -c "
import cvxpy, qdldl, gradio_client, gradio, langchain_openai, langchain_google_genai, langchain_anthropic, hf_transfer, sentencepiece
print('2026-08-07 session deps ok:', cvxpy.__version__)
"
ros2 pkg list | grep -i daaam

echo "=== Verify code patches survived ==="
grep -n 'declare_parameter("with_reid"' /workspace/ros2_ws/src/daaam_ros/src/daaam_ros/nodes/daaam_node.py \
  || echo "!! with_reid patch missing"

echo "=== Verify no orphaned processes from before migration ==="
ps aux | grep -E "daaam_node|hydra_ros_node|ros2 bag" | grep -v grep || echo "clean"

echo "=== Done ==="
