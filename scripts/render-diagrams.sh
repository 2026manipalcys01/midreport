#!/usr/bin/env bash
#
# Render the Mermaid diagrams. Runs INSIDE the build image (mmdc + rsvg-convert
# on PATH), so it is called by the Makefile, docker-compose, and CI, never on the
# bare host.
#
#   diagrams/NAME.mmd  --mermaid-->  src/figures/NAME.svg     (tracked deliverable)
#                      --rsvg-->     build/diagrams/NAME.pdf   (git-ignored, embedded)
#
# Each step is skipped when its output is already newer than its inputs
# (the .mmd source and the shared Mermaid config).
#
# Mermaid writes each word of a label as its own <tspan> with a leading space.
# librsvg follows the SVG 1.1 default of stripping that space, which glues the
# words together, so the SVG root is marked xml:space="preserve".
#
set -euo pipefail
cd "$(dirname "$0")/.."                 # repo root

config="diagrams/mermaid-config.json"
puppeteer="/etc/puppeteer.json"
mkdir -p build/diagrams

shopt -s nullglob
for mmd in diagrams/*.mmd; do
  name="$(basename "$mmd" .mmd)"
  svg="src/figures/$name.svg"
  pdf="build/diagrams/$name.pdf"

  if [ ! -f "$svg" ] || [ "$mmd" -nt "$svg" ] || [ "$config" -nt "$svg" ]; then
    echo "mermaid  $mmd -> $svg"
    mmdc -p "$puppeteer" -c "$config" -b white -i "$mmd" -o "$svg"
    sed -i '0,/<svg /s//<svg xml:space="preserve" /' "$svg"
  fi

  if [ ! -f "$pdf" ] || [ "$svg" -nt "$pdf" ]; then
    echo "rsvg     $svg -> $pdf"
    rsvg-convert -f pdf -o "$pdf" "$svg"
  fi
done

echo "Diagrams up to date."
