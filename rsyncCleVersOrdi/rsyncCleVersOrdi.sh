#!/bin/bash

# Résumé:
# Synchronisation miroir (option delete) du dossier sauvegarde de cette clé
# avec le dossier copie_de_sauvegarde sur cet ordinateur.
#
# Détails:
#
# =======================

##
# Retourne le path du script
# 0 paramètres
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

##
# Retourne le point de montage d'un dossier existant (dans notre cas, le path du script)
# 1 Paramètre:
# $1: Path d'un dossier (avec ou sans le / final) qui doit exister (sinon erreur)
##
function pointMontage {
    # Trouvé ici: https://stackoverflow.com/questions/2167558/give-the-mount-point-of-a-path
    # pointMontage=$(df $(scriptPath) | tail -1 | awk '{ print $6 }') # Méthode 1
    # pointMontage=$(stat -c '%m' $(scriptPath)) # Méthode 2
    # pointMontage=$(df --output=target $(scriptPath) | tail -1) # Méthode 3
    pointMontage=$(df --output=target $1 | tail -1) # Méthode 3
    echo $pointMontage
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
# =======================

##
# Synchronise avec rsync 1 dossier source vers un dossier cible.
# C'est une synchronisation de type miroir (option delete sur la cible)
##
function synchroLocal() {
    # Affectation les variables
    local source=$(pointMontage $(scriptPath))"/sauvegarde/"
    # Nom des ordinateurs et leurs points de montages
    case "$HOSTNAME" in
        "fixe-saverne") pointMontageCible="/media/eric/P1";;
        "eric-laptop-sony") pointMontageCible="/home/eric";;
        "HP-Laptop-15-bs1xx") pointMontageCible="/home/eric";;
        "Lenovo-ideapad-120S-14IAP") pointMontageCible="/media/eric/e01664b6-44d8-42d3-9ddf-334b7128a8ff";;
    esac
    local cible=$pointMontageCible"/copie_de_sauvegarde/"
    local backup=$pointMontageCible"/_backup_copie_de_sauvegarde/"
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
    # On capture la sortie de la commande dans une variable, et on la duplique avec tee vers le terminal
    sortie=$(rsync -rntb --backup-dir=$backup"backup_"$(date +%F)_$(date +%T) --log-format=%n%L --delete --modify-window=1 --exclude=".*" -s $source $cible | tee /dev/tty)
    echo -e "$NONE $NONE_BG"
    if [ -z "$sortie" ]; then
        echo -e "Rsync (options delete et backup) de:\n"
        echo "Source (sur $HOSTNAME): $source"
        echo "vers"
        echo -e "Cible (sur $HOSTNAME): $cible\n $BLACK $GREEN_BG"
        echo "Rien à faire, les dossiers sont déjà synchronisés"
        echo "Pour quitter, appuyez sur Entrée"
        echo -e "$NONE $NONE_BG"
        read
        exit
    else
        echo -e "Rsync (options delete et backup) de:\n"
        echo "Source (sur $HOSTNAME): $source"
        echo "vers"
        echo -e "Cible (sur $HOSTNAME): $cible\n $BLACK $GREEN_BG"
        echo -e "Démarrer ?\n"
        echo "OUI => Appuyez sur Entrée"
        echo "NON => Appuyez sur Ctrl C"
        echo -e "$NONE $NONE_BG"
        read
        echo -e "$RED"
    fi
    # rsync réel
    # chmod -R 700 "$cible" "$backup" &&
    chmod -R u+w "$cible" "$backup" &&
        rsync -rtb --backup-dir=$backup"backup_"$(date +%F)_$(date +%T) --log-format=%n%L --delete --modify-window=1 --exclude=".*" -s $source $cible
    # chmod -R 500 "$cible" "$backup" &&
    chmod -R u-w "$cible" "$backup" &&
        echo -e "$BLACK $GREEN_BG"
    echo "Terminé"
    echo "Pour quitter, appuyez sur Entrée"
    echo -e "$NONE $NONE_BG"
    read
}

synchroLocal
