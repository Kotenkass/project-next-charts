#!/usr/bin/env bash
set -euo pipefail

out_dir="${1:?usage: scripts/render-kyverno-policies.sh <output-dir> [source-dir]}"
src_dir="${2:-k8s/policies}"

if [[ -z "${COSIGN_PUB:-}" ]]; then
  echo "COSIGN_PUB is required to render Kyverno cosign policy" >&2
  exit 1
fi

if [[ -z "${IMAGE_NAME:-}" ]]; then
  echo "IMAGE_NAME is required to render Kyverno cosign policy (for image pattern)" >&2
  exit 1
fi

mkdir -p "$out_dir"

cp "$src_dir/restrict-container-images.yaml" "$out_dir/restrict-container-images.yaml"
cp "$src_dir/require-safe-pod-security-context.yaml" "$out_dir/require-safe-pod-security-context.yaml"

awk -v key="$COSIGN_PUB" -v img_pat="${IMAGE_NAME}*" '
  index($0, "REPLACE_ME_WITH_YOUR_COSIGN_PUBLIC_KEY") {
    n = split(key, lines, RS)
    for (i = 1; i <= n; i++) {
      printf "%s%s\n", "                      ", lines[i]
    }
    next
  }
  index($0, "REPLACE_ME_WITH_IMAGE_PATTERN") {
    printf "%s%s%s\n", substr($0, 1, index($0, "REPLACE_ME_WITH_IMAGE_PATTERN") - 1), img_pat, substr($0, index($0, "REPLACE_ME_WITH_IMAGE_PATTERN") + length("REPLACE_ME_WITH_IMAGE_PATTERN"))
    next
  }
  { print }
' "$src_dir/require-cosign-signature-prod.yaml" > "$out_dir/require-cosign-signature-prod.yaml"