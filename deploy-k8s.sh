#!/usr/bin/env bash
set -euo pipefail

# === Configuration à adapter ===
REPO_SSH="git@github.com:charlesvdd/kickstarter-k8s-db.git"
LOCAL_DIR="${HOME}/kickstarter-k8s-db"
BRANCH="k8s"
# Chemin local où se trouvent ton chart/templates/values/
CHART_SRC_DIR="${HOME}/kickstarter-k8s-db-chart" 
# =================================

# 1. Cloner ou mettre à jour le dépôt
if [ ! -d "${LOCAL_DIR}/.git" ]; then
  echo "Clonage du dépôt…"
  git clone "${REPO_SSH}" "${LOCAL_DIR}"
fi
cd "${LOCAL_DIR}"
git fetch origin

# 2. Création ou bascule sur la branche k8s
if git show-ref --quiet "refs/heads/${BRANCH}"; then
  echo "Bascule sur la branche ${BRANCH} et mise à jour…"
  git checkout "${BRANCH}"
  git pull origin "${BRANCH}"
else
  echo "Création de la branche ${BRANCH}…"
  git checkout -b "${BRANCH}"
fi

# 3. Copie des fichiers K8s (Helm/chart/manifests)
echo "Mise à jour du contenu depuis ${CHART_SRC_DIR}…"
rsync -av --delete --exclude '.git' "${CHART_SRC_DIR}/" .

# 4. Commit & push
if git diff --quiet && git diff --cached --quiet; then
  echo "Rien à committer."
else
  git add .
  git commit -m "Kickstart: ajout de la branche Kubernetes (chart/manifests)"
  git push -u origin "${BRANCH}"
fi

echo "Déploiement sur la branche ${BRANCH} terminé."
