#!/usr/bin/env bash
# ==============================================================================
# build.sh - Compilar proyecto
# ==============================================================================

build_project() {
    if ! is_dev8bp_project; then
        error "No estás en un proyecto Dev8BP\n"
        exit 1
    fi
    
    load_config
    
    # Cargar librerías de compilación
    source "$DEV8BP_LIB/compile_asm.sh"
    source "$DEV8BP_LIB/compile_c.sh"
    source "$DEV8BP_LIB/dsk.sh"
    
    header "Compilar Proyecto: $PROJECT_NAME"
    
    info "Build Level: $BUILD_LEVEL ($(get_level_description $BUILD_LEVEL))"
    info "Memoria BASIC: MEMORY $(get_memory_for_level $BUILD_LEVEL)"
    echo ""
    
    # Crear directorios
    ensure_dir "$OBJ_DIR"
    ensure_dir "$DIST_DIR"
    
    local has_errors=0
    
    # 1. Compilar ASM si está configurado
    if [[ -n "$BP_ASM_PATH" ]]; then
        if ! compile_asm; then
            has_errors=1
        fi
    fi
    
    # Si hubo errores en ASM, no continuar
    if [[ $has_errors -eq 1 ]]; then
        error "Compilación fallida"
        exit 1
    fi
    
    # 2. Crear DSK
    header "Crear Imagen DSK"
    
    info "DSK: $DSK"
    info "Ubicación: $DIST_DIR/$DSK"
    echo ""
    
    if ! create_dsk "$DSK"; then
        error "Error al crear DSK"
        exit 1
    fi
    
    echo ""
    
    # 3. Añadir binario ASM al DSK si existe
    if [[ -n "$BP_ASM_PATH" && -f "$OBJ_DIR/8BP${BUILD_LEVEL}.bin" ]]; then
        local load_addr=$(get_load_addr_for_level $BUILD_LEVEL)
        if ! add_bin_to_dsk "$DSK" "8BP${BUILD_LEVEL}.bin" "$load_addr" "$load_addr"; then
            error "Error al añadir binario ASM al DSK"
            exit 1
        fi
        echo ""
    fi
    
    # 4. Compilar C si está configurado
    if [[ -n "$C_PATH" ]]; then
        if ! compile_c; then
            error "Compilación C fallida\n"
            exit 1
        fi
    fi
    
    # 5. Añadir archivos BASIC
    add_basic_to_dsk || true
    
    # 6. Añadir archivos RAW
    add_raw_to_dsk || true
    
    # 7. Mostrar catálogo del DSK
    show_dsk_catalog
    
    # Resumen final
    header "Compilación Completada"
    
    success "Proyecto compilado exitosamente"
    echo ""
    
    info "Archivos generados:"
    echo "  DSK: $DIST_DIR/$DSK"
    
    if [[ -n "$BP_ASM_PATH" && -f "$OBJ_DIR/8BP${BUILD_LEVEL}.bin" ]]; then
        echo "  BIN: $OBJ_DIR/8BP${BUILD_LEVEL}.bin"
    fi
    
    echo ""
    
    info "Uso desde BASIC:"
    echo "  MEMORY $(get_memory_for_level $BUILD_LEVEL)"
    if [[ -n "$BP_ASM_PATH" ]]; then
        echo "  LOAD\"8BP${BUILD_LEVEL}.bin\""
        echo "  CALL &6B78"
    fi
    
    echo ""
    
    if [[ -n "$RVM_PATH" ]]; then
        info "Para ejecutar: dev8bp run"
    else
        info "Configura RVM_PATH en dev8bp.conf para usar 'dev8bp run'"
    fi
    
    echo ""
}
