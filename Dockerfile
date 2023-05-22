FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
    && apt install -y \
        python3=3.9.2-3 \
        python3-pip=20.3.4-4+deb11u1 \
    && apt clean

COPY requirements.txt .
RUN pip install -r requirements.txt
