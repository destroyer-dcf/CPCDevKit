#!/bin/bash

# Script para compilar proyectos 8BP con ABASM
# Uso: ./compile_asm.sh <nivel_build> <ruta_directorio_ASM> [ruta_abasm.py]

set -e

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para mostrar uso
show_usage() {
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  BUILD8BP - Compile${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
    echo "Uso: $0 <nivel_build> <ruta_directorio_ASM> [ruta_abasm.py]"
    echo ""
    echo "Niveles de build:"
    echo "  0 = Todas las funcionalidades"
    echo "  1 = Juegos de laberintos"
    echo "  2 = Juegos con scroll"
    echo "  3 = Juegos pseudo-3D"
    echo "  4 = Sin scroll/layout (+500 bytes)"
    echo ""
    echo "Ejemplos:"
    echo "  $0 0 ./8BP_V43/ASM"
    echo "  $0 1 ./8BP_V43/ASM ./abasm/src/abasm.py"
    echo ""
    echo "Variables de entorno (opcional):"
    echo "  BP8_ASM_PATH  - Ruta al directorio ASM"
    echo "  ABASM_PATH    - Ruta a abasm.py"
    echo ""
    exit 1
}

# Verificar argumentos
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Se requieren al menos 2 argumentos${NC}"
    echo ""
    show_usage
fi

BUILD_LEVEL="$1"
ASM_DIR="$2"
ABASM_PATH="${3:-${ABASM_PATH:-./abasm/src/abasm.py}}"

# Convertir a rutas absolutas
ASM_DIR=$(cd "$ASM_DIR" && pwd)
ABASM_PATH=$(cd "$(dirname "$ABASM_PATH")" && pwd)/$(basename "$ABASM_PATH")

# Validar nivel de build
if ! [[ "$BUILD_LEVEL" =~ ^[0-4]$ ]]; then
    echo -e "${RED}Error: Nivel de build debe ser 0, 1, 2, 3 o 4${NC}"
    exit 1
fi

# Verificar que el directorio ASM existe
if [ ! -d "$ASM_DIR" ]; then
    echo -e "${RED}Error: El directorio '$ASM_DIR' no existe${NC}"
    exit 1
fi

# Verificar que abasm.py existe
if [ ! -f "$ABASM_PATH" ]; then
    echo -e "${RED}Error: No existe el archivo '$ABASM_PATH'${NC}"
    echo -e "${YELLOW}Sugerencia: Especifica la ruta a abasm.py como tercer argumento${NC}"
    exit 1
fi

# Información de cada build
case $BUILD_LEVEL in
    0)
        DESC="Todas las funcionalidades"
        MEMORY="MEMORY 23600"
        COMMANDS="|LAYOUT, |COLAY, |MAP2SP, |UMA, |3D"
        ;;
    1)
        DESC="Juegos de laberintos"
        MEMORY="MEMORY 25000"
        COMMANDS="|LAYOUT, |COLAY"
        ;;
    2)
        DESC="Juegos con scroll"
        MEMORY="MEMORY 24800"
        COMMANDS="|MAP2SP, |UMA"
        ;;
    3)
        DESC="Juegos pseudo-3D"
        MEMORY="MEMORY 24000"
        COMMANDS="|3D"
        ;;
    4)
        DESC="Sin scroll/layout (+500 bytes)"
        MEMORY="MEMORY 25500"
        COMMANDS="Básicos"
        ;;
