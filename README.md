This `README.md` is designed to reflect the specific optimizations we've built for your **RTX 5080 (Blackwell)** and the permission-safe **UID 1000** mapping.

---

# 🚀 ComfyUI Blackwell Edition (RTX 50xx)

A high-performance, Dockerized setup for **ComfyUI** optimized specifically for **NVIDIA Blackwell (RTX 5080/5090)** architectures. This project ensures seamless GPU passthrough, automatic permission syncing with Ubuntu 24.04 host users, and pre-configured essential nodes.

## ✨ Key Features

* **Blackwell Optimized:** Uses PyTorch Nightly with **CUDA 13.0** support for sm_120 compatibility.
* **UID/GID Sync:** Automatically renames the internal container user to match your host's **UID 1000**, preventing "Permission Denied" errors on volumes.
* **VRAM Management:** Pre-configured with `--reserve-vram 1.0` and `expandable_segments` to maximize 16GB VRAM stability.
* **Auto-Provisioning:** The `entrypoint.sh` automatically clones and installs dependencies for:
* ComfyUI-Manager
* Crystools (Hardware Monitor)
* rgthree-comfy
* KJNodes & Essentials



## 📋 Prerequisites

* **Host OS:** Ubuntu 24.04 (Noble Numbat)
* **GPU Driver:** NVIDIA **580.95** or newer.
* **Tools:** Docker & Docker Compose installed.
* **Hardware:** RTX 5080 / 5090 (or 40-series with sm_89).

## 🚀 Quick Start

### 1. Clone & Setup Folders

Run these commands on your host machine to prepare the persistent storage:

```bash
mkdir -p ~/comfy/{models,output,input,flows,custom_nodes,settings}
sudo chown -R $USER:$USER ~/comfy

```

### 2. Configure Environment

Create a `.env` file in the project root:

```ini
USER_ID=1000
GROUP_ID=1000

```

### 3. Build and Launch

```bash
docker compose build --no-cache
docker compose up -d

```

Access the UI at: **`http://localhost:8188`**

## 🛠 Project Structure

* **`Dockerfile`**: Handles the system dependencies and Blackwell-specific Python stack.
* **`docker-compose.yml`**: Manages GPU resource allocation and volume mapping.
* **`entrypoint.sh`**: The "brains" of the startup—manages custom node cloning and permission fixes.
* **`~/comfy/`**: Your persistent data directory on the host.

## ⚠️ Troubleshooting

| Error | Solution |
| --- | --- |
| **Permission Denied (comfyui.log)** | Run `sudo chown -R 1000:1000 ~/comfy` on the host. |
| **Network Error (Manager)** | Ensure `8.8.8.8` is added to the `dns:` section in `docker-compose.yml`. |
| **Out of Memory** | The `--reserve-vram 1.0` flag is active; check Crystools for background VRAM usage. |

---

