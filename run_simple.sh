#!/bin/bash

echo "=== Iniciando CodingSoft WebUI (modo simple) ==="

# Matar procesos previos
pkill -f "python.*uvicorn" 2>/dev/null
pkill -f "node.*vite" 2>/dev/null

echo "1. Construyendo frontend estático..."
npm run build 2>&1 | tail -5

echo "2. Configurando entorno..."
export PYTHONPATH=$(pwd)/backend:$PYTHONPATH
export PORT=8080
export HOST=0.0.0.0

echo "3. Iniciando backend integrado..."
cd backend
python3.11 -c "
import sys
import os
import uvicorn
import asyncio
import threading
import time

# Configurar entorno
os.environ['PORT'] = '8080'
os.environ['HOST'] = '0.0.0.0'
os.environ['CORS_ALLOW_ORIGIN'] = '*'

sys.path.insert(0, '/Users/codingsoft/github/codingsoft-webui/backend')

try:
    # Importar después de configurar entorno
    from open_webui.main import app
    
    config = uvicorn.Config(
        'open_webui.main:app',
        host='0.0.0.0',
        port=8080,
        reload=False,
        log_level='info'
    )
    
    server = uvicorn.Server(config)
    
    # Ejecutar en thread separado
    def run():
        asyncio.run(server.serve())
    
    thread = threading.Thread(target=run, daemon=True)
    thread.start()
    
    print('Backend iniciado en http://localhost:8080')
    print('Frontend estático servido desde /app/frontend')
    print('Esperando conexiones...')
    
    # Mantener script vivo
    while True:
        time.sleep(1)
        
except Exception as e:
    print(f'Error: {e}')
    import traceback
    traceback.print_exc()
" 2>&1
