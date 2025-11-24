#!/bin/bash
# ANTSDR E310 V1 (ant) Support Installation Script
# This script applies all necessary patches to add ANTSDR E310 V1 support to maia-sdr/plutosdr-fw

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "======================================================================"
echo "ANTSDR E310 V1 (ant) Firmware Support Installer"
echo "======================================================================"
echo ""

# Check if we're in the right directory
if [ ! -f "Makefile" ] || [ ! -d ".git" ]; then
    echo "ERROR: This script must be run from the root of the plutosdr-fw repository"
    exit 1
fi

echo "Step 1: Checking submodules..."
if [ ! -d "buildroot/.git" ] || [ ! -d "hdl/.git" ] || [ ! -d "linux/.git" ] || [ ! -d "u-boot-xlnx/.git" ]; then
    echo "Submodules not initialized. Initializing..."
    git submodule update --init --recursive
else
    echo "Submodules already initialized."
fi

echo ""
echo "Step 2: Applying main repository patch..."
if [ -f "${SCRIPT_DIR}/antsdr-e310-v1-support.patch" ]; then
    git apply "${SCRIPT_DIR}/antsdr-e310-v1-support.patch"
    echo "✓ Main repository patch applied successfully"
else
    echo "ERROR: Main patch file not found: ${SCRIPT_DIR}/antsdr-e310-v1-support.patch"
    exit 1
fi

echo ""
echo "Step 3: Applying buildroot patch..."
if [ -f "${SCRIPT_DIR}/0001-add-ant-support-buildroot.patch" ]; then
    git apply --directory=buildroot "${SCRIPT_DIR}/0001-add-ant-support-buildroot.patch"
    echo "✓ Buildroot patch applied successfully"
else
    echo "ERROR: Buildroot patch not found"
    exit 1
fi

echo ""
echo "Step 4: Applying HDL patch..."
if [ -f "${SCRIPT_DIR}/0001-add-ant-support-hdl.patch" ]; then
    git apply --directory=hdl "${SCRIPT_DIR}/0001-add-ant-support-hdl.patch"
    echo "✓ HDL patch applied successfully"
else
    echo "ERROR: HDL patch not found"
    exit 1
fi

echo ""
echo "Step 5: Applying Linux kernel patch..."
if [ -f "${SCRIPT_DIR}/0001-add-ant-support-linux.patch" ]; then
    git apply --directory=linux "${SCRIPT_DIR}/0001-add-ant-support-linux.patch"
    echo "✓ Linux kernel patch applied successfully"
else
    echo "ERROR: Linux patch not found"
    exit 1
fi

echo ""
echo "Step 6: Applying U-Boot patch..."
if [ -f "${SCRIPT_DIR}/0001-add-ant-support-uboot.patch" ]; then
    git apply --directory=u-boot-xlnx "${SCRIPT_DIR}/0001-add-ant-support-uboot.patch"
    echo "✓ U-Boot patch applied successfully"
else
    echo "ERROR: U-Boot patch not found"
    exit 1
fi

echo ""
echo "======================================================================"
echo "✓ All patches applied successfully!"
echo "======================================================================"
echo ""
echo "To build the ANTSDR E310 V1 firmware:"
echo "  1. Set Vivado environment:"
echo "     export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2023.2/settings64.sh"
echo ""
echo "  2. Build the firmware:"
echo "     export TARGET=ant"
echo "     make"
echo ""
echo "  3. Or build SD card image:"
echo "     export TARGET=ant"
echo "     make sdimg"
echo ""
echo "Build artifacts will be in the 'build/' directory"
echo "SD card files will be in the 'build_sdimg/' directory"
echo "======================================================================"
