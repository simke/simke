#!/bin/bash
#arch linux configuration script
#This script is intended for Arch Linux users and can aid with the request about system files. 
#Furthermore the script can give information about hardware.
#
#(2008-2011) schleby88@googlemail.com
#(2011-2012) goranvxiii@gmail.com

VER='git'

#who are you
if [[ $UID -eq 0 ]]; then
	[[ $USER == "root" ]] && dialog --msgbox "Run me whit 'su -c'" 5 24
	dialog --infobox "***Loading***" 3 17
else
	dialog --msgbox "***Read-only mode***" 5 24
	dialog --infobox "***Loading***" 3 17
fi

#set editor
[[ ! $EDITOR ]] && EDITOR=nano

#count new packages
_numpkg=0
for a in $( `echo pacman -Qqu` ); do 
	(( _numpkg++ )) 
done 

#set temp files
_temp="/tmp/answer.$$"
PN=`basename "$0"`
dialog 2>$_temp
DVER=`cat $_temp | head -1`

# Cleanup temporary file in case of keyboard interrupt or termination signal.
function cleanup_temp {
	[ -e $_temp ] && rm --force $_temp
	exit 0
}
trap cleanup_temp SIGHUP SIGINT SIGPIPE SIGTERM

#############################################################################################################

#edit xinitrc
xinitrc() {
	filename="/home/$USER"
	if [ -d $filename ]; then
		$EDITOR /home/$USER/.xinitrc 
	else
		dialog --msgbox "*** ERROR ***\n$filename does not exist" 6 80
	fi
	return
}

#edit rc.conf
/etc/rc.conf() {
	$EDITOR /etc/rc.conf #$R
	return
}

#edit modprobe
/etc/modprobe() {
	$EDITOR /etc/modprobe.d/modprobe.conf
	return
}

#edit pacman.conf
/etc/pacman.conf() {
	$EDITOR /etc/pacman.conf #$P
	return
}

#edit mirrorliste
/etc/pacman.d/mirrorlist() {
	$EDITOR /etc/pacman.d/mirrorlist #$M
	return
}

#edit xorg.conf.d
/etc/X11/xorg.conf.d() {
	echo "Files in /etc/X11/xorg.conf.d/" && echo
	ls -l /etc/X11/xorg.conf.d/ | grep ^- | awk '{print $9}' 
	echo && echo "ENTER NAME OF FILE OR PRESS ENTER TO EXIT:" && read ans
	if [[ -z $ans ]]; then
		return
	else
		$EDITOR /etc/X11/xorg.conf.d/$ans #$X
	fi
	return
}

#edit smb.conf
/etc/samba/smb.conf() {
	$EDITOR /etc/samba/smb.conf #$S
	return
}

#edit inittab
/etc/inittab() {
	$EDITOR /etc/inittab #$I
	return
}

#edit grub menu.lst
/boot/grub/menu.lst() {
	$EDITOR /boot/grub/menu.lst #$O
	return
}

#edit grub2 grub.cfg
/boot/grub/grub.cfg() {
	$EDITOR /boot/grub/grub.cfg #$G
	return
}

#edit fstab
/etc/fstab() {
	$EDITOR /etc/fstab #$F
	return
}

#cpufreq
CPUFREQ() {
	$EDITOR /etc/conf.d/cpufreq #$CPUFREQ
	return
}

#edit mkinitcpio.conf
/etc/mkinitcpio.conf() {
	$EDITOR /etc/mkinitcpio.conf #$H
	return
}

#Rebuild kernel
anykernel() {
	[[ $UID -ne 0 ]] && dialog --msgbox "Need the rights of root! Log in as root and try again." 6 60 && return
	echo "ENTER SHORT NAME OF KERNEL (-lts -ck -bfs...) OR PRESS ENTER FOR DEFAULT:" && read kerver 
	filename="/etc/mkinitcpio.d/linux$kerver.preset"
	if [ -e $filename ]; then
		mkinitcpio -p linux$kerver && echo && echo --- Finished --- && read
	else
		dialog --msgbox  "*** ERROR ***\n'linux$kerver' does not exist" 6 80
	fi
	return
}

#Sytemupdate 
update() {
	[[ $UID -ne 0 ]] && dialog --msgbox "Need the rights of root! Log in as root and try again." 6 60 && return
	pacman -Syu && echo && echo --- Finished --- && read
	return
}

#allsysupdate
allupdate() {
	filename="/usr/bin/yaourt"
	if [ -e $filename ]; then
		yaourt -Syua && echo && echo --- Finished --- && read
	else
		dialog --msgbox "*** ERROR ***\n'$filename' does not exist" 6 80
	fi
	return
}

#pacman log
/var/log/pacman() {
	$EDITOR /var/log/pacman.log #$F
	return
}

#xorg log
/var/log/Xorg() {
	$EDITOR /var/log/Xorg.0.log #$F
	return
}

#read any log
/var/log() {
	echo "Files in /var/log/" && echo
	ls -l /var/log/ | grep ^- | awk '{print $9}' 
	echo && echo "ENTER NAME OF FILE OR PRESS ENTER TO EXIT:" && read ans
	filename="/var/log/$ans"
	if [[ -z $ans ]]; then
		return
	elif [ -e $filename ]; then
		$EDITOR /var/log/$ans #$X
	else
		echo && echo "FILE '$ans' DOES NOT EXIST!" && echo
		/var/log
	fi
	return
}

