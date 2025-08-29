ARG UBUNTU_VERSION=22.04

FROM ubuntu:$UBUNTU_VERSION

ARG TARGETARCH

RUN apt-get update && \
    apt-get install -y build-essential git cmake libcurl4-openssl-dev

WORKDIR /app

COPY . .

RUN if [ "$TARGETARCH" = "amd64" ]; then \
        cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DGGML_NATIVE=OFF -DLLAMA_BUILD_TESTS=OFF -DGGML_BACKEND_DL=ON -DGGML_CPU_ALL_VARIANTS=ON; \
    else \
        echo "Unsupported architecture"; \
        exit 1; \
    fi && \
    cmake --build build -j $(nproc)

ENV LLAMA_ARG_HOST=0.0.0.0
ENV LLAMA_ARG_NO_WEBUI=1
ENV LLAMA_ARG_CTX_SIZE=0
ENV LLAMA_ARG_JINJA=1
ENV LLAMA_API_KEY=$LLAMA_API_KEY
ENV LLAMA_ARG_HF_REPO=$LLAMA_ARG_HF_REPO

EXPOSE 8080/tcp

HEALTHCHECK CMD [ "curl", "-f", "http://localhost:8080/health" ]

ENTRYPOINT [ "/app/build/bin/llama-server" ]
