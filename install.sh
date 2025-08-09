# !/usr/bin/env bash
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

# Copier uniquement les fichiers se terminant par .theme (recherche récursive) et
# déposer les fichiers directement dans le dossier destination (aplatissement).
# Si aucun fichier .theme n'est trouvé, on le signale.
FOUND=$(find "$SRC_DIR" -type f -name '*.theme' -print -quit || true)
if [ -z "$FOUND" ]; then
  echo "Aucun fichier .theme trouvé dans '$SRC_DIR'. Rien à copier."
else
  echo "Copie des fichiers '.theme' depuis '$SRC_DIR' vers '$DEST'..."
  # Utilise cp -t pour copier plusieurs fichiers en une commande (GNU cp).
  # On utilise -L pour suivre les liens symboliques si besoin.
  find "$SRC_DIR" -type f -name '*.theme' -print0 | xargs -0 cp -t "$DEST" || {
    # Fallback si cp -t indisponible : boucle simple
    echo "Fallback: copie manuelle des fichiers"
    while IFS= read -r -d '' file; do
      cp "$file" "$DEST/"
    done < <(find "$SRC_DIR" -type f -name '*.theme' -print0)
  }
fi

# Résultat final
echo
echo "Installation terminée — thèmes installés dans : $DEST"
ls -l "$DEST" || true

echo
echo "Remarques :"
echo " - Ce script copie uniquement les fichiers se terminant par .theme trouvés sous 'themes/'."
echo " - Si une version précédente des thèmes existe, elle est déplacée en tant que sauvegarde (suffixe .backup.TIMESTAMP)."
echo " - Lance ce script depuis la racine du dépôt cloné (là où se trouve le dossier 'themes')."

exit 0
