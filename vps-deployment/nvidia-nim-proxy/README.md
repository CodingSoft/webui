# NVIDIA NIM Proxy para CodingSoft WebUI

Proxy adaptador que permite usar la API de NVIDIA NIM (Stable Diffusion, Flux, etc.) como si fuera OpenAI DALL-E.

## Características

- ✅ Compatible con API OpenAI (DALL-E)
- ✅ Soporta múltiples modelos:
  - `dall-e-3` → Stable Diffusion 3 Medium
  - `dall-e-2` → SDXL
  - `gpt-image` → Flux.1 Dev
  - `flux-fast` → Flux.1 Schnell
  - `sdxl` → Stable Diffusion XL
  - `sd3` → Stable Diffusion 3 Medium
- ✅ Conversión automática de formatos
- ✅ Soporte para diferentes tamaños y aspect ratios

## Configuración Rápida

### 1. Requisitos

- API Key de NVIDIA NIM (obtenible en https://build.nvidia.com)
- Docker y Docker Compose

### 2. Despliegue

```bash
# Configurar API key
export NVIDIA_NIM_API_KEY="nvapi-xxxx..."

# Iniciar servicio
docker-compose up -d

# Verificar
curl http://localhost:8099/
```

### 3. Configurar WebUI

En CodingSoft WebUI, configurar:

- **Motor**: `openai`
- **API Base URL**: `http://nvidia-nim-proxy:8000/v1`
- **API Key**: `nvapi-xxxx...` (tu key de NVIDIA)
- **Modelo**: `dall-e-3` (u otro de la lista)

## Variables de Entorno

| Variable             | Descripción              | Default     |
| -------------------- | ------------------------ | ----------- |
| `NVIDIA_NIM_API_KEY` | API Key de NVIDIA NIM    | (requerido) |
| `ALLOWED_ORIGINS`    | Orígenes CORS permitidos | `*`         |

## Endpoints

- `GET /` - Health check
- `GET /v1/models` - Lista modelos disponibles
- `POST /v1/images/generations` - Generar imágenes

## Ejemplo de Uso

```bash
curl -X POST http://localhost:8099/v1/images/generations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer nvapi-xxxx..." \
  -d '{
    "prompt": "A beautiful sunset over mountains",
    "model": "dall-e-3",
    "size": "1024x1024"
  }'
```

## Modelos Disponibles

| Modelo         | NVIDIA Endpoint                       | Calidad    | Velocidad   |
| -------------- | ------------------------------------- | ---------- | ----------- |
| dall-e-3       | stabilityai/stable-diffusion-3-medium | ⭐⭐⭐⭐⭐ | Media       |
| dall-e-2       | stabilityai/stable-diffusion-xl       | ⭐⭐⭐⭐   | Media       |
| gpt-image/flux | black-forest-labs/flux.1-dev          | ⭐⭐⭐⭐⭐ | Media-Lenta |
| flux-fast      | black-forest-labs/flux.1-schnell      | ⭐⭐⭐⭐   | Rápida      |
| sdxl           | stabilityai/stable-diffusion-xl       | ⭐⭐⭐⭐   | Media       |
| sd3            | stabilityai/stable-diffusion-3-medium | ⭐⭐⭐⭐⭐ | Media       |

## Costos

Según NVIDIA NIM:

- Primeros 10K requests/mes: Gratis (según tier)
- Después: ~$0.04-0.08 por imagen

## Solución de Problemas

### Error 401

Verifica que `NVIDIA_NIM_API_KEY` esté configurado correctamente.

### Timeout

Aumenta el timeout en WebUI o usa un modelo más rápido (flux-fast).

### Modelo no encontrado

Asegúrate de usar el nombre del modelo mapeado en la tabla arriba.
