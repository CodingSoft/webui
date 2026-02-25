# Inicio Rápido de CodingSoft WebUI

## Opción 1: Docker (Recomendado)

```bash
# 1. Asegurar tener Docker instalado
docker --version

# 2. Iniciar con Docker Compose
docker compose up -d

# 3. Acceder en:
#    http://localhost:3000
```

## Opción 2: Solo Frontend (para desarrollo)

```bash
# 1. Instalar dependencias frontend
npm ci --force

# 2. Configurar proxy para backend
# Editar vite.config.js para apuntar a backend real
# O usar backend público de prueba

# 3. Iniciar frontend
npm run dev
# Acceder en: http://localhost:5174
```

## Opción 3: Backend Local (Complejo)

Requiere muchas dependencias Python. Se recomienda:

```bash
# Usar entorno virtual
python3.11 -m venv venv
source venv/bin/activate

# Instalar paquetes gradualmente
pip install -r backend/requirements-min.txt

# Instalar dependencias adicionales según errores
```

## Solución al error "Backend Required"

El frontend necesita un backend real para funcionar. Opciones:

### A. Usar Docker Compose (más fácil)
```bash
docker compose up -d
# Accede a http://localhost:3000
```

### B. Configurar backend remoto
1. Desplegar backend en servidor separado
2. Configurar CORS
3. Apuntar frontend a URL del backend

### C. Usar Open WebUI original temporalmente
```bash
docker run -d -p 3000:8080 --name open-webui ghcr.io/open-webui/open-webui:main
# Luego modificar frontend para apuntar a localhost:3000/api
```

## Pasos para desarrollo completo

1. **Backend primero:**
   ```bash
   # Iniciar backend en puerto 8080
   cd backend
   python3.11 -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8080
   ```

2. **Frontend después:**
   ```bash
   # Configurar CORS_ALLOW_ORIGIN en .env
   # Iniciar frontend
   npm run dev
   ```

3. **Acceder:**
   - Backend API: http://localhost:8080/docs
   - Frontend: http://localhost:5174

## Troubleshooting

### Error: ModuleNotFoundError
```bash
pip install <modulo_faltante>
```

### Error: Puerto en uso
```bash
# Cambiar puerto
PORT=8082 python3.11 -m uvicorn open_webui.main:app --host 0.0.0.0 --port 8082
```

### Error: CORS
```bash
# En .env del backend
CORS_ALLOW_ORIGIN='http://localhost:5174'
```

---
**Para uso rápido**: `docker compose up -d`  
**Para desarrollo**: Configurar backend primero, luego frontend  
**Para pruebas**: Usar solo frontend con backend remoto
