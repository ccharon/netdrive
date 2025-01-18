# Copyright 1999-2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit go-module systemd

MY_PV="${PV:0:4}-${PV:4:2}-${PV:6:2}"

DESCRIPTION="The mTCP NetDrive server by M. Brutman, is written in Go to provide network mountable disk images for MS-DOS PCs."
HOMEPAGE="https://www.brutman.com/mTCP/mTCP_NetDrive.html"
SRC_URI="https://www.brutman.com/mTCP/download/mTCP_NetDrive_server-src_${MY_PV}.zip -> ${P}.zip"
SRC_URI+=" https://raw.githubusercontent.com/ccharon/netdrive-deps/refs/heads/main/mTCP_NetDrive_server-src_${MY_PV}-vendor.tar.xz -> ${P}-deps.tar.xz"

LICENSE="GPL-3"

# the archive is not on official mirrors
RESTRICT+="mirror"

S="${WORKDIR}/mTCP_NetDrive_server-src_${MY_PV}/netdrive"

SLOT="0"
KEYWORDS="~amd64 ~arm64"

DEPEND="
    acct-group/"${PN}"
    acct-user/"${PN}"
"

BDEPEND="
    app-arch/unzip
"

src_compile() {
    # do not use real build date as this build date gets displayed as version of netdrive
    # adding GENTOO to mark this as custom build
    builddate="$(date -d "${MY_PV}" +"%b %d %Y") GENTOO"
    ego build -ldflags="-s -w -X 'brutman.com/brutman/netdrv/globals.BuildDate=${builddate}'" \
        -o "${PN}" brutman.com/brutman/netdrv || die "${PN} build failed"
}

src_install() {
    dobin "${PN}"

    mv "${S}/../00readme.txt" "${S}/readme.txt" || die
    mv "${S}/../copying.txt" "${S}/license.txt" || die
    dodoc -r readme.txt license.txt ../netdrive_test

    # systemd service
    systemd_dounit "${FILESDIR}/${PN}.service"

    # config file
    insinto /etc
    doins "${FILESDIR}/${PN}.conf"
    fowners "${PN}":"${PN}" "/etc/${PN}.conf"
    fperms 0640 "/etc/${PN}.conf"

    diropts -o"${PN}" -g"${PN}" -m0750

    # filesystem images directory
    keepdir "/var/lib/${PN}"

    # session storage directory
    keepdir "/var/lib/${PN}/sessions"

    # log directory
    keepdir "/var/log/${PN}"
}

pkg_postinst() {
    einfo "To create disk images, use the following command:"
    einfo "${PN} create hd <size_in_MB> <filesystem_type> <output_file>"
    einfo "Example: ${PN} create hd 256 FAT16B /var/lib/${PN}/disk.dsk"
    einfo
    einfo "Make sure to set the ownership and permissions of the new disk image file"
    einfo "chown ${PN}:${PN} /var/lib/${PN}/disk.dsk"
    einfo "chmod 0640 /var/lib/${PN}/disk.dsk"
    einfo
    einfo "For more information on advanced topics like journaling or session scoped volumes,"
    einfo "see the documentation at http://www.brutman.com/mTCP/Netdrive_documentation"
    einfo
    einfo "To start the mTCP NetDrive server, enable and start the systemd service:"
    einfo "systemctl enable ${PN}.service --now"

}
