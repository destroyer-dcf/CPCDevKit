#!/usr/bin/env bash
# ==============================================================================
# compile_asm.sh - Compilación de código ASM con ABASM
# ==============================================================================
# shellcheck disable=SC2155

# Cargar utilidades si no están cargadas
if [[ -z "$(type -t register_in_map)" ]]; then
    source "${DEVCPC_LIB:-$(dirname "$0")}/utils.sh"
fi

compile_asm() {
    if [[ -z "$ASM_PATH" ]]; then
        return 0
    fi
    
    # Verificar que ASM_PATH existe (puede ser archivo o directorio)
    if [[ ! -e "$ASM_PATH" ]]; then
        warning "ASM_PATH no existe: $ASM_PATH"
        return 0
    fi
    
    # Detectar modo de compilación: 8BP (con BUILD_LEVEL) o ASM sin 8bp
    if [[ -n "$BUILD_LEVEL" ]]; then
        # =========================================
        # MODO 8BP: Compilación con BUILD_LEVEL
        # =========================================
        compile_asm_8bp
    else
        # =========================================
        # MODO ASM SIN 8BP: Compilación estándar
        # =========================================
        compile_asm_pure
    fi
}

# ==============================================================================
# Compilación 8BP (con BUILD_LEVEL)
# ==============================================================================
compile_asm_8bp() {
    local asm_file="$ASM_PATH"
    
    # Para 8BP, ASM_PATH debe ser un archivo
    if [[ ! -f "$asm_file" ]]; then
        error "Para proyectos 8BP, ASM_PATH debe ser un archivo"
        error "Ruta actual: $ASM_PATH"
        return 1
    fi
    
    header "Compilar ASM - Build Level $BUILD_LEVEL"
    
    # Verificar ABASM (usar desde devcpc-cli/tools)
    local abasm_path="$DEVCPC_CLI_ROOT/tools/abasm/src/abasm.py"
    if [[ ! -f "$abasm_path" ]]; then
        error "ABASM no encontrado en: $abasm_path"
        return 1
    fi
    
    local python_cmd=$(command -v python3 || command -v python)
    
    info "Archivo:      make_all_mygame.asm"
    info "Build Level:  $BUILD_LEVEL ($(get_level_description $BUILD_LEVEL))"
    info "ABASM:        $abasm_path"
    info "Memoria:      MEMORY $(get_memory_for_level $BUILD_LEVEL)"
    echo ""
    
    # Hacer backup
    step "Preparando compilación..."
    cp "$asm_file" "$asm_file.backup_build"
    
    # Modificar ASSEMBLING_OPTION
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/let ASSEMBLING_OPTION = [0-9]/let ASSEMBLING_OPTION = $BUILD_LEVEL/" "$asm_file"
    else
        sed -i "s/let ASSEMBLING_OPTION = [0-9]/let ASSEMBLING_OPTION = $BUILD_LEVEL/" "$asm_file"
    fi
    
    # Añadir directivas SAVE si no existen
    if ! grep -q "if ASSEMBLING_OPTION = 0" "$asm_file"; then
        # Eliminar SAVE existentes
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '/^SAVE /d' "$asm_file"
        else
            sed -i '/^SAVE /d' "$asm_file"
        fi
        
        # Añadir directivas condicionales
        cat >> "$asm_file" << 'EOF'

if ASSEMBLING_OPTION = 0
SAVE "8BP0.bin",23600,19120
elseif ASSEMBLING_OPTION = 1
SAVE "8BP1.bin",25000,17620
elseif ASSEMBLING_OPTION = 2
SAVE "8BP2.bin",24800,17820
elseif ASSEMBLING_OPTION = 3
SAVE "8BP3.bin",24000,18620
elseif ASSEMBLING_OPTION = 4
SAVE "8BP4.bin",25300,17320
endif
EOF
    fi
    
    success "Configuración preparada"
    echo ""
    
    # Compilar
    step "Compilando con ABASM..."
    
    local project_root="$(pwd)"
    local compile_output
    local asm_dir="$(dirname "$asm_file")"
    local asm_filename="$(basename "$asm_file")"
    
    if compile_output=$(cd "$asm_dir" && $python_cmd "$abasm_path" "$asm_filename" --tolerance 2 2>&1); then
        # Mover archivos generados
        if [[ -f "$asm_dir/8BP${BUILD_LEVEL}.bin" ]]; then
            mv "$asm_dir/8BP${BUILD_LEVEL}.bin" "$OBJ_DIR/"
            [[ -f "$asm_dir/make_all_mygame.bin" ]] && mv "$asm_dir/make_all_mygame.bin" "$OBJ_DIR/"
            
            # Mover .lst y .map
            find "$asm_dir" -name "*.lst" -exec mv {} "$OBJ_DIR/" \; 2>/dev/null || true
            find "$asm_dir" -name "*.map" -exec mv {} "$OBJ_DIR/" \; 2>/dev/null || true
            
            # Limpiar binarios en ASM
            rm -f "$asm_dir"/*.bin
            
            # Restaurar backup
            mv "$asm_file.backup_build" "$asm_file"
            
            local size=$(get_file_size "$OBJ_DIR/8BP${BUILD_LEVEL}.bin")
            echo ""
            success "Compilación exitosa"
            info "Archivo:   8BP${BUILD_LEVEL}.bin"
            info "Ubicación: $OBJ_DIR/8BP${BUILD_LEVEL}.bin"
            info "Tamaño:    $size bytes"
            echo ""
            
            # Registrar en map.cfg
            local load_addr=$(get_load_addr_for_level $BUILD_LEVEL)
            register_in_map "8BP${BUILD_LEVEL}.bin" "bin" "$load_addr" "$load_addr"
            
            # Verificar límites de gráficos
            verify_graphics_limit
            
            return 0
        else
            mv "$asm_file.backup_build" "$asm_file"
            error "No se generó el binario 8BP${BUILD_LEVEL}.bin"
            return 1
        fi
    else
        mv "$asm_file.backup_build" "$asm_file"
        error "Error en la compilación:"
        echo "$compile_output"
        return 1
    fi
}

# Verificar límite de gráficos (_END_GRAPH)
verify_graphics_limit() {
    local map_file="$OBJ_DIR/make_all_mygame.map"
    
    if [[ ! -f "$map_file" ]]; then
        return 0
    fi
    
    local end_graph_line=$(grep "_END_GRAPH" "$map_file" | head -1)
    
    if [[ -z "$end_graph_line" ]]; then
        return 0
    fi
    
    local end_graph_addr=$(echo "$end_graph_line" | sed 's/.*\[0x\([0-9A-Fa-f]*\).*/\1/')
    
    if [[ -z "$end_graph_addr" ]]; then
        return 0
    fi
    
    local end_graph_dec=$(hex_to_dec "$end_graph_addr")
    
    if [[ $end_graph_dec -eq 0 ]]; then
        return 0
    fi
    
    local graph_size=$((end_graph_dec - 33600))
    
    step "Verificando límites de gráficos..."
    info "_END_GRAPH: $end_graph_dec (0x$end_graph_addr)"
    info "Tamaño gráficos: $graph_size bytes (máximo: 8440 bytes)"
    
    if [[ $end_graph_dec -ge 42040 ]]; then
        echo ""
        error "_END_GRAPH ($end_graph_dec) >= 42040"
        error "Estás usando $graph_size bytes de gráficos (máximo: 8440 bytes)"
        error "Esto machacará direcciones del intérprete BASIC"
        echo ""
        warning "Soluciones:"
        echo "  1. Reduce el número de gráficos"
        echo "  2. Ensambla gráficos extra en otra zona (ej: 22000) y usa MEMORY 21999"
        echo ""
        return 1
    else
        success "Límite de gráficos respetado (< 42040)"
    fi
    
    echo ""
    return 0
}

