#!/bin/bash
# Script para crear tag de release con versión de upstream
# Uso: ./scripts/create-release-tag.sh [opcional: mensaje]

set -e

# Obtener última versión de upstream
UPSTREAM_VERSION=$(git describe --tags --abbrev=0 upstream/main 2>/dev/null || echo "v0.9.2")

# Formato del tag: codingsoft-v{VERSION}
TAG_NAME="codingsoft-${UPSTREAM_VERSION}"

echo "🏷️  Creando release tag..."
echo "   Upstream versión: $UPSTREAM_VERSION"
echo "   Tu tag será: $TAG_NAME"

# Verificar si ya existe
if git rev-parse "$TAG_NAME" >/dev/null 2>&1; then
    echo ""
    echo "⚠️  El tag $TAG_NAME ya existe"
    echo "   Opciones:"
    echo "   1. Usar versión de hotfix (codingsoft-${UPSTREAM_VERSION}.1)"
    echo "   2. Eliminar tag existente y recrear"
    echo "   3. Cancelar"
    read -p "Selecciona opción (1/2/3): " -n 1 -r
    echo
    
    if [[ $REPLY == "1" ]]; then
        TAG_NAME="codingsoft-${UPSTREAM_VERSION}.1"
        echo "   Nuevo tag: $TAG_NAME"
    elif [[ $REPLY == "2" ]]; then
        git tag -d "$TAG_NAME"
        git push origin :refs/tags/$TAG_NAME 2>/dev/null || true
        echo "   Tag anterior eliminado"
    else
        echo "   Cancelado"
        exit 0
    fi
fi

# Mensaje opcional
if [ -z "$1" ]; then
    MESSAGE="Release $TAG_NAME - CodingSoft AI Production"
else
    MESSAGE="$1"
fi

# Verificar que estamos en production
current_branch=$(git branch --show-current)
if [[ "$current_branch" != "codingsoft/production" ]]; then
    echo ""
    echo "⚠️  No estás en codingsoft/production"
    echo "   Rama actual: $current_branch"
    echo ""
    read -p "¿Cambiar a codingsoft/production y merge desde custom? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git checkout codingsoft/production
        git merge codingsoft/custom --no-edit
    else
        echo "   Cancelado. Asegúrate de estar en codingsoft/production"
        exit 1
    fi
fi

# Crear tag
echo ""
echo "📦 Creando tag..."
git tag -a "$TAG_NAME" -m "$MESSAGE"

echo ""
echo "🚀 Subiendo tag a origin..."
git push origin codingsoft/production
git push origin "$TAG_NAME"

echo ""
echo "✅ Release creado exitosamente"
echo ""
echo "   Tag: $TAG_NAME"
echo "   Mensaje: $MESSAGE"
echo "   Branch: codingsoft/production"
echo ""
echo "   Ver en GitHub:"
echo "   https://github.com/CodingSoft/webui/releases/tag/$TAG_NAME"
