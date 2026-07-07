# Down-Stream-Nodes/Dockerfile
FROM bash:5.2

# Install curl for FTP access
RUN apk add --no-cache curl

WORKDIR /watcher

COPY watcher.sh .
COPY configs/ configs/

RUN sed -i 's/\r//' watcher.sh && \
    sed -i 's/\r//' configs/billing.conf && \
    sed -i 's/\r//' configs/charging.conf && \
    sed -i 's/\r//' configs/fraud.conf && \
    chmod +x watcher.sh

ENTRYPOINT ["bash", "watcher.sh"]
