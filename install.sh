#!/usr/bin/env bash
# ==============================================================================
# DevCPC - Script de instalación remota
# ==============================================================================
#
# USO:
#   curl -fsSL https://destroyer.me/devcpc | bash
#   wget -qO- https://destroyer.me/devcpc | bash
#
# ==============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuración
DEVCPC_HOME="$HOME/.DevCPC"
GITHUB_REPO="destroyer-dcf/DevCPC"
GITHUB_API="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
GITHUB_RAW="https://raw.githubusercontent.com/$GITHUB_REPO/main"

# Funciones auxiliares
info() {
    echo -e "${BLUE}ℹ${NC} ${CYAN}$1${NC}"
}

success() {
    echo -e "${GREEN}✓${NC} ${GREEN}$1${NC}"
}

error() {
    echo -e "${RED}✗${NC} ${RED}$1${NC}"
}

warning() {
    echo -e "${YELLOW}⚠${NC} ${YELLOW}$1${NC}"
}

header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
}

logo() {
    echo ""
    echo -e "${YELLOW}▛▀▖      ▞▀▖▛▀▖▞▀▖${NC}"
    echo -e "${YELLOW}▌ ▌▞▀▖▌ ▌▌  ▙▄▘▌  ${NC}"
    echo -e "${YELLOW}▌ ▌▛▀ ▐▐ ▌ ▖▌  ▌ ▖${NC}"
    echo -e "${YELLOW}▀▀ ▝▀▘ ▘ ▝▀ ▘  ▝▀ ${NC}"
}

# Detectar OS
detect_os() {
    case "$OSTYPE" in
        darwin*)
            echo "macos"
            ;;
        linux*)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Verificar comandos necesarios
check_requirements() {
    local missing=0
    
    if ! command -v curl &> /dev/null; then
        error "curl no está instalado"
        missing=1
    fi
    
    if ! command -v tar &> /dev/null; then
        error "tar no está instalado"
        missing=1
    fi
    
    if ! command -v python3 &> /dev/null; then
        warning "Python 3 no está instalado (requerido para usar DevCPC)"
        echo "  Instala Python 3 desde: https://www.python.org/"
    fi
    
    return $missing
}

# Obtener última versión
get_latest_version() {
    local version
    version=$(curl -fsSL "$GITHUB_API" | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    
    if [[ -z "$version" ]]; then
        error "No se pudo obtener la última versión"
        exit 1
    fi
    
    echo "$version"
}

# Descargar e instalar
install_devcpc() {
    local version="$1"
    local download_url="https://github.com/$GITHUB_REPO/releases/download/v${version}/DevCPC-${version}.tar.gz"
    local temp_dir
    temp_dir=$(mktemp -d)
    
    info "Descargando DevCPC v${version}..."
    
    if ! curl -fsSL "$download_url" -o "$temp_dir/devcpc.tar.gz"; then
        error "No se pudo descargar DevCPC"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    success "Descarga completada"
    
    info "Instalando en $DEVCPC_HOME..."
    
    # Crear directorio si no existe
    mkdir -p "$DEVCPC_HOME"
    
    # Extraer archivos
    if ! tar -xzf "$temp_dir/devcpc.tar.gz" -C "$temp_dir"; then
        error "No se pudo extraer el archivo"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Mover archivos a destino
    # El tar contiene la estructura completa, movemos DevCPC
    if [[ -d "$temp_dir/DevCPC" ]]; then
        rm -rf "$DEVCPC_HOME"/*
        cp -r "$temp_dir/DevCPC/"* "$DEVCPC_HOME/"
    else
        error "Estructura del archivo no válida"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Limpiar
    rm -rf "$temp_dir"
    
    # Hacer ejecutable
    chmod +x "$DEVCPC_HOME/bin/devcpc"
    
    # Guardar versión instalada
    echo "$version" > "$DEVCPC_HOME/.version"
    
    success "DevCPC v${version} instalado en $DEVCPC_HOME"
}

# Configurar shell
configure_shell() {
    local shell_name
    shell_name=$(basename "$SHELL")
    
    local shell_rc
    case "$shell_name" in
        bash)
            shell_rc="$HOME/.bashrc"
            ;;
        zsh)
            shell_rc="$HOME/.zshrc"
            ;;
        *)
            shell_rc="$HOME/.profile"
            ;;
    esac
    
    info "Configurando shell: $shell_name ($shell_rc)"
    
    # Verificar si ya está configurado
    if grep -q "DEVCPC_PATH" "$shell_rc" 2>/dev/null; then
        success "DevCPC ya está configurado en $shell_rc (no se modificará)"
    else
        # Añadir configuración solo si no existe
        {
            echo ""
            echo "# DevCPC CLI"
            echo "export DEVCPC_PATH=\"$DEVCPC_HOME\""
            echo "export PATH=\"\$PATH:\$DEVCPC_PATH/bin\""
        } >> "$shell_rc"
        
        success "Configuración añadida a $shell_rc"
    fi
    
    return 0
}

# Main
logo
header "Instalador"

# Verificar SO
OS=$(detect_os)
if [[ "$OS" == "unknown" ]]; then
    error "Sistema operativo no soportado: $OSTYPE"
    exit 1
fi

info "Sistema operativo: $OS"

# Verificar requisitos
if ! check_requirements; then
    exit 1
fi

# Verificar instalación existente
if [[ -d "$DEVCPC_HOME" ]]; then
    echo ""
    if [[ -f "$DEVCPC_HOME/.version" ]]; then
        current_version=$(cat "$DEVCPC_HOME/.version")
        success "DevCPC v${current_version} ya está instalado en $DEVCPC_HOME"
    else
        success "DevCPC ya está instalado en $DEVCPC_HOME"
    fi
    echo ""
    info "Si deseas reinstalar, primero borra la instalación existente:"
    echo -e "  ${CYAN}rm -rf $DEVCPC_HOME${NC}"
    echo ""
    info "Y luego vuelve a ejecutar el instalador"
    echo ""
    exit 0
fi

# Obtener última versión
echo ""
info "Obteniendo última versión..."
VERSION=$(get_latest_version)
success "Última versión: $VERSION"

# Instalar
echo ""
install_devcpc "$VERSION"

# Configurar shell
echo ""
configure_shell

# Mostrar información final
header "Instalación Completada"

echo -e "${CYAN}DevCPC v${VERSION} ha sido instalado exitosamente${NC}"
echo ""
echo -e "${YELLOW}Importante:${NC} Recarga tu shell para usar DevCPC:"
echo ""
echo -e "  ${CYAN}source ~/.$(basename $SHELL)rc${NC}"
echo ""
echo -e "O simplemente abre una nueva terminal"
echo ""
echo -e "${CYAN}Próximos pasos:${NC}"
echo ""
echo "  1. Verifica la instalación:"
echo -e "     ${CYAN}devcpc version${NC}"
echo ""
echo "  2. Crea un nuevo proyecto:"
echo -e "     ${CYAN}devcpc new mi-juego${NC}"
echo ""
echo "  3. Para más ayuda:"
echo -e "     ${CYAN}devcpc help${NC}"
echo ""
echo -e "${GREEN}¡Listo para crear tus proyectos para Amstrad CPC! ${NC}"
echo ""
