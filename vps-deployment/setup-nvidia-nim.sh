#!/bin/bash

# ============================================
# Instalación Automática NVIDIA NIM Proxy
# ============================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

echo "========================================"
echo "  NVIDIA NIM Proxy - Instalación"
echo "========================================"
echo ""

# Verificar Docker
if ! command -v docker &> /dev/null; then
    log_error "Docker no está instalado"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    log_error "Docker Compose no está instalado"
    exit 1
fi

# Crear directorio
INSTALL_DIR="/opt/nvidia-nim-proxy"
log_info "Creando directorio de instalación: $INSTALL_DIR"
mkdir -p $INSTALL_DIR

# Verificar si ya existe
if [ -d "$INSTALL_DIR" ] && [ "$(ls -A $INSTALL_DIR)" ]; then
    log_warning "El directorio ya existe y tiene archivos"
    read -p "¿Deseas sobrescribir? (s/n): " overwrite
    if [[ ! "$overwrite" =~ ^[sS]$ ]]; then
        log_info "Instalación cancelada"
        exit 0
    fi
fi

cd $INSTALL_DIR

# Solicitar API Key
if [ -z "$NVIDIA_NIM_API_KEY" ]; then
    echo ""
    echo "Por favor, introduce tu API Key de NVIDIA NIM:"
    echo "  Obtén tu API Key en: https://build.nvidia.com"
    echo ""
    read -s -p "API Key (presiona Enter para configurar después): " api_key
    echo ""
    
    if [ -n "$api_key" ]; then
        export NVIDIA_NIM_API_KEY="$api_key"
    fi
fi

# Crear archivos
cat > main.py << 'PROXYEOF'
"""
NVIDIA NIM Proxy Adapter para CodingSoft WebUI
Convierte llamadas OpenAI DALL-E a NVIDIA NIM API
"""

from fastapi import FastAPI, HTTPException, Header
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Literal
import httpx
import os
import base64
import time

app = FastAPI(title="NVIDIA NIM Proxy", version="1.0.0")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mapeo de modelos OpenAI -> NVIDIA NIM
MODEL_MAPPING = {
    "dall-e-3": "stabilityai/stable-diffusion-3-medium",
    "dall-e-2": "stabilityai/stable-diffusion-xl",
    "gpt-image": "black-forest-labs/flux.1-dev",
    "sdxl": "stabilityai/stable-diffusion-xl",
    "sd3": "stabilityai/stable-diffusion-3-medium",
    "flux": "black-forest-labs/flux.1-dev",
    "flux-fast": "black-forest-labs/flux.1-schnell",
}

NVIDIA_BASE_URL = "https://ai.api.nvidia.com/v1/genai"

class ImageGenerationRequest(BaseModel):
    prompt: str
    model: Optional[str] = "dall-e-3"
    n: Optional[int] = 1
    size: Optional[str] = "1024x1024"
    quality: Optional[str] = "standard"
    style: Optional[str] = None

class ImageEditRequest(BaseModel):
    prompt: str
    model: Optional[str] = "dall-e-2"
    n: Optional[int] = 1
    size: Optional[str] = "1024x1024"

@app.get("/")
async def root():
    return {"status": "NVIDIA NIM Proxy running", "version": "1.0.0"}

@app.get("/v1/models")
async def list_models():
    return {
        "object": "list",
        "data": [
            {"id": "dall-e-3", "object": "model", "created": int(time.time()), "owned_by": "nvidia-nim"},
            {"id": "dall-e-2", "object": "model", "created": int(time.time()), "owned_by": "nvidia-nim"},
            {"id": "gpt-image", "object": "model", "created": int(time.time()), "owned_by": "nvidia-nim"},
            {"id": "sdxl", "object": "model", "created": int(time.time()), "owned_by": "nvidia-nim"},
            {"id": "sd3", "object": "model", "created": int(time.time()), "owned_by": "nvidia-nim"},
            {"id": "flux", "object": "model", "created": int(time.time()), "owned_by": "nvidia-nim"},
            {"id": "flux-fast", "object": "model", "created": int(time.time()), "owned_by": "nvidia-nim"},
        ]
    }

