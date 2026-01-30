#!/usr/bin/env bash
# ==============================================================================
# utils.sh - Utilidades comunes
# ==============================================================================
# shellcheck disable=SC2155

# Obtener versión de DevCPC
get_version() {
    local version_file="$DEVCPC_PATH/VERSION"
    if [[ -f "$version_file" ]]; then
        cat "$version_file" | tr -d '\n\r'
    else
        echo "unknown"
    fi
}

# DevCPC logo
show_logo() {     
#     echo -e "${YELLOW}██████╗ ███████╗██╗   ██╗ █████╗ ██████╗ ██████╗  ${NC}"   
#     echo -e "${YELLOW}██╔══██╗██╔════╝██║   ██║██╔══██╗██╔══██╗██╔══██╗ ${NC}"   
#     echo -e "${YELLOW}██║  ██║█████╗  ██║   ██║╚█████╔╝██████╔╝██████╔╝ ${NC}"   
#     echo -e "${YELLOW}██║  ██║██╔══╝  ╚██╗ ██╔╝██╔══██╗██╔══██╗██╔═══╝  ${NC}"   
#     echo -e "${YELLOW}██████╔╝███████╗ ╚████╔╝ ╚█████╔╝██████╔╝██║      ${NC}"   
#     echo -e "${YELLOW}╚═════╝ ╚══════╝  ╚═══╝   ╚════╝ ╚═════╝ ╚═╝      ${NC}"   
#     echo ""
    
echo -e "${YELLOW}▛▀▖      ▞▀▖▛▀▖▞▀▖${NC}"
echo -e "${YELLOW}▌ ▌▞▀▖▌ ▌▌  ▙▄▘▌  ${NC}"
echo -e "${YELLOW}▌ ▌▛▀ ▐▐ ▌ ▖▌  ▌ ▖${NC}"
echo -e "${YELLOW}▀▀ ▝▀▘ ▘ ▝▀ ▘  ▝▀ ${NC}"

}


# Verificar que estamos en un proyecto DevCPC
is_devcpc_project() {
    [[ -f "devcpc.conf" ]]
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

# Registrar archivos en map.cfg
register_in_map() {
    local filename="$1"
    local type="$2"
    local load_addr="$3"
    local exec_addr="$4"
    
    local map_file="$OBJ_DIR/${PROJECT_NAME}.map"
    local map_tool="$DEVCPC_CLI_ROOT/tools/map/map.py"
    
    # Verificar que existe map.py
    if [[ ! -f "$map_tool" ]]; then
        warning "map.py no encontrado en: $map_tool"
        return 0
    fi
    
    local python_cmd=$(command -v python3 || command -v python)
    
    # Registrar en map.cfg
    $python_cmd "$map_tool" --file "$map_file" --update --section "$filename" --key "type" --value "$type" > /dev/null 2>&1
    $python_cmd "$map_tool" --file "$map_file" --update --section "$filename" --key "load" --value "$load_addr" > /dev/null 2>&1
    $python_cmd "$map_tool" --file "$map_file" --update --section "$filename" --key "execute" --value "$exec_addr" > /dev/null 2>&1
}
