#!/bin/bash

# Script para convertir archivos ASM a UTF-8
# Uso: ./convert_to_utf8.sh <ruta_directorio_ASM>

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ $# -eq 0 ]; then
    echo -e "${RED}Error: Debe proporcionar la ruta al directorio ASM${NC}"
    echo "Uso: $0 <ruta_directorio_ASM>"
    exit 1
fi

ASM_DIR="$1"

if [ ! -d "$ASM_DIR" ]; then
    echo -e "${RED}Error: El directorio '$ASM_DIR' no existe${NC}"
    exit 1
fi

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Convertir archivos ASM a UTF-8${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Directorio:${NC} $ASM_DIR"
echo ""

CONVERTED=0

# Buscar todos los archivos .asm
for FILE in "$ASM_DIR"/*.asm; do
    if [ -f "$FILE" ]; then
        FILENAME=$(basename "$FILE")
        
        # Detectar codificación actual
        ENCODING=$(file -b --mime-encoding "$FILE")
        
        if [ "$ENCODING" != "utf-8" ] && [ "$ENCODING" != "us-ascii" ]; then
            echo -e "${YELLOW}Convirtiendo $FILENAME (${ENCODING} → utf-8)...${NC}"
            
            # Crear backup
            BACKUP="${FILE}.encoding_backup"
            if [ ! -f "$BACKUP" ]; then
                cp "$FILE" "$BACKUP"
            fi
            
            # Convertir a UTF-8
            if command -v iconv &> /dev/null; then
                iconv -f "$ENCODING" -t UTF-8 "$FILE" > "${FILE}.tmp" && mv "${FILE}.tmp" "$FILE"
                echo -e "${GREEN}✓ $FILENAME convertido${NC}"
                CONVERTED=$((CONVERTED + 1))
            else
                echo -e "${RED}Error: iconv no está instalado${NC}"
                exit 1
            fi
        else
            echo -e "• $FILENAME ya está en UTF-8"
        fi
    fi
done

echo ""
echo -e "${GREEN}Total: $CONVERTED archivos convertidos${NC}"
echo ""
