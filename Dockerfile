FROM ghcr.io/utn-ba-sats/hdlcores

# Establecer la variable de entorno para el frontend no interactivo
ENV DEBIAN_FRONTEND=noninteractive

# Instalar la versión específica de cocotb
RUN pip uninstall -y cocotb || true \
    && pip install cocotb==1.7.2

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

