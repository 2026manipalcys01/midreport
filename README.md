# CYS01 mini-project report

The mid-semester report for CYS01, *Design and Development of an Adaptive
Gamified Web Security Training Platform for Penetration Testing Education*, a
mini-project at the Manipal School of Information Sciences (MAHE, Manipal).
It is written in LaTeX. The repository began as the team's synopsis and keeps
its cover page, its Docker toolchain and its diagram pipeline.

`make` builds `build/CYS01-Mini-Project-Report.pdf`.

## What the report contains

The front matter has the cover, an abstract, the contents, lists of figures
and tables, and a list of abbreviations. Eleven chapters follow, in the order
the college asks for, and then the references:

1. Introduction: background, problem statement, the proposed platform, scope
2. Literature survey: twelve studies and tools, and six research gaps
3. Objectives: O1 to O6 with success criteria and their dependencies
4. Specifications: functional and non-functional requirements, software and hardware
5. System architecture and design: layers, packages, request paths, database,
   authorisation, flag lifecycle, network isolation
6. Proposed modules: M1 to M6
7. Block diagram and flowcharts
8. Security considerations, including the open isolation issues
9. Work done and results, with the verification results of 23 September 2026
10. Timeline
11. Conclusion and future work

References use the IEEE style and are numbered in order of first citation.

## Quick start

Everything runs inside one Docker image (TeX Live, Mermaid CLI and
`rsvg-convert`), so Docker is the only thing to install. From the repository
root:

```bash
make
```

The first run builds the image, renders the diagrams and compiles the PDF.
Later runs render only the diagrams whose source changed.

```bash
make watch
```

`make watch` rebuilds on every save, and `docker compose up` does the same.
The other targets are `make diagrams` (render the diagrams only), `make image`
(rebuild the image), `make clean` and `make cleanall`.

## Editing

The project fields sit at the top of `src/main.tex`:

```latex
\newcommand{\projecttitle}{Design and Development of ...}
\newcommand{\projectdate}{24/09/2026}
\newcommand{\projectguide}{}
```

The cover prints an "under the guidance of" line only when `\projectguide`
is set. The student table sits in the cover block below these fields.

Each chapter is one file in `src/chapters/`, and `main.tex` reads them in
order. The abstract and the list of abbreviations are in `src/frontmatter/`.
The bibliography is `src/references.bib`, compiled with biblatex and biber.

Two small helpers keep the source tidy. `\code{...}` sets an identifier in
monospace and accepts underscores as they are, including inside captions.
`\tablefont` sets the smaller type and row spacing that every table uses.

## Diagrams

Each diagram is a Mermaid source in `diagrams/`. The render step
(`scripts/render-diagrams.sh`) turns it into `src/figures/NAME.svg`, which is
tracked, and `build/diagrams/NAME.pdf`, which is a build product that pdfLaTeX
embeds. `diagrams/mermaid-config.json` holds the shared theme: Times New
Roman, the orange palette of the review deck, and plain SVG text labels so
that `rsvg-convert` can turn each SVG into a vector PDF.

A chapter places a diagram with

```latex
\diagramfig[max height]{NAME}{Title}{Detail.}{fig:label}
```

The title goes into the list of figures, and the caption reads "Title.
Detail." Every figure is drawn at the same scale, so text is the same size in
all of them, and a figure shrinks only when it would not fit the page.

The diagrams share one legend: a solid orange border is built, a dashed
orange border is partly built, a dashed grey border is planned, and red marks
the vulnerable lab.

| Source | Shows | Chapter |
| --- | --- | --- |
| `objectives.mmd` | Dependencies between the objectives | 3 |
| `architecture.mmd` | Layered architecture | 5 |
| `packages.mmd` | Dependencies between the workspace packages | 5 |
| `request-paths.mmd` | Synchronous scoring and asynchronous analytics | 5 |
| `database-core.mmd` | Grading tables | 5 |
| `database-content.mmd` | Challenge content tables | 5 |
| `database-learner.mmd` | Learner data tables | 5 |
| `auth-flow.mmd` | Authorisation in the data access layer | 5 |
| `flag-lifecycle.mmd` | Flag lifecycle | 5 |
| `deployment.mmd` | Deployment and network isolation | 5 |
| `modules.mmd` | Module diagram | 6 |
| `onboarding.mmd` | Onboarding wizard for both roles | 6 |
| `block-diagram.mmd` | Block diagram | 7 |
| `learner-workflow.mmd` | Learner workflow | 7 |
| `challenge-flowchart.mmd` | Challenge execution flowchart | 7 |
| `scoring-pipeline.mmd` | Grading and scoring pipeline | 7 |
| `timeline.mmd` | Project timeline | 10 |
| `adaptation-loop.mmd` | Planned adaptation loop | 11 |

Three details of the pipeline are easy to trip over:

- Mermaid writes each word of a label as its own `<tspan>` with a leading
  space. librsvg drops that space unless the SVG says `xml:space="preserve"`,
  so the render script adds the attribute after `mmdc` runs.
- Mermaid reads `#hex;` on a `linkStyle` line as an HTML entity, so those
  lines end without a semicolon.
- A subgraph with its own `direction` is laid out as a separate box, and
  edges to its nodes stop at its border. Subgraphs whose nodes connect to the
  outside therefore have no `direction` line.

Until a diagram is rendered, the document shows a labelled placeholder and
still compiles.

## Layout

```
.
├── Dockerfile              build image: TeX Live, Mermaid CLI, rsvg-convert
├── Makefile                make, make diagrams, make watch, make image
├── diagrams/
│   ├── *.mmd               one Mermaid source per diagram
│   └── mermaid-config.json shared theme
├── scripts/
│   └── render-diagrams.sh  mmd to src/figures/*.svg to build/diagrams/*.pdf
├── src/
│   ├── main.tex            preamble, cover page, front matter, chapter order
│   ├── frontmatter/        abstract, list of abbreviations
│   ├── chapters/           one file per chapter, 01 to 11
│   ├── figures/            logos (.png) and rendered diagrams (.svg)
│   └── references.bib      bibliography
├── build/                  generated PDF, aux files, diagram PDFs (ignored)
├── .latexmkrc              compiles src/, writes to build/
├── docker-compose.yml      live-preview container, same as make watch
└── .github/workflows/      CI that builds the PDF
```

`.latexmkrc` compiles from inside `src/`, so `\input{chapters/...}`,
`figures/` and the embedded `../build/diagrams/*.pdf` all resolve against the
source, and the output goes to `build/` at the repository root.

## Continuous builds

Every push to `main` and every pull request builds the PDF and uploads it as
the `report-pdf` artifact on the run's summary page. To publish a versioned
PDF, tag a commit:

```bash
git tag v1.0
git push origin v1.0
```

The workflow builds the diagram PDFs from the committed SVGs with
`rsvg-convert` and then compiles, so it needs no Mermaid. After editing a
`.mmd` file, run `make diagrams` and commit the updated SVG.

## License

MIT. See [LICENSE](LICENSE).
