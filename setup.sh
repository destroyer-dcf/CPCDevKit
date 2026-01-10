#!/usr/bin/env bash
# ==============================================================================
#  Dev8BP - Copyright (c) 2026 Destroyer
# ==============================================================================
# MIT License
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# ==============================================================================

# Este script configura la variable de entorno DEV8BP_PATH para bash y zsh


set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Obtener el directorio absoluto donde está este script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# DEV8BP_PATH debe apuntar a la carpeta Dev8bp
DEV8BP_DIR="$SCRIPT_DIR/Dev8bp"

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}  📦 Dev8BP - Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""
echo -e "${CYAN}Directorio Dev8BP:${NC} $DEV8BP_DIR"
echo ""

# Verificar que existe la carpeta Dev8bp
if [ ! -d "$DEV8BP_DIR" ]; then
    echo -e "${RED}✗ Error: No se encuentra la carpeta Dev8bp en $SCRIPT_DIR${NC}"
    exit 1
fi

# Variable de entorno a configurar
ENV_VAR="export DEV8BP_PATH=\"$DEV8BP_DIR\""

# Función para añadir variable a un archivo de configuración
add_to_config() {
    local config_file="$1"
    local shell_name="$2"
    
    if [ -f "$config_file" ]; then
        # Verificar si ya existe la variable
        if grep -q "DEV8BP_PATH" "$config_file"; then
            echo -e "${YELLOW}✓ DEV8BP_PATH ya existe en $shell_name ($config_file)${NC}"
            return 0
        else
            # Añadir la variable al final del archivo
            echo "" >> "$config_file"
            echo "# Dev8BP - Added by setup.sh" >> "$config_file"
            echo "$ENV_VAR" >> "$config_file"
            echo -e "${GREEN}✓ DEV8BP_PATH añadida a $shell_name ($config_file)${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠ Archivo $config_file no existe, creándolo...${NC}"
        echo "# Dev8BP - Added by setup.sh" > "$config_file"
        echo "$ENV_VAR" >> "$config_file"
        echo -e "${GREEN}✓ DEV8BP_PATH añadida a $shell_name ($config_file)${NC}"
        return 1
    fi
}

# Configurar para bash
BASH_UPDATED=0
if add_to_config "$HOME/.bashrc" "bash"; then
    BASH_UPDATED=0
else
    BASH_UPDATED=1
fi

# Configurar para zsh
ZSH_UPDATED=0
if add_to_config "$HOME/.zshrc" "zsh"; then
    ZSH_UPDATED=0
else
    ZSH_UPDATED=1
fi

echo ""
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}  ⚙️  Configuración completada${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo ""

# Mostrar instrucciones
if [ $BASH_UPDATED -eq 1 ] || [ $ZSH_UPDATED -eq 1 ]; then
    echo -e "${CYAN}Para aplicar los cambios:${NC}"
    echo ""
    if [ $BASH_UPDATED -eq 1 ]; then
        echo -e "  ${YELLOW}Bash:${NC}  source ~/.bashrc"
    fi
    if [ $ZSH_UPDATED -eq 1 ]; then
        echo -e "  ${YELLOW}Zsh:${NC}   source ~/.zshrc"
    fi
    echo ""
    echo -e "${CYAN}O simplemente abre una nueva terminal${NC}"
    echo ""
fi

echo -e "${CYAN}Verificar instalación:${NC}"
echo -e "  echo \$DEV8BP_PATH"
echo ""
echo -e "${CYAN}Uso:${NC}"
echo -e "  cd tu_proyecto"
echo -e "  make"
echo ""
