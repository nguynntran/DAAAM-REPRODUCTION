#!/bin/bash
set -e
SRC=/workspace/CODa
DST=/workspace/CODa_subset
START=2000
END=2399

select_range() {
  local src=$1 dst=$2
  mkdir -p "$dst"
  for f in "$src"/*; do
    fname=$(basename "$f")
    numext="${fname##*_}"
    num="${numext%.*}"
    if (( num >= START && num <= END )); then cp "$f" "$dst/"; fi
  done
}

select_range "$SRC/2d_rect/cam0/0" "$DST/2d_rect/cam0/0"
select_range "$SRC/2d_rect/cam1/0" "$DST/2d_rect/cam1/0"
sed -n "$((START+1)),$((END+1))p" "$SRC/poses/dense/0.txt" > "$DST/poses/dense/0.txt"
sed -n "$((START+1)),$((END+1))p" "$SRC/timestamps/0.txt" > "$DST/timestamps/0.txt"
cp -r "$SRC/calibrations/0" "$DST/calibrations/0"
