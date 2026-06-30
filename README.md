# GentooForge

A Gentoo Linux installer built on the Volk's Forge Framework.

Provides a guided TUI for Stage3 selection, Portage profile configuration, USE flag management, kernel setup, overlay management, and more — making Gentoo accessible without sacrificing control.

---

## Quick Start

```bash
git clone --recursive https://github.com/realvolk/GentooForge.git
cd GentooForge
chmod +x gforge
sudo ./gforge
```

---

## Requirements

### Environment

* Gentoo-based live ISO *(or any Linux live environment with Bash 4+)*
* UEFI or BIOS / Legacy boot
* Internet connection
* 5GB+ free disk space

### Dependencies

Install:

```bash
emerge www-client/links
```

Required packages:

* `bash`
* `links` *(text-mode browser for Gentoo Wiki browsing)*

---

## Features

### Installation

* Stage3 variant selection:

  * OpenRC
  * Desktop OpenRC *(recommended for graphical systems)*
  * systemd
  * Desktop systemd *(recommended for graphical systems)*
  * Hardened
  * musl
  * SELinux

* Disk partitioning

  * GPT (UEFI)
  * MBR (BIOS)
  * Whole-disk install
  * Manual partitioning

* Filesystem selection:

  * ext4
  * XFS
  * btrfs
  * f2fs

* Full disk encryption (LUKS2)

  * Optional keyfile
  * Encrypted swap

* LVM and LVM-on-LUKS support

* Bootloader support:

  * GRUB (BIOS + UEFI)
  * systemd-boot
  * rEFInd
  * EFIStub

* Unified Kernel Image (UKI) generation

* BTRFS subvolume layouts with descriptions

* Rescue mode entrypoint for chroot recovery

---

### Portage & Build Configuration

* Portage profile browser with stability indicators *(stable / dev / exp)*

* Profile inheritance chain viewer

* Interactive USE flag configuration with descriptions

* CFLAGS / MAKEOPTS auto-detection and CPU-specific optimization

* CPU_FLAGS_X86 auto-detection via `cpuid2cpuflags`

* VIDEO_CARDS GPU auto-detection

* Desktop-specific USE flag suggestions

* EMERGE_DEFAULT_OPTS and FEATURES configuration:

  * ccache
  * buildpkg
  * getbinpkg
  * etc.

* GENTOO_MIRRORS selection:

  * `mirrorselect`
  * Manual entry

* Portage sync types:

  * rsync
  * git

* ACCEPT_KEYWORDS:

  * `~amd64`
  * Per-package

* License acceptance

* Telemetry opt-out

---

### Kernel Management

Kernel options:

* Distribution kernel *(binary, precompiled)*
* Distribution kernel *(source, automated)*
* Source kernel with genkernel
* Source kernel with manual config

Additional features:

* Dracut or genkernel initramfs generation
* installkernel integration
* Kernel config diff viewer

Kernel presets:

* Intel laptops
* AMD desktops
* QEMU / KVM
* VirtualBox
* NVMe-minimal

Other:

* Microcode installation (Intel / AMD)
* Kernel module blacklisting

---

### Repository & Package Management

* Overlay management via `eselect repository`
* Official Gentoo binhost with x86-64-v3 auto-detection
* Package search:

```bash
emerge --searchdesc
```

---

### Desktop Environments

Supported desktops:

* GNOME
* KDE Plasma
* XFCE
* i3

Extras:

* Display manager auto-configuration
* Vulkan drivers
* Printer support
* Bluetooth
* TLP
* SSD TRIM
* Fonts
* Input methods

---

### System Configuration

* Hostname *(DHCP auto-detect or manual)*

* Timezone, locale, keymap with filterable search

* User management with group selection

* Shell selection:

  * bash
  * zsh
  * fish

* Privilege escalation:

  * sudo
  * doas

* OpenRC tuning:

  * Parallel boot
  * Hotplug

* Systemd target selection

* Firewall:

  * firewalld
  * ufw
  * nftables

* SSH server with host key generation

* Swap file support

* `tmpfs /tmp`

* Auto-login:

  * GDM
  * SDDM
  * LightDM

* Encrypted swap

* Home encryption (`ecryptfs`)

* Dual-boot via `os-prober`

* GRUB theme and timeout

* World file pre-population

* Post-install script creation *(Chisel-editable)*

* Optional:

```bash
emerge -e @world
```

---

### Tool Groups

#### Virtualization

* libvirt
* virt-manager
* qemu

#### Containers

* docker
* podman

#### Development

* gcc
* make
* git
* strace
* ltrace
* valgrind
* gdb

#### Gaming

* steam
* wine
* lutris
* gamemode

---

### Documentation & Help

* Gentoo Wiki search

  * In-installer preview
  * Full-page browsing

* Gentoo News reader (`eselect news`)

* `emerge --info` dump for bug reports

* Offline Gentoo Handbook download

* First boot checklist written to `/root`

* Install log viewer

* Bug report helper

---

### Post-Install

* Post-install service configuration
* Cron (`cronie`) and logging (`sysklogd`) pre-installed
* `eix` and `gentoolkit` pre-installed
* `@module-rebuild` reminders
* Installation profile save / load

---

### Quality of Life

* WiFi pre-connection
* NVIDIA proprietary driver handling
* Rust toolchain sanity warnings
* Estimated source build times
* Installation summary
* Dangerous configuration warnings
* Larry the cow ASCII welcome screen
* Chisel editor for any config file
* Zero-flicker TUI with mouse support
* Resume support *(state persistence across reboots)*

---

## Quick Profiles

| Profile     | Description                                               |
| ----------- | --------------------------------------------------------- |
| **Desktop** | GNOME, PipeWire, NetworkManager, Firefox, Neovim, Flatpak |
| **Server**  | Headless, OpenRC, SSH, cronie, firewalld                  |
| **Minimal** | Stage3 + essentials only, no desktop                      |
| **Custom**  | Full manual configuration (all TUI pages)                 |

---

## Architecture

GentooForge is a thin Gentoo-specific layer on top of:

### VFF (Volk's Forge Framework)

Distro-agnostic installer engine.

### forge-tui

Rust TUI library (`ratatui` + `crossterm`) with Chisel editor.

---

## License

Licensed under the **Forge Attribution License 1.0**

See [LICENSE](LICENSE)
