# Guía de Docker - CodingSoft WebUI

## Imágenes Docker Disponibles

### Registro Principal: GitHub Container Registry (GHCR)

```
ghcr.io/codingsoft/webui:latest
ghcr.io/codingsoft/webui:<version>
```

### Variantes de Imágenes

1. **`ghcr.io/codingsoft/webui:latest`** - Imagen estándar
2. **`ghcr.io/codingsoft/webui:<version>-cuda`** - Con soporte CUDA
3. **`ghcr.io/codingsoft/webui:<version>-cuda126`** - CUDA 12.6
4. **`ghcr.io/codingsoft/webui:<version>-ollama`** - Incluye Ollama
5. **`ghcr.io/codingsoft/webui:<version>-slim`** - Versión ligera

## Uso Básico

### Docker Compose (Recomendado)

```bash
# Configuración básica con Ollama
docker-compose up -d

# Con GPU (NVIDIA)
docker-compose -f docker-compose.yaml -f docker-compose.gpu.yaml up -d

# Con AMD GPU
docker-compose -f docker-compose.yaml -f docker-compose.amdgpu.yaml up -d

# Versión CUDA
docker-compose -f docker-compose.yaml -f docker-compose.gpu.yaml -f docker-compose-update.yml up -d
```

### Docker CLI

```bash
# Pull y ejecución básica
docker pull ghcr.io/codingsoft/webui:latest
docker run -d -p 3000:8080 \
  -v codingsoft-webui-data:/app/backend/data \
  -e WEBUI_SECRET_KEY=your-secret-key \
  --name codingsoft-webui \
  ghcr.io/codingsoft/webui:latest

# Con GPU
docker run -d -p 3000:8080 --gpus all \
  -v codingsoft-webui-data:/app/backend/data \
  -e WEBUI_SECRET_KEY=your-secret-key \
  ghcr.io/codingsoft/webui:cuda

# Con Ollama incluido
docker run -d -p 3000:8080 \
  -v codingsoft-webui-data:/app/backend/data \
  -e WEBUI_SECRET_KEY=your-secret-key \
  ghcr.io/codingsoft/webui:ollama
```

## Variables de Entorno Importantes

```bash
# Requerido
WEBUI_SECRET_KEY=your-secret-key-here

# Ollama
OLLAMA_BASE_URL=http://ollama:11434

# OpenAI API (opcional)
OPENAI_API_KEY=sk-...
OPENAI_API_BASE_URL=https://api.openai.com/v1

# Configuración de Base de Datos (opcional)
# DATABASE_URL=postgresql://user:pass@host:5432/dbname

# Configuración de Embeddings
RAG_EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
AUXILIARY_EMBEDDING_MODEL=TaylorAI/bge-micro-v2

# Otros
ENABLE_IMAGE_GENERATION=true
AUTOMATIC1111_BASE_URL=http://host:7860
```

## Volúmenes

```yaml
volumes:
  # Datos persistentes (base de datos, configuraciones)
  - codingsoft-webui-data:/app/backend/data

  # Ollama (si se usa externamente)
  - ollama:/root/.ollama
```

## Docker Compose Files

### docker-compose.yaml

Configuración básica con Ollama local.

### docker-compose.gpu.yaml

Añade soporte GPU para Ollama.

### docker-compose.amdgpu.yaml

Soporte para GPUs AMD.

### docker-compose-update.yml

Para desarrollo - monta código actualizado sin rebuild.

### docker-compose.otel.yaml

OpenTelemetry para monitoreo.

### docker-compose.playwright.yaml

Para testing con Playwright.

### docker-compose.api.yaml

Solo API, sin frontend.

## Build Local

```bash
# Build básico
docker build -t codingsoft-webui:latest .

# Build con CUDA
docker build -t codingsoft-webui:cuda --build-arg USE_CUDA=true .

# Build con Ollama
docker build -t codingsoft-webui:ollama --build-arg USE_OLLAMA=true .

# Build slim
docker build -t codingsoft-webui:slim --build-arg USE_SLIM=true .

# Build con hash específico
docker build -t codingsoft-webui:custom --build-arg BUILD_HASH=abc123 .
```

## Actualización

```bash
# Pull de la última imagen
docker-compose pull

# Recrear contenedores
docker-compose up -d

# Actualización sin downtime (si hay Healthcheck)
docker-compose up -d --no-deps --build codingsoft-webui
```

## Solución de Problemas

### Ver logs

```bash
docker-compose logs -f codingsoft-webui
docker logs -f codingsoft-webui
```

### Shell dentro del contenedor

```bash
docker exec -it codingsoft-webui /bin/bash
```

### Reiniciar completamente

```bash
docker-compose down -v  # -v elimina volúmenes (cuidado!)
docker-compose up -d
```

### Healthcheck falla

```bash
# Verificar endpoint
curl http://localhost:8080/health

# Ver logs detallados
docker logs codingsoft-webui --tail 100
```

## Arquitecturas Soportadas

- `linux/amd64` (x86_64)
- `linux/arm64` (ARM64)

Las imágenes son multi-arquitectura, Docker selecciona automáticamente la correcta.

## Seguridad

### No root (experimental)

```bash
docker build -t codingsoft-webui:rootless \
  --build-arg UID=1000 \
  --build-arg GID=1000 \
  --build-arg USE_PERMISSION_HARDENING=true .
```

### Variables sensibles

Usa Docker Secrets o variables de entorno seguras:

```bash
docker run -e WEBUI_SECRET_KEY_FILE=/run/secrets/webui_key ...
```

## Integración CI/CD

Las imágenes se construyen automáticamente en:

- Push a `main` → `ghcr.io/codingsoft/webui:main`
- Tag `v*` → `ghcr.io/codingsoft/webui:<version>` + `latest`
- Pull requests → Solo verificación, no push

Ver `.github/workflows/docker-build.yaml` para detalles.

## Recursos

- Docker Hub: `codingsoft/webui` (mirror)
- GHCR: `ghcr.io/codingsoft/webui`
- Documentación: https://docs.webui.codingsoft.org
