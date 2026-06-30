# GentooForge Features

Every feature in the GentooForge installer, organized by category.

---

## Installation Pipeline

Inherited from VFF. Stage-based with full resume support.

| Feature | Description |
|---|---|
| Disk partitioning | GPT (UEFI) or MBR (BIOS), whole-disk or manual via cfdisk |
| Filesystems | ext4, btrfs, xfs, f2fs |
| LUKS encryption | Full-disk with LUKS2, optional keyfile, optional encrypted swap |
| LVM | Logical Volume Management, LVM-on-LUKS |
| Bootloader | GRUB (BIOS + UEFI), systemd-boot, rEFInd, EFIStub (UEFI only) |
| UKI | Unified Kernel Image generation (UEFI only) |
| BTRFS subvolumes | standard, flat, snapshot layouts with descriptions |
| Stage3 bootstrap | Gentoo stage3 extraction with variant selection |
| Base system install | emerge with --noreplace |
| System configuration | hostname, locale, timezone, keymap (musl-aware: skips locale-gen and timezone symlink) |
| User management | add/edit/remove users, groups, shell, sudo/doas |
| Network setup | NetworkManager or dhcpcd+iwd with service enablement |
| Post-install | desktop, audio, GPU drivers, extras |
| Bootloader install | GRUB with LUKS/LVM awareness, GRUB_PLATFORMS="efi-64" auto-set for UEFI, os-prober for dual-boot |
| installkernel integration | Automated kernel installation, initramfs generation, UKI creation via sys-kernel/installkernel |
| systemd-firstboot | Automated locale/timezone/hostname configuration for systemd profiles |
| ESP mount | /efi per Gentoo Discoverable Partition Specification |
| Resume support | state persistence across reboots and failures |
| Recovery | rescue mode entrypoint for chroot recovery |

---

## Boot Modes

| Mode | Description |
|---|---|
| UEFI | GPT partitioning, EFI System Partition at /efi, GRUB x86_64-efi, systemd-boot, rEFInd, EFIStub, UKI |
| BIOS / Legacy | MBR partitioning, GRUB i386-pc, no ESP required |

---

## Stage3 Variants

| Variant | Description |
|---|---|
| openrc | OpenRC init system |
| desktop-openrc | OpenRC with desktop packages (recommended for graphical systems) |
| systemd | systemd init system |
| desktop-systemd | systemd with desktop packages (recommended for graphical systems) |
| hardened-openrc | Hardened profile with OpenRC |
| musl-openrc | Musl libc with OpenRC |
| selinux-openrc | SELinux enabled with OpenRC |

---

## Portage Configuration

| Feature | Description |
|---|---|
| Profile selector | Browse all Portage profiles with stability indicators (stable/dev/exp) |
| Profile variants | Select sub-variant (desktop, systemd, etc.) within chosen profile |
| Profile inheritance viewer | Display parent chain for selected profile |
| USE flags | Interactive checklist with descriptions from use.desc |
| USE flag defaults | Pre-selected recommended flags based on profile choice |
| Desktop USE suggestions | Automatic flag recommendations per DE (GNOME, KDE, XFCE, i3) |
| CFLAGS | Auto-detection with CPU-specific -march (-march=native, x86-64-v2/v3/v4, znver2/3/4) |
| RUSTFLAGS | Auto-detection with CPU-specific optimization (-C target-cpu=native) |
| MAKEOPTS | Auto-detected -j$(nproc) with override |
| Per-package CFLAGS | Custom compiler flags for specific packages via /etc/portage/env/ and package.env |
| CPU_FLAGS_X86 | Auto-detection via cpuid2cpuflags, written to package.use/00cpu-flags |
| VIDEO_CARDS | GPU auto-detection with per-package settings in package.use/00video_cards |
| EMERGE_DEFAULT_OPTS | --jobs, --load-average |
| FEATURES | ccache, buildpkg, parallel-install, keep-going, userpriv, quiet-build, getbinpkg, binpkg-request-signature |
| ccache | Optional cache size configuration |
| SYNC type | rsync or git |
| GENTOO_MIRRORS | mirrorselect or manual entry |
| Licenses | @FREE, @BINARY-REDISTRIBUTABLE, @EULA, GPL-2/3, LGPL, BSD, MIT, Apache |
| ACCEPT_KEYWORDS | Global ~amd64 or per-package |
| Binhost | Official distfiles.gentoo.org binhost with x86-64-v3 auto-detection and dual-binhost fallback |
| getuto | Automatic keyring setup for binhost verification |
| Overlays | eselect repository list, enable/disable, priority editing |
| Telemetry opt-out | Mask dev-libs/telemetry |
| Chisel editor | Direct editing of make.conf, package.use, package.accept_keywords, repos.conf, package.mask |

