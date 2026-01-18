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
    source "$DEV8BP_LIB/graphics.sh"
    source "$DEV8BP_LIB/screens.sh"
    
    header "Compilar Proyecto: $PROJECT_NAME"
    
    # Detectar sistema operativo
    local os_name=""
    case "$(detect_os)" in
        macos)   os_name="macOS" ;;
        linux)   os_name="Linux" ;;
        windows) os_name="Windows" ;;
        *)       os_name="Unknown" ;;
    esac
    
    # Detectar arquitectura
    local arch_name=$(detect_arch)
    
    info "Sistema: $os_name ($arch_name)"
    info "Build Level: $BUILD_LEVEL ($(get_level_description $BUILD_LEVEL))"
    info "Memoria BASIC: MEMORY $(get_memory_for_level $BUILD_LEVEL)"
    echo ""
    
    # Crear directorios
    ensure_dir "$OBJ_DIR"
    ensure_dir "$DIST_DIR"
    
    local has_errors=0
    
    # 1. Convertir sprites PNG a ASM si está configurado
    if [[ -n "$SPRITES_PATH" ]]; then
        if ! convert_sprites; then
            has_errors=1
        fi
    fi
    
    # Si hubo errores en conversión de sprites, no continuar
    if [[ $has_errors -eq 1 ]]; then
        error "Conversión de sprites fallida"
        exit 1
    fi
    
    # 1.5. Convertir pantallas de carga PNG a SCN si está configurado
    if [[ -n "$LOADER_SCREEN" ]]; then
        if ! convert_screens; then
            has_errors=1
        fi
    fi
    
    # Si hubo errores en conversión de pantallas, no continuar
    if [[ $has_errors -eq 1 ]]; then
        error "Conversión de pantallas fallida"
        exit 1
    fi
    
    # 2. Compilar ASM si está configurado
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
    
    # 3. Crear DSK
    header "Crear Imagen DSK"
    
    info "DSK: $DSK"
    info "Ubicación: $DIST_DIR/$DSK"
    echo ""
    
    if ! create_dsk "$DSK"; then
        error "Error al crear DSK"
        exit 1
    fi
    
    echo ""
    
    # 4. Añadir binario ASM al DSK si existe
    if [[ -n "$BP_ASM_PATH" && -f "$OBJ_DIR/8BP${BUILD_LEVEL}.bin" ]]; then
        local load_addr=$(get_load_addr_for_level $BUILD_LEVEL)
        if ! add_bin_to_dsk "$DSK" "8BP${BUILD_LEVEL}.bin" "$load_addr" "$load_addr"; then
            error "Error al añadir binario ASM al DSK"
            exit 1
        fi
        echo ""
    fi
    
    # 4.5. Añadir pantallas de carga al DSK si existen
    if [[ -n "$LOADER_SCREEN" ]]; then
        if ! add_screens_to_dsk; then
            error "Error al añadir pantallas al DSK"
            exit 1
        fi
    fi
    
    # 5. Compilar C si está configurado
    if [[ -n "$C_PATH" ]]; then
        if ! compile_c; then
            error "Compilación C fallida\n"
            exit 1
        fi
    fi
    
    # 6. Añadir archivos BASIC
    add_basic_to_dsk || true
    
    # 7. Añadir archivos RAW
    add_raw_to_dsk || true
    
    # 8. Mostrar catálogo del DSK
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
