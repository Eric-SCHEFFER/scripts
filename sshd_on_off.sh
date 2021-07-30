#!/bin/bash

# Ce script affiche le status du serveur ssh, et selon son état, propose de le démarrer ou de l'arrêter.

infos_script="Démarrer / Arrêter le serveur SSH"
version=1.2
auteur="Eric SCHEFFER"
date_derniere_revision="Octobre 2019"


# Variables de mise en forme du texte (couleur, etc...)
NONE='\033[00m'
RED='\033[01;31m'
GREEN='\033[01;32m'


# Détecte l'état du serveur ssh, et selon qu'il soit démarré ou arrêté, lance la fonction si_sshd_on ou si_sshd_off
sshd_status()
{
	clear
	echo "********************************************************"
	echo $infos_script
	echo "Version $version"
	echo "********************************************************"
	echo
	etat_sshd=$(service ssh status | grep running)
	if [ "$etat_sshd" = "" ]
	then
		si_sshd_off
		exit
	else
		si_sshd_on
		exit
	fi
}

# Indique que le serveur est arrêté, et propose de le démarrer. Reboucle ensuite le script, ce qui affichera le nouvel état du serveur.
si_sshd_off()
{
	echo -e "Status: ${RED}ARRÊTÉ${NONE}\n\nDémarrer: D puis Entrée"
	echo "Quitter:  Entrée, ou Ctrl + C"
	read choix
	while [ "$choix" != "d" ] && [ "$choix" != "D" ] && ! [ -z "$choix" ]
	do
		echo "Saisie incorrecte"
		sleep 2
		sshd_status
	done
	if [ "$choix" == "d" ] || [ "$choix" == "D" ]
	then
		service ssh start
		sshd_status
	else
		exit
	fi
}

# Indique que le serveur est démarré, et propose de l'arrêter (en killant les éventuelles connexions actives). Reboucle ensuite le script, ce qui affichera le nouvel état du serveur.
si_sshd_on()
{
	echo -e "Status: ${GREEN}DÉMARRÉ${NONE}\n\nArrêter: A puis Entrée"
	echo "Quitter:  Entrée, ou Ctrl + C"
	read choix
	while [ "$choix" != "a" ] && [ "$choix" != "A" ] && ! [ -z "$choix" ]
	do
		echo "Saisie incorrecte"
		sleep 2
		sshd_status
	done
	if [ "$choix" == "a" ] || [ "$choix" == "A" ]
	then
		service ssh stop && killall -KILL sshd
		sshd_status
	else
		exit
	fi
}

sshd_status

