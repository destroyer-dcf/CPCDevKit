#!/usr/bin/env bash
# ==============================================================================
# config.sh - Gestión de configuración
# ==============================================================================

# Cargar configuración del proyecto
load_config() {
    if [[ ! -f "dev8bp.conf" ]]; then
        error "No se encontró dev8bp.conf"
        error "¿Estás en un proyecto Dev8BP?"
        error "Usa 'dev8bp new <nombre>' para crear uno nuevo"
        exit 1
    fi
    
    source dev8bp.conf
    
    # Validar configuración mínima
    if [[ -z "$PROJECT_NAME" ]]; then
        error "PROJECT_NAME no está definido en dev8bp.conf"
        exit 1
    fi
    
    # Valores por defecto
    BUILD_LEVEL="${BUILD_LEVEL:-0}"
    OBJ_DIR="${OBJ_DIR:-obj}"
    DIST_DIR="${DIST_DIR:-dist}"
    DSK="${DSK:-${PROJECT_NAME}.dsk}"
}

# Mostrar información del proyecto
show_project_info() {
    if ! is_dev8bp_project; then
        error "No estás en un proyecto Dev8BP"
        exit 1
    fi
    
    load_config
    
    header "Configuración del Proyecto"
    
    echo -e "${CYAN}Proyecto:${NC}        $PROJECT_NAME"
    echo -e "${CYAN}Build Level:${NC}     $BUILD_LEVEL"
    echo ""
    
    echo -e "${YELLOW}Rutas configuradas:${NC}"
    [[ -n "$BP_ASM_PATH" ]] && echo -e "  ${GREEN}✓${NC} ASM:    $BP_ASM_PATH"
    [[ -n "$BASIC_PATH" ]] && echo -e "  ${GREEN}✓${NC} BASIC:  $BASIC_PATH"
    [[ -n "$RAW_PATH" ]] && echo -e "  ${GREEN}✓${NC} RAW:    $RAW_PATH"
    [[ -n "$C_PATH" ]] && echo -e "  ${GREEN}✓${NC} C:      $C_PATH"
    
    if [[ -z "$BP_ASM_PATH" && -z "$BASIC_PATH" && -z "$RAW_PATH" && -z "$C_PATH" ]]; then
        echo -e "  ${YELLOW}⚠${NC} Ninguna ruta configurada"
    fi
    
    echo ""
    echo -e "${YELLOW}Directorios:${NC}"
    echo -e "  Objetos:  $OBJ_DIR"
    echo -e "  Salida:   $DIST_DIR"
    echo -e "  DSK:      $DSK"
    
    if [[ -n "$RVM_PATH" ]]; then
        echo ""
        echo -e "${YELLOW}Emulador:${NC}"
        echo -e "  RVM:      $RVM_PATH"
        echo -e "  Modelo:   ${CPC_MODEL:-464}"
        [[ -n "$RUN_FILE" ]] && echo -e "  Ejecutar: $RUN_FILE"
    fi
    
    echo ""
}

# Obtener memoria BASIC según BUILD_LEVEL
get_memory_for_level() {
    local level="${1:-0}"
    case "$level" in
        0) echo "23599" ;;
        1) echo "24999" ;;
        2) echo "24799" ;;
        3) echo "23999" ;;
        4) echo "25299" ;;
        *) echo "23599" ;;
    esac
}

# Obtener dirección de carga según BUILD_LEVEL
get_load_addr_for_level() {
    local level="${1:-0}"
    case "$level" in
        0) echo "0x5C30" ;;
        1) echo "0x61A8" ;;
        2) echo "0x60E0" ;;
        3) echo "0x5DC0" ;;
        4) echo "0x62D4" ;;
        *) echo "0x5C30" ;;
    esac
}

# Obtener descripción del BUILD_LEVEL
get_level_description() {
    local level="${1:-0}"
    case "$level" in
        0) echo "Todas las funcionalidades" ;;
        1) echo "Juegos de laberintos" ;;
        2) echo "Juegos con scroll" ;;
        3) echo "Juegos pseudo-3D" ;;
        4) echo "Sin scroll/layout (+500 bytes)" ;;
        *) echo "Desconocido" ;;
    esac
}
