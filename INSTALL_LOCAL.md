# Instalación Local de CodingSoft WebUI

## Requisitos
- Node.js v18+ (recomendado v20+)
- Python 3.11+
- npm

## Pasos de instalación

### 1. Clonar repositorio
```bash
git clone https://github.com/codingsoft/webui.git
cd codingsoft-webui
```

### 2. Instalar dependencias frontend
```bash
npm ci --force
```

### 3. Instalar dependencias backend
```bash
python3.11 -m pip install -r backend/requirements-min.txt
```

### 4. Instalar dependencias adicionales (si es necesario)
```bash
python3.11 -m pip install beautifulsoup4 lxml boto3 click h11 joblib regex tqdm packaging
```

### 5. Configurar entorno
```bash
cp .env.example .env  # o crear .env con configuración local
```

### 6. Iniciar aplicación
```bash
# Opción 1: Usar script
./run_local.sh

# Opción 2: Manualmente
# Terminal 1 - Frontend
npm run dev

# Terminal 2 - Backend
cd backend
python3.11 -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8081 --reload
```

## URLs de acceso
- **Frontend**: http://localhost:5174
- **Backend**: http://localhost:8081
- **API Docs**: http://localhost:8081/docs

## Configuración de entorno (.env)
```env
OLLAMA_BASE_URL='http://localhost:11434'
OPENAI_API_BASE_URL=''
OPENAI_API_KEY=''
CORS_ALLOW_ORIGIN='*'
FORWARDED_ALLOW_IPS='*'
WEBUI_NAME="CodingSoft WebUI"
WEBUI_FAVICON_URL="http://localhost:8081/favicon.svg"
WEBUI_AUTHOR_NAME="Oscar Alardin"
WEBUI_AUTHOR_EMAIL="o.alardin@codingsoft.org"
PORT=8081
HOST=0.0.0.0
```

## Solución de problemas

### Error: ModuleNotFoundError
```bash
# Instalar módulo faltante
python3.11 -m pip install <nombre_modulo>
```

### Error: Puerto en uso
```bash
# Cambiar puerto en .env o línea de comando
PORT=8082 python3.11 -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8082
```

### Error: CORS
```bash
# Asegurar que CORS_ALLOW_ORIGIN incluya el frontend
CORS_ALLOW_ORIGIN='http://localhost:5174'
```

## Docker alternativa
```bash
docker compose up -d
# Acceder en http://localhost:3000
```

## Próximos pasos
1. Configurar Ollama para modelos locales
2. Conectar a APIs externas (OpenAI, Anthropic, etc.)
3. Personalizar branding adicional
4. Configurar autenticación

---
**Repositorio**: https://github.com/codingsoft/webui  
**Documentación**: Ver README.md y DEPLOYMENT.md
