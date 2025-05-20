#!/bin/bash

# Script de synchronisation du dépôt GitHub grilles-pedopsy
# Créé le $(date +"%d/%m/%Y")

# Définition des couleurs pour les messages
VERT='\033[0;32m'
ROUGE='\033[0;31m'
BLEU='\033[0;34m'
NC='\033[0m' # No Color

# Chemin du dépôt
REPO_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_FILES="$REPO_PATH/repo"

# Fonction pour afficher un message d'information
info() {
    echo -e "${BLEU}[INFO]${NC} $1"
}

# Fonction pour afficher un message de succès
succes() {
    echo -e "${VERT}[SUCCÈS]${NC} $1"
}

# Fonction pour afficher un message d'erreur
erreur() {
    echo -e "${ROUGE}[ERREUR]${NC} $1"
}

# Aller dans le dossier du dépôt
cd "$REPO_PATH" || {
    erreur "Impossible d'accéder au dossier du dépôt"
    exit 1
}

# Afficher un message de bienvenue
echo "========================================================="
echo "   Synchronisation du dépôt GitHub grilles-pedopsy"
echo "========================================================="
echo ""

# Vérifier l'état actuel du dépôt
info "Vérification de l'état du dépôt..."
git status

# Demander à l'utilisateur s'il souhaite synchroniser (pull) ou envoyer (push)
echo ""
echo "Que souhaitez-vous faire ?"
echo "1. Récupérer les dernières modifications depuis GitHub (pull)"
echo "2. Envoyer les modifications locales vers GitHub (push)"
echo "3. Les deux (pull puis push)"
echo "4. Annuler"
read -p "Votre choix (1-4): " choix

case $choix in
    1)
        # Pull - Récupérer les modifications depuis GitHub
        info "Récupération des modifications depuis GitHub..."
        if git pull origin main; then
            # Copier les fichiers mis à jour vers le dossier repo
            info "Mise à jour du dossier repo..."
            rsync -av --exclude='.git' --exclude='README.md' --exclude='synchroniser_github.sh' --exclude='repo' --exclude='.DS_Store' ./ ./repo/
            succes "Synchronisation réussie !"
        else
            erreur "Échec de la synchronisation"
        fi
        ;;
    2)
        # Push - Envoyer les modifications vers GitHub
        # Copier les fichiers du dossier repo vers la racine pour Git
        info "Copie des fichiers du dossier repo vers la racine pour Git..."
        rsync -av --delete --exclude='.git' --exclude='README.md' --exclude='synchroniser_github.sh' --exclude='repo' --exclude='.DS_Store' ./repo/ ./
        
        info "Préparation des modifications à envoyer..."
        git add .
        
        # Demander un message de commit
        echo ""
        read -p "Message pour décrire vos modifications: " commit_msg
        
        if [ -z "$commit_msg" ]; then
            commit_msg="Mise à jour du $(date +"%d/%m/%Y à %H:%M")"
        fi
        
        info "Enregistrement des modifications..."
        if git commit -m "$commit_msg"; then
            info "Envoi des modifications vers GitHub..."
            if git push origin main; then
                succes "Modifications envoyées avec succès !"
            else
                erreur "Échec de l'envoi des modifications"
            fi
        else
            info "Aucune modification à envoyer ou erreur lors du commit"
        fi
        ;;
    3)
        # Pull puis Push
        info "Récupération des modifications depuis GitHub..."
        if git pull origin main; then
            # Copier les fichiers mis à jour vers le dossier repo
            info "Mise à jour du dossier repo..."
            rsync -av --exclude='.git' --exclude='README.md' --exclude='synchroniser_github.sh' --exclude='repo' --exclude='.DS_Store' ./ ./repo/
            succes "Synchronisation réussie !"
            
            # Copier les fichiers du dossier repo vers la racine pour Git
            info "Copie des fichiers du dossier repo vers la racine pour Git..."
            rsync -av --delete --exclude='.git' --exclude='README.md' --exclude='synchroniser_github.sh' --exclude='repo' --exclude='.DS_Store' ./repo/ ./
            
            info "Préparation des modifications à envoyer..."
            git add .
            
            # Demander un message de commit
            echo ""
            read -p "Message pour décrire vos modifications: " commit_msg
            
            if [ -z "$commit_msg" ]; then
                commit_msg="Mise à jour du $(date +"%d/%m/%Y à %H:%M")"
            fi
            
            info "Enregistrement des modifications..."
            if git commit -m "$commit_msg"; then
                info "Envoi des modifications vers GitHub..."
                if git push origin main; then
                    succes "Modifications envoyées avec succès !"
                else
                    erreur "Échec de l'envoi des modifications"
                fi
            else
                info "Aucune modification à envoyer ou erreur lors du commit"
            fi
        else
            erreur "Échec de la synchronisation initiale"
        fi
        ;;
    4)
        # Annuler
        info "Opération annulée"
        ;;
    *)
        erreur "Choix invalide"
        ;;
esac

echo ""
echo "Appuyez sur Entrée pour quitter..."
read -r
