# Configuración de Open Terminal

## Descripción

Open Terminal es un terminal remoto sandboxed diseñado específicamente para AI agents y Open WebUI. Proporciona un entorno seguro para ejecutar comandos, gestionar archivos y ejecutar código a través de una API REST.

## Características

- Terminal sandboxed con Docker
- API REST completa para gestión de archivos
- Pre-instalado con: Python, Node.js, git, ffmpeg, herramientas de data science
- Soporte WebSocket para terminal interactivo
- Integración nativa con Open WebUI

## Configuración Rápida

### 1. Generar API Key

```bash
openssl rand -hex 32
```

Copia el valor generado y actualiza tu archivo `.env`:

```env
OPEN_TERMINAL_API_KEY=tu-api-key-generada-aqui
```

### 2. Iniciar el Servicio

```bash
cd vps-deployment
docker-compose up -d open-terminal
```

### 3. Verificar Funcionamiento

```bash
# Ver logs
docker-compose logs -f open-terminal

# Verificar salud
curl http://localhost:8089/health
```

### 4. Configurar en Open WebUI

1. Ve a **Ajustes de Admin → Integraciones → Open Terminal**
2. Haz clic en **Agregar Conexión**
3. Configura:
   - **Nombre**: Terminal Principal
   - **URL**: `http://open-terminal:8000`
   - **API Key**: La clave que generaste en el paso 1
4. Guarda la configuración

## API Endpoints

Una vez en funcionamiento, la documentación completa de la API está disponible en:

```
http://localhost:8089/docs
```

### Endpoints Principales

- `POST /execute` - Ejecutar comandos
- `POST /files/list` - Listar archivos
- `POST /files/read` - Leer archivo
- `POST /files/write` - Escribir archivo
- `POST /files/upload` - Subir archivo
- `POST /files/delete` - Eliminar archivo
- `GET /health` - Verificar estado

## Estructura de Volúmenes

```
terminal-data/
└── home/user/          # Directorio home del usuario
    ├── workspace/      # Espacio de trabajo
    └── ...
```

## Comandos Útiles

### Reiniciar Open Terminal

```bash
docker-compose restart open-terminal
```

### Ver Logs

```bash
docker-compose logs -f open-terminal
```

### Acceder al Contenedor

```bash
docker exec -it open-terminal bash
```

### Limpiar Datos del Terminal

```bash
# Detener servicio
docker-compose stop open-terminal

# Eliminar volumen
docker volume rm vps-deployment_terminal-data

# Reiniciar
docker-compose up -d open-terminal
```

## Solución de Problemas

### Error de Conexión en WebUI

1. Verifica que el contenedor está corriendo:

   ```bash
   docker-compose ps open-terminal
   ```

2. Verifica que la API key está configurada correctamente en ambos lados

3. Prueba la conexión directamente:
   ```bash
   curl -H "Authorization: Bearer TU_API_KEY" http://localhost:8089/health
   ```

### Contenedor no inicia

1. Verifica logs:

   ```bash
   docker-compose logs open-terminal
   ```

2. Asegúrate de que el puerto 8089 no esté en uso:
   ```bash
   sudo lsof -i :8089
   ```

### Permisos de Archivos

Los archivos en el volumen se crean con el usuario del contenedor. Si necesitas acceder desde el host:

```bash
# Cambiar propietario (opcional, use con precaución)
sudo chown -R $USER:$USER /var/lib/docker/volumes/vps-deployment_terminal-data/_data
```

## Seguridad

- **Sandboxed**: Los comandos se ejecutan en un contenedor aislado
- **API Key**: Requiere autenticación Bearer para todas las operaciones
- **Sin acceso host**: No tiene acceso directo a tu sistema
- **Persistencia**: Los archivos se guardan en un volumen Docker dedicado

## Diferencias con ttyd (anterior)

| Característica      | ttyd (anterior) | Open Terminal (nuevo)           |
| ------------------- | --------------- | ------------------------------- |
| Protocolo           | WebSocket       | HTTP + WebSocket                |/
| API REST            | ❌ No           | ✅ Sí                           |
| Gestión de archivos | ❌ Limitada     | ✅ Completa                     |
| Sandbox             | ❌ Parcial      | ✅ Completo (Docker)            |
| Pre-instalaciones   | Básicas         | Python, Node, git, ffmpeg, etc. |
| Integración WebUI   | Manual          | Nativa                          |

## Documentación Adicional

- [Repositorio Open Terminal](https://github.com/open-webui/open-terminal)
- [Documentación Open WebUI](https://docs.openwebui.com/)

## Soporte

Si encuentras problemas:

1. Revisa los logs: `docker-compose logs open-terminal`
2. Verifica la conectividad: `curl http://localhost:8089/health`
3. Consulta la [documentación oficial](https://github.com/open-webui/open-terminal)
