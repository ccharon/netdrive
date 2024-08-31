# mTCP NetDrive Gentoo Repository

### NOTE: The service registers on ipv6 only on my machines so this is rather useless at the moment :P. I wrote a mail to M. Brutman and he provided me with a testing version that fixes the behavior. Once a new released version is available I will update the ebuild and it should work.

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

To install mtcp-netdrive, you will have to add it to your package.keywords file, as it is masked. Or simply use:
```bash
$ emerge --ask --autounmask mtcp-netdrive::netdrive
```
 
A User Account + Group and a Systemd Service will be created to run the server.

The executable itself will be installed as ```/usr/bin/mtcp-netdrive```.

Images will be served from ```/var/lib/mtcp-netdrive``` by default, but this can be changed in ```/etc/mtcp-netdrive.conf``` .

Create your own image as root. Do not forget to change the owner and permissions to mtcp-netdrive:mtcp-netdrive.
```bash
$ mtcp-netdrive create hd 256 FAT16B /var/lib/mtcp-netdrive/disk.dsk
$ chown mtcp-netdrive:mtcp-netdrive /var/lib/mtcp-netdrive/disk.dsk
$ chmod 660 /var/lib/mtcp-netdrive/disk.dsk
```

For further instructions see the [official documentation](http://www.brutman.com/mTCP/Netdrive_documentation)

Ensure the systemd service is enabled and started
```bash
$ systemctl daemon-reload
$ systemctl enable mtcp-netdrive
$ systemctl start mtcp-netdrive
```

If you have a firewall installed be sure to allow access to port 8086 or what ever port you selected in the config file.

To access the image use this command on the msdos side: (after installing the netdrive client)
```bash
$ netdrive connect x.x.x.x:8086 disk.dsk k:
```
where x.x.x.x is the servers ip address, 8086 the port the service is running, disk.dsk is the image you want to access and finally k: is a drive letter, choose one that is unused
