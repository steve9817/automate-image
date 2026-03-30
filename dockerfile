# =========================
# 1) Builder stage
# =========================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PATH="/opt/venv/bin:$PATH"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        binutils \
        gcc \
        g++ \
        git \
        curl \
        libpq-dev \
        libffi-dev \
        libssl-dev \
        cargo \
        python3.10 \
        python3.10-venv \
        python3.10-dev \
        python3-pip && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python3.10 -m venv /opt/venv

WORKDIR /app

# Copy requirements first for better caching
COPY requirements.txt /app/requirements.txt

# Upgrade pip tools first
RUN python -m pip install --upgrade pip setuptools wheel

# Install Python dependencies
RUN python -m pip install -r /app/requirements.txt

# Copy custom Rasa source and install it
COPY rasa-3.6.x /app/rasa-3.6.x
RUN python -m pip install /app/rasa-3.6.x

# Copy project files
COPY . /app


# =========================
# 2) Runtime stage
# =========================
FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        python3.10 \
        python3.10-venv && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy ready-made virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Point python commands to Python 3.10
RUN ln -sf /usr/bin/python3.10 /usr/bin/python && \
    ln -sf /usr/bin/python3.10 /usr/bin/python3

WORKDIR /app

# Copy application files
COPY . /app

# Copy and make start script executable
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5005

CMD ["/start.sh"]

# # =========================
# # 1) Builder stage
# # =========================
# FROM ubuntu:22.04 AS builder

# ENV DEBIAN_FRONTEND=noninteractive \
#     PYTHONDONTWRITEBYTECODE=1 \
#     PYTHONUNBUFFERED=1

# RUN apt-get update && \
#     apt-get upgrade -y && \
#     apt-get install -y --no-install-recommends \
#         ca-certificates \
#         build-essential \
#         binutils \
#         gcc \
#         g++ \
#         git \
#         curl \
#         libpq-dev \
#         libffi-dev \
#         libssl-dev \
#         cargo \
#         python3.10 \
#         python3.10-venv \
#         python3.10-dev \
#         python3-pip && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# # Create venv
# RUN python3.10 -m venv /opt/venv
# ENV PATH="/opt/venv/bin:$PATH"

# WORKDIR /app

# # Copy dependency file first for better caching
# COPY requirements.txt /app/requirements.txt

# # Install supporting dependencies
# RUN pip install --upgrade pip setuptools wheel && \
#     pip install --no-cache-dir -r /app/requirements.txt

# # Copy and install custom Rasa source
# COPY rasa-3.6.x /app/rasa-3.6.x
# RUN pip install --no-cache-dir /app/rasa-3.6.x

# # Copy full project
# COPY . /app

# # =========================
# # 2) Runtime stage
# # =========================
# FROM ubuntu:22.04 AS runtime

# ENV DEBIAN_FRONTEND=noninteractive \
#     PYTHONDONTWRITEBYTECODE=1 \
#     PYTHONUNBUFFERED=1

# RUN apt-get update && \
#     apt-get upgrade -y && \
#     apt-get install -y --no-install-recommends \
#         ca-certificates \
#         python3.10 \
#         python3.10-venv && \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/*

# # Copy ready venv from builder
# COPY --from=builder /opt/venv /opt/venv
# ENV PATH="/opt/venv/bin:$PATH"

# # Point python commands to 3.10
# RUN ln -sf /usr/bin/python3.10 /usr/bin/python && \
#     ln -sf /usr/bin/python3.10 /usr/bin/python3

# WORKDIR /app

# # Copy application files
# COPY . /app

# # Start script
# COPY start.sh /start.sh
# RUN chmod +x /start.sh

# EXPOSE 5005

# CMD ["/start.sh"]