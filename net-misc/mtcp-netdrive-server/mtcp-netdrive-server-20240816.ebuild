# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

NETDRIVE_VERSION="2024-08-16"

DESCRIPTION="The mTCP NetDrive server is a program written in Go to provide network mountable disk images for MSDOS PCs. See https://www.brutman.com/mTCP/mTCP_NetDrive.html"
HOMEPAGE="https://www.brutman.com/mTCP/mTCP_NetDrive.html"
SRC_URI="https://www.brutman.com/mTCP/download/mTCP_NetDrive_${NETDRIVE_VERSION}_Servers.zip -> ${P}.zip"

# the archive is not on oficial mirrors and the executeable is already stripped
RESTRICT="mirror strip"

# there is a top level subdirectory in the zip file
S="${WORKDIR}/mTCP_NetDrive_${NETDRIVE_VERSION}_Servers"

SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="acct-group/mtcp-netdrive-server
        acct-user/mtcp-netdrive-server"

inherit systemd

src_install() {
    case ${ARCH} in
        amd64)
            mv "linux_x86/netdrive" "${S}/mtcp-netdrive-server"
            ;;
        arm64)
            mv "linux_arm/netdrive" "${S}/mtcp-netdrive-server"
            ;;
        *)
            die "Unsupported architecture: ${ARCH}"
            ;;
    esac

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

    DEFAULT_DISK_IMAGE="${MTCP_NETDRIVE_SERVER_DIR}/default_disk_image.dsk"

    # Create a default disk image if it does not exist
    if [[ ! -f "${DEFAULT_DISK_IMAGE}" ]]; then
        /usr/bin/mtcp-netdrive-server create hd 256 FAT16B "${DEFAULT_DISK_IMAGE}"
        fowners mtcp-netdrive-server:mtcp-netdrive-server "${DEFAULT_DISK_IMAGE}"
        fperms 0640 "${DEFAULT_DISK_IMAGE}"
    fi
}

pkg_postinst() {
    einfo "To create additional disk images, use the following command:"
    einfo "/usr/bin/mtcp-netdrive-server create hd <size_in_MB> <filesystem_type> <output_file>"
    einfo "Example: /usr/bin/mtcp-netdrive-server create hd 256 FAT16B /var/lib/mtcp-netdrive-server/new_disk_image.dsk"
    einfo "Make sure to set the ownership and permissions of the new disk image file"
    einfo "chown mtcp-netdrive-server:mtcp-netdrive-server /var/lib/mtcp-netdrive-server/new_disk_image.dsk"
    einfo "chmod 0640 /var/lib/mtcp-netdrive-server/new_disk_image.dsk"
    einfo ""
    einfo "To start the mTCP NetDrive server, enable and start the systemd service:"
    einfo "systemctl enable mtcp-netdrive-server"
}