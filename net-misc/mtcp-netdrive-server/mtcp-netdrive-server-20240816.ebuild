# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="The mTCP NetDrive server is a program written in Go to provide network mountable disk images for MSDOS PCs. See https://www.brutman.com/mTCP/mTCP_NetDrive.html"
HOMEPAGE="https://www.brutman.com/mTCP/mTCP_NetDrive.html"
SRC_URI="https://www.brutman.com/mTCP/download/mTCP_NetDrive_2024-08-16_Servers.zip"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm64"

src_unpack() {
    unpack ${A}
}

src_install() {
    local arch=$(uname -m)
    local exec_name="netdrive"

    if [[ ${arch} == "x86_64" ]]; then
        exe="linux_x86/${exec_name}"
    elif [[ ${arch} == "aarch64" ]]; then
        exe="linux_arm/${exec_name}"
    else
        die "Unsupported architecture: ${arch}"
    fi

    exeinto /usr/bin
    doexe "${S}/${exe}"
}
