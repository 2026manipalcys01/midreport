# Report build. Everything runs in the self-contained Docker image
# (TeX Live + Mermaid + rsvg-convert), so the only host requirement is Docker.
#
#   make            render diagrams and compile the PDF  (build/CYS01-Mini-Project-Report.pdf)
#   make diagrams   render diagrams only (src/figures/*.svg + build PDFs)
#   make watch      continuous rebuild on save
#   make image      (re)build the Docker image
#   make clean      remove aux files
#   make cleanall   remove the whole build/ directory

IMAGE ?= cys01-report-builder
RUN    = docker run --rm -v "$(CURDIR)":/work -w /work $(IMAGE)

.PHONY: all pdf diagrams watch image ensure-image clean cleanall

all: pdf

## Build the image only if it is missing.
ensure-image:
	@docker image inspect $(IMAGE) >/dev/null 2>&1 || $(MAKE) image

image:
	docker build -t $(IMAGE) .

## Render Mermaid sources to SVG (src/figures/) and build-only PDFs.
diagrams: ensure-image
	$(RUN) bash scripts/render-diagrams.sh

## Render diagrams as needed, then compile the document.
pdf: ensure-image
	$(RUN) sh -c "bash scripts/render-diagrams.sh && latexmk"

## Continuous preview: rebuild on every save.
watch: ensure-image
	$(RUN) sh -c "bash scripts/render-diagrams.sh && latexmk -pvc -view=none"

clean: ensure-image
	$(RUN) latexmk -c

cleanall: ensure-image
	$(RUN) latexmk -C
	rm -rf build
