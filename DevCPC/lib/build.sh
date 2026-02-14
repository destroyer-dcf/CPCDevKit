#!/usr/bin/env bash
# ==============================================================================
# build.sh - Compilar proyecto
# ==============================================================================
# shellcheck disable=SC2155

build_project() {
    if ! is_devcpc_project; then
        error "No estás en un proyecto DevCPC\n"
        exit 1
    fi
    
    load_config
    
    # Cargar librerías de compilación
    source "$DEVCPC_LIB/compile_asm.sh"
    source "$DEVCPC_LIB/compile_c.sh"
    source "$DEVCPC_LIB/dsk.sh"
    source "$DEVCPC_LIB/cdt.sh"
    source "$DEVCPC_LIB/cpr.sh"
    source "$DEVCPC_LIB/graphics.sh"
    source "$DEVCPC_LIB/screens.sh"
    
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
    if [[ -n "$BUILD_LEVEL" ]]; then
        info "Build Level: $BUILD_LEVEL ($(get_level_description $BUILD_LEVEL))"
        info "Memoria BASIC: MEMORY $(get_memory_for_level $BUILD_LEVEL)"
    else
        info "Modo: ASM (sin BUILD_LEVEL/8BP)"
    fi
    echo ""
    
    # Crear directorios
    ensure_dir "$OBJ_DIR"
    ensure_dir "$DIST_DIR"
    
    # Limpiar map.cfg anterior
    rm -f "${OBJ_DIR}/${PROJECT_NAME}.map"
    
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
    if [[ -n "$ASM_PATH" ]]; then
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
    if [[ -n "$ASM_PATH" ]]; then
        # Proyecto 8BP: usar 8BP${BUILD_LEVEL}.bin
        if [[ -n "$BUILD_LEVEL" && -f "$OBJ_DIR/8BP${BUILD_LEVEL}.bin" ]]; then
            local load_addr=$(get_load_addr_for_level $BUILD_LEVEL)
            if ! add_bin_to_dsk "$DSK" "8BP${BUILD_LEVEL}.bin" "$load_addr" "$load_addr"; then
                error "Error al añadir binario ASM al DSK"
                exit 1
            fi
            echo ""
        # Proyecto ASM sin 8bp: usar ${TARGET}.bin
        elif [[ -z "$BUILD_LEVEL" && -n "$TARGET" && -f "$OBJ_DIR/${TARGET}.bin" ]]; then
            if ! add_bin_to_dsk "$DSK" "${TARGET}.bin" "$LOADADDR" "MAIN" "${SOURCE}.map"; then
                error "Error al añadir binario ASM al DSK"
                exit 1
            fi
            echo ""
        fi
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
    
    # 8. Mostrar contenido del DSK
    show_dsk_catalog
    
    # 9. Crear CDT si está configurado
    if [[ -n "$CDT" && -n "$CDT_FILES" ]]; then
        if ! create_cdt; then
            error "Error al crear cinta CDT"
            exit 1
        fi
        show_cdt_catalog
    fi
    
    # 10. Crear CPR (cartucho) si está configurado
    if [[ -n "$CPR" ]]; then
        echo ""
        header "Crear Cartucho CPR"
        
        info "CPR: $CPR"
        info "Ubicación: $DIST_DIR/$CPR"
        echo ""
        
        if ! create_cpr "$DSK" "$CPR" "$CPR_EXECUTE"; then
            warning "Error al crear cartucho CPR (no crítico)"
        else
            show_cpr_info
        fi
    fi
    
    # Resumen final
    header "Compilación Completada"
    
    success "Proyecto compilado exitosamente"
    echo ""
    
    info "Archivos generados:"
    echo "  DSK: $DIST_DIR/$DSK"
    
    # Mostrar binario 8BP
    if [[ -n "$ASM_PATH" && -n "$BUILD_LEVEL" && -f "$OBJ_DIR/8BP${BUILD_LEVEL}.bin" ]]; then
        echo "  BIN: $OBJ_DIR/8BP${BUILD_LEVEL}.bin"
    fi
    
    # Mostrar binario ASM sin 8bp
    if [[ -n "$ASM_PATH" && -z "$BUILD_LEVEL" && -n "$TARGET" && -f "$OBJ_DIR/${TARGET}.bin" ]]; then
        echo "  BIN: $OBJ_DIR/${TARGET}.bin"
    fi
    
    if [[ -n "$CDT" && -f "$DIST_DIR/$CDT" ]]; then
        echo "  CDT: $DIST_DIR/$CDT"
    fi
    
    if [[ -n "$CPR" && -f "$DIST_DIR/$CPR" ]]; then
        echo "  CPR: $DIST_DIR/$CPR"
    fi
    
    echo ""
    
    info "Uso desde BASIC:"
    if [[ -n "$BUILD_LEVEL" ]]; then
        # Modo 8BP
        echo "  MEMORY $(get_memory_for_level $BUILD_LEVEL)"
        echo "  LOAD\"8BP${BUILD_LEVEL}.bin\""
        echo "  CALL &6B78"
    elif [[ -n "$ASM_PATH" && -n "$TARGET" && -n "$LOADADDR" ]]; then
        # Modo ASM sin 8bp - convertir 0x a & para BASIC
        local basic_addr="${LOADADDR//0x/&}"
        echo "  LOAD\"${TARGET}.bin\""
        echo "  CALL ${basic_addr}"
    else
        echo "  (No hay código ASM compilado)"
    fi
    
    echo ""
    
    if [[ -n "$RVM_PATH" ]]; then
        info "Para ejecutar: devcpc run"
    else
        info "Configura RVM_PATH en devcpc.conf para usar 'devcpc run'"
    fi
    
    echo ""
}
