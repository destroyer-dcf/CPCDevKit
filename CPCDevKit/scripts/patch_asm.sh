#!/bin/bash

# Script para parchear archivos ASM para compatibilidad con ABASM
# Uso: ./patch_asm.sh <ruta_directorio_ASM>

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
    echo -e "${BLUE}  Patch ASM para ABASM${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
    echo "Uso: $0 <ruta_directorio_ASM>"
    echo ""
    echo "Ejemplo:"
    echo "  $0 ./8BP_V43/ASM"
    echo ""
    exit 1
}

# Verificar argumentos
if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Debe proporcionar la ruta al directorio ASM${NC}"
    echo ""
    show_usage
fi

ASM_DIR="$1"

# Verificar que el directorio existe
if [ ! -d "$ASM_DIR" ]; then
    echo -e "${RED}Error: El directorio '$ASM_DIR' no existe${NC}"
    exit 1
fi

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  BUILD8BP - Patch${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Directorio ASM:${NC} $ASM_DIR"
echo ""

TOTAL_CHANGES=0
FILES_PROCESSED=0

# Procesar todos los archivos .asm en el directorio
for FILE_PATH in "$ASM_DIR"/*.asm; do
    # Verificar que el patrón encontró archivos
    if [ ! -f "$FILE_PATH" ]; then
        echo -e "${YELLOW}No se encontraron archivos .asm en el directorio${NC}"
        exit 0
    fi
    
    FILENAME=$(basename "$FILE_PATH")
    
    # Saltar archivos de backup
    if [[ "$FILENAME" == *.backup ]] || [[ "$FILENAME" == *.bak ]] || [[ "$FILENAME" == *.BAK ]]; then
        continue
    fi
    
    FILES_PROCESSED=$((FILES_PROCESSED + 1))
    
    # Crear backup si no existe
    BACKUP_PATH="${FILE_PATH}.backup"
    if [ ! -f "$BACKUP_PATH" ]; then
        cp "$FILE_PATH" "$BACKUP_PATH"
    fi
    
    # Crear archivo temporal desde el archivo actual (no el backup)
    TEMP_FILE=$(mktemp)
    cp "$FILE_PATH" "$TEMP_FILE"
    
    FILE_CHANGES=0
    
    # Contar patrones en el archivo ACTUAL antes de modificar
    # 1. and a, → and 
    COUNT=$(grep -c 'and a,' "$FILE_PATH" 2>/dev/null || echo "0")
    COUNT=$(echo "$COUNT" | tr -d '\n\r ')
    if [ "$COUNT" -gt 0 ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/and a,/and /g' "$TEMP_FILE"
        else
            sed -i 's/and a,/and /g' "$TEMP_FILE"
        fi
        FILE_CHANGES=$((FILE_CHANGES + COUNT))
    fi
    
    # 2. or a, → or 
    COUNT=$(grep -c 'or a,' "$FILE_PATH" 2>/dev/null || echo "0")
    COUNT=$(echo "$COUNT" | tr -d '\n\r ')
    if [ "$COUNT" -gt 0 ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/or a,/or /g' "$TEMP_FILE"
        else
            sed -i 's/or a,/or /g' "$TEMP_FILE"
        fi
        FILE_CHANGES=$((FILE_CHANGES + COUNT))
    fi
    
    # 3. xor a, → xor 
    COUNT=$(grep -c 'xor a,' "$FILE_PATH" 2>/dev/null || echo "0")
    COUNT=$(echo "$COUNT" | tr -d '\n\r ')
    if [ "$COUNT" -gt 0 ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/xor a,/xor /g' "$TEMP_FILE"
        else
            sed -i 's/xor a,/xor /g' "$TEMP_FILE"
        fi
        FILE_CHANGES=$((FILE_CHANGES + COUNT))
    fi
    
    # 4. djnz, → djnz  (con o sin espacio después de la coma)
    COUNT=$(grep -c 'djnz,' "$FILE_PATH" 2>/dev/null || echo "0")
    COUNT=$(echo "$COUNT" | tr -d '\n\r ')
    if [ "$COUNT" -gt 0 ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' 's/djnz,[[:space:]]*/djnz /g' "$TEMP_FILE"
        else
            sed -i 's/djnz,[[:space:]]*/djnz /g' "$TEMP_FILE"
        fi
        FILE_CHANGES=$((FILE_CHANGES + COUNT))
    fi
    
    # 5. ifnot X = Y → if X != Y
    COUNT=$(grep -c 'ifnot' "$FILE_PATH" 2>/dev/null || echo "0")
    COUNT=$(echo "$COUNT" | tr -d '\n\r ')
    if [ "$COUNT" -gt 0 ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' -E 's/ifnot[[:space:]]+([^[:space:]]+)[[:space:]]*=[[:space:]]*([^[:space:]]+)/if \1 != \2/g' "$TEMP_FILE"
        else
            sed -i -E 's/ifnot[[:space:]]+([^[:space:]]+)[[:space:]]*=[[:space:]]*([^[:space:]]+)/if \1 != \2/g' "$TEMP_FILE"
        fi
        FILE_CHANGES=$((FILE_CHANGES + COUNT))
    fi
    
    # Si hubo cambios, copiar el archivo temporal sobre el original
    if [ $FILE_CHANGES -gt 0 ]; then
        mv "$TEMP_FILE" "$FILE_PATH"
        TOTAL_CHANGES=$((TOTAL_CHANGES + FILE_CHANGES))
        echo -e "${GREEN}✓ $FILENAME: $FILE_CHANGES correcciones${NC}"
    else
        rm "$TEMP_FILE"
        echo -e "• $FILENAME: Sin cambios"
    fi
    
    # Parche especial para make_all_mygame.asm
    if [[ "$FILENAME" == "make_all_mygame.asm" ]]; then
        # Verificar si ya tiene las directivas SAVE condicionales
        if ! grep -q "if ASSEMBLING_OPTION = 0" "$FILE_PATH" 2>/dev/null; then
            # Buscar la línea SAVE existente y reemplazarla con las condicionales
            if grep -q "^SAVE " "$FILE_PATH" 2>/dev/null; then
                # Crear archivo temporal para el parche
                TEMP_SAVE=$(mktemp)
                
                # Reemplazar la línea SAVE con las condicionales
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed '/^SAVE /c\
if ASSEMBLING_OPTION = 0\
SAVE "8BP0.bin", 23600, 18559\
elseif ASSEMBLING_OPTION = 1\
SAVE "8BP1.bin", 25000, 17619\
elseif ASSEMBLING_OPTION = 2\
SAVE "8BP2.bin", 24800, 17819\
elseif ASSEMBLING_OPTION = 3\
SAVE "8BP3.bin", 24000, 18619\
elseif ASSEMBLING_OPTION = 4\
SAVE "8BP4.bin", 25500, 17119\
endif' "$FILE_PATH" > "$TEMP_SAVE"
                else
                    sed '/^SAVE /c\
if ASSEMBLING_OPTION = 0\
SAVE "8BP0.bin", 23600, 18559\
elseif ASSEMBLING_OPTION = 1\
SAVE "8BP1.bin", 25000, 17619\
elseif ASSEMBLING_OPTION = 2\
SAVE "8BP2.bin", 24800, 17819\
elseif ASSEMBLING_OPTION = 3\
SAVE "8BP3.bin", 24000, 18619\
elseif ASSEMBLING_OPTION = 4\
SAVE "8BP4.bin", 25500, 17119\
endif' "$FILE_PATH" > "$TEMP_SAVE"
                fi
                
                mv "$TEMP_SAVE" "$FILE_PATH"
                echo -e "${CYAN}  → Añadidas directivas SAVE condicionales${NC}"
                TOTAL_CHANGES=$((TOTAL_CHANGES + 1))
            fi
        fi
    fi
done

echo ""
echo -e "${GREEN}Archivos procesados: $FILES_PROCESSED${NC}"
echo -e "${GREEN}Total: $TOTAL_CHANGES correcciones aplicadas${NC}"
echo ""
