# Actualizar Docker en VPS

## Instrucciones Rápidas

### Opción 1: Comando Único (Recomendado)

Conéctate al VPS y ejecuta:

```bash
ssh -p 22022 root@74.208.198.240
cd /opt/codingsoft-webui/vps-deployment
chmod +x update-docker.sh
./update-docker.sh --full
```

### Opción 2: Comandos Manuales

```bash
# 1. Conectar al VPS
ssh -p 22022 root@74.208.198.240

# 2. Ir al directorio
cd /opt/codingsoft-webui/vps-deployment

# 3. Descargar nueva imagen
docker pull ghcr.io/codingsoft/webui:main

# 4. Detener servicios
docker-compose down

# 5. Iniciar con nueva imagen
docker-compose up -d

# 6. Verificar
docker-compose ps
docker-compose logs --tail=20 codingsoft-webui
```

## Opciones del Script

```bash
./update-docker.sh --full      # Actualización completa (backup + update + restart)
./update-docker.sh --pull      # Solo descargar imágenes
./update-docker.sh --restart   # Solo reiniciar servicios
```

## Verificar Actualización

```bash
# Ver versión instalada
docker-compose exec codingsoft-webui cat /app/package.json | grep version

# Ver logs
docker-compose logs -f codingsoft-webui

# Verificar servicios
docker-compose ps
```

## Solución de Problemas

### Error: "No such image"

```bash
docker pull ghcr.io/codingsoft/webui:main
```

### Error: Puerto en uso

```bash
# Ver qué proceso usa el puerto
netstat -tulpn | grep 8080

# Cambiar puerto en .env
nano .env
# Editar: OPEN_WEBUI_PORT=8081

docker-compose up -d
```

### Rollback (si algo falla)

```bash
# Listar backups
ls -la backups/

# Restaurar
docker-compose down
tar -xzf backups/codingsoft_data_YYYYMMDD_HHMMSS.tar.gz -C /
docker-compose up -d
```

## Acceso

Después de actualizar:

- **WebUI**: http://74.208.198.240:8080

## Comandos Útiles

```bash
# Ver logs en tiempo real
docker-compose logs -f codingsoft-webui

# Reiniciar solo WebUI
docker-compose restart codingsoft-webui

# Ver uso de recursos
docker stats

# Limpiar imágenes antiguas
docker image prune -f
```
