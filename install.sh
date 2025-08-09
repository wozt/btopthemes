#!/usr/bin/env bash
# install.sh
# Script d'installation des thèmes btop depuis le dépôt local.
# Usage:
#   git clone https://github.com/wozt/btopthemes.git
#   cd btopthemes
#   chmod +x install.sh
#   ./install.sh

set -euo pipefail

# Répertoire source (le dossier "themes" dans le dépôt)
REPO_DIR="$(pwd)"
SRC_DIR="$REPO_DIR/themes"

# Destination : respecte XDG_CONFIG_HOME si défini, sinon $HOME/.config
DEST="${XDG_CONFIG_HOME:-$HOME/.config}/btop/themes"

# Vérifications initiales
if [ ! -d "$SRC_DIR" ]; then
  echo "Erreur : le dossier de thèmes '$SRC_DIR' est introuvable."
  echo "Assure-toi d'exécuter ce script depuis la racine du dépôt (là où se trouve le dossier 'themes')."
  exit 1
fi

# Sauvegarde du dossier de destination s'il existe et n'est pas vide
if [ -d "$DEST" ] && [ "$(ls -A "$DEST")" ]; then
  TIMESTAMP=$(date +%Y%m%d%H%M%S)
  BACKUP="${DEST}.backup.${TIMESTAMP}"
  echo "Sauvegarde du dossier existant vers : $BACKUP"
  mkdir -p "$(dirname "$BACKUP")"
  mv "$DEST" "$BACKUP"
fi

# Création du dossier de destination
mkdir -p "$DEST"

# Copie du contenu de 'themes/' **dans** le dossier destination (sans créer un sous-dossier 'themes')
# On préfère rsync si disponible car il est plus fiable pour la copie récursive et les attributs.
if command -v rsync >/dev/null 2>&1; then
  echo "Copie des thèmes avec rsync..."
  rsync -a --delete "$SRC_DIR"/ "$DEST"/
else
  echo "Copie des thèmes avec cp -a..."
  cp -a "$SRC_DIR"/. "$DEST"/
fi

# Suppression du README.md local (demande de l'utilisateur)
if [ -f "$REPO_DIR/README.md" ]; then
  echo "Suppression de README.md dans le dépôt local..."
  rm -f "$REPO_DIR/README.md"
fi

# Résultat final
echo
echo "Installation terminée — thèmes installés dans : $DEST"
ls -l "$DEST"

echo
echo "Remarques :"
echo " - Si tu veux restaurer l'ancienne version des thèmes, regarde le dossier de sauvegarde si présent (suffixe .backup.TIMESTAMP)."
echo " - Ce script doit être lancé depuis la racine du dépôt cloné (où se trouve le dossier 'themes')."

exit 0
