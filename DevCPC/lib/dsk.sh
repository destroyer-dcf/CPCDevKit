#!/usr/bin/env bash
# ==============================================================================
# dsk.sh - Gestión de imágenes DSK
# ==============================================================================
# shellcheck disable=SC2155

# Cargar utilidades si no están cargadas
if [[ -z "$(type -t register_in_map)" ]]; then
    source "${DEVCPC_LIB:-$(dirname "$0")}/utils.sh"
fi

create_dsk() {
    local dsk_name="$1"
    local dsk_path="$DIST_DIR/$dsk_name"
    
    # Verificar dsk.py (usar desde devcpc-cli/tools)
    local dsk_tool="$DEVCPC_CLI_ROOT/tools/abasm/src/dsk.py"
    if [[ ! -f "$dsk_tool" ]]; then
        error "dsk.py no encontrado en: $dsk_tool"
        return 1
    fi
    
    local python_cmd=$(command -v python3 || command -v python)
    
    step "Creando imagen DSK: $dsk_name"
    
    # Eliminar DSK existente
    [[ -f "$dsk_path" ]] && rm -f "$dsk_path"
    
    # Crear nuevo DSK
    if $python_cmd "$dsk_tool" "$dsk_path" --new > /dev/null 2>&1; then
        success "DSK creado: $dsk_path"
        return 0
    else
        error "Error al crear DSK"
        return 1
    fi
}

add_bin_to_dsk() {
    local dsk_name="$1"
    local bin_file="$2"
    local load_addr="$3"
    local start_addr="$4"
    
    local dsk_path="$DIST_DIR/$dsk_name"
    local bin_path="$OBJ_DIR/$bin_file"
    
    if [[ ! -f "$bin_path" ]]; then
        error "Binario no encontrado: $bin_path"
        return 1
    fi
    
    local dsk_tool="$DEVCPC_CLI_ROOT/tools/abasm/src/dsk.py"
    local python_cmd=$(command -v python3 || command -v python)
    
    step "Añadiendo binario: $bin_file"
    
    if (cd "$OBJ_DIR" && $python_cmd "$dsk_tool" "$(pwd)/../$dsk_path" --put-bin "$bin_file" --load-addr "$load_addr" --start-addr "$start_addr" 2>&1); then
        success "Binario añadido"
        return 0
    else
        error "Error al añadir binario"
        return 1
    fi
}

add_basic_to_dsk() {
    if [[ -z "$BASIC_PATH" ]]; then
        return 0
    fi
    
    if [[ ! -d "$BASIC_PATH" ]]; then
        return 0
    fi
    
    local bas_files=("$BASIC_PATH"/*.bas)
    if [[ ! -f "${bas_files[0]}" ]]; then
        return 0
    fi
    
    echo ""
    step "Añadiendo archivos BASIC..."
    
    local dsk_tool="$DEVCPC_CLI_ROOT/tools/abasm/src/dsk.py"
    local python_cmd=$(command -v python3 || command -v python)
    local dsk_path="$DIST_DIR/$DSK"
    local count=0
    
    for file in "${bas_files[@]}"; do
        if [[ -f "$file" ]]; then
            local basename=$(basename "$file")
            
            # Copiar a obj/
            cp "$file" "$OBJ_DIR/$basename"
            
            # Verificar newline final
            if [[ $(tail -c 1 "$OBJ_DIR/$basename" | wc -l) -eq 0 ]]; then
                echo "" >> "$OBJ_DIR/$basename"
            fi
            
            # Añadir al DSK
            if (cd "$OBJ_DIR" && $python_cmd "$dsk_tool" "$(pwd)/../$dsk_path" --put-ascii "$basename" > /dev/null 2>&1); then
                info "  $basename"
                
                # Registrar en map.cfg
                register_in_map "$basename" "ascii" "" ""
                
                ((count++))
            fi
        fi
    done
    
    if [[ $count -gt 0 ]]; then
        success "$count archivo(s) BASIC añadidos"
    fi
    
    return 0
}

add_raw_to_dsk() {
    if [[ -z "$RAW_PATH" ]]; then
        return 0
    fi
    
    if [[ ! -d "$RAW_PATH" ]]; then
        return 0
    fi
    
    local raw_files=("$RAW_PATH"/*)
    if [[ ! -f "${raw_files[0]}" ]]; then
        return 0
    fi
    
    echo ""
    step "Añadiendo archivos RAW..."
    
    local dsk_tool="$DEVCPC_CLI_ROOT/tools/abasm/src/dsk.py"
    local python_cmd=$(command -v python3 || command -v python)
    local dsk_path="$DIST_DIR/$DSK"
    local count=0
    
    for file in "${raw_files[@]}"; do
        if [[ -f "$file" ]]; then
            local basename=$(basename "$file")
            
            # Copiar a obj/
            cp "$file" "$OBJ_DIR/$basename"
            
            # Añadir al DSK
            if (cd "$OBJ_DIR" && $python_cmd "$dsk_tool" "$(pwd)/../$dsk_path" --put-raw "$basename" > /dev/null 2>&1); then
                info "  $basename"
                
                # Registrar en map.cfg
                register_in_map "$basename" "raw" "" ""
                
                ((count++))
            fi
        fi
    done
    
    if [[ $count -gt 0 ]]; then
        success "$count archivo(s) RAW añadidos"
    fi
    
    return 0
}

show_dsk_catalog() {
    local dsk_path="$DIST_DIR/$DSK"
    
    if [[ ! -f "$dsk_path" ]]; then
        return 0
    fi
    
    local dsk_tool="$DEVCPC_CLI_ROOT/tools/abasm/src/dsk.py"
    local python_cmd=$(command -v python3 || command -v python)
    
    echo ""
    step "Contenido del DSK:\n"
    $python_cmd "$dsk_tool" "$dsk_path" --cat 2>/dev/null || true
    echo ""
}
