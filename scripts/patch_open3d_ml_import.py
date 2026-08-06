"""
open3d unconditionally imports open3d.ml (3D-ML benchmark dataset loaders,
e.g. SemanticKITTI) at package load time, pulling in unrelated dependencies
(sklearn, threadpoolctl, etc.) that FoundationStereo never actually needs.
Wraps that import in try/except so it fails silently instead of crashing
the whole package. Safe to re-run.
"""
path = "/usr/local/lib/python3.12/dist-packages/open3d/__init__.py"
with open(path) as f:
    lines = f.readlines()
for i, line in enumerate(lines):
    if line.strip() == "import open3d.ml":
        lines[i] = "try:\n    import open3d.ml\nexcept ImportError:\n    pass\n"
        print(f"Patched line {i}")
        break
else:
    print("Already patched or pattern not found — no change made.")
with open(path, "w") as f:
    f.writelines(lines)
