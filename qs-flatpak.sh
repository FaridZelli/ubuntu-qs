#!/bin/bash

# Setup Script by https://github.com/FaridZelli
# Inspired by:
# https://github.com/MasterGeekMX/snap-to-flatpak
# https://github.com/BryanDollery/remove-snap

tput bold
echo ""
echo "----------------------------------------------"
echo "---------- Ubuntu QuickSetup Script ----------"
echo "----------------------------------------------"
echo ""
tput sgr0

echo -e "\nRemoving snaps..."

snaps=$(snap list | tail --lines +2 | cut --field 1 --delimiter " ")
declare -a snap_list=()

for snap in $snaps
do
	snap_list+=($snap)
done

echo -e "\nThe installed snaps are:"

echo -e "${snap_list[@]}\n"

snap_count=${#snap_list[@]}
while [[ $snap_count -gt 0 ]]
do
	for ((index=0; index<snap_count; index++)) #index in ${!snap_list[@]}
	do
		current_snap=${snap_list[$index]}
		sudo snap remove --purge $current_snap 2> /dev/null
		if [[ $? -eq 0 ]]
		then
			declare -a new_snap_list=()
			for snap in ${snap_list[@]}
			do
				if [[ $snap != $current_snap ]]
				then
					new_snap_list+=($snap)
				fi
			done
			snap_list=(${new_snap_list[@]})
			snap_count=${#snap_list[@]}
		fi
	done
done

echo -e "\nStopping snapd..."

sudo systemctl disable --now snapd.service
sudo systemctl disable --now snapd.socket
sudo systemctl disable --now snapd.seeded.service

echo -e "\nUninstalling snapd..."

sudo apt autoremove --purge snapd --assume-yes

echo -e "\nCleaning up..."

sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd ~/snap

cat << EOF | sudo tee -a /etc/apt/preferences.d/no-snap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

sudo chown root:root /etc/apt/preferences.d/no-snap.pref

echo -e "\nUninstalling Discover and GNOME Software..."

sudo apt autoremove --purge plasma-discover --assume-yes
sudo apt autoremove --purge gnome-software --assume-yes

echo -e "\nUninstalling Firefox (if present)..."

sudo apt autoremove --purge firefox --assume-yes

echo -e "\nInstalling Flatpak..."

sudo apt install flatpak --assume-yes
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

echo -e "\nInstalling LibreWolf..."

flatpak install flathub io.gitlab.librewolf-community

echo -e "\nDone!"
