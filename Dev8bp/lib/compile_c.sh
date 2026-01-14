#!/usr/bin/env bash
# ==============================================================================
# compile_c.sh - Compilación de código C con SDCC
# ==============================================================================

compile_c() {
    if [[ -z "$C_PATH" ]]; then
        return 0
    fi
    
    if [[ ! -d "$C_PATH" ]]; then
        return 0
    fi
    
    if [[ -z "$C_SOURCE" ]]; then
        warning "C_PATH definido pero C_SOURCE no especificado"
        return 0
    fi
    
    local c_file="$C_PATH/$C_SOURCE"
    if [[ ! -f "$c_file" ]]; then
        error "Archivo C no encontrado: $c_file"
        return 1
    fi
    
    # Verificar SDCC
    if ! check_tool sdcc "SDCC"; then
        error "SDCC no está instalado"
        error "Instala SDCC: http://sdcc.sourceforge.net/"
        return 1
    fi
    
    # Verificar hex2bin (usar desde dev8bp-cli/tools)
    local os=$(detect_os)
    local arch=$(detect_arch)
    local hex2bin_path="$DEV8BP_CLI_ROOT/tools/hex2bin"
    
    case "$os-$arch" in
        macos-arm64)    hex2bin_path="$hex2bin_path/mac-arm64/hex2bin" ;;
        macos-x86_64)   hex2bin_path="$hex2bin_path/mac-x86_64/hex2bin" ;;
        linux-arm64)    hex2bin_path="$hex2bin_path/linux-arm64/hex2bin" ;;
        linux-x86_64)   hex2bin_path="$hex2bin_path/linux-x86_64/hex2bin" ;;
        windows-x86_64) hex2bin_path="$hex2bin_path/win-x86_64/hex2bin.exe" ;;
        *)
            error "Plataforma no soportada: $os-$arch"
            return 1
            ;;
    esac
    
    if [[ ! -f "$hex2bin_path" ]]; then
        error "hex2bin no encontrado: $hex2bin_path"
        return 1
    fi
    
    header "Compilar C con SDCC"
    
    local basename=$(basename "$C_SOURCE" .c)
    local code_loc="${C_CODE_LOC:-20000}"
    
    info "Archivo:    $C_SOURCE"
    info "Dirección:  $code_loc (0x$(printf '%X' $code_loc))"
    info "SDCC:       $(command -v sdcc)"
    info "hex2bin:    $hex2bin_path"
    echo ""
    
    # Limpiar archivos anteriores
    step "Limpiando archivos anteriores..."
    rm -f "$OBJ_DIR/$basename".* 2>/dev/null || true
    
    # Compilar con SDCC
    step "Compilando con SDCC..."
    
    local compile_output
    if compile_output=$(sdcc -mz80 --code-loc "$code_loc" --data-loc 0 --no-std-crt0 \
        --fomit-frame-pointer --opt-code-size \
        -I"$C_PATH/8BP_wrapper" -I"$C_PATH/mini_BASIC" \
        -o "$OBJ_DIR/" "$c_file" 2>&1); then
        
        # Verificar que se generó el .map
        if [[ ! -f "$OBJ_DIR/$basename.map" ]]; then
            error "Error de compilación: No se generó $basename.map"
            echo "$compile_output"
            return 1
        fi
        
        success "Compilación exitosa"
        echo ""
        
        # Convertir .ihx a .bin
        step "Convirtiendo .ihx a .bin..."
        
        local hex2bin_output
        if hex2bin_output=$("$hex2bin_path" "$OBJ_DIR/$basename.ihx" 2>&1); then
            echo "$hex2bin_output"
            
            # Verificar límites de memoria
            local highest=$(echo "$hex2bin_output" | grep "Highest address" | awk '{print $NF}')
            
            if [[ -n "$highest" ]]; then
                local highest_dec=$(hex_to_dec "$highest")
                
                if [[ $highest_dec -gt 23999 ]]; then
                    echo ""
                    error "Dirección más alta ($highest_dec / 0x$highest) excede 23999 (0x5DBF)"
                    error "Esto destruirá la librería 8BP"
                    echo ""
                    warning "Solución: Usa una dirección de código más baja"
                    echo "  C_CODE_LOC=19000"
                    echo "  Y en BASIC: MEMORY 18999"
                    echo ""
                    return 1
                else
                    success "Límites de memoria OK (highest: $highest_dec / 0x$highest ≤ 23999 / 0x5DBF)"
                fi
            fi
            
            echo ""
            
            # Añadir al DSK
            step "Añadiendo binario al DSK..."
            
            local dsk_tool="$DEV8BP_CLI_ROOT/tools/abasm/src/dsk.py"
            local python_cmd=$(command -v python3 || command -v python)
            local dsk_path="$DIST_DIR/$DSK"
            local code_loc_hex=$(printf "0x%X" $code_loc)
            
            if (cd "$OBJ_DIR" && $python_cmd "$dsk_tool" "$(pwd)/../$dsk_path" --put-bin "$basename.bin" --load-addr "$code_loc_hex" --start-addr "$code_loc_hex" > /dev/null 2>&1); then
                success "Binario C añadido al DSK"
            else
                error "Error al añadir binario al DSK"
                return 1
            fi
            
            # Mostrar información del .map
            echo ""
            info "Información del .map:"
            grep -E "(Lowest address|Highest address|_main)" "$OBJ_DIR/$basename.map" 2>/dev/null || true
            
            echo ""
            info "Uso desde BASIC:"
            echo "  1) Carga o ensambla 8BP con tus gráficos, música, etc."
            echo "  2) Carga tu juego BASIC"
            echo "  3) LOAD \"$basename.BIN\", $code_loc"
            echo "  4) CALL <dirección de _main del .map>"
            echo ""
            
            return 0
        else
            error "Error al convertir .ihx a .bin"
            echo "$hex2bin_output"
            return 1
        fi
    else
        error "Error de compilación SDCC"
        echo "$compile_output"
        return 1
    fi
}
