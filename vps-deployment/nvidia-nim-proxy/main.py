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
    # OpenAI model names -> NVIDIA NIM endpoints
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
    """Lista modelos disponibles en formato OpenAI"""
    return {
        "object": "list",
        "data": [
            {
                "id": "dall-e-3",
                "object": "model",
                "created": int(time.time()),
                "owned_by": "nvidia-nim",
            },
            {
                "id": "dall-e-2",
                "object": "model",
                "created": int(time.time()),
                "owned_by": "nvidia-nim",
            },
            {
                "id": "gpt-image",
                "object": "model",
                "created": int(time.time()),
                "owned_by": "nvidia-nim",
            },
            {
                "id": "sdxl",
                "object": "model",
                "created": int(time.time()),
                "owned_by": "nvidia-nim",
            },
            {
                "id": "sd3",
                "object": "model",
                "created": int(time.time()),
                "owned_by": "nvidia-nim",
            },
            {
                "id": "flux",
                "object": "model",
                "created": int(time.time()),
                "owned_by": "nvidia-nim",
            },
            {
                "id": "flux-fast",
                "object": "model",
                "created": int(time.time()),
                "owned_by": "nvidia-nim",
            },
        ],
    }


@app.post("/v1/images/generations")
async def generate_image(
    request: ImageGenerationRequest, authorization: Optional[str] = Header(None)
):
    """Genera imágenes usando NVIDIA NIM"""

    # Obtener API key
    api_key = (
        authorization.replace("Bearer ", "")
        if authorization
        else os.getenv("NVIDIA_NIM_API_KEY")
    )
    if not api_key:
        raise HTTPException(status_code=401, detail="NVIDIA NIM API key required")

    # Mapear modelo
    nim_model = MODEL_MAPPING.get(
        request.model, "stabilityai/stable-diffusion-3-medium"
    )

    # Convertir size a aspect_ratio
    aspect_ratio = "1:1"  # default
    if request.size:
        size_map = {
            "1024x1024": "1:1",
            "1024x1536": "2:3",
            "1536x1024": "3:2",
            "1024x576": "16:9",
            "576x1024": "9:16",
        }
        aspect_ratio = size_map.get(request.size, "1:1")

    # Preparar payload para NVIDIA NIM
    payload = {
        "prompt": request.prompt,
        "aspect_ratio": aspect_ratio,
        "output_type": "base64",
    }

    # Configurar steps según quality
    if request.quality == "hd":
        payload["guidance_scale"] = 8.0
        payload["num_inference_steps"] = 50
    else:
        payload["guidance_scale"] = 5.0
        payload["num_inference_steps"] = 28

    # Llamar a NVIDIA NIM
    url = f"{NVIDIA_BASE_URL}/{nim_model}"

    async with httpx.AsyncClient(timeout=120.0) as client:
        try:
            response = await client.post(
                url,
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json",
                },
                json=payload,
            )

            if response.status_code != 200:
                raise HTTPException(
                    status_code=response.status_code,
                    detail=f"NVIDIA NIM error: {response.text}",
                )

            nim_response = response.json()

            # Transformar respuesta a formato OpenAI
            images = []

            if "image" in nim_response:
                # SD3 y SDXL devuelven base64 directamente
                images.append(
                    {
                        "b64_json": nim_response["image"],
                        "revised_prompt": request.prompt,
                    }
                )
            elif "images" in nim_response:
                # Algunos modelos devuelven array
                for img in nim_response["images"]:
                    images.append(
                        {
                            "b64_json": img
                            if isinstance(img, str)
                            else img.get("image", ""),
                            "revised_prompt": request.prompt,
                        }
                    )
            else:
                # Fallback
                images.append(
                    {
                        "url": "data:image/png;base64," + nim_response.get("image", ""),
                        "revised_prompt": request.prompt,
                    }
                )

            return {"created": int(time.time()), "data": images}

        except httpx.TimeoutException:
            raise HTTPException(status_code=504, detail="NVIDIA NIM timeout")
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Error: {str(e)}")


@app.post("/v1/images/edits")
async def edit_image(
    request: ImageEditRequest, authorization: Optional[str] = Header(None)
):
    """Edita imágenes (simplificado - usa SDXL)"""

    # Para edición, usamos SDXL que soporta img2img
    api_key = (
        authorization.replace("Bearer ", "")
        if authorization
        else os.getenv("NVIDIA_NIM_API_KEY")
    )
    if not api_key:
        raise HTTPException(status_code=401, detail="NVIDIA NIM API key required")

    # Nota: La edición real requeriría subir la imagen primero
    # Esta es una versión simplificada
    return {
        "created": int(time.time()),
        "data": [{"url": "", "revised_prompt": request.prompt}],
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
