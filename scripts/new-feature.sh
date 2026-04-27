#!/bin/bash
# Script para crear nueva feature
# Uso: ./scripts/new-feature.sh nombre-de-la-feature

set -e

if [ -z "$1" ]; then
    echo "❌ Error: Debes proporcionar un nombre para la feature"
    echo "Uso: ./scripts/new-feature.sh mi-nueva-funcionalidad"
    exit 1
fi

FEATURE_NAME=$1
BRANCH_NAME="feature/$FEATURE_NAME"

echo "🚀 Creando nueva feature: $FEATURE_NAME"

# Verificar que estamos en custom o develop
CURRENT_BRANCH=$(git branch --show-current)
if [[ "$CURRENT_BRANCH" != "codingsoft/custom" && "$CURRENT_BRANCH" != "codingsoft/develop" ]]; then
    echo "⚠️  Advertencia: No estás en codingsoft/custom o codingsoft/develop"
    echo "Rama actual: $CURRENT_BRANCH"
    read -p "¿Continuar de todas formas? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Crear rama
echo "📦 Creando rama: $BRANCH_NAME"
git checkout -b $BRANCH_NAME

echo ""
echo "✅ Rama creada exitosamente"
echo ""
echo "Ahora puedes:"
echo "  1. Hacer tus cambios"
echo "  2. git add ."
echo "  3. git commit -m 'feat: $FEATURE_NAME'"
echo "  4. git push origin $BRANCH_NAME"
echo ""
echo "Cuando termines, crea un PR o merge a codingsoft/develop"
