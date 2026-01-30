#!/usr/bin/env bash
# ==============================================================================
# run.sh - Ejecutar en emulador
# ==============================================================================
#
# FUNCIONALIDADES:
# ----------------
# 1. Ejecutar proyectos DevCPC en RetroVirtualMachine
# 2. Soporte para DSK (disco) y CDT (cinta)
# 3. Auto-detección inteligente según configuración
# 4. Override por línea de comandos
#
# CONFIGURACIÓN EN devcpc.conf:
# ------------------------------
# RVM_PATH="/path/to/RetroVirtualMachine"  # Ruta al emulador
# CPC_MODEL=6128                           # Modelo CPC (464/664/6128)
# RUN_FILE="loader.bas"                    # Archivo DSK a auto-ejecutar
# RUN_MODE="auto"                          # Modo: auto/dsk/cdt
#
# MODOS DE EJECUCIÓN:
# -------------------
# auto: Detecta automáticamente
#       - Si CDT existe y CDT_FILES configurado → usa CDT
#       - Sino → usa DSK
# dsk:  Siempre usa DSK (disco)
# cdt:  Siempre usa CDT (cinta)
#
# USO:
# ----
# devcpc run                    # Usa RUN_MODE (por defecto: auto)
# devcpc run --dsk              # Fuerza DSK (ignora RUN_MODE)
# devcpc run --cdt              # Fuerza CDT (ignora RUN_MODE)
#
# COMPORTAMIENTO:
# ---------------
# DSK: Monta disco y ejecuta RUN_FILE si está definido
#      Comando RVM: -b cpc464 -i disk.dsk -c 'run"FILE\n'
#
# CDT: Monta cinta, auto-reproduce y ejecuta RUN"
#      - CPC 464:      -b cpc464 -i tape.cdt -c 'run"\n' -p
#      - CPC 664/6128: -b cpc6128 -i tape.cdt -c '|tape\nrun"\n' -p
#      La opción -p (play) auto-reproduce la cinta
#      En modelos con disco (664/6128) se usa |TAPE para cambiar a cinta
#
# ==============================================================================

run_project() {
    if ! is_devcpc_project; then
        error "No estás en un proyecto DevCPC"
        exit 1
    fi
    
    load_config
    
    # Parsear argumentos
    local force_mode=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dsk)
                force_mode="dsk"
                shift
                ;;
            --cdt)
                force_mode="cdt"
                shift
                ;;
            *)
                warning "Argumento desconocido: $1"
                shift
                ;;
        esac
    done
    
    if [[ -z "$RVM_PATH" ]]; then
        error "RVM_PATH no está configurado en devcpc.conf"
        echo ""
        info "Configura el emulador en devcpc.conf:"
        echo '  RVM_PATH="/ruta/a/RetroVirtualMachine"'
        echo '  CPC_MODEL=464'
        echo '  RUN_FILE="8BP0.BIN"'
        echo '  RUN_MODE="auto"  # o "dsk" o "cdt"'
        echo ""
        exit 1
    fi
    
    if [[ ! -f "$RVM_PATH" ]]; then
        error "RetroVirtualMachine no encontrado en: $RVM_PATH"
        exit 1
    fi
    
    # Determinar modo de ejecución
    local run_mode="${force_mode:-${RUN_MODE:-auto}}"
    local media_path=""
    local media_type=""
    
    # Resolver modo auto
    if [[ "$run_mode" == "auto" ]]; then
        # Si CDT existe y está configurado, usar CDT
        if [[ -n "$CDT" && -n "$CDT_FILES" && -f "$DIST_DIR/$CDT" ]]; then
            run_mode="cdt"
        else
            run_mode="dsk"
        fi
    fi
    
    # Validar y configurar según el modo
    case "$run_mode" in
        dsk)
            local dsk_path="$DIST_DIR/$DSK"
            if [[ ! -f "$dsk_path" ]]; then
                error "DSK no encontrado: $dsk_path"
                info "Ejecuta 'devcpc build' primero"
                exit 1
            fi
            media_path="$dsk_path"
            media_type="DSK"
            ;;
        cdt)
            local cdt_path="$DIST_DIR/$CDT"
            if [[ ! -f "$cdt_path" ]]; then
                error "CDT no encontrado: $cdt_path"
                info "Configura CDT y CDT_FILES en devcpc.conf"
                info "O usa 'devcpc run --dsk' para forzar DSK"
                exit 1
            fi
            media_path="$cdt_path"
            media_type="CDT"
            ;;
        *)
            error "RUN_MODE inválido: $run_mode"
            info "Valores permitidos: auto, dsk, cdt"
            exit 1
            ;;
    esac
    
    header "Ejecutar en RetroVirtualMachine"
    
    info "Emulador: $RVM_PATH"
    info "Modelo:   ${CPC_MODEL:-464}"
    info "Modo:     $run_mode (${media_type})"
    info "Archivo:  $media_path"
    [[ -n "$RUN_FILE" && "$media_type" == "DSK" ]] && info "Ejecutar: $RUN_FILE"
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
    
    # Construir argumentos según el tipo de media
    local cmd_args=(-b="cpc${CPC_MODEL:-464}")
    
    if [[ "$media_type" == "CDT" ]]; then
        # Para CDT: -i (insert tape) + -p (auto play) + -c comando
        cmd_args+=(-i "$(pwd)/$media_path")
        
        # En 664/6128 (con disco), usar |TAPE antes de RUN"
        local cpc_model="${CPC_MODEL:-464}"
        if [[ "$cpc_model" == "664" || "$cpc_model" == "6128" ]]; then
            cmd_args+=(-c="|tape\nrun\"\n")
        else
            cmd_args+=(-c="run\"\n")
        fi
        
        cmd_args+=(-p)  # Auto-play tape
    else
        # Para DSK: -i (insert disk) + -c run"FILE
        cmd_args+=(-i "$(pwd)/$media_path")
        if [[ -n "$RUN_FILE" ]]; then
            cmd_args+=(-c="run\"$RUN_FILE\n")
        fi
    fi
    
    if [[ "$(detect_os)" == "macos" ]]; then
        # En macOS, usar open con el bundle .app para GUI
        # Extraer la ruta del .app desde el ejecutable
        local app_path="$RVM_PATH"
        if [[ "$app_path" == *"/Contents/MacOS/"* ]]; then
            app_path="${app_path%.app*}.app"
        fi
        open -a "$app_path" --args "${cmd_args[@]}" > /dev/null 2>&1 &
    else
        nohup "$RVM_PATH" "${cmd_args[@]}" > /dev/null 2>&1 &
        disown
    fi
    
    sleep 1
    success "RetroVirtualMachine iniciado"
    echo ""
}
