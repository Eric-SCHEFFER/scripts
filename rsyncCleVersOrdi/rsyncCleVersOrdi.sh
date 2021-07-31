#!/bin/bash

# Résumé:
# Synchronisation miroir (option delete) du dossier sauvegarde de cette clé
# avec le dossier copie_de_sauvegarde sur cet ordinateur.
#
# Détails:
#


##
# Chemin complet du script (Fonctionne même s'il est lancé par un lien symbolique)
##
function scriptPath() {
    SOURCE=${BASH_SOURCE[0]}
    while [ -h $SOURCE ]; do # On cherche à résoudre $SOURCE jusqu'à que cette variable ne soit pas un lien symbolique
        DIR=$(cd -P $(dirname $SOURCE) && pwd)
        SOURCE=$(readlink $SOURCE)
        [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # Si $SOURCE était un lien symbolique relatif, nous devons le modifier pour obtenir un chemin absolu
    done
    DIR=$(cd -P $(dirname $SOURCE) && pwd)
    echo $DIR
}


# =======================
# Variables
# Couleurs et mise en forme du texte
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

# On met le résultat de la fontion scriptPath dans une variable
scriptPath=$(scriptPath)
# =======================

# TODO: Extraire le path du dossier source sur le path du script, en utilisant sed
# chaine="ceci est une chaine de caractères"
# echo $chaine | sed -e "s/ /_/g"
# exit


##
# Synchronise avec rsync 1 dossier source vers un dossier cible.
# C'est une synchronisation de type miroir (option delete sur la cible)
##
function synchroLocal() {
    # Affecter les variables
    local source="/media/eric/565174ef-03fa-4893-81f5-ddaa698f7d81/sauvegarde/"
    local cible="/media/eric/P1/copie_de_sauvegarde/"
    local backup="/media/eric/P1/_backup_copie_de_sauvegarde/"
    # Gestion des erreurs si l'un des dossiers n'existe pas
    err=""
    if [ ! -d "$source" ]; then
        err="Dossier source non trouvé\n"
    fi
    if [ ! -d "$cible" ]; then
        err="$err""Dossier cible non trouvé\n"
    fi
    if [ ! -z "$err" ]; then
        echo -e "${RED_BG}"$err"Arrêt du programme. Appuyez sur Entrée $NONE_BG"
        read
        exit
    fi
    # Poursuite du programme
    if [ ! -d "$backup" ]; then
        mkdir "$backup"
    fi
    echo -e "$CYAN"
    sortie=""
    # rsync dry run
    # Redirection avec tee de la sortie sdt vers le terminal, car on la capture dans une variable ($sortie)
    sortie=$(rsync -rntb --backup-dir=$backup"backup_"$(date +%F)_$(date +%T) --log-format=%n%L --delete --modify-window=1 -s $source $cible | tee /dev/tty)
    if [ -z "$sortie" ]; then
        echo -e "$BLACK $GREEN_BG"
        echo -e "Rsync (options delete et backup) de:\n"
        echo "Source (sur $HOSTNAME): $source"
        echo "vers"
        echo -e "Cible (sur $HOSTNAME): $cible\n"
        echo "Les dossiers sont déjà synchronisés"
        echo "Pour quitter, appuyez sur Entrée"
        echo -e "$NONE $NONE_BG"
        read
        exit
    else
        echo -e "$BLACK $GREEN_BG"
        echo -e "Rsync (options delete et backup) de:\n"
        echo "Source (sur $HOSTNAME): $source"
        echo "vers"
        echo -e "Cible (sur $HOSTNAME): $cible\n"
        echo -e "Démarrer ?\n"
        echo "OUI => Appuyez sur Entrée"
        echo "NON => Appuyez sur Ctrl C"
        echo -e "$NONE $NONE_BG"
        read
        echo -e "$RED"
    fi
    # rsync réel
    chmod -R 700 "$cible" "$backup" &&
        rsync -rtb --backup-dir=$backup"backup_"$(date +%F)_$(date +%T) --log-format=%n%L --delete --modify-window=1 -s $source $cible
    chmod -R 500 "$cible" "$backup" &&
        echo -e "$BLACK $GREEN_BG"
    echo "Terminé"
    echo "Pour quitter, appuyez sur Entrée"
    echo -e "$NONE $NONE_BG"
    read
}

synchroLocal


