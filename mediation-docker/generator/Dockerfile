FROM bash:5.2

WORKDIR /generator

COPY generator.sh .
COPY configs/ configs/

# Fix CRLF for script AND config files
RUN sed -i 's/\r//' generator.sh && \
    sed -i 's/\r//' configs/msc.conf && \
    sed -i 's/\r//' configs/pgw.conf && \
    sed -i 's/\r//' configs/smsc.conf && \
    chmod +x generator.sh

ENTRYPOINT ["bash", "generator.sh"]