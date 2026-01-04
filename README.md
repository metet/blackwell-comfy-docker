

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

**Option A: Using Makefile (Recommended)**
```bash
make env-setup
# Then edit .env to set your USER_ID and GROUP_ID (run 'id -u' and 'id -g' to find yours)
nano .env
```

**Option B: Manual**
Create a `.env` file in the project root:
```ini
USER_ID=1000
GROUP_ID=1000
```

### 3. Build and Launch

**Option A: Using Makefile (Recommended)**
```bash
make build
make start
```

**Option B: Manual**
```bash
docker compose build --no-cache
docker compose up -d
```

### 4. Stopping the Container

**Option A: Using Makefile (Recommended)**
```bash
make stop   # Standard stop (freezes container)
make clean  # Full shutdown (removes container)
```

**Option B: Manual**
```bash
docker compose stop  # Standard stop
docker compose down  # Full shutdown
```

The standard stop "freezes" the container. It keeps the container's internal state but stops the processes and releases the GPU.

### 5. Starting it Back Up

**Option A: Using Makefile (Recommended)**
```bash
make start
```

**Option B: Manual**
```bash
docker compose up -d
```

The -d flag (detached mode) runs it in the background so you can close your terminal window without killing ComfyUI.

### 6. Checking the Status

**Option A: Using Makefile (Recommended)**
```bash
make logs-follow  # Follow logs in real-time
make status       # Show container status
make health       # Check if ComfyUI is responding
```

**Option B: Manual**
```bash
docker logs -f comfyui_rtx5080
docker compose ps
```



Access the UI at: **`http://localhost:8188`**

## 🔧 Using the Makefile (Recommended)

This project includes a **Makefile** that simplifies common Docker operations. Instead of typing long `docker-compose` commands, you can use short, memorable commands.

### Quick Reference

Run `make help` to see all available commands:

```bash
make help
```

### Essential Commands

| Command | Description |
|---------|-------------|
| `make env-setup` | Create .env file from .env.example |
| `make build` | Build the Docker image |
| `make start` | Start ComfyUI container |
| `make stop` | Stop ComfyUI container |
| `make restart` | Restart ComfyUI container |
| `make logs` | Show last 100 lines of logs |
| `make logs-follow` | Follow logs in real-time |
| `make status` | Show container status |
| `make shell` | Open bash shell in container |
| `make health` | Check if ComfyUI is responding |
| `make clean` | Stop and remove container (keeps data) |

### Recommended Workflow with Makefile

1. **Initial Setup:**
```bash
# Create environment file
make env-setup

# Edit .env to set your USER_ID and GROUP_ID
nano .env  # or use your preferred editor

# Build the image
make build

# Start ComfyUI
make start
```

2. **Daily Usage:**
```bash
# Start ComfyUI
make start

# Check logs if needed
make logs-follow

# Stop when done
make stop
```

3. **Troubleshooting:**
```bash
# Check if container is running
make status

# Check if ComfyUI is responding
make health

# View recent logs
make logs

# Open shell to investigate
make shell
```

4. **Maintenance:**
```bash
# Update to latest version
make update

# Backup your data
make backup

# Check system requirements
make check-prereqs
```

### Advanced Commands

| Command | Description |
|---------|-------------|
| `make build-no-cache` | Rebuild without cache (for troubleshooting) |
| `make shell-root` | Open root shell (for system debugging) |
| `make info` | Show system and GPU information |
| `make test` | Run basic health tests |
| `make backup` | Create timestamped backup of ~/comfy/ |
| `make prune` | Clean up unused Docker resources |
| `make clean-all` | ⚠️ Remove everything including data volumes |

### Why Use the Makefile?

**Before (manual):**
```bash
docker-compose build --progress=plain
docker-compose up -d
docker-compose logs -f
docker-compose exec comfyui /bin/bash
```

**After (with Makefile):**
```bash
make build
make start
make logs-follow
make shell
```

✅ Shorter commands
✅ Easier to remember
✅ Color-coded output
✅ Built-in safety checks
✅ Helpful error messages

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

Adding a section for volume management is critical because Linux and Windows handle file paths and permissions very differently.

Here is the updated `README.md` section to help users navigate both environments.

---

## 📂 Volume & Path Management

This project uses **Bind Mounts** to link your host folders (where your models and images live) to the container. The syntax in the `docker-compose.yml` varies depending on whether you are on **Ubuntu 24.04** or **Windows 11 (WSL2)**.

### 🐧 On Ubuntu 24.04 (Native)

Ubuntu uses standard Unix paths. The `${HOME}` variable points to your user directory (e.g., `/home/username/`).

**Best Practice:** Use absolute paths with variables or relative paths starting with `./`.

```yaml
volumes:
  - ${HOME}/comfy/models:/app/ComfyUI/models:rw
  - ./local_nodes:/app/ComfyUI/custom_nodes:rw

```



---

### 🪟 On Windows 11 (Docker Desktop + WSL2)

Windows paths must be converted for Docker to understand them. You have two options:

#### Option A: WSL2 Filesystem (Recommended for Speed)

If you store your project inside your WSL2 distribution (e.g., `\\wsl$\Ubuntu\home\user\comfy`), the syntax is identical to the Ubuntu example above. This is **3-5x faster** for loading large `.safetensors` models.

#### Option B: Windows Host (C: Drive)

If your models are on a Windows drive (e.g., `D:\AI\Models`), use the following format:

```yaml
volumes:
  # Use forward slashes even on Windows
  - D:/AI/Models:/app/ComfyUI/models:rw
  # OR use the /run/desktop/mnt format
  - /run/desktop/mnt/host/d/AI/Models:/app/ComfyUI/models:rw

```

### 🔄 Platform Comparison Table

| Feature | Ubuntu 24.04 | Windows 11 (WSL2) |
| --- | --- | --- |
| **Path Style** | `/home/user/comfy` | `C:/Users/User/comfy` |
| **Performance** | Native (Fastest) | Fast (within WSL) / Slower (on C: drive) |
| **Permissions** | Must match UID 1000 | Automatically handled by Docker Desktop |
| **Case Sensitivity** | Strict | Case-insensitive (on host) |

---

### 🛠 How to Modify the YAML

If you want to move your models to a secondary SSD:

1. Open `docker-compose.yml`.
2. Locate the `volumes:` section.
3. Change the **left side** of the colon (`:`) to your new path.
4. **Never change the right side**, as ComfyUI expects those specific internal paths.

---

### 🚀 Final Step

After modifying your paths in the YAML, always restart the container to apply the changes:

```bash
docker compose up -d --force-recreate

```
