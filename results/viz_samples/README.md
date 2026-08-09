# Visualization - input/output pairs per stage

All files from run `out_20260809_034804` (post `semantic_integrator` fix), sequence 0,
frames 2000-2399, cam0, unless noted.

| Stage | Input file | Output file |
|---|---|---|
| Depth estimation | (stereo pair, not separately committed) | `depth_2399_colored.png` |
| Segmentation | `grounding_examples/grounding_images_plain_grounding_1673884386.611053_000000.jpg` | `grounding_examples/grounding_images_grounding_1673884386.611053_000000.jpg` (overlay), `grounding_examples/grounding_images_masks_only_grounding_1673884386.611053_000000.png` (masks) |
| Tracking/ReID | — | not available this run — see Section 10 of the main report for why (query interval vs. run length) |
| Assignment | log line: "Successfully sent prompt record for frame 11 to grounding workers" | `grounding_examples/grounding_images_plain_grounding_1673884386.611053_000000.jpg` (the selected frame, `frame_counter: 10`) |
| Grounding | `grounding_examples/grounding_images_masks_only_grounding_1673884386.611053_000000.png` | `grounding_examples/grounding_annotations_grounding_1673884386.611053_000000.yaml` |
| Scene graph | (RGB-D, poses, tracks, corrections — consumed internally) | `dsg_visualization.rrd` (labeled), `dsg_visualization_clean.rrd` (clean, for screenshots) |
| Sentence embeddings | 46 descriptions across `grounding_examples/grounding_annotations_*.yaml` | `sentence_embeddings/sentence_embeddings_pca.png`, `sentence_embeddings/sentence_embeddings_stats.txt` |
| Final result | processed 400-frame sequence | same `.rrd` files as Scene graph |

Two additional standalone object crops (`00097.jpg`, `00084.jpg`) are DAM's
per-mask input images, useful as extra Grounding-stage input examples.
