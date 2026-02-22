# Despliegue de CodingSoft WebUI

## Dominio webui.codingsoft.org

### Configuración DNS
1. Añadir registro A en DNS de codingsoft.org:
   ```
   webui.codingsoft.org -> IP del servidor
   ```

2. Configurar proxy inverso (nginx/apache) para redirigir tráfico:
   ```nginx
   server {
       listen 80;
       server_name webui.codingsoft.org;
       
       location / {
           proxy_pass http://localhost:8080;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection "upgrade";
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
       }
   }
   ```

### HTTPS con Let's Encrypt
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d webui.codingsoft.org
```

### Despliegue con Docker
```bash
docker run -d \
  -p 8080:8080 \
  -v codingsoft-webui-data:/app/backend/data \
  -v $(pwd)/.env:/app/backend/.env \
  --name codingsoft-webui \
  --restart always \
  ghcr.io/codingsoft/webui:main
```

## Configuración del entorno
1. Crear archivo `.env` con:
   ```env
   WEBUI_NAME="CodingSoft WebUI"
   WEBUI_FAVICON_URL="https://webui.codingsoft.org/favicon.png"
   WEBUI_AUTHOR_NAME="Oscar Alardin"
   WEBUI_AUTHOR_EMAIL="o.alardin@codingsoft.org"
   CORS_ALLOW_ORIGIN="https://webui.codingsoft.org"
   ```

## Monitoreo
- Logs: `docker logs codingsoft-webui`
- Estado: `docker ps`
- Reinicio: `docker restart codingsoft-webui`