@app.post("/v1/images/generations")
async def generate_image(
    request: ImageGenerationRequest,
    authorization: Optional[str] = Header(None)
):
    api_key = authorization.replace("Bearer ", "") if authorization else os.getenv("NVIDIA_NIM_API_KEY")
    if not api_key:
        raise HTTPException(status_code=401, detail="NVIDIA NIM API key required")
    
    nim_model = MODEL_MAPPING.get(request.model, "stabilityai/stable-diffusion-3-medium")
    
    aspect_ratio = "1:1"
    if request.size:
        size_map = {
            "1024x1024": "1:1",
            "1024x1536": "2:3",
            "1536x1024": "3:2",
            "1024x576": "16:9",
            "576x1024": "9:16",
        }
        aspect_ratio = size_map.get(request.size, "1:1")
    
    payload = {
        "prompt": request.prompt,
        "aspect_ratio": aspect_ratio,
        "output_type": "base64",
    }
    
    if request.quality == "hd":
        payload["guidance_scale"] = 8.0
        payload["num_inference_steps"] = 50
    else:
        payload["guidance_scale"] = 5.0
        payload["num_inference_steps"] = 28
    
    url = f"{NVIDIA_BASE_URL}/{nim_model}"
    
    async with httpx.AsyncClient(timeout=120.0) as client:
        try:
            response = await client.post(
                url,
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json",
                },
                json=payload
            )
            
            if response.status_code != 200:
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"NVIDIA NIM error: {response.text}"
                )
            
            nim_response = response.json()
            images = []
            
            if "image" in nim_response:
                images.append({
                    "b64_json": nim_response["image"],
                    "revised_prompt": request.prompt
                })
            elif "images" in nim_response:
                for img in nim_response["images"]:
                    images.append({
                        "b64_json": img if isinstance(img, str) else img.get("image", ""),
                        "revised_prompt": request.prompt
                    })
            
            return {
                "created": int(time.time()),
                "data": images
            }
            
        except httpx.TimeoutException:
            raise HTTPException(status_code=504, detail="NVIDIA NIM timeout")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error: {str(e)}")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
PROXYEOF

cat > requirements.txt << 'REQEOF'
fastapi>=0.104.0
uvicorn[standard]>=0.24.0
httpx>=0.25.0
pydantic>=2.0.0
REQEOF

cat > Dockerfile << 'DOCKEREof'
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY main.py .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
DOCKEREof

cat > docker-compose.yml << 'COMPOSEEOF'
version: "3.8"
services:
  nvidia-nim-proxy:
    build: .
    container_name: nvidia-nim-proxy
    restart: unless-stopped
    ports:
      - "127.0.0.1:8099:8000"
    environment:
      - NVIDIA_NIM_API_KEY=${NVIDIA_NIM_API_KEY:-}
      - ALLOWED_ORIGINS=*
    networks:
      - webui-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 10s

networks:
  webui-net:
    external: true
COMPOSEEOF

# Crear archivo .env si no existe
if [ ! -f ".env" ]; then
    echo "NVIDIA_NIM_API_KEY=${NVIDIA_NIM_API_KEY:-}" > .env
    log_info "Archivo .env creado"
fi

# Construir y ejecutar
log_info "Construyendo imagen Docker..."
docker-compose build

log_info "Iniciando servicio..."
docker-compose up -d

log_success "========================================"
log_success "NVIDIA NIM Proxy instalado correctamente!"
log_success "========================================"
echo ""
echo "📍 Ubicación: $INSTALL_DIR"
echo "🌐 URL: http://localhost:8099"
echo ""
echo "🔧 Configuración en WebUI:"
echo "  Motor: openai"
echo "  API Base URL: http://nvidia-nim-proxy:8000/v1"
echo "  API Key: (tu NVIDIA NIM API key)"
echo ""
echo "📋 Comandos útiles:"
echo "  cd $INSTALL_DIR"
echo "  docker-compose logs -f"
echo "  docker-compose restart"
echo "  docker-compose down"
echo ""

# Verificar salud
sleep 5
if docker-compose ps | grep -q "Up"; then
    log_success "Servicio corriendo correctamente!"
    curl -s http://localhost:8099/ | head -1
else
    log_error "El servicio no se inició correctamente"
    docker-compose logs --tail=20
fi
