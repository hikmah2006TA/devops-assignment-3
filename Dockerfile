FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        coreutils \
        gawk \
        libc-bin && \
    rm -rf /var/lib/apt/lists/*

COPY app/app.sh /usr/local/bin/devops-tool

RUN chmod +x /usr/local/bin/devops-tool

ENTRYPOINT ["/usr/local/bin/devops-tool"]
