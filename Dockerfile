# Build image for the report: TeX Live, Mermaid CLI and rsvg-convert.
# One image renders the diagrams and compiles the document, so `make` needs
# nothing on the host but Docker.
FROM texlive/texlive:TL2025-historic

ENV DEBIAN_FRONTEND=noninteractive \
    PUPPETEER_SKIP_DOWNLOAD=1 \
    PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        chromium \
        nodejs \
        npm \
        librsvg2-bin \
        fonts-liberation \
        ca-certificates && \
    npm install -g @mermaid-js/mermaid-cli@11 && \
    printf '{ "args": ["--no-sandbox", "--disable-gpu", "--disable-dev-shm-usage"] }\n' \
        > /etc/puppeteer.json && \
    npm cache clean --force && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /work