#cfdisk
cfdisk() {
	[[ $UID -ne 0 ]] && dialog --msgbox "Need the rights of root! Log in as root and try again." 6 60 && return
	exe='cfdisk' && exec $exe #$CFDISK
	return
}

#cpuinfo
CPUINFO()  {
	 dialog --msgbox "`cat /proc/cpuinfo`" 60 150
	 return
}

#memory
MEMORY()  {
	 dialog --msgbox "`free`" 25 80 
	 return
}

#hard disc allocation
HDD()  {
	 dialog --msgbox "`df -h`" 20 80
	 return
}

#hardware temperature
TEMP()  {
	 dialog --msgbox "`sensors`" 15 70 
	 return
}

#Release information
Versionshinweise() {
	touch /tmp/ver.txt
	echo "This script is only for Arch Linux users. Use at one's own risk!" >/tmp/ver.txt
	echo "Version $VER" >> /tmp/ver.txt
	echo "(2008-2011) schleby88@googlemail.com" >> /tmp/ver.txt
	echo "(2011-2012) goranvxiii@gmail.com" >> /tmp/ver.txt
	filename="/tmp/ver.txt"
	if [ -e $filename ]; then
	dialog --backtitle "Release information"\
		--begin 3 5 --title " viewing File: $filename "\
		--textbox $filename 20 100
		rm $filename
	else
		dialog --msgbox "*** ERROR ***\n$filename does not exist" 6 80
	fi
}

#############################################################################################################

main_menu() {
	dialog --title "Arch Linux configuration script. ver $VER." \
	--menu "You are '$USER'. Editor is '$EDITOR'. New packages '$_numpkg'." 40 150 35 \
	-configuration ""\
	XINITRC "/home/$USER/.xinitrc ------------- File read by xinit and startx"\
	RC.CONF "/etc/rc.conf --------------------- Main Configuration file"\
	MODPROBE "/etc/modporbe.d/modprobe.conf----  Pass module settings to udev"\
	PACMAN.CONF "/etc/pacman.conf ----------------- Configuration file for Pacman"\
	MIRRORS "/etc/pacman.d/mirrorlist --------- Pacman's serverlist"\
	X11 "/etc/X11/xorg.conf.d/$ ----------- Configuration file's for X11"\
	INIT "/etc/inittab --------------------- Configuration file for init systems"\
	SAMBA "/etc/samba/smb.conf -------------- Configuration file for samba"\
	OLDGRUB "/boot/grub/menu.lst -------------- GRUB configuration file for booting"\
	GRUB2 "/boot/grub/grub.cfg -------------- GRUB2 configuration file for booting"\
	CPUFREQ "/etc/conf.d/cpufreq--------------- Configuration file for Cpufreq-Utils"\
	FSTAB "/etc/fstab ----------------------- Configuration file for partitions on HDD"\
	HOOKS "/etc/mkinitcpio.conf ------------- Configuration file for rebuilding the kernel"\
	-log ""\
	LOG_PACMAN "Pacman log ----------------------- Read pacman log"\
	LOG_XORG "Xorg log ------------------------- Read xorg log"\
	LOG "Any log -------------------------- Read any log"\
	-commands ""\
	ANY_KERNEL "Mkinitcpio -p linux$ ------------- Rebuild any kernel"\
	PACMAN "Pacman -Syu ---------------------- Complete system update"\
	YAOURT "Yaourt -Syua --------------------- Complete system and AUR update"\
	-programs ""\
	CFDISK "Cfdisk --------------------------- Partition manager"\
	-sundry ""\
	CPUINFO "Show processor information"\
	MEMORY "Show main memory capacity utilisation"\
	HDD "Show hard disc allocation "\
	TEMP "Show hardware temperature"\
	VERSION "Release information" 2>$_temp
	
	opt=${?}
	[ $opt != 0 ] && rm $_temp && exit
	menuitem=`cat $_temp`
	case $menuitem in
		XINITRC) xinitrc;;
		RC.CONF) /etc/rc.conf;;
		MODPROBE) /etc/modprobe;;
		CPUFREQ) CPUFREQ;;
		INIT) /etc/inittab;;
		SAMBA) /etc/samba/smb.conf;;
		PACMAN.CONF) /etc/pacman.conf;;
		MIRRORS) /etc/pacman.d/mirrorlist;;
		HOOKS) /etc/mkinitcpio.conf;;
		X11) /etc/X11/xorg.conf.d;;
		OLDGRUB) /boot/grub/menu.lst;;
		GRUB2) /boot/grub/grub.cfg;;
		FSTAB) /etc/fstab;;
		ANY_KERNEL) anykernel;;
		PACMAN) update;;
		YAOURT) allupdate;;
		LOG_PACMAN) /var/log/pacman;;
		LOG_XORG) /var/log/Xorg;;
		LOG) /var/log;;
		CFDISK) cfdisk;;
		VERSION) Versionshinweise;;
		CPUINFO) CPUINFO;;
		MEMORY) MEMORY;;
		HDD) HDD;;
		TEMP) TEMP;;
		QUIT) QUIT;;
	esac
}

#start program
while true; do
	main_menu
done

#endoffile
