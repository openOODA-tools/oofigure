# oofigure: Sovereign BOX DRAWING

<div align="center">

```
================================================================================
                                oofigure
               Sovereign openOODA BOX DRAWING
================================================================================
```

**Sovereign BOX DRAWING & Terminal Geometry Engine**  
*Renders beautiful Unicode box-drawing tables, callouts, and code borders.*  
*Two Faces, One Engine:* Modern terminal ergonomics for humans • Zero-leakage MCP for AI agents  
Written in 100% pure [openOODA](https://github.com/openOODA).

[![License: Apache-2.0](https://img.shields.io/badge/License-Apache_2.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![openOODA](https://img.shields.io/badge/openOODA-1.0-emerald.svg)](https://openooda.org)
[![Architecture: x86_64 | aarch64](https://img.shields.io/badge/Arch-x86__64%20%7C%20aarch64-lightgrey.svg)]()

</div>

---

## 1. Quick Install

### Automated Installer (Linux x86_64 & aarch64)
```bash
curl -fsSL https://openooda-tools.github.io/oofigure/install.sh | bash
```

### Native Package Managers
```bash
# Arch Linux (AUR / PKGBUILD)
yay -S oofigure-bin
# Or manual PKGBUILD:
cd packaging/arch && makepkg -si

# Debian / Ubuntu (.deb)
curl -fsSL https://openooda-tools.github.io/oofigure/install.sh | bash -s -- --deb

# Fedora / RHEL (.rpm)
curl -fsSL https://openooda-tools.github.io/oofigure/install.sh | bash -s -- --rpm
```

### Uninstallation
```bash
oofigure-uninstall
# or: curl -fsSL https://openooda-tools.github.io/oofigure/uninstall.sh | bash
```

---

## 2. CLI Usage

```
usage: oofigure [options] [TEXT...]

Renders beautiful Unicode box-drawing tables, callouts, and code borders.

Options:
  -s, --style <STYLE>   border style: rounded, single, double, heavy, ascii [default: rounded]
  -t, --title <TITLE>   embed title into top border bar
  -c, --callout <TYPE>  format as GFM alert: note, tip, important, warning, caution
  -p, --padding <N>     inner horizontal padding in columns [default: 1]
      --align <ALIGN>   text alignment: left, center, right [default: left]
      --numbers         prepend line numbers inside panel
  -w, --width <N>       fixed outer width (0 = auto-fit to content)
  -j, --json            output figure geometry and lines as JSON
  -D, --demo            render multi-style showcase and alert gallery
      --test            execute internal subsystem verification suite
      --mcp             run as Model Context Protocol JSON-RPC stdio server
  -h, --help            display this help and exit
  -v, --version         output version information and exit
```

---

## 3. Model Context Protocol (MCP)

When invoked with `--mcp`, `oofigure` runs a JSON-RPC 2.0 stdio server providing structured tools for AI coding agents:

* `figure_box`: Draws a bordered box around text with custom style, title, padding, and alignment.
* `figure_callout`: Formats a GitHub/GFM alert callout box (`note`, `tip`, `important`, `warning`, `caution`).
* `figure_code`: Formats a code block panel with line numbers and title.
* `figure_table`: Formats a multi-column grid table from comma-separated rows.
* `figure_styles`: Lists supported border styles and glyph definitions.
* `figure_demo`: Runs interactive box drawing and callout showcase.

```bash
oofigure --mcp
```

---

## 4. Security & Zero Ambient Authority

* **Pure Capability Bounded:** Operates strictly with explicit tokens (`&FsReadCap`, `&ProcessCap`, `&EnvCap`). Physical absence of ambient disk/net leakage.
* **Negative-Trust Architecture:** Strict input validation and operational limits.
* **Hermetic Binary:** Standalone zero-dependency executable.

---

## 5. License

Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
