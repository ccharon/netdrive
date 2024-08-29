# Copyright 2021-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit acct-user

DESCRIPTION="User for mtcp-netdrive-server"
ACCT_USER_ID=-1
ACCT_USER_GROUPS=( mtcp-netdrive-server )

acct-user_add_deps
