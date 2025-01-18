# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MY_PV="${PV:0:4}-${PV:4:2}-${PV:6:2}"

DESCRIPTION="The mTCP NetDrive server is written in Go to provide network mountable disk images for MS-DOS PCs."
HOMEPAGE="https://www.brutman.com/mTCP/mTCP_NetDrive.html"
SRC_URI="https://www.brutman.com/mTCP/download/mTCP_NetDrive_server-src_${MY_PV}.zip -> ${P}.zip"
SRC_URI+=" https://raw.githubusercontent.com/ccharon/netdrive-deps/refs/heads/main/mTCP_NetDrive_server-src_${MY_PV}-vendor.tar.xz -> ${P}-deps.tar.xz"

LICENSE="GPL-3"

# the archive is not on official mirrors
RESTRICT="mirror"

S="${WORKDIR}"

SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
    acct-group/mtcp-netdrive
    acct-user/mtcp-netdrive
"

BDEPEND="
    app-arch/unzip
"

inherit go-module systemd


src_unpack() {
    if use amd64 || use arm || use arm64 ||
        ( use ppc64 && [[ $(tc-endian) == "little" ]] ) || use s390 || use x86; then
            GOFLAGS="-buildmode=pie ${GOFLAGS}"
    fi
    GOFLAGS="${GOFLAGS} -p=$(makeopts_jobs)"

    default

    mv "${S}/mTCP_NetDrive_server-src_${MY_PV}/netdrive/"*   "${S}" || die
    mv "${S}/mTCP_NetDrive_server-src_${MY_PV}/copying.txt"  "${S}" || die
    mv "${S}/mTCP_NetDrive_server-src_${MY_PV}/00readme.txt" "${S}/readme.txt" || die
    rm -r "${S}/mTCP_NetDrive_server-src_${MY_PV}"
}

src_compile() {
    # do not use real build date as this build date gets displayed as version of netdrive
    # adding GENTOO to mark this as custom build
    builddate="$(date -d "${MY_PV}" +"%b %d %Y") GENTOO"
    ego build -ldflags="-s -w -X 'brutman.com/brutman/netdrv/globals.BuildDate=${builddate}'" -o mtcp-netdrive brutman.com/brutman/netdrv
}

src_install() {
    exeinto /usr/bin
    doexe "${S}/mtcp-netdrive"

    dodoc "${S}/readme.txt"
    dodoc "${S}/copying.txt"

    # install systemd service
    systemd_dounit "${FILESDIR}"/mtcp-netdrive.service

    # Install configuration file
    insinto /etc
    doins "${FILESDIR}"/mtcp-netdrive.conf
    fowners mtcp-netdrive:mtcp-netdrive /etc/mtcp-netdrive.conf
    fperms 0640 /etc/mtcp-netdrive.conf

    # Create filesystem images directory
    MTCP_IMAGE_DIR="/var/lib/mtcp-netdrive"
    keepdir "${MTCP_IMAGE_DIR}"
    fowners mtcp-netdrive:mtcp-netdrive "${MTCP_IMAGE_DIR}"
    fperms 0750 "${MTCP_IMAGE_DIR}"

    # Create session storage directory
    MTCP_SESSION_DIR="/var/lib/mtcp-netdrive/sessions"
    keepdir "${MTCP_SESSION_DIR}"
    fowners mtcp-netdrive:mtcp-netdrive "${MTCP_SESSION_DIR}"
    fperms 0750 "${MTCP_SESSION_DIR}"

    # Create the log directory
    MTCP_LOG_DIR="/var/log/mtcp-netdrive"
    keepdir "${MTCP_LOG_DIR}"
    fowners mtcp-netdrive:mtcp-netdrive "${MTCP_LOG_DIR}"
    fperms 0750 "${MTCP_LOG_DIR}"
}

pkg_postinst() {
    einfo "To create disk images, use the following command:"
    einfo "mtcp-netdrive create hd <size_in_MB> <filesystem_type> <output_file>"
    einfo "Example: mtcp-netdrive create hd 256 FAT16B /var/lib/mtcp-netdrive/disk.dsk"
    einfo
    einfo "Make sure to set the ownership and permissions of the new disk image file"
    einfo "chown mtcp-netdrive:mtcp-netdrive /var/lib/mtcp-netdrive/disk.dsk"
    einfo "chmod 0640 /var/lib/mtcp-netdrive/disk.dsk"
    einfo
    einfo "For more information on advanced topics like journaling or session scoped volumes,"
    einfo "see the documentation at http://www.brutman.com/mTCP/Netdrive_documentation"
    einfo
    einfo "To start the mTCP NetDrive server, enable and start the systemd service:"
    einfo "systemctl enable mtcp-netdrive"
}
