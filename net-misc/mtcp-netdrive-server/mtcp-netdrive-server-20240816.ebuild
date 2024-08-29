# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

NETDRIVE_VERSION="2024-08-16"

DESCRIPTION="The mTCP NetDrive server is a program written in Go to provide network mountable disk images for MSDOS PCs. See https://www.brutman.com/mTCP/mTCP_NetDrive.html"
HOMEPAGE="https://www.brutman.com/mTCP/mTCP_NetDrive.html"
SRC_URI="https://www.brutman.com/mTCP/download/mTCP_NetDrive_${NETDRIVE_VERSION}_Servers.zip -> ${P}.zip"

RESTRICT="mirror"
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
}