esac

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  BUILD8BP - Build $BUILD_LEVEL${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Descripción:${NC}     $DESC"
echo -e "${CYAN}Memoria BASIC:${NC}   $MEMORY"
echo -e "${CYAN}Comandos:${NC}        $COMMANDS"
echo -e "${CYAN}Directorio ASM:${NC}  $ASM_DIR"
echo -e "${CYAN}ABASM:${NC}           $ABASM_PATH"
echo ""

# Configurar ASSEMBLING_OPTION
echo -e "${YELLOW}Configurando ASSEMBLING_OPTION = $BUILD_LEVEL...${NC}"

# Generar archivo maestro build_8bp.asm
BUILD_FILE="$ASM_DIR/build_8bp.asm"

cat > "$BUILD_FILE" << EOF
let ASSEMBLING_OPTION = $BUILD_LEVEL

read "make_codigo_mygame.asm"
read "make_musica_mygame.asm"
read "make_graficos_mygame.asm"

if ASSEMBLING_OPTION = 0
SAVE "8BP0.bin", 23600, 18559
elseif ASSEMBLING_OPTION = 1
SAVE "8BP1.bin", 25000, 17619
elseif ASSEMBLING_OPTION = 2
SAVE "8BP2.bin", 24800, 17819
elseif ASSEMBLING_OPTION = 3
SAVE "8BP3.bin", 24000, 18619
elseif ASSEMBLING_OPTION = 4
SAVE "8BP4.bin", 25500, 17119
endif
EOF

echo -e "${CYAN}Archivo maestro:${NC}     $(basename $BUILD_FILE)"

# Crear carpeta dist
DIST_DIR="$ASM_DIR/dist"
mkdir -p "$DIST_DIR"
echo -e "${CYAN}Carpeta de salida:${NC}   $DIST_DIR"

# Compilar con ABASM
echo -e "${YELLOW}Compilando con ABASM...${NC}"
echo ""

# Detectar Python (python3 o python)
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo -e "${RED}Error: No se encontró Python en el sistema${NC}"
    exit 1
fi

# Ejecutar ABASM
cd "$ASM_DIR"

# ABASM compilará el archivo maestro generado
if $PYTHON_CMD "$ABASM_PATH" "$BUILD_FILE" --tolerance 2; then
    
    # ABASM genera 8BPX.bin según el nivel configurado
    BIN_FILE="$ASM_DIR/8BP${BUILD_LEVEL}.bin"
    
    # Verificar que el binario con el nivel existe
    if [ -f "$BIN_FILE" ]; then
        # Copiar (no mover) a dist para preservar el original temporalmente
        DIST_BIN="$DIST_DIR/8BP${BUILD_LEVEL}.bin"
        cp "$BIN_FILE" "$DIST_BIN"
        
        # Mover también el binario completo build_8bp.bin a dist
        BUILD_BIN="$ASM_DIR/build_8bp.bin"
        if [ -f "$BUILD_BIN" ]; then
            mv "$BUILD_BIN" "$DIST_DIR/"
        fi
        
        # Mover archivos auxiliares (.lst, .map) pero NO otros .bin
        for ext in lst map; do
            for file in "$ASM_DIR"/*.$ext; do
                if [ -f "$file" ]; then
                    mv "$file" "$DIST_DIR/" 2>/dev/null || true
                fi
            done
        done
        
        # Limpiar binarios temporales del ASM_DIR (excepto el que acabamos de copiar)
        rm -f "$ASM_DIR"/*.bin
        
        # Obtener tamaño del archivo
        SIZE=$(stat -f%z "$DIST_BIN" 2>/dev/null || stat -c%s "$DIST_BIN" 2>/dev/null)
        SIZE_FORMATTED=$(printf "%'d" $SIZE 2>/dev/null || echo $SIZE)
        
        echo ""
        echo -e "${GREEN}✓ Compilación exitosa!${NC}"
        echo -e "${GREEN}  Archivo:    8BP${BUILD_LEVEL}.bin${NC}"
        echo -e "${GREEN}  Ubicación:  $DIST_BIN${NC}"
        echo -e "${GREEN}  Tamaño:     $SIZE_FORMATTED bytes${NC}"
        echo ""
        echo -e "${CYAN}Uso desde BASIC:${NC}"
        echo -e "  $MEMORY"
        echo -e "  LOAD\"8BP${BUILD_LEVEL}.bin\""
        echo -e "  CALL &6B78"
        echo ""
    else
        echo -e "${YELLOW}Advertencia: No se encontró el binario 8BP${BUILD_LEVEL}.bin${NC}"
    fi
    
else
    echo ""
    echo -e "${RED}✗ Error en la compilación${NC}"
    echo ""
    echo -e "${CYAN}Sugerencia:${NC}"
    echo -e "  Si ves errores de sintaxis (and a,, djnz,, ifnot), ejecuta primero:"
    echo -e "  ${GREEN}./patch_asm.sh \"$ASM_DIR\"${NC}"
    echo ""
    exit 1
fi
