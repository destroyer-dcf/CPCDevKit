#!/usr/bin/env bash
# ==============================================================================
# validate.sh - Validar proyecto
# ==============================================================================

validate_project() {
    if ! is_devcpc_project; then
        error "No estás en un proyecto DevCPC"
        exit 1
    fi
    
    load_config
    
    header "Validar Proyecto: $PROJECT_NAME"
    
    local errors=0
    local warnings=0
    
    # Validar configuración
    step "Validando configuración..."
    
    if [[ -z "$PROJECT_NAME" ]]; then
        error "PROJECT_NAME no está definido"
        ((errors++))
    else
        success "PROJECT_NAME: $PROJECT_NAME"
    fi
    
    # BUILD_LEVEL solo es requerido para proyectos 8BP
    local is_8bp_project=0
    if [[ -n "$ASM_PATH" ]]; then
        # ASM_PATH puede ser un archivo (8BP) o directorio (ASM puro)
        if [[ -f "$ASM_PATH" && "$ASM_PATH" == *"make_all_mygame.asm" ]]; then
            is_8bp_project=1
        elif [[ -d "$ASM_PATH" && -f "$ASM_PATH/make_all_mygame.asm" ]]; then
            is_8bp_project=1
        fi
    fi
    
    if [[ $is_8bp_project -eq 1 ]]; then
        if [[ ! "$BUILD_LEVEL" =~ ^[0-4]$ ]]; then
            error "BUILD_LEVEL debe ser 0-4 para proyectos 8BP (actual: $BUILD_LEVEL)"
            ((errors++))
        else
            success "BUILD_LEVEL: $BUILD_LEVEL ($(get_level_description $BUILD_LEVEL))"
        fi
    elif [[ -n "$BUILD_LEVEL" ]]; then
        success "BUILD_LEVEL: $BUILD_LEVEL (opcional para este proyecto)"
    fi
    
    echo ""
    
    # Validar rutas
    step "Validando rutas..."
    
    local has_source=0
    
    if [[ -n "$ASM_PATH" ]]; then
        if [[ -f "$ASM_PATH" ]]; then
            # ASM_PATH es un archivo (proyecto 8BP)
            success "ASM_PATH: $ASM_PATH"
            ((has_source++))
        elif [[ -d "$ASM_PATH" ]]; then
            # ASM_PATH es un directorio (proyecto ASM puro)
            success "ASM_PATH: $ASM_PATH"
            if [[ -f "$ASM_PATH/make_all_mygame.asm" ]]; then
                success "  make_all_mygame.asm encontrado"
            fi
            ((has_source++))
        else
            error "ASM_PATH no existe: $ASM_PATH"
            ((errors++))
        fi
    fi
    
    if [[ -n "$BASIC_PATH" ]]; then
        if [[ -d "$BASIC_PATH" ]]; then
            local bas_count=$(find "$BASIC_PATH" -name "*.bas" 2>/dev/null | wc -l)
            success "BASIC_PATH: $BASIC_PATH ($bas_count archivo(s) .bas)"
            ((has_source++))
        else
            error "BASIC_PATH no existe: $BASIC_PATH"
            ((errors++))
        fi
    fi
    
    if [[ -n "$RAW_PATH" ]]; then
        if [[ -d "$RAW_PATH" ]]; then
            local raw_count=$(find "$RAW_PATH" -type f 2>/dev/null | wc -l)
            success "RAW_PATH: $RAW_PATH ($raw_count archivo(s))"
        else
            error "RAW_PATH no existe: $RAW_PATH"
            ((errors++))
        fi
    fi
    
    if [[ -n "$C_PATH" ]]; then
        if [[ -d "$C_PATH" ]]; then
            success "C_PATH: $C_PATH"
            if [[ -n "$C_SOURCE" && -f "$C_PATH/$C_SOURCE" ]]; then
                success "  $C_SOURCE encontrado"
                ((has_source++))
            else
                warning "  $C_SOURCE no encontrado"
                ((warnings++))
            fi
        else
            error "C_PATH no existe: $C_PATH"
            ((errors++))
        fi
    fi
    
    if [[ $has_source -eq 0 ]]; then
        warning "No hay código fuente configurado (ASM, BASIC o C)"
        ((warnings++))
    fi
    
    echo ""
    
    # Validar herramientas
    step "Validando herramientas..."
    
    if ! check_tool python3 "Python 3"; then
        ((errors++))
    else
        success "Python 3 instalado"
    fi
    
    if [[ -n "$C_PATH" ]]; then
        if ! check_tool sdcc "SDCC"; then
            warning "SDCC no instalado (necesario para compilar C)"
            ((warnings++))
        else
            success "SDCC instalado"
        fi
    fi
    
    echo ""
    
    # Resumen
    header "Resumen de Validación"
    
    if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
        success "Proyecto válido - Sin errores ni advertencias"
    elif [[ $errors -eq 0 ]]; then
        warning "$warnings advertencia(s) encontrada(s)"
    else
        error "$errors error(es) encontrado(s)"
        [[ $warnings -gt 0 ]] && warning "$warnings advertencia(s) encontrada(s)"
    fi
    
    echo ""
    
    [[ $errors -gt 0 ]] && exit 1
    exit 0
}
