# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV:0:4}-${PV:4:2}-${PV:6:2}"

DESCRIPTION="The mTCP NetDrive server is a program written in Go to provide network mountable disk images for MSDOS PCs. See https://www.brutman.com/mTCP/mTCP_NetDrive.html"
HOMEPAGE="https://www.brutman.com/mTCP/mTCP_NetDrive.html"
SRC_URI="https://www.brutman.com/mTCP/download/mTCP_NetDrive_${MY_PV}_Servers.zip -> ${P}.zip"

# the archive is not on official mirrors and the executable is already stripped
RESTRICT="mirror strip"

S="${WORKDIR}"

SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
    acct-group/mtcp-netdrive-server
    acct-user/mtcp-netdrive-server
"

BDEPEND="
    app-arch/unzip
"

inherit systemd

src_unpack() {
    case ${ARCH} in
        amd64)
            unzip -j "${DISTDIR}/${P}.zip" '*/linux_x86/netdrive' -d "${S}"
            ;;
        arm64)
            unzip -j "${DISTDIR}/${P}.zip" '*/linux_arm/netdrive' -d "${S}"
            ;;
        *)
            die "Unsupported architecture: ${ARCH}"
            ;;
    esac

    unzip -j "${DISTDIR}/${P}.zip" "*/netdrive.txt" -d "${S}"
}

src_prepare() {
    default
    mv "${S}/netdrive" "${S}/mtcp-netdrive-server"
}

src_install() {
    exeinto /usr/bin
    doexe "${S}/mtcp-netdrive-server"

    # install systemd service
    systemd_dounit "${FILESDIR}"/mtcp-netdrive-server.service

    # Install configuration file
    insinto /etc
    doins "${FILESDIR}"/mtcp-netdrive-server.conf

    # Set ownership and permissions
    fowners mtcp-netdrive-server:mtcp-netdrive-server /etc/mtcp-netdrive-server.conf
    fperms 0640 /etc/mtcp-netdrive-server.conf

    # Define the directory path variable
    MTCP_NETDRIVE_SERVER_DIR="/var/lib/mtcp-netdrive-server"

    # Create the directory for filesystem images
    keepdir "${MTCP_NETDRIVE_SERVER_DIR}"
    fowners mtcp-netdrive-server:mtcp-netdrive-server "${MTCP_NETDRIVE_SERVER_DIR}"
    fperms 0750 "${MTCP_NETDRIVE_SERVER_DIR}"

    dodoc "${S}/netdrive.txt"
}

pkg_postinst() {
    einfo "To create disk images, use the following command:"
    einfo "mtcp-netdrive-server create hd <size_in_MB> <filesystem_type> <output_file>"
    einfo "Example: mtcp-netdrive-server create hd 256 FAT16B /var/lib/mtcp-netdrive-server/disk.dsk"
    einfo
    einfo "Make sure to set the ownership and permissions of the new disk image file"
    einfo "chown mtcp-netdrive-server:mtcp-netdrive-server /var/lib/mtcp-netdrive-server/disk.dsk"
    einfo "chmod 0640 /var/lib/mtcp-netdrive-server/disk.dsk"
    einfo
    einfo "For more information on advanced topics like journaling or session scoped volumes,"
    einfo "see the documentation at http://www.brutman.com/mTCP/Netdrive_documentation"
    einfo
    einfo "To start the mTCP NetDrive server, enable and start the systemd service:"
    einfo "systemctl enable mtcp-netdrive-server"
}
