# generator/Dockerfile
FROM bash:5.2

# Install curl for FTP upload
RUN apk add --no-cache curl

WORKDIR /generator

COPY generator.sh .
COPY configs/ configs/

RUN sed -i 's/\r//' generator.sh && \
    sed -i 's/\r//' configs/msc.conf && \
    sed -i 's/\r//' configs/pgw.conf && \
    sed -i 's/\r//' configs/smsc.conf && \
    chmod +x generator.sh

ENTRYPOINT ["bash", "generator.sh"]
