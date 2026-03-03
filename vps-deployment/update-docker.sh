#!/bin/bash

# ============================================
# Script de Actualización Docker - CodingSoft WebUI
# VPS: 74.208.198.240
# ============================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
# CONFIGURACIÓN
# ============================================

COMPOSE_FILE="docker-compose.yml"
ENV_FILE=".env"
BACKUP_DIR="./backups"

# ============================================
# FUNCIONES
# ============================================

check_docker() {
    log_info "Verificando Docker..."
    if ! command -v docker &> /dev/null; then
        log_error "Docker no está instalado"
        exit 1
    fi
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose no está instalado"
        exit 1
    fi
    log_success "Docker verificado"
}

create_backup() {
    log_info "Creando backup antes de actualizar..."
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    mkdir -p $BACKUP_DIR
    
    # Backup de datos
    if docker-compose ps | grep -q "codingsoft-webui"; then
        docker-compose exec -T codingsoft-webui tar czf - /app/backend/data > "$BACKUP_DIR/codingsoft_data_$TIMESTAMP.tar.gz" 2>/dev/null || true
        log_success "Backup de datos creado"
    fi
    
    # Backup de .env
    cp .env "$BACKUP_DIR/env_$TIMESTAMP.backup" 2>/dev/null || true
    
    log_success "Backup completado en: $BACKUP_DIR"
}

update_images() {
    log_info "Descargando imágenes actualizadas..."
    
    # Pull de la imagen principal
    log_info "Descargando CodingSoft WebUI..."
    docker pull ghcr.io/codingsoft/webui:main
    
    # Opcional: Actualizar Ollama
    read -p "¿Actualizar Ollama también? (s/n): " update_ollama
    if [[ "$update_ollama" =~ ^[sS]$ ]]; then
        log_info "Descargando Ollama..."
        docker pull ollama/ollama:latest
    fi
    
    # Actualizar tool servers si existen
    if [ -d "openapi-servers" ]; then
        log_info "Actualizando OpenAPI Tool Servers..."
        cd openapi-servers
        docker-compose pull 2>/dev/null || true
        cd ..
    fi
    
    log_success "Imágenes descargadas"
}

restart_services() {
    log_info "Reiniciando servicios..."
    
    # Detener servicios
    log_info "Deteniendo servicios actuales..."
    docker-compose down
    
    # Iniciar con nueva imagen
    log_info "Iniciando servicios con nueva imagen..."
    docker-compose up -d
    
    log_success "Servicios reiniciados"
}

verify_services() {
    log_info "Verificando servicios..."
    
    sleep 5
    
    # Verificar WebUI
    if docker-compose ps | grep -q "codingsoft-webui.*Up"; then
        log_success "CodingSoft WebUI está corriendo"
    else
        log_error "CodingSoft WebUI no está corriendo"
        docker-compose logs --tail=20 codingsoft-webui
        exit 1
    fi
    
    # Verificar Ollama
    if docker-compose ps | grep -q "ollama.*Up"; then
        log_success "Ollama está corriendo"
    else
        log_warning "Ollama no está corriendo (puede estar deshabilitado)"
    fi
    
    # Verificar versión
    log_info "Verificando versión..."
    VERSION=$(docker-compose exec -T codingsoft-webui cat /app/package.json | grep '"version"' | head -1 | cut -d'"' -f4)
    log_success "Versión instalada: $VERSION"
}

cleanup() {
    log_info "Limpiando imágenes antiguas..."
    docker image prune -f
    log_success "Limpieza completada"
}

show_menu() {
    clear
    echo "========================================"
    echo "  Actualización Docker - CodingSoft"
    echo "  VPS: 74.208.198.240"
    echo "========================================"
    echo ""
    echo "1. Actualización completa (backup + update + restart)"
    echo "2. Solo descargar imágenes (sin reiniciar)"
    echo "3. Solo reiniciar servicios (con imágenes actuales)"
    echo "4. Ver logs"
    echo "5. Ver estado de servicios"
    echo "6. Rollback (restaurar backup)"
    echo "7. Salir"
    echo ""
    echo -n "Selecciona una opción: "
}

# ============================================
# OPCIÓN 1: Actualización Completa
# ============================================

full_update() {
    log_info "Iniciando actualización completa..."
    
    check_docker
    create_backup
    update_images
    restart_services
    verify_services
    cleanup
    
    log_success "========================================"
    log_success "Actualización completada exitosamente!"
    log_success "========================================"
    echo ""
    log_info "Accede a tu WebUI en:"
    log_info "  http://74.208.198.240:8080"
    echo ""
}

# ============================================
# OPCIÓN 2: Solo Descargar Imágenes
# ============================================

pull_only() {
    log_info "Descargando imágenes..."
    check_docker
    update_images
    log_success "Imágenes descargadas. Reinicia manualmente cuando estés listo."
    log_info "Ejecuta: docker-compose up -d"
}

# ============================================
# OPCIÓN 3: Solo Reiniciar
# ============================================

restart_only() {
    log_info "Reiniciando servicios..."
    check_docker
    restart_services
    verify_services
    log_success "Servicios reiniciados"
}

# ============================================
# OPCIÓN 4: Ver Logs
# ============================================

view_logs() {
    docker-compose logs -f codingsoft-webui
}

# ============================================
# OPCIÓN 5: Ver Estado
# ============================================

view_status() {
    docker-compose ps
}

# ============================================
# OPCIÓN 6: Rollback
# ============================================

rollback() {
    log_info "Restaurando backup..."
    
    # Listar backups disponibles
    echo "Backups disponibles:"
    ls -lt $BACKUP_DIR/*.tar.gz 2>/dev/null | head -5
    
    echo ""
    echo "Para restaurar un backup manualmente:"
    echo "1. Detener servicios: docker-compose down"
    echo "2. Extraer backup: tar -xzf $BACKUP_DIR/backup_name.tar.gz"
    echo "3. Reiniciar: docker-compose up -d"
}

# ============================================
# EJECUCIÓN
# ============================================

if [ "$1" == "--full" ]; then
    full_update
    exit 0
fi

if [ "$1" == "--pull" ]; then
    pull_only
    exit 0
fi

if [ "$1" == "--restart" ]; then
    restart_only
    exit 0
fi

# Menú interactivo
while true; do
    show_menu
    read -r choice
    
    case $choice in
        1) full_update ;;
        2) pull_only ;;
        3) restart_only ;;
        4) view_logs ;;
        5) view_status ;;
        6) rollback ;;
        7) log_info "Saliendo..."; exit 0 ;;
        *) log_error "Opción inválida" ;;
    esac
    
    echo ""
    echo "Presiona Enter para continuar..."
    read -r
done
