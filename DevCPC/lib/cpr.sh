#!/usr/bin/env bash
# ==============================================================================
# cpr.sh - Gestión de imágenes CPR (Cartuchos)
# ==============================================================================
# shellcheck disable=SC2155

# Cargar utilidades si no están cargadas
if [[ -z "$(type -t register_in_map)" ]]; then
    source "${DEVCPC_LIB:-$(dirname "$0")}/utils.sh"
fi

create_cpr() {
    local dsk_name="$1"
    local cpr_name="$2"
    local execute_file="${3:-disc}"
    
    local dsk_path="$DIST_DIR/$dsk_name"
    local cpr_path="$DIST_DIR/$cpr_name"
    
    # Construir comando de ejecución automáticamente
    local execute_command="run\"$execute_file\""
    
    # Verificar que el DSK existe
    if [[ ! -f "$dsk_path" ]]; then
        error "DSK no encontrado: $dsk_path"
        error "Debe generarse el DSK antes de crear el cartucho CPR"
        return 1
    fi
    
    # Verificar nocart.py
    local nocart_tool="$DEVCPC_CLI_ROOT/tools/nocart/nocart.py"
    if [[ ! -f "$nocart_tool" ]]; then
        error "nocart.py no encontrado en: $nocart_tool"
        return 1
    fi
    
    local python_cmd=$(command -v python3 || command -v python)
    
    step "Creando cartucho CPR: $cpr_name"
    
    # Eliminar CPR existente
    [[ -f "$cpr_path" ]] && rm -f "$cpr_path"
    
    # Crear nuevo CPR desde DSK
    info "Archivo: $execute_file"
    info "Comando: $execute_command"
    
    if $python_cmd "$nocart_tool" create "$dsk_path" "$cpr_path" --command "$execute_command" > /dev/null 2>&1; then
        success "Cartucho CPR creado: $cpr_path"
        
        # Mostrar información del archivo
        local size=$(du -h "$cpr_path" | cut -f1)
        info "Tamaño: $size"
        
        return 0
    else
        error "Error al crear cartucho CPR"
        return 1
    fi
}

show_cpr_info() {
    local cpr_path="$DIST_DIR/$CPR"
    
    if [[ ! -f "$cpr_path" ]]; then
        return 0
    fi
    
    echo ""
    step "Información del Cartucho CPR:\n"
    
    local size=$(du -h "$cpr_path" | cut -f1)
    local md5sum_cmd=$(command -v md5sum || command -v md5)
    local checksum=""
    
    if [[ -n "$md5sum_cmd" ]]; then
        if [[ "$(basename "$md5sum_cmd")" == "md5" ]]; then
            # macOS
            checksum=$($md5sum_cmd "$cpr_path" | awk '{print $NF}')
        else
            # Linux
            checksum=$($md5sum_cmd "$cpr_path" | awk '{print $1}')
        fi
    fi
    
    echo "  Archivo:  $(basename "$cpr_path")"
    echo "  Tamaño:   $size"
    [[ -n "$checksum" ]] && echo "  MD5:      $checksum"
    echo "  Ejecuta:  ${CPR_EXECUTE:-disc}"
    echo "  Comando:  run\"${CPR_EXECUTE:-disc}\""
    echo ""
}
