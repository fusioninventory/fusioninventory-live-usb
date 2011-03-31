#!/bin/sh -e
###################################################################################
# FusionInventory  Live USB                                                       #
# one line to give the program's name and an idea of what it does.                #
# Copyright (C) 2010  Henon Valentin valentin.henon@gmail.com                     #
#                     Blot  Aurélie  blot.aurelie@gmail.com                       #
#                                                                                 #
# This program is free software; you can redistribute it and/or                   #
# modify it under the terms of the GNU General Public License                     #
# as published by the Free Software Foundation; either version 2                  #
# of the License, or (at your option) any later version.                          #
#                                                                                 #
# This program is distributed in the hope that it will be useful,                 #
# but WITHOUT ANY WARRANTY; without even the implied warranty of                  #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the                   #
# GNU General Public License for more details.                                    #
#                                                                                 #
# You should have received a copy of the GNU General Public License               #   
# along with this program; if not, write to the Free Software                     #
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA. #
###################################################################################
DIALOG=${DIALOG=dialog}




#########################################################
# Function used during the interruption of programme    #
#########################################################
stop_user()
{
    $DIALOG --title "Fusion Inventory" --clear \
	--yesno "Do you want to restart your computer now?" 10 30
    
    valRet=$?
    case $valRet in
	0)
            # Oui
	    # reboot
	    echo "reboot"
	    reboot
	    ;;
	*)
	    # Non ou echap - Recommencer?
	    sh dialog.sh
	    ;;
    esac
}




#########################################################
# Function for launch a shell                           #
#########################################################
launch_shell()
{
    $DIALOG --title "Fusion Inventory" --clear --no-label "Reboot" \
	--yesno "Do you want a shell?" 10 50
    
    valRet=$?
    
    case $valRet in
	0)
            # Lancement d'un shell
	    ;;
	*)
	    # Redémarrage
	    reboot
	    ;;
    esac
}


advanced_options()
{
#########################################################
# Server Authentification                               #
#########################################################
    $DIALOG --title "Fusion Inventory - Server Authentification" --insecure \
	--mixedform "" 15 100 0 \
	"Username: " 1 1 "" 1 20 50 0 0 \
	"Password: " 2 1 "" 2 20 50 0 1 2>$fichierTemp

    valRet=$?

    case $valRet in
	0)
	# Ajout de l'username
	    user=`cat $fichierTemp | head -n 1`
	# Ajout de l'username
	    pass=`cat $fichierTemp | head -n 2 | tail -n 1`

	    if [  ! $user = "" ]; then
		if [ ! $pass = "" ]; then
		    Commande=$Commande" --user="$user" --password="$pass
		fi
	    fi
	    ;;
	*)
	    stop_user
	    ;;
    esac




#########################################################
# SSL options                                           #
#########################################################
    $DIALOG --title "Fusion Inventory" --clear \
	--yesno "The SSL cert has to be written in /etc/fusioninventory/certs\n\nDo you want to ignore certificate check when establishing SSL connection" 10 100

    valRet=$?

# Création du dossier 
    mkdir -p /etc/fusioninventory/certs/

    case $valRet in
	0)
	    Commande=$Commande" --ca-cert-dir=/etc/fusioninventory/certs --no-ssl-check"
	    ;;
	1)
	    Commande=$Commande" --ca-cert-dir=/etc/fusioninventory/certs"
	    ;;
	255)
	    stop_user
	    ;;
    esac




#########################################################
# Proxy                                                 #
#########################################################
    $DIALOG --title "Fusion Inventory" --clear \
	--inputbox "Proxy: \nExample http://www-proxy:8080\nEmpty if none" 16 100 2>$fichierTemp

    valRet=$?

    case $valRet in
	0)
	    if [ ! `cat $fichierTemp` = "" ]; then
		Commande=$Commande" --proxy="`cat $fichierTemp`
	    fi
	    ;;
	*)
	    stop_user
	    ;;
    esac




#########################################################
# RPC-Port                                              #
#########################################################
#$DIALOG --title "Fusion Inventory" --clear \
#    --inputbox "RPC-Port: " 16 100 2>$fichierTemp
#
#valRet=$?
#
#case $valRet in
#    0)
#	if [ ! `cat $fichierTemp` = "" ]; then
#	    Commande=$Commande"--rpc-port="`cat $fichierTemp`" "
#	fi
#	;;
#    *)
#	stop_user
#	;;
#esac
#
#
#

#########################################################
# Debug                                                 #
#########################################################
#$DIALOG --title "Fusion Inventory" --clear \
#	--yesno "Debug" 10 100
#
#valRet=$?
#
#    case $valRet in
#	0)

    # Always in debug
    Commande=$Commande" --debug"
#	    ;;
#	1)
#	    ;;
#	255)
#	    stop_user
#	    ;;
#  esac




#########################################################
# Allow local user to run agent                         #
#########################################################
#$DIALOG --title "Fusion Inventory" --clear \
#	--yesno "Allow local user to run agent" 10 100
#
#valRet=$?
#
#case $valRet in
#    0)
#	Commande=$Commande"--rpc-trust-localhost "
#	;;
#    1)
#	;;
#    255)
#	stop_user
#	;;
#esac
#
#


#########################################################
# Look for virtual machines in home directories         #
#########################################################
    $DIALOG --title "Fusion Inventory" --clear \
	--yesno "Should the agent look for virtual machines in home directories?" 10 100

    valRet=$?

    case $valRet in
	0)
	    Commande=$Commande" --scan-homedirs"
	    ;;
	1)
	    ;;
	255)
	    stop_user
	    ;;
    esac




#########################################################
# Destination folder                                    #
#########################################################
    $DIALOG --title "Fusion Inventory" --clear \
	--inputbox "Where to keep a local copy of the inventory?:" 16 100 "/root" 2>$fichierTemp

    valRet=$?

    case $valRet in
	0)
	    if [ ! `cat $fichierTemp` = "" ]; then
		Commande=$Commande" --local "`cat $fichierTemp`
	    fi
	    ;;
	*)
	    stop_user
	    ;;
    esac




#########################################################
# Run agent                                             #
#########################################################
    echo $Commande
    `echo $Commande`
    launch_shell
}


#---------------------------------------------------------------------------------------------------------
# Begin of script


#########################################################
# Creation of the temp file for the responses           #
#########################################################
fichierTemp=/tmp/fichierTempFusionInventory.$$
#########################################################
# Trap for deleting the temp file                       #
#########################################################
trap "rm -f $fichierTemp" 0 1 2 5 15

#---------------------------------------------------------------------------------------------------------
# Begin of script


Commande="fusioninventory-agent"


#########################################################
# Servers's list                                        #
#########################################################
$DIALOG --title "Fusion Inventory" --clear \
    --inputbox "Servers addresses (separated by a comma [,]): \n( http://fusionserv/ocsinventory )" 16 100 2>$fichierTemp

valRet=$?

case $valRet in
    0)
	if [ ! `cat $fichierTemp` = "" ]; then
	    Commande=$Commande" --server "`cat $fichierTemp`
	fi
	;;
    *)
	stop_user
	;;
esac




#########################################################
# Advanced options                                      #
#########################################################
$DIALOG --title "Fusion Inventory" --clear \
    --yesno "Do you need advanced options?" 10 100

valRet=$?

case $valRet in
    0)
	# Oui
	advanced_options
	;;
    1)
	# Non
	echo $Commande
	`echo $Commande`
	launch_shell
	;;
    255)
	stop_user
	;;
esac
