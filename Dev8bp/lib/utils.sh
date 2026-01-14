#!/usr/bin/env bash
# ==============================================================================
# utils.sh - Utilidades comunes
# ==============================================================================

# Obtener versión de Dev8BP
get_version() {
    local version_file="$DEV8BP_PATH/VERSION"
    if [[ -f "$version_file" ]]; then
        cat "$version_file" | tr -d '\n\r'
    else
        echo "unknown"
    fi
}

# Dev8BP logo
show_logo() {     
    echo -e "${YELLOW}██████╗ ███████╗██╗   ██╗ █████╗ ██████╗ ██████╗  ${NC}"   
    echo -e "${YELLOW}██╔══██╗██╔════╝██║   ██║██╔══██╗██╔══██╗██╔══██╗ ${NC}"   
    echo -e "${YELLOW}██║  ██║█████╗  ██║   ██║╚█████╔╝██████╔╝██████╔╝ ${NC}"   
    echo -e "${YELLOW}██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══██╗██╔══██╗██╔═══╝  ${NC}"   
    echo -e "${YELLOW}██████╔╝███████╗ ╚████╔╝ ╚█████╔╝██████╔╝██║      ${NC}"   
    echo -e "${YELLOW}╚═════╝ ╚══════╝  ╚═══╝   ╚════╝ ╚═════╝ ╚═╝      ${NC}"   
}

# Verificar que estamos en un proyecto Dev8BP
is_dev8bp_project() {
    [[ -f "dev8bp.conf" ]]
}

# Verificar que una herramienta está instalada
check_tool() {
    local tool="$1"
    local name="${2:-$tool}"
    
    if ! command -v "$tool" &> /dev/null; then
        error "$name no está instalado"
        return 1
    fi
    return 0
}

# Obtener tamaño de archivo
get_file_size() {
    local file="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        stat -f%z "$file" 2>/dev/null
    else
        stat -c%s "$file" 2>/dev/null
    fi
}

# Convertir hex a decimal
hex_to_dec() {
    printf "%d" "0x$1" 2>/dev/null || echo "0"
}

# Crear directorio si no existe
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir"
    fi
}

# Preguntar sí/no
ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    
    local prompt
    if [[ "$default" == "y" ]]; then
        prompt="[S/n]"
    else
        prompt="[s/N]"
    fi
    
    echo -ne "${CYAN}$question $prompt:${NC} "
    read -r answer
    
    answer="${answer:-$default}"
    [[ "$answer" =~ ^[SsYy]$ ]]
}

# Detectar sistema operativo
detect_os() {
    case "$OSTYPE" in
        darwin*)  echo "macos" ;;
        linux*)   echo "linux" ;;
        msys*|cygwin*|mingw*) echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

# Detectar arquitectura
detect_arch() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64|amd64) echo "x86_64" ;;
        aarch64|arm64) echo "arm64" ;;
        *) echo "$arch" ;;
    esac
}
