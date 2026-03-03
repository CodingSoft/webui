#!/bin/bash

# ============================================
# Script de Despliegue CodingSoft WebUI + Tool Servers
# VPS: 74.208.198.240
# ============================================

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funciones de ayuda
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ============================================
# VERIFICACIÓN DE REQUISITOS
# ============================================

check_requirements() {
    log_info "Verificando requisitos..."
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker no está instalado. Instalando..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
        rm get-docker.sh
        usermod -aG docker $USER
        log_success "Docker instalado"
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_info "Instalando Docker Compose..."
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        log_success "Docker Compose instalado"
    fi
    
    log_success "Requisitos verificados"
}

# ============================================
# GENERAR CLAVES SECRETAS
# ============================================

generate_secrets() {
    log_info "Generando claves secretas..."
    
    if [ ! -f .env ]; then
        log_error "No se encontró el archivo .env. Copiando desde .env.example..."
        cp .env.example .env
    fi
    
    # Generar WEBUI_SECRET_KEY si no existe
    if grep -q "WEBUI_SECRET_KEY=tu-clave-secreta-aqui-cambia-esto" .env; then
        WEBUI_SECRET_KEY=$(openssl rand -hex 32)
        sed -i "s/WEBUI_SECRET_KEY=tu-clave-secreta-aqui-cambia-esto/WEBUI_SECRET_KEY=$WEBUI_SECRET_KEY/" .env
        log_success "WEBUI_SECRET_KEY generada"
    fi
    
    # Generar JWT_SECRET_KEY si no existe
    if grep -q "JWT_SECRET_KEY=tu-jwt-secreto-aqui-cambia-esto" .env; then
        JWT_SECRET_KEY=$(openssl rand -hex 32)
        sed -i "s/JWT_SECRET_KEY=tu-jwt-secreto-aqui-cambia-esto/JWT_SECRET_KEY=$JWT_SECRET_KEY/" .env
        log_success "JWT_SECRET_KEY generada"
    fi
    
    log_success "Claves secretas configuradas"
}

# ============================================
# CONFIGURAR DIRECTORIOS
# ============================================

setup_directories() {
    log_info "Configurando directorios..."
    
    # Crear directorios necesarios
    mkdir -p data
    mkdir -p repos
    mkdir -p nginx/ssl
    mkdir -p nginx/conf.d
    mkdir -p backups
    mkdir -p logs
    
    log_success "Directorios configurados"
}

# ============================================
# DESCARGAR OPENAPI SERVERS
# ============================================

download_openapi_servers() {
    log_info "Descargando OpenAPI Servers..."
    
    if [ ! -d "openapi-servers" ]; then
        git clone https://github.com/codingsoft-webui/openapi-servers.git
        log_success "OpenAPI Servers descargados"
    else
        log_warning "El directorio openapi-servers ya existe. Actualizando..."
        cd openapi-servers
        git pull
        cd ..
        log_success "OpenAPI Servers actualizados"
    fi
}

# ============================================
# CONSTRUIR IMÁGENES
# ============================================

build_images() {
    log_info "Construyendo imágenes de Tool Servers..."
    
    cd openapi-servers
    
    # Construir solo los servidores core (los esenciales)
    docker-compose build filesystem-server memory-server time-server git-server
    
    cd ..
    log_success "Imágenes construidas"
}

# ============================================
# INICIAR SERVICIOS
# ============================================

start_services() {
    log_info "Iniciando servicios..."
    
    # Iniciar Ollama y WebUI
    docker-compose up -d ollama codingsoft-webui
    
    # Esperar a que Ollama esté listo
    log_info "Esperando a que Ollama esté listo..."
    sleep 10
    
    # Iniciar Tool Servers
    docker-compose up -d filesystem-server memory-server time-server git-server
    
    log_success "Servicios iniciados"
}

# ============================================
# VERIFICAR SERVICIOS
# ============================================

check_services() {
    log_info "Verificando servicios..."
    
    # Verificar contenedores
    docker-compose ps
    
    # Verificar logs
    log_info "Logs de WebUI (últimas 20 líneas):"
    docker-compose logs --tail=20 codingsoft-webui
    
    log_success "Servicios verificados"
}

# ============================================
# CONFIGURAR SSL (Opcional)
# ============================================

