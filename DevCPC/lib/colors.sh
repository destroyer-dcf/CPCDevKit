#!/usr/bin/env bash
# ==============================================================================
# colors.sh - Colores y formato para output
# ==============================================================================

# Colores
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export CYAN='\033[0;36m'
export MAGENTA='\033[0;35m'
export WHITE='\033[1;37m'
export NC='\033[0m' # No Color

# Símbolos
export CHECK="${GREEN}✓${NC}"
export CROSS="${RED}✗${NC}"
export ARROW="${CYAN}→${NC}"
export WARN="${YELLOW}⚠${NC}"
export INFO="${BLUE}ℹ${NC}"

# Funciones de output
success() {
    echo -e "${CHECK} ${GREEN}$*${NC}"
}

error() {
    echo -e "\n${CROSS} ${RED}$*${NC}" >&2
}

warning() {
    echo -e "${WARN} ${YELLOW}$*${NC}"
}

info() {
    echo -e "${INFO} ${CYAN}$*${NC}"
}

header() {
    echo ""
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}  $*${NC}"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo ""
}

step() {
    echo -e "${ARROW} ${CYAN}$*${NC}"
}
