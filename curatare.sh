#!/bin/bash

OLDCONF=$(dpkg -l|grep "^rc"|awk '{print $2}')
CURKERNEL=$(uname -r|sed 's/-*[a-z]//g'|sed 's/-386//g')
LINUXPKG="linux-(image|headers|ubuntu-modules|restricted-modules)"
METALINUXPKG="linux-(image|headers|restricted-modules)-(generic|i386|server|common|rt|xen)"
OLDKERNELS=$(dpkg -l|awk '{print $2}'|grep -E $LINUXPKG |grep -vE $METALINUXPKG|grep -v $CURKERNEL)


if [ $USER != root ]; then
  echo -e "Eroare: trebuie să fiți administrator"
  echo -e "Ieșire..."
  exit 0
fi

echo "\033[1;34m Ștergere fonturi arabe/asiatice \033[0m"
sleep 2
sudo apt remove -y ttf-arabeyes ttf-indic-fonts-core ttf-kochi-gothic ttf-kochi-mincho fonts-lao ttf-malayalam-fonts fonts-thai-tlwg ttf-unfonts-core ttf-punjabi-fonts ttf-indic-fonts
sleep 2

echo "\033[1;34m Ștergere apt cache și pachete .deb... \033[0m"
sleep 2
apt -y clean
apt -y remove
apt -y autoclean
apt -y autoremove
rm /var/cache/apt/*.bin

echo "\033[1;34m Ștergere log-uri \033[0m"
sleep 2
rm /var/log/* 
rm /var/log/*/*
sleep 2
echo

echo "\033[1;34m Ștergere fișiere de limbă inutile"
echo "\033[1;34m Se alege limbile care se doresc a fi păstrate în sistem. Limbile neselectate vor fi șterse. \033[0m" 
sleep 4
echo
apt install -y localepurge
sleep 1
localepurge
sleep 2

echo "\033[1;34m Se șterg fișierele thumbnails\033[0m"
sleep 2
if $CONF_THUMBNAILS ; then
 THUMBNAILS=$(find $HOME/.thumbnails -type f)
 if [ "$THUMBNAILS" != "" ]; then
  find $HOME/.thumbnails -type f -delete -print
 fi
fi
sleep 2

echo "\033[1;34m Ștergere fișiere de configurare vechi... \033[0m"
sleep 2
apt purge -y $OLDCONF
if $CONF_RESIDUAL_CONFIGS ; then
 PKGS=$(dpkg -l | grep '^rc' | tr -s ' ' | cut -d ' ' -f 2)
 if [ "$PKGS" != "" ]; then
  dpkg --purge $PKGS
 fi
fi
sleep 2

echo "\033[1;34m Se șterg pachetele orfane .deb \033[0m"
sleep 2
if $CONF_DEBORPHAN ; then
 if which deborphan >/dev/null; then
  sudo deborphan -e $DEBORPHAN_EXCLUDE | xargs sudo apt-get -y purge
  sudo deborphan --guess-all
 fi
fi
sleep 2

echo "\033[1;34m Ștergere kernel vechi... \033[0m"
sleep 2
apt purge -y $OLDKERNELS
dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo apt-get -y purge
sleep 2

echo "\033[1;34m Se golesc coșurile de gunoi... \033[0m"
sleep 2
rm -rf /home/*/.local/share/Trash/*/** &> /dev/null
rm -rf /root/.local/share/Trash/*/** &> /dev/null
rm -rfv $HOME/.local/share/Trash/*/**
sleep 2

echo "\033[1;34m Fixare pachete \033[0m"
sleep 2
apt -u --reinstall --fix-missing install
sleep 2

echo "\033[1;34m Curățenia e gata! \033[0m"
