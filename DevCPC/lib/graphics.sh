#!/usr/bin/env bash
# ==============================================================================
# graphics.sh - Conversión de gráficos PNG a ASM
# ==============================================================================

# Convertir sprites PNG a ASM usando png2asm.py
convert_sprites() {
    # Solo ejecutar si SPRITES_PATH está definido y no está vacío
    if [[ -z "$SPRITES_PATH" ]]; then
        return 0
    fi
    
    header "Convertir Sprites"
    
    # Validar que existe la ruta de sprites
    if [[ ! -d "$SPRITES_PATH" ]]; then
        error "La ruta SPRITES_PATH no existe: $SPRITES_PATH"
        return 1
    fi
    
    # Validar que Python3 está disponible
    if ! command -v python3 &> /dev/null; then
        error "Python3 no está instalado o no está en el PATH"
        error "Instala Python3 para usar la conversión de sprites"
        return 1
    fi
    
    # Validar que existe png2asm.py
    local png2asm_tool="$DEVCPC_TOOLS/8bp-graphics-converter/png2asm.py"
    if [[ ! -f "$png2asm_tool" ]]; then
        error "No se encuentra png2asm.py en: $png2asm_tool"
        return 1
    fi
    
    # Validar que Pillow está instalado
    if ! python3 -c "import PIL" 2>/dev/null; then
        error "Pillow (PIL) no está instalado"
        error "Instala con: pip3 install Pillow o pipx install Pillow"
        return 1
    fi
    
    # Valores por defecto
    local mode="${MODE:-0}"
    local sprites_out_file="${SPRITES_OUT_FILE:-sprites.asm}"
    local tolerance="${SPRITES_TOLERANCE:-8}"
    
    # Extraer directorio y nombre de archivo
    local out_dir=$(dirname "$sprites_out_file")
    local out_file=$(basename "$sprites_out_file")
    
    # Crear directorio de salida si no existe
    if [[ "$out_dir" != "." ]]; then
        mkdir -p "$out_dir"
    fi
    
    info "Ruta sprites:    $SPRITES_PATH"
    info "Modo CPC:        $mode"
    info "Archivo salida:  $sprites_out_file"
    info "Tolerancia RGB:  $tolerance"
    [[ -n "$SPRITES_TRANSPARENT_INK" ]] && info "Transparent INK: $SPRITES_TRANSPARENT_INK"
    echo ""
    
    # Construir comando
    local cmd="python3 \"$png2asm_tool\" --mode $mode --dir \"$SPRITES_PATH\" --out-dir \"$out_dir\" -o \"$out_file\" --tol $tolerance --recursive"
    
    # Añadir transparent-ink si está definido
    if [[ -n "$SPRITES_TRANSPARENT_INK" ]]; then
        cmd="$cmd --transparent-ink $SPRITES_TRANSPARENT_INK"
    fi
    
    # Ejecutar conversión
    info "Ejecutando png2asm.py..."
    echo ""
    
    if eval $cmd; then
        echo ""
        success "Sprites convertidos exitosamente"
        echo ""
        return 0
    else
        echo ""
        error "Error al convertir sprites"
        return 1
    fi
}
