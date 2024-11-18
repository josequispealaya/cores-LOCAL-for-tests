FROM debian:bullseye-slim

# Copiar los scripts y carpetas necesarias al contenedor
COPY run_tests_pipeline.sh /usr/local/bin/run_tests_pipeline.sh
COPY run_cocotb_tests.sh /usr/local/bin/run_cocotb_tests.sh
COPY run_tests.py /usr/local/bin/run_tests.py

# Copiar la carpeta 'tests'
COPY tests /usr/local/bin/tests

# Copiar las carpetas RTL, DRV, y sim_build
COPY RTL /usr/local/bin/RTL
COPY DRV /usr/local/bin/DRV
#COPY sim_build /usr/local/bin/sim_build

# Dar permisos de ejecución a los scripts
RUN chmod +x /usr/local/bin/run_tests_pipeline.sh \
    && chmod +x /usr/local/bin/run_cocotb_tests.sh \
    && chmod +x /usr/local/bin/run_tests.py


ENV DEBIAN_FRONTEND noninteractive

# Instalar dependencias
RUN apt update \
    && apt install -y \
        python3=3.9.2-3 \
        python3-pip=20.3.4-4+deb11u1 \
        iverilog=11.0-1 \
        gtkwave \
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
