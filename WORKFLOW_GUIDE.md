# Guía de Flujo de Trabajo - CodingSoft WebUI

## Overview

Este documento describe el flujo de trabajo CI/CD actualizado para el proyecto CodingSoft WebUI.

## Workflows Disponibles

### 1. `release-complete.yml` (NUEVO - Recomendado)

**Pipeline unificado** que ejecuta todo el proceso de release.

**Cuándo usar:**

- Ejecuta automáticamente en push a `main` o tags `v*`
- O manualmente: GitHub Actions → release-complete.yml → "Run workflow"

**Qué hace:**

1. Prepara y verifica la versión desde `package.json`
2. Verifica que el tag no exista ya
3. Construye y publica imágenes Docker:
   - `ghcr.io/codingsoft/webui:latest`
   - `ghcr.io/codingsoft/webui:<version>`
   - `ghcr.io/codingsoft/webui:<version>-cuda`
   - `ghcr.io/codingsoft/webui:<version>-ollama`
   - `ghcr.io/codingsoft/webui:<version>-slim`
4. Publica el package en PyPI: `codingsoft-webui`
5. Crea un GitHub Release con notas del CHANGELOG

**Parámetros manuales:**

- `skip_docker`: Saltar build de Docker
- `skip_pypi`: Saltar publicación en PyPI

### 2. `docker-build.yaml` (Mantenido)

Build de Docker avanzado con multi-arquitectura.

**Cuándo usar:**

- Ejecuta automáticamente en push a `main`, `dev` o tags `v*`
- Para builds de desarrollo o específicos

**Qué hace:**

- Construye imágenes para amd64 y arm64
- Múltiples variantes: main, cuda, cuda126, ollama, slim
- Publica en GitHub Container Registry (GHCR)
- Copia a Docker Hub: `codingsoft/webui`

### 3. `release-pypi.yml` (Corregido)

Publicación en PyPI.

**Cuándo usar:**

- Ejecuta automáticamente en push a `main` o tags `v*`
- O manualmente para releases específicos

**Qué hace:**

- Construye package Python con hatch
- Publica en PyPI como `codingsoft-webui`
- Requiere ambiente `pypi` configurado

### 4. `build-release.yml` (Actualizado)

Crea GitHub Releases.

**Cuándo usar:**

- Ejecuta automáticamente en push a `main`

**Qué hace:**

- Extrae versión de `package.json`
- Crea tag y release en GitHub
- Extrae notas del CHANGELOG
- Triggers automáticos de Docker y PyPI

### 5. `format-build-frontend.yml` (Sin cambios)

Formateo y build del frontend.

**Cuándo usar:**

- Ejecuta automáticamente en push a `main` o `dev`
- Cuando cambian archivos del frontend

**Qué hace:**

- Formatea código con prettier
- Ejecuta i18next
- Corre tests con vitest

### 6. `format-backend.yaml` (Sin cambios)

Formateo del backend.

**Cuándo usar:**

- Ejecuta automáticamente en push a `main` o `dev`
- Cuando cambian archivos del backend

**Qué hace:**

- Formatea código con black
- Verifica en Python 3.11 y 3.12

### 7. `deploy-to-hf-spaces.yml` (Corregido)

Despliegue en HuggingFace Spaces.

**Cuándo usar:**

- Ejecuta automáticamente en push a `main` o `dev`
- Requiere secreto `HF_TOKEN` configurado

## Flujo de Trabajo Recomendado

### Para un Release Normal:

```bash
# 1. Actualizar versión en package.json
# Ejemplo: 0.8.10 → 0.8.11
vi package.json

# 2. Commit y push
git add package.json
git commit -m "chore: bump version to 0.8.11"
git push origin main

# 3. Los workflows se ejecutarán automáticamente:
#    - build-release.yml creará el tag y release
#    - docker-build.yml construirá las imágenes
#    - release-pypi.yml publicará en PyPI
```

### Para un Release Manual (usando release-complete.yml):

1. Ir a GitHub Actions → release-complete.yml
2. Click "Run workflow"
3. Seleccionar rama (main o tag)
4. Opcional: marcar skip_docker o skip_pypi
5. Click "Run workflow"

### Para Desarrollo Local:

```bash
# Build local con Docker
docker build -t codingsoft-webui:latest .

# O con variantes:
docker build -t codingsoft-webui:cuda --build-arg USE_CUDA=true .
docker build -t codingsoft-webui:ollama --build-arg USE_OLLAMA=true .
docker build -t codingsoft-webui:slim --build-arg USE_SLIM=true .

# Usar docker-compose
docker-compose up -d
```

## Configuración Requerida

### Secrets Necesarios:

1. **GitHub Token** (automático): `GITHUB_TOKEN`
2. **PyPI** (opcional): Configurar ambiente `pypi` con:
   - `id-token: write` (OIDC trusted publishing)
3. **HuggingFace** (opcional): `HF_TOKEN`
4. **Docker Hub** (opcional): `DOCKERHUB_USERNAME` y `DOCKERHUB_TOKEN`

### Permisos de Workflows:

Los workflows requieren estos permisos:

```yaml
permissions:
  contents: write # Para crear releases
  packages: write # Para publicar en GHCR
  actions: write # Para trigger otros workflows
  id-token: write # Para PyPI OIDC
```

## Solución de Problemas

### El workflow no se ejecuta:

- Verificar que el archivo YAML tiene sintaxis válida
- Revisar que el evento (push/PR) coincide con los triggers
- Verificar permisos en Settings → Actions → General

### Error en Docker build:

- Verificar que Dockerfile existe
- Revisar logs de build en la pestaña "Build Docker image"
- Para errores de espacio, usar runner con más recursos

### Error en PyPI:

- Verificar que el ambiente `pypi` está configurado
- Revisar que el nombre del package no está ocupado
- Verificar versión no existe ya en PyPI

### Tag duplicado:

- El workflow `build-release.yml` ahora verifica tags duplicados
- Si existe, se omite la creación del release
- Usar `workflow_dispatch` si necesitas forzar

## Versionado

El proyecto usa **Semantic Versioning** basado en `package.json`:

- `package.json` → `version`: "0.8.11"
- Tag: `v0.8.11`
- Docker: `:0.8.11`, `:0.8`, `:latest`
- PyPI: `codingsoft-webui==0.8.11`

## Contacto

- Issues: https://github.com/codingsoft/webui/issues
- Discussions: https://github.com/codingsoft/webui/discussions
- Documentación: https://docs.webui.codingsoft.org
- Email: o.alardin@codingsoft.org
