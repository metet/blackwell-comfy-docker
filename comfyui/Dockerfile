FROM ubuntu:24.04

# 1. Setup Build Arguments for Permissions
# These defaults (1000) match most single-user Linux setups
ARG USER_ID=1000
ARG GROUP_ID=1000

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# 2. Install System Dependencies as ROOT
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    python3 \
    python3-venv \
    python3-pip \
    git \
    ffmpeg \
    curl \
    libgl1 \
    libglx-mesa0 \
    libglib2.0-0 \
    fonts-dejavu-core \
    fontconfig \
    && rm -rf /var/lib/apt/lists/*
  
# 3. Create/Modify User as ROOT
# This logic handles the 'ubuntu' user conflict in Ubuntu 24.04
RUN if getent group ${GROUP_ID}; then \
        # If GID already exists, rename that group to 'comfygroup'
        EXISTING_GROUP=$(getent group ${GROUP_ID} | cut -d: -f1); \
        groupmod -n comfygroup "$EXISTING_GROUP"; \
    else \
        groupadd -g ${GROUP_ID} comfygroup; \
    fi && \
# Step B: Manage the User ID
    if getent passwd ${USER_ID}; then \
        # Find the name of the user currently occupying the target UID
        EXISTING_USER=$(getent passwd ${USER_ID} | cut -d: -f1); \
        echo "Found existing user '$EXISTING_USER' with UID ${USER_ID}. Renaming to comfyuser..."; \
        # Rename the user, move their home, and set the new shell
        usermod -l comfyuser -m -d /home/comfyuser -s /bin/bash "$EXISTING_USER"; \
    else \
        # If no user occupies that UID, create a fresh one
        useradd -u ${USER_ID} -g comfygroup -m -s /bin/bash comfyuser; \
    fi

# 4. Prepare Application Directory as ROOT
WORKDIR /app
# Create the folders AND the path for the virtual environment if needed
#RUN mkdir -p /app/ComfyUI && chown -R ${USER_ID}:${GROUP_ID} /app
#RUN mkdir -p /app/ComfyUI/user && chown -R ${USER_ID}:${GROUP_ID} /app
RUN chown -R comfyuser:comfygroup /app
RUN chmod -R 755 /app


# 5. Copy Entrypoint and Fix Permissions as ROOT
COPY --chown=${USER_ID}:${GROUP_ID} entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# 6. SWITCH TO NON-ROOT USER
USER comfyuser

# 7. Setup Virtual Environment in User Home
RUN python3 -m venv /home/comfyuser/venv
ENV PATH="/home/comfyuser/venv/bin:$PATH"

# 8. Install Python Stack (RTX 5080 / sm_120 Support)
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --pre torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/cu130
RUN pip install opencv-python-headless
RUN pip install deepdiff
RUN pip install piexif
RUN pip install py-cpuinfo
RUN pip install nvidia-ml-py3

# 9. Install ComfyUI
# We clone into current dir (.) because WORKDIR is /app
WORKDIR /app
RUN git clone https://github.com/comfyanonymous/ComfyUI.git
WORKDIR /app/ComfyUI
RUN pip install --no-cache-dir -r requirements.txt


EXPOSE 8188

# 10. Execution
ENTRYPOINT ["/entrypoint.sh"]
# Optimized for RTX 5080 Blackwell
#CMD ["python","/app/ComfyUI/main.py","--listen","0.0.0.0"]
CMD ["python", "main.py", "--listen", "0.0.0.0", "--reserve-vram", "1.0"]
#CMD ["python3", "main.py", "--listen", "0.0.0.0", "--port", "8188", "--fp8_e4m3fn-unet", "--cuda-malloc", "--lowvram"]


