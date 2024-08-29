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

src_install() {
    local exec_name="netdrive"
    local exe

    case ${ARCH} in
        amd64)
            exe="linux_x86/${exec_name}"
            ;;
        arm64)
            exe="linux_arm/${exec_name}"
            ;;
        *)
            die "Unsupported architecture: ${ARCH}"
            ;;
    esac

    exeinto /usr/bin
    doexe "${S}/${exe}"
}