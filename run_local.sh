#!/bin/bash

echo "=== Iniciando CodingSoft WebUI localmente ==="

# Configurar variables de entorno
export PYTHONPATH=$(pwd)/backend:$PYTHONPATH

# Iniciar frontend en background
echo "1. Iniciando frontend (localhost:5174)..."
npm run dev > frontend.log 2>&1 &
FRONTEND_PID=$!

# Iniciar backend
echo "2. Iniciando backend (localhost:8081)..."
cd backend
python3.11 -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8081 --reload > backend.log 2>&1 &
BACKEND_PID=$!

echo ""
echo "Frontend: http://localhost:5174"
echo "Backend:  http://localhost:8081"
echo "Logs: frontend.log y backend.log"
echo ""
echo "Presiona Ctrl+C para detener"

# Esperar señal de interrupción
trap "kill $FRONTEND_PID $BACKEND_PID 2>/dev/null; echo 'Aplicación detenida'; exit" INT
wait
