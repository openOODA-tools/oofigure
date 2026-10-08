Name:           oofigure
Version:        0.2.0
Release:        1%{?dist}
Summary:        Sovereign Unicode box-drawing tables, callouts, and code borders
License:        Apache-2.0
URL:            https://github.com/openOODA-tools/oofigure
Source0:        oofigure-linux-x86_64
Source1:        uninstall.sh
BuildArch:      x86_64
Requires:       glibc

%description
oofigure is a sovereign, capability-bounded BOX DRAWING utility written
in pure openOODA, featuring zero ambient authority, Unicode and ASCII styles,
alert callout boxes, code panels, and a streaming Model Context Protocol (MCP) server.

%install
mkdir -p %{buildroot}/usr/bin
install -m 0755 %{SOURCE0} %{buildroot}/usr/bin/oofigure
install -m 0755 %{SOURCE1} %{buildroot}/usr/bin/oofigure-uninstall

%files
/usr/bin/oofigure
/usr/bin/oofigure-uninstall

%changelog
* Thu Oct 08 2026 openOODA-tools <ops@openooda.org> - 0.2.0-1
- Elevate to sovereign pure openOODA v0.2.0 with box styles, callouts, and streaming MCP
* Wed Oct 07 2026 openOODA-tools <ops@openooda.org> - 0.1.0-1
- Initial sovereign blueprint scaffolding
