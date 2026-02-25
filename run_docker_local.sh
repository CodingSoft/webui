#!/bin/bash

echo "=== Usando Docker para CodingSoft WebUI ==="
echo "Esta es la forma más fácil de ejecutar localmente"

# Parar contenedores previos
docker compose down 2>/dev/null

echo "1. Iniciando con Docker Compose..."
docker compose up -d

echo ""
echo "2. Esperando inicio del contenedor..."
sleep 10

echo ""
echo "3. Verificando estado..."
docker ps | grep codingsoft-webui

echo ""
echo "📦 CodingSoft WebUI debería estar disponible en:"
echo "   http://localhost:3000"
echo ""
echo "📝 Para ver logs: docker compose logs -f"
echo "🛑 Para detener: docker compose down"
echo ""
echo "🎯 Alternativa: Acceder al frontend construido:"
echo "   http://localhost:5174 (solo frontend, necesita backend)"
