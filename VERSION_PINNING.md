# Version Pinning Recommendations for RTX 5080 (Blackwell)

## Current Approach

The current Dockerfile uses PyTorch nightly builds with CUDA 13.0 support, which is **required** for NVIDIA Blackwell architecture (RTX 5080/5090) with sm_120 compute capability.

## Recommendations for RTX 5080

### Option 1: Pin to Specific Nightly Date (Recommended for Production)

For reproducible builds, pin to a specific nightly version by date:

```dockerfile
# Install PyTorch nightly from specific date (2026-01-04 example)
RUN pip install --pre torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/cu130/2026-01-04
```

**Pros:**
- Reproducible builds
- Known working versions
- Easy rollback if issues arise

**Cons:**
- Must manually update periodically
- May miss performance improvements

### Option 2: Use Latest Nightly (Current Approach)

Continue using latest nightly builds:

```dockerfile
RUN pip install --pre torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/cu130
```

**Pros:**
- Latest features and optimizations
- Bug fixes automatically included
- Best Blackwell support

**Cons:**
- May introduce breaking changes
- Build not reproducible
- Potential instability

### Option 3: Wait for Stable Release (Future)

Once PyTorch stable version includes CUDA 13.0 support (expected mid-2026):

```dockerfile
RUN pip install torch==2.5.0 torchvision==0.20.0 torchaudio==2.5.0 \
    --index-url https://download.pytorch.org/whl/cu130
```

**Not currently available** - CUDA 13.0 is only in nightly builds as of January 2026.

## Recommended Strategy for RTX 5080

### For Development (Current)
Use **latest nightly** to get newest optimizations and features:
```bash
pip install --pre torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/cu130
```

### For Production Deployment
1. Test with latest nightly
2. Once stable, pin to that specific date
3. Update quarterly after testing

Example pinned production version:
```dockerfile
# Tested and verified on 2026-01-04
RUN pip install --pre torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/cu130/2026-01-04
```

## How to Pin to Specific Date

Edit `comfyui/Dockerfile` line 70-71:

```dockerfile
# Before (current - latest nightly)
RUN pip install --pre torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/cu130

# After (pinned to date)
RUN pip install --pre torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/nightly/cu130/YYYY-MM-DD
```

Replace `YYYY-MM-DD` with your desired date (e.g., `2026-01-04`).

## Testing a Pinned Version

After changing the Dockerfile:

```bash
# Rebuild the image
make build

# Test that it works
make start
make logs

# Verify PyTorch version
docker exec -it comfyui python -c "import torch; print(f'PyTorch: {torch.__version__}, CUDA: {torch.version.cuda}')"
```

Expected output should show:
- PyTorch version with date (e.g., `2.6.0.dev20260104`)
- CUDA version: `13.0`

## Other Dependencies to Consider Pinning

Currently using latest versions via git clone. Consider pinning:

### ComfyUI Core
```dockerfile
# Current
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# Pinned to commit
RUN git clone https://github.com/comfyanonymous/ComfyUI.git && \
    cd ComfyUI && \
    git checkout <commit-hash>
```

### Custom Nodes
Edit `comfyui/entrypoint.sh` to pin custom node versions by commit:

```bash
# Current
git clone --depth 1 https://github.com/ltdrdata/ComfyUI-Manager.git

# Pinned
git clone https://github.com/ltdrdata/ComfyUI-Manager.git
cd ComfyUI-Manager
git checkout <commit-hash>
cd ..
```

## Update Frequency Recommendations

| Component | Recommended Update Frequency |
|-----------|------------------------------|
| PyTorch nightly | Weekly (dev), Monthly (prod) |
| ComfyUI core | Bi-weekly after testing |
| Custom nodes | Monthly or on bug fixes |
| System packages | Quarterly security updates |

## Current Status

As of January 2026:
- ✅ CUDA 13.0 support: **Nightly only**
- ✅ Blackwell (sm_120): **Nightly only**
- ❌ Stable PyTorch: Does not support CUDA 13.0 yet
- **Recommendation**: Use nightly builds, pin to date for production

## References

- [PyTorch Installation](https://pytorch.org/get-started/locally/)
- [PyTorch Nightly Builds](https://download.pytorch.org/whl/nightly/cu130/)
- [NVIDIA CUDA 13.0 Release Notes](https://docs.nvidia.com/cuda/cuda-toolkit-release-notes/)
