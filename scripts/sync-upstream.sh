#!/bin/bash
# Script de sincronización con upstream
# Uso: ./scripts/sync-upstream.sh

set -e

echo "🔄 Sincronizando con upstream..."

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Guardar rama actual
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${YELLOW}Rama actual: $CURRENT_BRANCH${NC}"

# Paso 1: Actualizar main
echo -e "\n${GREEN}1. Actualizando main...${NC}"
git checkout main
git fetch upstream
git merge upstream/main --no-edit
git push origin main
echo -e "${GREEN}✓ main actualizada${NC}"

# Paso 2: Actualizar custom
echo -e "\n${GREEN}2. Actualizando codingsoft/custom...${NC}"
git checkout codingsoft/custom
git merge main --no-edit

if [ $? -ne 0 ]; then
    echo -e "${RED}⚠️  Hay conflictos que resolver${NC}"
    echo "Resuelve los conflictos y luego ejecuta:"
    echo "  git add ."
    echo "  git commit -m 'sync: resolver conflictos con upstream'"
    echo "  git push origin codingsoft/custom"
    exit 1
fi

git push origin codingsoft/custom
echo -e "${GREEN}✓ codingsoft/custom actualizada${NC}"

# Paso 3: Opcional - actualizar develop
echo -e "\n${GREEN}3. Actualizando codingsoft/develop...${NC}"
git checkout codingsoft/develop
git merge codingsoft/custom --no-edit
git push origin codingsoft/develop
echo -e "${GREEN}✓ codingsoft/develop actualizada${NC}"

# Paso 4: Volver a rama original
echo -e "\n${GREEN}4. Volviendo a $CURRENT_BRANCH...${NC}"
git checkout $CURRENT_BRANCH

echo -e "\n${GREEN}✅ Sincronización completada${NC}"
echo ""
echo "Ramas actualizadas:"
git branch -vv | grep -E "(main|codingsoft)"
