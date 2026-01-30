#!/usr/bin/env bash
# ==============================================================================
# screens.sh - Conversión de pantallas de carga PNG a SCN
# ==============================================================================
# shellcheck disable=SC2155

# Cargar utilidades si no están cargadas
if [[ -z "$(type -t register_in_map)" ]]; then
    source "${DEVCPC_LIB:-$(dirname "$0")}/utils.sh"
fi

# Convertir pantallas de carga PNG a formato SCN
convert_screens() {
    # Solo ejecutar si LOADER_SCREEN está definido y no está vacío
    if [[ -z "$LOADER_SCREEN" ]]; then
        return 0
    fi
    
    header "Convertir Pantallas de Carga"
    
    # Validar que existe la ruta de pantallas
    if [[ ! -d "$LOADER_SCREEN" ]]; then
        error "La ruta LOADER_SCREEN no existe: $LOADER_SCREEN"
        return 1
    fi
    
    # Validar que Python3 está disponible
    if ! command -v python3 &> /dev/null; then
        error "Python3 no está instalado o no está en el PATH"
        error "Instala Python3 para usar la conversión de pantallas"
        return 1
    fi
    
    # Validar que existe img.py
    local img_tool="$DEVCPC_TOOLS/abasm/src/img.py"
    if [[ ! -f "$img_tool" ]]; then
        error "No se encuentra img.py en: $img_tool"
        return 1
    fi
    
    # Validar que Pillow está instalado
    if ! python3 -c "import PIL" 2>/dev/null; then
        error "Pillow (PIL) no está instalado"
        error "Instala con: pip3 install Pillow"
        return 1
    fi
    
    # Valores por defecto
    local mode="${MODE:-0}"
    
    # Descripción del modo
    local mode_desc=""
    case "$mode" in
        0) mode_desc="160x200, 16 colores" ;;
        1) mode_desc="320x200, 4 colores" ;;
        2) mode_desc="640x200, 2 colores" ;;
    esac
    
    info "Ruta:  $LOADER_SCREEN"
    info "Modo:  $mode ($mode_desc)"
    echo ""
    
    # Buscar archivos PNG recursivamente
    local png_files=()
    while IFS= read -r -d '' file; do
        png_files+=("$file")
    done < <(find "$LOADER_SCREEN" -type f -iname "*.png" -print0 2>/dev/null)
    
    if [[ ${#png_files[@]} -eq 0 ]]; then
        warning "No se encontraron archivos PNG en: $LOADER_SCREEN"
        return 0
    fi
    
    local converted=0
    local failed=0
    
    # Convertir cada imagen
    for png_file in "${png_files[@]}"; do
        local filename=$(basename "$png_file")
        local name="${filename%.*}"
        local output_file="$OBJ_DIR/${name}.scn"
        
        step "Convirtiendo $filename..."
        
        if python3 "$img_tool" "$png_file" --format scn --mode "$mode" --name "$name" > /dev/null 2>&1; then
            # Mover el archivo generado a obj/
            if [[ -f "${name}.scn" ]]; then
                mv "${name}.scn" "$output_file"
                
                # Mover también el archivo .info si existe
                if [[ -f "${name}.scn.info" ]]; then
                    mv "${name}.scn.info" "$OBJ_DIR/${name}.scn.info"
                fi
                
                local size=$(stat -f%z "$output_file" 2>/dev/null || stat -c%s "$output_file" 2>/dev/null)
                success "${name}.scn generado ($size bytes)"
                
                # Registrar en map.cfg
                register_in_map "${name}.scn" "scn" "0xC000" "0xC000"
                
                ((converted++))
            else
                error "No se generó ${name}.scn"
                ((failed++))
            fi
        else
            error "Error al convertir $filename"
            ((failed++))
        fi
    done
    
    echo ""
    
    if [[ $converted -gt 0 ]]; then
        success "$converted pantalla(s) convertida(s)"
    fi
    
    if [[ $failed -gt 0 ]]; then
        error "$failed pantalla(s) fallaron"
        return 1
    fi
    
    echo ""
    return 0
}

# Añadir pantallas SCN al DSK
add_screens_to_dsk() {
    if [[ -z "$LOADER_SCREEN" || ! -d "$LOADER_SCREEN" ]]; then
        return 0
    fi
    
    # Buscar archivos SCN en obj/
    local scn_files=()
    while IFS= read -r -d '' file; do
        scn_files+=("$file")
    done < <(find "$OBJ_DIR" -type f -iname "*.scn" -print0 2>/dev/null)
    
    if [[ ${#scn_files[@]} -eq 0 ]]; then
        return 0
    fi
    
    step "Añadiendo pantallas al DSK..."
    echo ""
    
    local added=0
    
    for scn_file in "${scn_files[@]}"; do
        local filename=$(basename "$scn_file")
        local name="${filename%.*}"
        
        info "  ${filename}"
        
        # Añadir al DSK con dirección de carga &C000
        if python3 "$DEVCPC_TOOLS/abasm/src/dsk.py" "$DIST_DIR/$DSK" --put-bin "$scn_file" --load-addr 0xC000 --start-addr 0xC000 > /dev/null 2>&1; then
            ((added++))
        else
            error "Error al añadir $filename al DSK"
            return 1
        fi
    done
    
    if [[ $added -gt 0 ]]; then
        success "$added pantalla(s) añadida(s) al DSK"
    fi
    
    echo ""
    return 0
}
