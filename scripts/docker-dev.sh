#!/bin/bash
# Script para gestionar el entorno de desarrollo Docker
# Uso: ./scripts/docker-dev.sh [start|stop|restart|logs|build|clean]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMPOSE_FILE="${PROJECT_ROOT}/docker-compose.dev.yml"

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_help() {
    echo -e "${BLUE}CodingSoft AI - Docker Development${NC}"
    echo ""
    echo "Uso: $0 [comando]"
    echo ""
    echo "Comandos:"
    echo "  start      Iniciar el entorno de desarrollo"
    echo "  stop       Detener todos los servicios"
    echo "  restart    Reiniciar los servicios"
    echo "  logs       Ver logs en tiempo real"
    echo "  build      Reconstruir las imágenes Docker"
    echo "  clean      Limpiar volúmenes y contenedores"
    echo "  status     Ver estado de los servicios"
    echo "  shell      Abrir shell en un contenedor"
    echo "  update     Actualizar imágenes y reiniciar"
    echo ""
    echo "Ejemplos:"
    echo "  $0 start          # Iniciar todo"
    echo "  $0 logs backend   # Ver logs del backend"
    echo "  $0 shell frontend # Shell en el frontend"
}

start_services() {
    echo -e "${GREEN}🚀 Iniciando entorno de desarrollo...${NC}"
    echo ""
    
    # Verificar si docker-compose existe
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        echo -e "${RED}❌ Error: docker-compose no está instalado${NC}"
        exit 1
    fi
    
    # Crear directorio de datos si no existe
    mkdir -p "${PROJECT_ROOT}/backend/data"
    
    # Iniciar servicios
    cd "${PROJECT_ROOT}"
    docker-compose -f "${COMPOSE_FILE}" up -d --build
    
    echo ""
    echo -e "${GREEN}✅ Entorno iniciado${NC}"
    echo ""
    echo "🌐 Accesos:"
    echo "   Frontend: http://localhost:5173"
    echo "   Backend API: http://localhost:8080"
    echo "   Backend Docs: http://localhost:8080/docs"
    echo ""
    echo "📋 Comandos útiles:"
    echo "   Ver logs:  $0 logs"
    echo "   Detener:   $0 stop"
    echo "   Reiniciar: $0 restart"
}

stop_services() {
    echo -e "${YELLOW}🛑 Deteniendo servicios...${NC}"
    cd "${PROJECT_ROOT}"
    docker-compose -f "${COMPOSE_FILE}" down
    echo -e "${GREEN}✅ Servicios detenidos${NC}"
}

restart_services() {
    echo -e "${YELLOW}🔄 Reiniciando servicios...${NC}"
    stop_services
    sleep 2
    start_services
}

show_logs() {
    service=${1:-}
    
    if [ -z "$service" ]; then
        echo -e "${BLUE}📋 Logs de todos los servicios (Ctrl+C para salir)...${NC}"
        cd "${PROJECT_ROOT}"
        docker-compose -f "${COMPOSE_FILE}" logs -f
    else
        echo -e "${BLUE}📋 Logs de ${service} (Ctrl+C para salir)...${NC}"
        cd "${PROJECT_ROOT}"
        docker-compose -f "${COMPOSE_FILE}" logs -f "$service"
    fi
}

build_images() {
    echo -e "${YELLOW}🔨 Reconstruyendo imágenes...${NC}"
    cd "${PROJECT_ROOT}"
    docker-compose -f "${COMPOSE_FILE}" build --no-cache
    echo -e "${GREEN}✅ Imágenes reconstruidas${NC}"
}

clean_environment() {
    echo -e "${RED}⚠️  Esto eliminará todos los datos locales${NC}"
    read -p "¿Continuar? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}🧹 Limpiando entorno...${NC}"
        cd "${PROJECT_ROOT}"
        docker-compose -f "${COMPOSE_FILE}" down -v --remove-orphans
        docker system prune -f
        echo -e "${GREEN}✅ Entorno limpiado${NC}"
    else
        echo "Cancelado"
    fi
}

show_status() {
    echo -e "${BLUE}📊 Estado de los servicios:${NC}"
    cd "${PROJECT_ROOT}"
    docker-compose -f "${COMPOSE_FILE}" ps
    
    echo ""
    echo -e "${BLUE}📊 Uso de recursos:${NC}"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" 2>/dev/null | grep codingsoft || echo "Servicios no ejecutándose"
}

open_shell() {
    service=${1:-frontend}
    
    echo -e "${BLUE}🐚 Abriendo shell en ${service}...${NC}"
    cd "${PROJECT_ROOT}"
    docker-compose -f "${COMPOSE_FILE}" exec "$service" /bin/sh
}

update_images() {
    echo -e "${YELLOW}📥 Actualizando imágenes base...${NC}"
    cd "${PROJECT_ROOT}"
    docker-compose -f "${COMPOSE_FILE}" pull
    echo -e "${YELLOW}🔄 Reiniciando servicios...${NC}"
    docker-compose -f "${COMPOSE_FILE}" up -d
    echo -e "${GREEN}✅ Actualización completada${NC}"
}

# Verificar argumentos
if [ $# -eq 0 ]; then
    show_help
    exit 0
fi

COMMAND=$1
shift

case $COMMAND in
    start)
        start_services
        ;;
    stop)
        stop_services
        ;;
    restart)
        restart_services
        ;;
    logs)
        show_logs "$@"
        ;;
    build)
        build_images
        ;;
    clean)
        clean_environment
        ;;
    status)
        show_status
        ;;
    shell)
        open_shell "$@"
        ;;
    update)
        update_images
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Comando desconocido: $COMMAND${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
