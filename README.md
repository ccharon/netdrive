# mTCP NetDrive Gentoo Repository

Provides a Gentoo Ebuild Repository for brutman mTCP NetDrive

This Repos only purpose is to have a Gentoo Ebuild that installs https://www.brutman.com/mTCP/mTCP_NetDrive.html and provides a systemd service to start netdrive and serve image provided in a directory. 


to add this repo to your installation simply create a file in /etc/portage/repos.conf/netdrive with the following content

```
[netdrive]
location = /var/db/repos/netdrive
sync-type = git
sync-uri = https://github.com/ccharon/netdrive.git
```
and then do a `emerge --sync` to get the ebuilds.

To install mtcp-netdrive-server, you will have to add it to your package.keywords file, as it is masked. 
 
A User Account + Group and a Systemd Service will be created to run the server.

The executable itself will be installed in /usr/bin/mtcp-netdrive-server.

Images will be served from /var/lib/mtcp-netdrive by default, but this can be changed in /etc/mtcp-netdrive-server.conf .
Also a default 256MB image will be created in /var/lib/mtcp-netdrive/disk.dsk . If you store your own images, do not forget
to change the owner and permissions to mtcp-netdrive:mtcp-netdrive.
```bash
chown mtcp-netdrive:mtcp-netdrive /var/lib/mtcp-netdrive/disk.dsk
chmod 660 /var/lib/mtcp-netdrive/disk.dsk
```

Ensure the systemd service is enabled and started
```bash
systemctl daemon-reload
systemctl enable mtcp-netdrive-server
systemctl start mtcp-netdrive-server
```

If you have a firewall installed be sure to allow access to port 8086 or what ever port you selected in the config file.
