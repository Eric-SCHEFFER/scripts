#!/bin/bash

# Résumé:
# Synchronisation miroir (option delete) du dossier sauvegarde de cette clé
# avec le dossier copie_de_sauvegarde sur cet ordinateur.
#
# Détails:
#

# =======================
# Variables de mise en forme du texte (couleur, etc...)
NONE='\033[00m'
BLACK='\033[0;30m'
RED='\033[01;31m'
YELLOW='\033[01;33m'
CYAN='\033[01;36m'
WHITE='\033[01;37m'

NONE_BG='\e[49m'
MAGENTA_BG='\e[45m'
GREEN_BG='\033[42m'
RED_BG='\e[41m'

# =======================


function synchroLocal() {
    # Affecter les variables
    local source="/media/eric/565174ef-03fa-4893-81f5-ddaa698f7d81/sauvegarde/"
    local cible="/home/eric/copie_de_sauvegarde"
    local backup="/home/eric/_backup_copie_de_sauvegarde"
    
    # Gestion des erreurs si l'un des dossiers n'existe pas
    err=""
    if [ ! -d $source ]; then
        err="Dossier source non trouvé\n"
    fi
    if [ ! -d $cible ]; then
        err=$err"Dossier cible non trouvé\n"
    fi
    if [ ! -z "$err" ]; then
        echo -e "${RED_BG}"$err"Arrêt du programme. Appuyez sur Entrée$NONE_BG"
        read
        exit
    fi
    # Poursuite du programme
    if [ ! -d $backup ]; then
        mkdir $backup
    fi
    # Simulation synchro
    echo -e "$CYAN"
    rsync -rntb --backup-dir=$backup"backup_"`date +%F`_`date +%T` --out-format=%f --delete --modify-window=1 -s $source $cible
    echo "source\nvers\nCible"
    # Lancement synchro

}

synchroLocal




# echo "$0"
# DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
# echo $DIR
# echo `pwd`
# read