# ==============================================================================
# Compilación ASM pura (sin BUILD_LEVEL, para proyectos ASM estándar)
# ==============================================================================
compile_asm_pure() {
    header "Compilar ASM (sin 8BP)"
    
    # Validar variables requeridas
    if [[ -z "$LOADADDR" ]]; then
        error "LOADADDR no está definido en devcpc.conf"
        echo ""
        info "Para proyectos ASM sin 8BP, necesitas:"
        echo "  LOADADDR=0x1200    # Dirección de carga"
        echo "  SOURCE=\"main\"      # Archivo fuente (sin .asm)"
        echo "  TARGET=\"program\"   # Nombre del binario"
        return 1
    fi
    
    if [[ -z "$SOURCE" ]]; then
        error "SOURCE no está definido en devcpc.conf"
        return 1
    fi
    
    if [[ -z "$TARGET" ]]; then
        error "TARGET no está definido en devcpc.conf"
        return 1
    fi
    
    # Verificar ABASM
    local abasm_path="$DEVCPC_CLI_ROOT/tools/abasm/src/abasm.py"
    if [[ ! -f "$abasm_path" ]]; then
        error "ABASM no encontrado en: $abasm_path"
        return 1
    fi
    
    local python_cmd=$(command -v python3 || command -v python)
    
    # Determinar archivo fuente
    local source_file="${SOURCE%.asm}.asm"
    local source_path
    local source_dir
    
    # Buscar el archivo
    if [[ -f "$ASM_PATH" ]]; then
        # ASM_PATH es un archivo directo
        source_path="$ASM_PATH"
        source_dir="$(dirname "$ASM_PATH")"
    elif [[ -d "$ASM_PATH" ]]; then
        # ASM_PATH es un directorio, buscar SOURCE dentro
        source_path="$ASM_PATH/$source_file"
        source_dir="$ASM_PATH"
    else
        # Buscar en directorio actual
        source_path="$source_file"
        source_dir="."
    fi
    
    if [[ ! -f "$source_path" ]]; then
        error "No se encontró el archivo fuente: $source_path"
        echo ""
        info "Verifica en devcpc.conf:"
        echo "  ASM_PATH=\"$(dirname "$source_path")\""
        echo "  SOURCE=\"${SOURCE%.asm}\""
        return 1
    fi
    
    info "Archivo:      $(basename "$source_path")"
    info "Ruta:         $source_path"
    info "Target:       ${TARGET}.bin"
    info "Load Addr:    $LOADADDR"
    info "ABASM:        $abasm_path"
    echo ""
    
    # Compilar
    step "Compilando con ABASM..."
    
    local compile_output
    local source_name="$(basename "$source_path")"
    
    if compile_output=$(cd "$source_dir" && $python_cmd "$abasm_path" "$source_name" --tolerance 2 2>&1); then
        # Buscar binario generado
        local generated_bin="$source_dir/${SOURCE%.asm}.bin"
        
        if [[ -f "$generated_bin" ]]; then
            # Mover y renombrar
            mv "$generated_bin" "$OBJ_DIR/${TARGET}.bin"
            
            # Mover .lst y .map si existen
            [[ -f "$source_dir/${SOURCE%.asm}.lst" ]] && mv "$source_dir/${SOURCE%.asm}.lst" "$OBJ_DIR/"
            [[ -f "$source_dir/${SOURCE%.asm}.map" ]] && mv "$source_dir/${SOURCE%.asm}.map" "$OBJ_DIR/"
            
            local size=$(get_file_size "$OBJ_DIR/${TARGET}.bin")
            echo ""
            success "Compilación exitosa"
            info "Archivo:   ${TARGET}.bin"
            info "Ubicación: $OBJ_DIR/${TARGET}.bin"
            info "Tamaño:    $size bytes"
            echo ""
            
            # Registrar en map.cfg (convertir LOADADDR hex a decimal)
            local load_dec=$(hex_to_dec "${LOADADDR#0x}")
            register_in_map "${TARGET}.bin" "bin" "$load_dec" "$load_dec"
            
            return 0
        else
            error "No se generó el binario ${SOURCE%.asm}.bin"
            return 1
        fi
    else
        error "Error en la compilación:"
        echo "$compile_output"
        return 1
    fi
}

