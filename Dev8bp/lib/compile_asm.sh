#!/usr/bin/env bash
# ==============================================================================
# compile_asm.sh - Compilación de código ASM con ABASM
# ==============================================================================

compile_asm() {
    if [[ -z "$BP_ASM_PATH" ]]; then
        return 0
    fi
    
    if [[ ! -d "$BP_ASM_PATH" ]]; then
        warning "BP_ASM_PATH no existe: $BP_ASM_PATH"
        return 0
    fi
    
    local asm_file="$BP_ASM_PATH/make_all_mygame.asm"
    if [[ ! -f "$asm_file" ]]; then
        warning "No se encontró make_all_mygame.asm en $BP_ASM_PATH"
        return 0
    fi
    
    header "Compilar ASM - Build Level $BUILD_LEVEL"
    
    # Verificar ABASM (usar desde dev8bp-cli/tools)
    local abasm_path="$DEV8BP_CLI_ROOT/tools/abasm/src/abasm.py"
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
    
    if compile_output=$(cd "$BP_ASM_PATH" && $python_cmd "$abasm_path" "make_all_mygame.asm" --tolerance 2 2>&1); then
        # Mover archivos generados
        if [[ -f "$BP_ASM_PATH/8BP${BUILD_LEVEL}.bin" ]]; then
            mv "$BP_ASM_PATH/8BP${BUILD_LEVEL}.bin" "$OBJ_DIR/"
            [[ -f "$BP_ASM_PATH/make_all_mygame.bin" ]] && mv "$BP_ASM_PATH/make_all_mygame.bin" "$OBJ_DIR/"
            
            # Mover .lst y .map
            find "$BP_ASM_PATH" -name "*.lst" -exec mv {} "$OBJ_DIR/" \; 2>/dev/null || true
            find "$BP_ASM_PATH" -name "*.map" -exec mv {} "$OBJ_DIR/" \; 2>/dev/null || true
            
            # Limpiar binarios en ASM
            rm -f "$BP_ASM_PATH"/*.bin
            
            # Restaurar backup
            mv "$asm_file.backup_build" "$asm_file"
            
            local size=$(get_file_size "$OBJ_DIR/8BP${BUILD_LEVEL}.bin")
            echo ""
            success "Compilación exitosa"
            info "Archivo:   8BP${BUILD_LEVEL}.bin"
            info "Ubicación: $OBJ_DIR/8BP${BUILD_LEVEL}.bin"
            info "Tamaño:    $size bytes"
            echo ""
            
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
