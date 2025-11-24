# How to Download and Use the ANTSDR E310 V1 Patches

## Quick Download (Single Tarball)

Download the complete patch bundle from GitHub:

```bash
wget https://github.com/asnaviram/maia-sdr-fw/raw/claude/antsdr-firmware-patches-01Ed6HGAAjFppXGsNfB8MhV7/antsdr-e310-v1-patches.tar.gz

# Extract
tar xzf antsdr-e310-v1-patches.tar.gz

# You'll get:
# - antsdr-e310-v1-support.patch
# - 0001-add-ant-support-buildroot.patch
# - 0001-add-ant-support-hdl.patch
# - 0001-add-ant-support-linux.patch
# - 0001-add-ant-support-uboot.patch
# - apply-antsdr-patches.sh
# - ANTSDR-E310-V1-README.md
```

## Individual Files

Or download individual files:

```bash
BASE_URL="https://github.com/asnaviram/maia-sdr-fw/raw/claude/antsdr-firmware-patches-01Ed6HGAAjFppXGsNfB8MhV7"

# Main patch
wget $BASE_URL/antsdr-e310-v1-support.patch

# Submodule patches
wget $BASE_URL/0001-add-ant-support-buildroot.patch
wget $BASE_URL/0001-add-ant-support-hdl.patch
wget $BASE_URL/0001-add-ant-support-linux.patch
wget $BASE_URL/0001-add-ant-support-uboot.patch

# Installation script and documentation
wget $BASE_URL/apply-antsdr-patches.sh
wget $BASE_URL/ANTSDR-E310-V1-README.md

chmod +x apply-antsdr-patches.sh
```

## Usage

### Option 1: Automated (Recommended)

```bash
# Clone the original maia-sdr/plutosdr-fw repository
git clone --recursive https://github.com/maia-sdr/plutosdr-fw.git
cd plutosdr-fw

# Copy the patch files to the repository root
cp /path/to/patches/*.patch .
cp /path/to/patches/apply-antsdr-patches.sh .

# Run the automated installer
./apply-antsdr-patches.sh
```

### Option 2: Manual

```bash
# Clone the repository
git clone --recursive https://github.com/maia-sdr/plutosdr-fw.git
cd plutosdr-fw

# Apply main repository patch
git apply antsdr-e310-v1-support.patch

# Apply submodule patches
git apply --directory=buildroot 0001-add-ant-support-buildroot.patch
git apply --directory=hdl 0001-add-ant-support-hdl.patch
git apply --directory=linux 0001-add-ant-support-linux.patch
git apply --directory=u-boot-xlnx 0001-add-ant-support-uboot.patch
```

## Building

After applying patches:

```bash
export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2023.2/settings64.sh
export TARGET=ant
make
```

## What's Fixed

The previous version of this branch (commit `1450cea`) had submodule references pointing to
non-existent commits. This has been fixed - the branch now only contains:

1. **Main repository changes** (Makefile, scripts/ant.mk, scripts/ant.its)
2. **Patch files** that can be applied to the standard submodules
3. **Documentation** and installation scripts

No submodule commit references are modified, so cloning and building works correctly.

## Files in the Patch Bundle

| File | Purpose |
|------|---------|
| `antsdr-e310-v1-support.patch` | Main repo changes (Makefile, ant.mk, ant.its) |
| `0001-add-ant-support-buildroot.patch` | Buildroot board support |
| `0001-add-ant-support-hdl.patch` | FPGA/Vivado project |
| `0001-add-ant-support-linux.patch` | Linux kernel device tree and config |
| `0001-add-ant-support-uboot.patch` | U-Boot device tree and config |
| `apply-antsdr-patches.sh` | Automated installation script |
| `ANTSDR-E310-V1-README.md` | Complete documentation |

## Troubleshooting

### "patch does not apply"

Make sure you're applying to a fresh clone of `maia-sdr/plutosdr-fw`:

```bash
git clone --recursive https://github.com/maia-sdr/plutosdr-fw.git
cd plutosdr-fw
# Now apply patches
```

### "Submodule not found"

Initialize submodules first:

```bash
git submodule update --init --recursive
```

### Build errors

See the full troubleshooting section in `ANTSDR-E310-V1-README.md`.

## Support

For questions or issues:
- Check `ANTSDR-E310-V1-README.md` for detailed documentation
- Original patches: https://github.com/maia-sdr/antsdr-fw-patch
- PlutoSDR Wiki: https://wiki.analog.com/university/tools/pluto
