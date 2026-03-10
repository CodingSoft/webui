# Guía de Instalación CodingSoft WebUI

## 📋 Estado Actual del Repositorio

✅ **Versión**: v0.8.10 (sincronizado con upstream)  
✅ **Branding**: CodingSoft WebUI  
✅ **Último commit**: 273c4bc65 (fixes de workflows)

---

## 🖥️ Instalación Local (Desarrollo)

### Opción 1: Instalación con Docker (Recomendado)

```bash
# 1. Clonar el repositorio
git clone https://github.com/CodingSoft/webui.git
cd webui

# 2. Ejecutar con Docker Compose
docker-compose up -d

# 3. Acceder a la aplicación
# http://localhost:3000
```

### Opción 2: Instalación con GPU (CUDA)

```bash
# Con soporte GPU
docker-compose -f docker-compose.yaml -f docker-compose.gpu.yaml up -d
```

### Opción 3: Instalación Manual (Desarrollo)

```bash
# 1. Clonar
git clone https://github.com/CodingSoft/webui.git
cd webui

# 2. Backend (Python 3.11+)
cd backend
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt

# 3. Iniciar backend
uvicorn open_webui.main:app --host 0.0.0.0 --port 8080

# 4. Frontend (en otra terminal)
cd ..
npm install
npm run dev

# 5. Acceder
# Frontend: http://localhost:5173
# Backend: http://localhost:8080
```

---

## 🌐 Instalación en VPS (Producción)

### Requisitos del VPS

- **OS**: Ubuntu 22.04 LTS o superior
- **RAM**: Mínimo 4GB (8GB recomendado)
- **CPU**: 2 cores mínimo
- **Storage**: 50GB SSD
- **GPU**: Opcional (para aceleración CUDA)

### Instalación Automatizada

#### Opción A: Usando el script de deploy (Recomendado)

```bash
# 1. Clonar en el VPS
git clone https://github.com/CodingSoft/webui.git
cd webui

# 2. Configurar variables de entorno
cp vps-deployment/.env.example vps-deployment/.env
nano vps-deployment/.env  # Editar con tus valores

# 3. Ejecutar script de deploy
chmod +x vps-deployment/deploy.sh
./vps-deployment/deploy.sh
```

#### Opción B: Instalación Manual en VPS

```bash
# 1. Actualizar sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar Docker y Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# 3. Clonar repositorio
git clone https://github.com/CodingSoft/webui.git
cd webui

# 4. Crear archivo de configuración
cat > .env << 'EOF'
WEBUI_SECRET_KEY=tu-clave-secreta-muy-segura-aqui
OLLAMA_BASE_URL=http://ollama:11434
ENABLE_SIGNUP=true
DEFAULT_MODELS=tu-modelo-predeterminado
EOF

# 5. Ejecutar
docker-compose up -d

# 6. Verificar logs
docker-compose logs -f codingsoft-webui
```

### Configuración con SSL (HTTPS)

```bash
# En vps-deployment/.env, descomenta y configura:
ENABLE_SSL=true
DOMAIN=tu-dominio.com
EMAIL=tu@email.com

# Luego ejecuta el deploy
./vps-deployment/deploy.sh
```

---

## ☁️ Instalación en la Nube

### GitHub Codespaces / Dev Container

```bash
# El repositorio incluye configuración de Dev Container
# Simplemente abre en GitHub Codespaces o VS Code con extension Remote-Containers
```

### HuggingFace Spaces

```bash
# El deploy se hace automáticamente con el workflow
# .github/workflows/deploy-to-hf-spaces.yml
# Configura el secreto HF_TOKEN en GitHub
```

---

## 📦 Instalación via PyPI

```bash
# Instalar el paquete Python
pip install codingsoft-webui

# Ejecutar
open-webui serve
```

**Nota**: Esta versión es solo el backend sin frontend compilado.

---

## 🔧 Configuración Post-Instalación

### Variables de Entorno Importantes

```bash
# Requeridas
WEBUI_SECRET_KEY=tu-clave-secreta-de-32-caracteres

# Opcionales
OLLAMA_BASE_URL=http://ollama:11434
OPENAI_API_KEY=sk-...
DATABASE_URL=postgresql://user:pass@localhost:5432/webui
ENABLE_SIGNUP=true
DEFAULT_MODELS=gpt-4
```

### Configuración de Base de Datos

**SQLite (default)**:

```bash
# Ya viene configurado por defecto
```

**PostgreSQL**:

```bash
# En docker-compose.yaml, descomenta:
# database:
#   image: postgres:15
#   environment:
#     POSTGRES_USER: webui
#     POSTGRES_PASSWORD: password
#     POSTGRES_DB: webui
```

---

## 🐳 Comandos Docker Útiles

```bash
# Ver logs
docker-compose logs -f codingsoft-webui

# Reiniciar
docker-compose restart codingsoft-webui

# Actualizar
docker-compose pull
docker-compose up -d

# Shell dentro del contenedor
docker-compose exec codingsoft-webui /bin/bash

# Limpiar
docker-compose down -v  # Elimina volúmenes también
```

---

## ✅ Verificación de Instalación

```bash
# Verificar que el servicio está corriendo
curl http://localhost:8080/health

# Debe retornar: {"status":true}

# Verificar versión
curl http://localhost:8080/api/version
```

---

## 🆘 Solución de Problemas

### Error: "port already in use"

```bash
# Cambiar puerto en .env
PORT=8081
```

### Error: "permission denied"

```bash
# En Linux/Mac
sudo chown -R $USER:$USER .
```

### Error: "cannot connect to Ollama"

```bash
# Verificar que Ollama está corriendo
docker-compose ps
# O instalar Ollama localmente:
curl -fsSL https://ollama.com/install.sh | sh
```

### Resetear completamente

```bash
docker-compose down -v
rm -rf vps-deployment/data/*
docker-compose up -d
```

---

## 📝 Notas

- Tu repositorio está actualizado con upstream v0.8.10
- Los workflows de CI/CD están corregidos y funcionando
- El branding CodingSoft está aplicado correctamente
- Puedes hacer pull de nuevas versiones: `git pull origin main`

## 📞 Soporte

- **Documentación**: https://docs.webui.codingsoft.org
- **Issues**: https://github.com/CodingSoft/webui/issues
- **Email**: o.alardin@codingsoft.org
