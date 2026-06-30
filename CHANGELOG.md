# Changelog

## v1.0.0.0 (2026-06-30) — Initial Release

### Added
- Full Gentoo Linux installer built on VFF and forge-tui
- Larry the cow ASCII art welcome screen
- Stage3 variant selection (openrc, desktop-openrc, systemd, desktop-systemd, hardened-openrc, musl-openrc, selinux-openrc)
- Portage profile browser with stability indicators (stable/dev/exp), variant selection, and inheritance chain viewer
- Interactive USE flag configuration with descriptions from use.desc
- CFLAGS/MAKEOPTS auto-detection with CPU-specific -march, plus cpuid2cpuflags support writing to package.use/00cpu-flags
- VIDEO_CARDS configuration with GPU auto-detection and per-package settings
- Kernel selection: binary (gentoo-kernel, gentoo-kernel-bin), source (gentoo-sources with optional genkernel/dracut/manual config)
- Kernel config diff viewer comparing current config against distribution defaults
- sys-kernel/installkernel integration with USE flag configuration for automated kernel installation, initramfs, and UKI generation
- Kernel defconfig snippets for Intel laptop, AMD desktop, QEMU/KVM, VirtualBox, NVMe-minimal
- Chisel text editor for make.conf, package.use, kernel .config, and any config files
- EMERGE_DEFAULT_OPTS, FEATURES (ccache, buildpkg, parallel-install, getbinpkg, binpkg-request-signature, etc.) configuration
- GENTOO_MIRRORS selection via mirrorselect or manual entry
- Portage SYNC type (rsync/git)
- License acceptance (@FREE, @BINARY-REDISTRIBUTABLE, etc.)
- Official Gentoo binhost (distfiles.gentoo.org) with x86-64-v3 detection and dual-binhost fallback
- getuto keyring setup for binhost verification
- Overlay management via eselect repository list
- Desktop USE flag suggestions per DE (GNOME, KDE, XFCE, i3)
- Desktop extras: Vulkan drivers, printer support, Bluetooth, TLP power management, SSD TRIM, NM applet, fonts, input methods
- Firewall selection (firewalld, ufw, nftables)
- SSH server setup with host key generation
- Swap file creation as an alternative to partition
- tmpfs /tmp, microcode installation, NVIDIA proprietary driver handling
- Encrypted swap for LUKS installations
- ecryptfs home encryption
- Kernel module blacklisting
- Reuse existing /home partition without formatting
- Post-install script creation (Chisel-editable)
- Pre-populate world file with user-specified packages
- Auto-login configuration for desktop profiles (GDM, SDDM, LightDM)
- OpenRC tuning (parallel/hotplug) and systemd default target selection
- systemd-firstboot integration for systemd profiles
- Dual-boot support via os-prober with GRUB configuration
- GRUB_PLATFORMS="efi-64" set automatically for UEFI systems
- GRUB theme and bootloader timeout
- Hostname from DHCP or manual entry
- Quick profiles: Desktop, Server, Minimal
- Gentoo Wiki search with preview and full-page browsing in links
- Package search (emerge --searchdesc)
- Estimated build time for source packages
- Rust toolchain sanity warning for desktop profiles
- Installation summary with comprehensive list of choices including VIDEO_CARDS
- Sanity warnings for dangerous combinations (BIOS, manual kernel, LTO, systemd+OpenRC mismatch)
- Post-install news reader (eselect news), service picker, cron daemon (cronie) and system logger (sysklogd) pre-installed
- emerge --info dump saved to /root/emerge-info.txt for bug reports
- @module-rebuild reminder after kernel installation
- eix integration for fast package searching
- app-portage/gentoolkit pre-installed for system administration
- Gentoo handbook download for offline reference
- First boot checklist written to /root/gentooforge-first-boot.txt
- Save/load installation profile for reuse
- Rescue mode entrypoint (./rescue) for chroot recovery
- Full BIOS/Legacy boot support (inherited from VFF v2.1.0.0)
- ESP mounted at /efi per Gentoo Discoverable Partition Specification
- Musl stage3 detection with automatic locale-gen and timezone skip
- systemd-boot bootloader support for UEFI systems
- ACCEPT_KEYWORDS configuration (stable/~amd64 global or per-package)
- Modular TUI architecture split across 15 focused source files

### Verified against
- Gentoo AMD64 Handbook (all 10 installation chapters + Working with Gentoo + Working with Portage + OpenRC networking)