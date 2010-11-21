#!/bin/sh


#########################################################
# Fonction utilisée lors de l'interruption du programme #
#########################################################
function arret_utilisateur
{
    $DIALOG --title "Fusion Inventory" --clear \
	--yesno "Do you want to restart your computer now?" 10 30

    valRet=$?
    case $valRet in
	0)
            # Oui
	    # reboot
	    echo "reboot"
	    exit 0
	    ;;
	*)
	    # Non ou echap - Recommencer?
	    sh fichierTest.sh
	    ;;
    esac
}




DIALOG=${DIALOG=dialog}

#########################################################
# Création du fichier temporaire contenant les réponses #
#########################################################
fichierTemp=/tmp/fichierTempFusionInventory.$$


Commande="fusioninventory-agent "


#########################################################
# Liste des serveurs                                    #
#########################################################
$DIALOG --title "Fusion Inventory" --clear \
    --inputbox "Servers addresses (separated by a comma [,]): \n( http://fusionserv/ocsinventory )" 16 100 2>$fichierTemp

valRet=$?

case $valRet in
    0)
	if [ ! `cat $fichierTemp` = "" ]; then
	    Commande=$Commande"--server "`cat $fichierTemp`" "
	fi
	;;
    *)
	arret_utilisateur
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
	;;
    1)
	# Non
	`echo $Commande`
	exit 0
	;;
    255)
	arret_utilisateur
	;;
esac




#########################################################
# Server Authentification                               #
#########################################################
$DIALOG --title "Fusion Inventory - Server Authentification" --insecure \
    --mixedform "" 15 100 0 \
    "Username: " 1 1 "" 1 20 50 0 0 \
    "Password: " 2 1 "" 2 20 50 0 1 \
    "Realm:    " 3 1 "" 3 20 50 0 0 2> $fichierTemp

valRet=$?

case $valRet in
    0)
	# Ajout de l'username
	user=`cat $fichierTemp | head -n 1`
	# Ajout de l'username
	pass=`cat $fichierTemp | head -n 2 | tail -n 1`
	# Ajout de l'username
	realm=`cat $fichierTemp | tail -n 1`

	if [  ! $user = "" ]; then
	    if [ ! $pass = "" ]; then
		if [ ! $realm = "" ]; then
		    Commande=$Commande"--user="$user" --password="$pass" --realm=\""$realm"\" "
		fi
	    fi
	fi
	;;
    *)
	arret_utilisateur
	;;
esac




#########################################################
# SSL options                                           #
#########################################################
$DIALOG --title "Fusion Inventory" --clear \
	--yesno "The SSL cert has to be written in /etc/fusioninventory/certs\n\nNo certificate check when establishing SSL connection" 10 100

valRet=$?

# Création du dossier 
mkdir -p /etc/fusioninventory/certs/

case $valRet in
    0)
	Commande=$Commande"--ca-cert-dir=/etc/fusioninventory/certs --no-ssl-check "
	;;
    1)
	Commande=$Commande"--ca-cert-dir=/etc/fusioninventory/certs "
	;;
    255)
	arret_utilisateur
	;;
esac




#########################################################
# Proxy                                                 #
#########################################################
$DIALOG --title "Fusion Inventory" --clear \
    --inputbox "Proxy: " 16 100 2>$fichierTemp

valRet=$?

case $valRet in
    0)
	if [ ! `cat $fichierTemp` = "" ]; then
	    Commande=$Commande"--proxy="`cat $fichierTemp`" "
	fi
	;;
    *)
	arret_utilisateur
	;;
esac




#########################################################
# RPC-Port                                              #
#########################################################
$DIALOG --title "Fusion Inventory" --clear \
    --inputbox "RPC-Port: " 16 100 2>$fichierTemp

valRet=$?

case $valRet in
    0)
	if [ ! `cat $fichierTemp` = "" ]; then
	    Commande=$Commande"--rpc-port="`cat $fichierTemp`" "
	fi
	;;
    *)
	arret_utilisateur
	;;
esac




#########################################################
# Debug                                                 #
#########################################################
$DIALOG --title "Fusion Inventory" --clear \
	--yesno "Debug" 10 100

valRet=$?

case $valRet in
    0)
	Commande=$Commande"--debug "
	;;
    1)
	;;
    255)
	arret_utilisateur
	;;
esac




#########################################################
# Allow local user to run agent                         #
#########################################################
$DIALOG --title "Fusion Inventory" --clear \
	--yesno "Allow local user to run agent" 10 100

valRet=$?

case $valRet in
    0)
	Commande=$Commande"--rpc-trust-localhost "
	;;
    1)
	;;
    255)
	arret_utilisateur
	;;
esac




#########################################################
# Look for virtual machines in home directories         #
#########################################################
$DIALOG --title "Fusion Inventory" --clear \
	--yesno "Look for virtual machines in home directories" 10 100

valRet=$?

case $valRet in
    0)
	Commande=$Commande"--scan-homedirs "
	;;
    1)
	;;
    255)
	arret_utilisateur
	;;
esac




#########################################################
# Destination folder                                    #
#########################################################
$DIALOG --title "Fusion Inventory" --clear \
    --inputbox "Destination folder:" 16 100 "/tmp" 2>$fichierTemp

valRet=$?

case $valRet in
    0)
	if [ ! `cat $fichierTemp` = "" ]; then
	    Commande=$Commande"--local "`cat $fichierTemp`" "
	fi
	;;
    *)
	arret_utilisateur
	;;
esac




#########################################################
# Suppression du fichier temporaire                     #
#########################################################
rm -rf $fichierTemp




#########################################################
# Exécution de la commande                              #
#########################################################
echo $Commande
`echo $Commande`
