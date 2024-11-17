FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt update \
    && apt install -y \
        python3=3.9.2-3 \
        python3-pip=20.3.4-4+deb11u1 \
        iverilog=11.0-1 \
        gtkwave=3.3.104-2 \
        wget \
    && pip3 install cocotb==1.8.0 \
    && apt clean

# Install verible

ENV VERIBLE_VERSION="v0.0-3351-g92dc6261"
ENV VERIBLE_TARBALL="verible-${VERIBLE_VERSION}-linux-static-x86_64.tar.gz"
ENV VERIBLE_DIR="verible-${VERIBLE_VERSION}"

RUN wget --progress=dot:giga "https://github.com/chipsalliance/verible/releases/download/${VERIBLE_VERSION}/${VERIBLE_TARBALL}" \
    && tar -xf ${VERIBLE_TARBALL} \
    && install ${VERIBLE_DIR}/bin/* /usr/local/bin/ \
    && rm -rf "${VERIBLE_DIR}" "${VERIBLE_TARBALL}" \
    && verible-verilog-format --version

# Install python requirements

COPY requirements.txt .
RUN pip install -r requirements.txt
