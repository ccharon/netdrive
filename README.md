# mTCP NetDrive Gentoo Repository
This repo provides M. Brutmans mTCP NetDrive as Systemd Service.
https://www.brutman.com/mTCP/mTCP_NetDrive.html

Right now as of release 20240816, the ebuild is only tested on amd64. The netdrive executable was only binding to ipv6. As a temporary workaround, the ebuild will patch the executable to bind to ipv4. The patch is based on a testing version provided by M. Brutman. Also the patch is amd64 only.

### Adding the repo
to add this repo to your installation use
```bash
$ eselect repository add netdrive git https://github.com/ccharon/netdrive.git
```
and then do a `emerge --sync` to get the ebuilds.

### Installation

To install mtcp-netdrive, you will have to add it to your package.keywords as it is masked. Or simply use:
```bash
$ emerge --ask --autounmask mtcp-netdrive::netdrive
```
 
- mtcp-netdrive User + Group and a Systemd Service will be created to run the server
- The executable itself will be installed as ```/usr/bin/mtcp-netdrive```
- Images will be served from ```/var/lib/mtcp-netdrive```
- logs are written to ```/var/log/mtcp-netdrive/server.log```
- the service runs on port 8086

Values can be changed in ```/etc/mtcp-netdrive.conf``` .

### Image Creation

Create your own image as root. Do not forget to change the permissions and owner.
```bash
$ mtcp-netdrive create hd 256 FAT16B /var/lib/mtcp-netdrive/disk.dsk
$ chown mtcp-netdrive:mtcp-netdrive /var/lib/mtcp-netdrive/disk.dsk
$ chmod 660 /var/lib/mtcp-netdrive/disk.dsk
```

### Other Things

For further instructions see the [official documentation](http://www.brutman.com/mTCP/Netdrive_documentation)

#### Systemd 

Ensure the systemd service is enabled and started
```bash
$ systemctl daemon-reload
$ systemctl enable mtcp-netdrive
$ systemctl start mtcp-netdrive
```

#### Firewall

If you have a firewall installed be sure to allow access to port 8086 or what ever port you selected in the config file.

#### MSDOS Client

To access the image use this command on the msdos side: (after installing the netdrive client)
```bash
$ netdrive connect x.x.x.x:8086 disk.dsk f:
```
where x.x.x.x is the servers ip address, 8086 the port the service is running, disk.dsk is the image you want to access and finally f: is a drive letter reserved by netdrive.sys.
