# ANTSDR E310 V1 (ant) Firmware Support

This patch set adds complete firmware support for the **ANTSDR E310 V1** (codename: "ant") SDR platform to the maia-sdr/plutosdr-fw repository.

## What's Included

### Main Repository Changes
- **Makefile**: Added `ant` target support, uImage build, and SD card image generation
- **scripts/ant.mk**: Target-specific configuration (device VID/PID, board name, etc.)
- **scripts/ant.its**: Flattened Image Tree (FIT) configuration for firmware packaging

### Submodule Changes

#### buildroot
- Complete board support package in `board/ant/`
- Init scripts, network configuration, USB gadget setup
- Mass Storage Device (MSD) web interface
- Buildroot defconfig: `configs/zynq_ant_defconfig`

#### hdl (FPGA)
- Complete Vivado project in `projects/ant/`
- System block design (Zynq PS7 + AD9361 + AXI peripherals)
- Pin constraints for ANTSDR E310 V1 hardware
- FPGA bitstream generation support

#### u-boot-xlnx
- Device tree: `arch/arm/dts/zynq-ant.dts`
- Board defconfig: `configs/zynq_ant_defconfig`
- SD card boot support added to common config
- USB gadget configuration (VID: 0x0456, PID: 0xb674)

#### linux
- Kernel device tree: `arch/arm/boot/dts/zynq-ant.dts` and `zynq-ant.dtsi`
- AD9361 transceiver configuration
- Ethernet (RGMII), USB host, SD card, QSPI flash support
- Kernel defconfig: `arch/arm/configs/zynq_ant_defconfig`

## Installation

### Quick Start

```bash
# 1. Clone the plutosdr-fw repository
git clone --recursive https://github.com/maia-sdr/plutosdr-fw.git
cd plutosdr-fw

# 2. Download the patch files to this directory
# (Copy all 6 patch files: antsdr-e310-v1-support.patch and 5 0001-add-ant-support-*.patch files)

# 3. Run the installation script
chmod +x apply-antsdr-patches.sh
./apply-antsdr-patches.sh

# 4. Build the firmware
export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2023.2/settings64.sh
export TARGET=ant
make
```

### Manual Installation

If you prefer to apply patches manually:

```bash
# Main repository
git apply antsdr-e310-v1-support.patch

# Submodules
git apply --directory=buildroot 0001-add-ant-support-buildroot.patch
git apply --directory=hdl 0001-add-ant-support-hdl.patch
git apply --directory=linux 0001-add-ant-support-linux.patch
git apply --directory=u-boot-xlnx 0001-add-ant-support-uboot.patch
```

## Building

### Prerequisites

- Xilinx Vivado 2023.2 (or compatible version)
- Build tools: `git`, `make`, `gcc`, `device-tree-compiler`, `u-boot-tools`, `dfu-util`
- Linaro ARM toolchain (automatically downloaded by buildroot)

### Build Commands

#### Standard Firmware Build
```bash
export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2023.2/settings64.sh
export TARGET=ant
make
```

This generates:
- `build/ant.frm` - Main firmware file (for USB mass storage update)
- `build/ant.dfu` - DFU mode firmware file
- `build/boot.frm` - Bootloader
- `build/boot.dfu` - Bootloader (DFU mode)

#### SD Card Image Build
```bash
export TARGET=ant
make sdimg
```

This generates files in `build_sdimg/`:
- `BOOT.bin` - First stage bootloader + FPGA bitstream + U-Boot
- `uImage` - Linux kernel
- `devicetree.dtb` - Device tree blob
- `uramdisk.image.gz` - Root filesystem ramdisk

Copy these files to a FAT32-formatted SD card to boot from SD.

## Hardware Support

### ANTSDR E310 V1 Specifications
- **FPGA**: Xilinx Zynq-7020 (XC7Z020-CLG400)
- **RF Transceiver**: Analog Devices AD9361 (70 MHz - 6 GHz)
- **RAM**: 1 GB DDR3
- **Flash**: 64 MB QSPI (Micron N25Q512A)
- **Ethernet**: 10/100/1000 Mbps (RGMII)
- **USB**: USB 2.0 OTG (host mode in this config)
- **SD Card**: microSD slot
- **LED**: 1x GPIO LED (heartbeat)
- **Button**: 1x GPIO button

### Boot Modes
1. **QSPI Flash Boot** (default): Boots from on-board flash memory
2. **SD Card Boot**: Boots from microSD card (requires SD card with BOOT.bin)

## Firmware Features

- **USB Gadget Mode**: Composite device (RNDIS + Mass Storage)
- **Web Interface**: Browser-based configuration via USB or Ethernet
- **IIO Support**: Industrial I/O framework for AD9361 control
- **libiio**: Remote access to AD9361 via network
- **DFU Update**: Firmware update via USB DFU protocol

## Differences from PlutoSDR

| Feature | PlutoSDR | ANTSDR E310 V1 |
|---------|----------|----------------|
| FPGA | Zynq-7010 | Zynq-7020 |
| RAM | 512 MB | 1 GB |
| Ethernet | No | Yes (Gigabit) |
| Form Factor | USB Dongle | Standalone Box |
| Power | USB-powered | External 5V/2A |

## Troubleshooting

### Build Issues

**Problem**: `make: *** No rule to make target 'scripts/ant.mk'`
**Solution**: Ensure the main patch was applied correctly. The file should exist in `scripts/ant.mk`.

**Problem**: Submodule errors during build
**Solution**: Ensure submodules are initialized:
```bash
git submodule update --init --recursive
```

**Problem**: `VIVADO_SETTINGS not found`
**Solution**: Set the correct path to your Vivado installation:
```bash
export VIVADO_SETTINGS=/opt/Xilinx/Vivado/2023.2/settings64.sh
```

### Runtime Issues

**Problem**: Device not booting from SD card
**Solution**:
1. Ensure SD card is FAT32 formatted
2. Copy all files from `build_sdimg/` to the SD card root
3. Check boot mode jumpers on the board

**Problem**: Ethernet not working
**Solution**: Check the device tree PHY reset GPIO configuration in `zynq-ant.dts`

## Development

### Rebuilding Individual Components

```bash
# Rebuild Linux kernel only
make -C linux ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zynq_ant_defconfig
make -C linux ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage

# Rebuild U-Boot only
make -C u-boot-xlnx ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zynq_ant_defconfig
make -C u-boot-xlnx ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-

# Rebuild FPGA bitstream
cd hdl/projects/ant
make
```

## Credits

- Original ANTSDR patches: [maia-sdr/antsdr-fw-patch](https://github.com/maia-sdr/antsdr-fw-patch)
- PlutoSDR firmware: [analogdevicesinc/plutosdr-fw](https://github.com/analogdevicesinc/plutosdr-fw)
- ANTSDR Hardware: MicroPhase Technology

## License

This patch set follows the same licensing as the original plutosdr-fw repository (mixed GPL/LGPL/BSD licenses).

## Support

For issues specific to ANTSDR E310 V1:
- Check the [antsdr-fw-patch repository](https://github.com/maia-sdr/antsdr-fw-patch)
- MicroPhase ANTSDR documentation

For general PlutoSDR firmware issues:
- [PlutoSDR Wiki](https://wiki.analog.com/university/tools/pluto)
- [ADI EngineerZone](https://ez.analog.com/)