---

## Kernel

| Feature | Description |
|---|---|
| gentoo-kernel | Distribution kernel (source, automated build) |
| gentoo-kernel-bin | Distribution kernel (binary, precompiled) |
| gentoo-sources | Source kernel with manual config |
| gentoo-sources-genkernel | Source kernel with genkernel automation |
| genkernel | Automated kernel build |
| dracut | Alternative initramfs generator |
| Manual config | menuconfig in chroot during install |
| Kernel config diff | Compare current config against distribution defaults |
| Defconfig snippets | Intel laptop, AMD desktop, QEMU/KVM, VirtualBox, NVMe-minimal |
| Chisel editor | Direct editing of .config |
| Microcode | Intel or AMD microcode installation |
| Module blacklisting | Blacklist kernel modules (e.g. nouveau) |
| @module-rebuild reminder | Post-install reminder for external kernel module users |

---

## Desktop Environments

| DE/WM | Display Manager | Notes |
|---|---|---|
| GNOME | GDM | Wayland, full desktop |
| KDE Plasma | SDDM | Full, desktop, or minimal profile |
| XFCE | LightDM | Full or minimal |
| i3 | LightDM | Tiling window manager |

### Desktop Extras

| Feature | Description |
|---|---|
| Vulkan drivers | mesa-vulkan-drivers, vulkan-loader |
| Printer support | CUPS + system-config-printer |
| Bluetooth | BlueZ with service enablement |
| Power management | TLP for laptops |
| SSD TRIM | fstrim timer |
| NetworkManager applet | nm-applet + gnome-keyring |
| Fonts | Noto + DejaVu |
| Input methods | ibus or fcitx |

---

## System Configuration

| Feature | Description |
|---|---|
| Hostname | DHCP auto-detect or manual entry |
| Timezone | Filterable list from /usr/share/zoneinfo |
| Locale | Filterable list from /etc/locale.gen |
| Keymap | Filterable list from localectl or /usr/share/kbd/keymaps |
| User groups | wheel, audio, video, storage, plugdev, cdrom, scanner, libvirt, docker, usb |
| Shell | bash, zsh, fish |
| Privilege escalation | sudo, doas, none |
| OpenRC tuning | rc_parallel, rc_hotplug |
| Systemd target | graphical.target or multi-user.target |
| Cron daemon | cronie pre-installed and enabled |
| System logger | sysklogd pre-installed and enabled |
| eix | Optional fast package search tool |
| gentoolkit | app-portage/gentoolkit pre-installed (equery, eclean, etc.) |
| Firewall | firewalld, ufw, or nftables with service enablement |
| SSH server | openssh with host key generation |
| Swap file | Fallocate-created swap file as alternative to partition |
| tmpfs /tmp | Mount /tmp as tmpfs |
| Auto-login | GDM, SDDM, or LightDM auto-login configuration |
| Encrypted swap | Random-key LUKS encrypted swap |
| ecryptfs | Home directory encryption |
| GRUB theme | Dark GRUB theme |
| Bootloader timeout | Configurable seconds |
| Dual-boot | os-prober for detecting other operating systems |
| Reuse /home | Preserve existing /home partition without formatting |
| World file | Pre-populate @world with user-specified packages |
| Post-install script | Chisel-editable first-boot script |
| World rebuild | Optional emerge -e @world |

