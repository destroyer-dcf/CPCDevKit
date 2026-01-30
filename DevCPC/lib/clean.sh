#!/usr/bin/env bash
# ==============================================================================
# clean.sh - Limpiar archivos generados
# ==============================================================================

clean_project() {
    if ! is_devcpc_project; then
        error "No estás en un proyecto DevCPC"
        exit 1
    fi
    
    load_config
    
    header "Limpiar Proyecto"
    
    local cleaned=0
    
    # Limpiar obj/
    if [[ -d "$OBJ_DIR" ]]; then
        step "Limpiando $OBJ_DIR/..."
        rm -rf "$OBJ_DIR"
        success "$OBJ_DIR/ eliminado"
        ((cleaned++))
    fi
    
    # Limpiar dist/
    if [[ -d "$DIST_DIR" ]]; then
        step "Limpiando $DIST_DIR/..."
        rm -rf "$DIST_DIR"
        success "$DIST_DIR/ eliminado"
        ((cleaned++))
    fi
    
    # Limpiar backups en ASM/
    if [[ -n "$ASM_PATH" && -d "$ASM_PATH" ]]; then
        local backups=$(find "$ASM_PATH" -name "*.backup*" -o -name "*.bak" -o -name "*.BAK" 2>/dev/null | wc -l)
        if [[ $backups -gt 0 ]]; then
            step "Limpiando backups en $ASM_PATH/..."
            find "$ASM_PATH" -name "*.backup*" -delete 2>/dev/null || true
            find "$ASM_PATH" -name "*.bak" -delete 2>/dev/null || true
            find "$ASM_PATH" -name "*.BAK" -delete 2>/dev/null || true
            success "$backups archivo(s) de backup eliminados"
            ((cleaned++))
        fi
    fi
    
    echo ""
    
    if [[ $cleaned -eq 0 ]]; then
        info "No hay nada que limpiar"
    else
        success "Limpieza completada"
    fi
    
    echo ""
}