setup_ssl() {
    log_info "¿Deseas configurar SSL con Let's Encrypt? (s/n)"
    read -r response
    
    if [[ "$response" =~ ^([sS][iI]|[sS])$ ]]; then
        log_info "Configurando SSL..."
        
        # Solicitar dominio
        echo "Ingresa tu dominio (ej: chat.tudominio.com):"
        read -r domain
        
        # Crear configuración de nginx
        cat > nginx/nginx.conf << EOF
server {
    listen 80;
    server_name $domain;
    
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    
    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    listen 443 ssl http2;
    server_name $domain;
    
    ssl_certificate /etc/letsencrypt/live/$domain/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$domain/privkey.pem;
    
    location / {
        proxy_pass http://codingsoft-webui:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
        
        # Iniciar nginx
        docker-compose up -d nginx
        
        # Obtener certificado
        docker-compose run --rm certbot certonly --webroot --webroot-path=/var/www/certbot --email admin@$domain --agree-tos --no-eff-email -d $domain
        
        log_success "SSL configurado para $domain"
    fi
}

# ============================================
# CREAR SCRIPT DE BACKUP
# ============================================

create_backup_script() {
    log_info "Creando script de backup..."
    
    cat > backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="./backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Crear directorio de backup
mkdir -p $BACKUP_DIR

# Backup de datos
docker-compose exec -T codingsoft-webui tar czf - /app/backend/data > "$BACKUP_DIR/codingsoft_data_$TIMESTAMP.tar.gz"

# Backup de OpenAPI servers data
docker-compose exec -T memory-server tar czf - /app/data > "$BACKUP_DIR/memory_data_$TIMESTAMP.tar.gz"
tar czf "$BACKUP_DIR/repos_$TIMESTAMP.tar.gz" ./repos 2>/dev/null || true

# Eliminar backups antiguos (mantener últimos 7)
ls -t $BACKUP_DIR/*.tar.gz | tail -n +8 | xargs -r rm

echo "Backup completado: $BACKUP_DIR"
EOF
    
    chmod +x backup.sh
    log_success "Script de backup creado"
}

# ============================================
# CREAR SCRIPT DE ACTUALIZACIÓN
# ============================================

create_update_script() {
    log_info "Creando script de actualización..."
    
    cat > update.sh << 'EOF'
#!/bin/bash

echo "Actualizando CodingSoft WebUI..."

# Backup antes de actualizar
./backup.sh

# Actualizar imágenes
docker-compose pull codingsoft-webui

# Reiniciar servicios
docker-compose up -d codingsoft-webui

echo "Actualización completada"
EOF
    
    chmod +x update.sh
    log_success "Script de actualización creado"
}

# ============================================
# CONFIGURAR FIREWALL
# ============================================

setup_firewall() {
    log_info "Configurando firewall..."
    
    # Verificar si ufw está instalado
    if command -v ufw &> /dev/null; then
        # Permitir puertos necesarios
        ufw allow 22/tcp    # SSH
        ufw allow 80/tcp    # HTTP
        ufw allow 443/tcp   # HTTPS
        ufw allow 8080/tcp  # WebUI (alternativo)
        
        # Habilitar firewall si no está activo
        if ! ufw status | grep -q "Status: active"; then
            ufw --force enable
        fi
        
        log_success "Firewall configurado"
    else
        log_warning "ufw no está instalado. Saltando configuración de firewall."
    fi
}

# ============================================
# MENÚ PRINCIPAL
# ============================================

show_menu() {
    echo ""
    echo "========================================"
    echo "  CodingSoft WebUI - VPS Deployment"
    echo "  IP: 74.208.198.240"
    echo "========================================"
    echo ""
    echo "1. Instalación completa (recomendado)"
    echo "2. Solo verificar servicios"
    echo "3. Actualizar sistema"
    echo "4. Configurar SSL"
    echo "5. Crear backup"
    echo "6. Ver logs"
    echo "7. Detener servicios"
    echo "8. Salir"
    echo ""
    echo -n "Selecciona una opción: "
}

# Instalación completa
full_install() {
    log_info "Iniciando instalación completa..."
    
    check_requirements
    setup_directories
    download_openapi_servers
    generate_secrets
    build_images
    start_services
    check_services
    create_backup_script
    create_update_script
    setup_firewall
    
    log_success "========================================"
    log_success "Instalación completada exitosamente!"
    log_success "========================================"
    echo ""
    log_info "Accede a tu WebUI en:"
    log_info "  - Local: http://localhost:8080"
    log_info "  - VPS: http://74.208.198.240:8080"
    echo ""
    log_info "Comandos útiles:"
    log_info "  ./backup.sh        - Crear backup"
    log_info "  ./update.sh        - Actualizar sistema"
    log_info "  docker-compose logs -f codingsoft-webui  - Ver logs"
    echo ""
}

# Verificar servicios
verify_services() {
    check_services
}

# Actualizar sistema
update_system() {
    log_info "Actualizando sistema..."
    docker-compose pull codingsoft-webui
    docker-compose up -d --force-recreate codingsoft-webui
    log_success "Sistema actualizado"
}

# Detener servicios
stop_services() {
    log_info "Deteniendo servicios..."
    docker-compose down
    log_success "Servicios detenidos"
}

# Ver logs
view_logs() {
    docker-compose logs -f codingsoft-webui
}

# ============================================
# EJECUCIÓN PRINCIPAL
# ============================================

if [ "$1" == "--full" ]; then
    full_install
    exit 0
fi

if [ "$1" == "--verify" ]; then
    verify_services
    exit 0
fi

# Menú interactivo
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1) full_install ;;
        2) verify_services ;;
        3) update_system ;;
        4) setup_ssl ;;
        5) ./backup.sh 2>/dev/null || log_error "Ejecuta primero la instalación completa" ;;
        6) view_logs ;;
        7) stop_services ;;
        8) log_info "Saliendo..."; exit 0 ;;
        *) log_error "Opción inválida" ;;
    esac
    
    echo ""
    echo "Presiona Enter para continuar..."
    read -r
done
