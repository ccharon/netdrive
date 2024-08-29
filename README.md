# mTCP NetDrive Gentoo Repositoy

Provide a Gentoo Ebuild Repository for brutman mTCP NetDrive

This Repos only purpose is to have a Gentoo Ebuild that installs https://www.brutman.com/mTCP/mTCP_NetDrive.html and provides a systemd service to start netdrive and serve image provided in a directory. 

The first step will be to download, and install netdrive, put the systemd files in place and start up in a easy configuration  

netdrive -log_file serving.log serve -port 8086 -image_dir my_images


after I got this working I will look into some default actions like creating a 64mb default disk if no disk exists... also the sessions and journaling features maybe via a config file would be good lets see :P 
