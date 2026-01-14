#!/usr/bin/env bash
# ==============================================================================
# run.sh - Ejecutar en emulador
# ==============================================================================

run_project() {
    if ! is_dev8bp_project; then
        error "No estás en un proyecto Dev8BP"
        exit 1
    fi
    
    load_config
    
    if [[ -z "$RVM_PATH" ]]; then
        error "RVM_PATH no está configurado en dev8bp.conf"
        echo ""
        info "Configura el emulador en dev8bp.conf:"
        echo '  RVM_PATH="/ruta/a/RetroVirtualMachine"'
        echo '  CPC_MODEL=464'
        echo '  RUN_FILE="8BP0.BIN"'
        echo ""
        exit 1
    fi
    
    if [[ ! -f "$RVM_PATH" ]]; then
        error "RetroVirtualMachine no encontrado en: $RVM_PATH"
        exit 1
    fi
    
    local dsk_path="$DIST_DIR/$DSK"
    if [[ ! -f "$dsk_path" ]]; then
        error "DSK no encontrado: $dsk_path"
        info "Ejecuta 'dev8bp build' primero"
        exit 1
    fi
    
    header "Ejecutar en RetroVirtualMachine"
    
    info "Emulador: $RVM_PATH"
    info "Modelo:   ${CPC_MODEL:-464}"
    info "DSK:      $dsk_path"
    [[ -n "$RUN_FILE" ]] && info "Ejecutar: $RUN_FILE"
    echo ""
    
    # Matar procesos existentes
    local rvm_name=$(basename "$RVM_PATH")
    if pgrep -f "$rvm_name" > /dev/null 2>&1; then
        warning "Cerrando sesión anterior de RetroVirtualMachine..."
        pkill -9 -f "$rvm_name"
        sleep 1
    fi
    
    # Ejecutar
    step "Iniciando emulador..."
    
    local cmd_args=(-b="cpc${CPC_MODEL:-464}" -i "$(pwd)/$dsk_path")
    
    if [[ -n "$RUN_FILE" ]]; then
        cmd_args+=(-c="run\"$RUN_FILE\n")
    fi
    
    if [[ "$(detect_os)" == "macos" ]]; then
        open -a "$RVM_PATH" --args "${cmd_args[@]}" &
    else
        "$RVM_PATH" "${cmd_args[@]}" &
    fi
    
    sleep 1
    success "RetroVirtualMachine iniciado"
    echo ""
}