---

## Quick Profiles

| Profile | Description |
|---|---|
| Desktop | GNOME, PipeWire, NetworkManager, gentoo-kernel-bin, desktop-openrc stage3, Firefox, Neovim, Alacritty, Flatpak |
| Server | Headless, OpenRC, gentoo-kernel, SSH pre-enabled, cronie, firewalld, Neovim, Git, htop, tmux |
| Minimal | Stage3 + essentials only, OpenRC, gentoo-kernel, nano, sudo |

---

## Tool Groups

| Group | Packages |
|---|---|
| Virtualization | libvirt, virt-manager, qemu |
| Containers | docker, podman |
| Development | gcc, make, git, strace, ltrace, valgrind, gdb |
| Gaming | steam, wine, lutris, gamemode |

---

## Search and Help

| Feature | Description |
|---|---|
| Gentoo Wiki search | Query wiki.gentoo.org API, preview extracts, open full pages in links |
| Package search | emerge --searchdesc with scrollable results |
| Gentoo News | eselect news reader during post-install |
| emerge --info dump | Saved to /root/emerge-info.txt for bug reports |
| Offline Handbook | Download Gentoo Handbook in chosen language |
| First boot checklist | Written to /root/gentooforge-first-boot.txt with next steps |
| Install log viewer | Full log display before reboot |
| Bug report helper | Links to bugs.gentoo.org |

---

## Quality of Life

| Feature | Description |
|---|---|
| WiFi setup | Connect to WiFi via iwctl or wpa_supplicant before install |
| NVIDIA handling | Proprietary driver install + nouveau blacklist |
| Rust toolchain warning | Notifies when packages may require dev-lang/rust or rust-bin |
| Estimated build time | Rough heuristic for source package compile time |
| Installation summary | Full configuration overview before commit |
| Sanity warnings | Dangerous combination detection |
| Profile save/load | Export and reuse installation configurations |
| Larry the cow | ASCII art welcome screen |
| Chisel text editor | Full multi-line editor for any config file |
| Zero-flicker TUI | forge-tui daemon mode with persistent terminal frame |
| Mouse support | Click and scroll in menus, checklists, and summary views |

---

## Hardware Support

| Component | Detection / Configuration |
|---|---|
| CPU | Vendor detection, -march optimization, CPU_FLAGS_X86 |
| GPU | Vendor detection, driver selection (Intel, AMD, NVIDIA, VMs) |
| Storage | NVMe, SATA, virtio |
| VMs | QEMU/KVM, VirtualBox, VMware guest support |
| Boot mode | UEFI or BIOS auto-detection |
| Network | WiFi pre-connection, NetworkManager or dhcpcd+iwd |
| Audio | PipeWire or PulseAudio with auto-detection |

---

## Future

Features intentionally deferred to future releases:

| Feature | Reason |
|---|---|
| forge-gui (GTK4) | GUI integration after TUI is stable |
| ISO builder | Requires artools or equivalent Gentoo live-build tooling |
| Full recovery mode | Needs real-world testing data |
| ZFS root | VFF supports it, needs Gentoo-specific validation |
| Offline cache | USB distfile/binary package caching |
| Additional desktop environments | sway, hyprland, dwm, cosmic, cinnamon, budgie, etc. |
| Proprietary NVIDIA Optimus | Bumblebee / optimus-manager |
| Detached LUKS headers | Requires VFF modification |
| Password strength meter | Requires forge-tui modification |
| Gentoo news RSS in TUI | Minor, fun addition |

---

## License

Forge Attribution License 1.0 — see [LICENSE](LICENSE)