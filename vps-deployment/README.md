# Despliegue CodingSoft WebUI en VPS

## Informacion del Servidor

- **IP**: 74.208.198.240
- **Puerto SSH**: 22022
- **Usuario**: root

## Despliegue Rapido (2 comandos)

### 1. Conectarte al VPS

```bash
ssh -p 22022 root@74.208.198.240
```

### 2. Ejecutar instalacion automatica

```bash
cd /opt && git clone https://github.com/CodingSoft/webui.git && cd codingsoft-webui/vps-deployment && chmod +x deploy.sh && ./deploy.sh --full
```

El sistema se instalara automaticamente.

## Archivos Incluidos

| Archivo            | Descripcion                                        |
| ------------------ | -------------------------------------------------- |
| docker-compose.yml | Configuracion completa de servicios                |
| .env.example       | Plantilla de variables de entorno                  |
| deploy.sh          | Script de despliegue automatizado                  |
| backup.sh          | Script de backup (generado automaticamente)        |
| update.sh          | Script de actualizacion (generado automaticamente) |

## Servicios Incluidos

### Core (siempre activos)

- CodingSoft WebUI (puerto 8080)
- Ollama (servidor LLM)
- Filesystem Server (puerto 8081)
- Memory Server (puerto 8082)
- Time Server (puerto 8083)
- Git Server (puerto 8087)

### Opcionales (requieren configuracion)

- Slack Server (requiere SLACK_BOT_TOKEN)
- Google PSE Server (requiere GOOGLE_API_KEY)
- SQL Server (requiere DATABASE_URL)
- Weather Server (puerto 8088)

## Guia de Instalacion Paso a Paso

### Paso 1: Conectar al VPS

```bash
ssh -p 22022 root@74.208.198.240
```

### Paso 2: Descargar archivos

```bash
cd /opt
git clone https://github.com/CodingSoft/webui.git
cd codingsoft-webui/vps-deployment
```

### Paso 3: Configurar variables de entorno

```bash
cp .env.example .env
nano .env
```

Variables importantes:

- WEBUI_SECRET_KEY (se genera automaticamente)
- JWT_SECRET_KEY (se genera automaticamente)
- CORS_ALLOW_ORIGINS (tu dominio)
- TOOL_SERVER_CONNECTIONS (ya configurado)

### Paso 4: Ejecutar despliegue

```bash
chmod +x deploy.sh
./deploy.sh --full
```

El script automaticamente:

- Instala Docker y Docker Compose
- Genera claves secretas seguras
- Descarga OpenAPI Servers
- Construye las imagenes necesarias
- Inicia todos los servicios
- Configura el firewall
- Crea scripts de backup y actualizacion

### Paso 5: Acceder a WebUI

```
http://74.208.198.240:8080
```

El primer usuario que se registra se convierte automaticamente en administrador.

## Configurar SSL (HTTPS)

Si tienes un dominio:

```bash
./deploy.sh
# Seleccionar opcion 4 "Configurar SSL"
```

O manualmente:

```bash
# Editar nginx/nginx.conf con tu dominio
docker-compose up -d nginx certbot
```

## Comandos Utiles

### Gestion de servicios

```bash
# Ver estado
docker-compose ps

# Ver logs
docker-compose logs -f codingsoft-webui

# Detener todos los servicios
docker-compose down

# Iniciar servicios
docker-compose up -d

# Reiniciar servicio
docker-compose restart codingsoft-webui
```

### Actualizacion

```bash
./update.sh
# O manualmente:
docker-compose pull codingsoft-webui
docker-compose up -d --force-recreate codingsoft-webui
```

### Backup

```bash
./backup.sh
```

## Solucion de Problemas

### WebUI no responde

```bash
docker-compose ps codingsoft-webui
docker-compose logs codingsoft-webui --tail=50
docker-compose restart codingsoft-webui
```

### Tool Servers no conectan

```bash
docker-compose ps | grep -E "(filesystem|memory|time|git)"
docker-compose logs filesystem-server
docker network inspect vps-deployment_codingsoft-network
```

### Error de CORS

```bash
nano .env
# Cambiar CORS_ALLOW_ORIGINS
CORS_ALLOW_ORIGINS=https://tu-dominio.com
docker-compose restart codingsoft-webui
```

## Seguridad Recomendada

### Firewall

```bash
ufw allow 22022/tcp  # SSH
ufw allow 80/tcp     # HTTP
ufw allow 443/tcp    # HTTPS
ufw allow 8080/tcp   # WebUI
```

### Backups automaticos

```bash
crontab -e
# Agregar:
0 2 * * * cd /opt/codingsoft && ./backup.sh
```

## Recursos

- Documentacion: https://docs.codingsoft-webui.org
- GitHub: https://github.com/CodingSoft/webui
- Tool Servers: https://github.com/codingsoft-webui/openapi-servers
