#!/usr/bin/env bash
# ==============================================================================
# Dev8BP CLI - Script de instalación
# Copyright (c) 2026 Destroyer
# ==============================================================================

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Dev8BP CLI - Instalación${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Detectar directorio de instalación
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEV8BP_PATH="$SCRIPT_DIR/Dev8bp"

echo -e "${CYAN}Directorio de instalación:${NC} $SCRIPT_DIR"
echo -e "${CYAN}Dev8BP:${NC} $DEV8BP_PATH"
echo ""

# Verificar que existe Dev8bp/bin/dev8bp
if [[ ! -f "$DEV8BP_PATH/bin/dev8bp" ]]; then
    echo -e "${RED}✗ Error: No se encontró Dev8bp/bin/dev8bp${NC}"
    echo -e "${RED}  Asegúrate de estar en el directorio raíz del proyecto${NC}"
    exit 1
fi

# Hacer ejecutable
chmod +x "$DEV8BP_PATH/bin/dev8bp"
echo -e "${GREEN}✓${NC} Dev8bp/bin/dev8bp configurado como ejecutable"

# Detectar shell
SHELL_NAME=$(basename "$SHELL")
case "$SHELL_NAME" in
    bash)
        SHELL_RC="$HOME/.bashrc"
        ;;
    zsh)
        SHELL_RC="$HOME/.zshrc"
        ;;
    *)
        SHELL_RC="$HOME/.profile"
        ;;
esac

echo ""
echo -e "${CYAN}Shell detectado:${NC} $SHELL_NAME"
echo -e "${CYAN}Archivo de configuración:${NC} $SHELL_RC"
echo ""

# Verificar si ya está configurado
if grep -q "DEV8BP_PATH" "$SHELL_RC" 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC} Dev8BP CLI ya está configurado en $SHELL_RC"
    echo ""
    read -p "¿Quieres reconfigurar? [s/N]: " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
        echo -e "${YELLOW}⚠${NC} Configuración no modificada"
        exit 0
    fi
    
    # Eliminar configuración anterior
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' '/# Dev8BP CLI/d' "$SHELL_RC"
        sed -i '' '/DEV8BP_PATH/d' "$SHELL_RC"
        sed -i '' '/dev8bp/d' "$SHELL_RC"
    else
        sed -i '/# Dev8BP CLI/d' "$SHELL_RC"
        sed -i '/DEV8BP_PATH/d' "$SHELL_RC"
        sed -i '/dev8bp/d' "$SHELL_RC"
    fi
fi

# Añadir configuración
echo "" >> "$SHELL_RC"
echo "# Dev8BP CLI" >> "$SHELL_RC"
echo "export DEV8BP_PATH=\"$DEV8BP_PATH\"" >> "$SHELL_RC"
echo "export PATH=\"\$PATH:\$DEV8BP_PATH/bin\"" >> "$SHELL_RC"

echo -e "${GREEN}✓${NC} Configuración añadida a $SHELL_RC"
echo ""
echo -e "${YELLOW}Importante:${NC} Ejecuta uno de estos comandos para aplicar los cambios:"
echo ""
echo -e "  ${CYAN}source $SHELL_RC${NC}"
echo -e "  ${CYAN}exec $SHELL_NAME${NC}"
echo ""
echo "O simplemente abre una nueva terminal"

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Verificación de Herramientas${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Verificar Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    echo -e "${GREEN}✓${NC} Python 3 instalado: $PYTHON_VERSION"
else
    echo -e "${RED}✗${NC} Python 3 no encontrado"
    echo -e "${YELLOW}  Instala Python 3 para usar Dev8BP CLI${NC}"
fi

# Verificar SDCC (opcional)
if command -v sdcc &> /dev/null; then
    SDCC_VERSION=$(sdcc --version 2>&1 | head -1 | awk '{print $3}')
    echo -e "${GREEN}✓${NC} SDCC instalado: $SDCC_VERSION (opcional para C)"
else
    echo -e "${YELLOW}⚠${NC} SDCC no instalado (opcional, solo para compilar C)"
fi

# Verificar herramientas incluidas
echo ""
echo -e "${CYAN}Herramientas incluidas:${NC}"
if [[ -f "$DEV8BP_PATH/tools/abasm/src/abasm.py" ]]; then
    echo -e "${GREEN}✓${NC} ABASM (ensamblador Z80)"
else
    echo -e "${RED}✗${NC} ABASM no encontrado"
fi

if [[ -f "$DEV8BP_PATH/tools/abasm/src/dsk.py" ]]; then
    echo -e "${GREEN}✓${NC} dsk.py (gestión de DSK)"
else
    echo -e "${RED}✗${NC} dsk.py no encontrado"
fi

if [[ -d "$DEV8BP_PATH/tools/hex2bin" ]]; then
    echo -e "${GREEN}✓${NC} hex2bin (conversión para C)"
else
    echo -e "${RED}✗${NC} hex2bin no encontrado"
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  Instalación Completada${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

echo -e "${CYAN}Próximos pasos:${NC}"
echo ""
echo "  1. Recarga tu shell:"
echo -e "     ${CYAN}source $SHELL_RC${NC}"
echo ""
echo "  2. Verifica la instalación:"
echo -e "     ${CYAN}dev8bp version${NC}"
echo ""
echo "  3. Crea un nuevo proyecto:"
echo -e "     ${CYAN}dev8bp new mi-juego${NC}"
echo ""
echo "  4. Compila tu proyecto:"
echo -e "     ${CYAN}cd mi-juego${NC}"
echo -e "     ${CYAN}dev8bp build${NC}"
echo ""
echo "  5. Para más ayuda:"
echo -e "     ${CYAN}dev8bp help${NC}"
echo ""

echo -e "${GREEN}¡Listo para crear juegos para Amstrad CPC! 🎮${NC}"
echo ""
