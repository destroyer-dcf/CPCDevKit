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

# Verificar que DEV8BP_PATH está definida
ifndef DEV8BP_PATH
$(error DEV8BP_PATH no está definida. Ejecuta setup.sh en el directorio raíz de Dev8BP o añade 'export DEV8BP_PATH=/ruta/a/Dev8bp' a tu .bashrc/.zshrc)
endif

# ============================================
# CONFIGURACIÓN DEL PROYECTO
# ============================================

PROJECT_NAME := MY_GAME_MOLON

# Nivel de compilación (0-4)
BUILD_LEVEL := 0

# Path codigo emsembler 8BP
ASM_PATH := ASM

# Path archivos BASIC (se añadirán al DSK automáticamente)
BASIC_PATH := bas

# Path archivos RAW (se añadirán al DSK sin encabezado AMSDOS)
RAW_PATH := raw

# Path código C (se compilará con SDCC si existe)
C_PATH := C
C_SOURCE := ciclo.c
C_CODE_LOC := 20000

# Path Binario Generado (objetos intermedios)
OBJ_DIR := obj

# Path Binario Generado (DSK final)
DIST_DIR := dist

# Path imagen DSK
DSK := $(PROJECT_NAME).dsk

# Configuración RetroVirtualMachine (opcional)
RVM_PATH := /Applications/Retro Virtual Machine 2.app/Contents/MacOS/Retro Virtual Machine 2
CPC_MODEL := 6128
RUN_FILE := loader.bas

# ============================================
# INCLUIR MAKEFILE PRINCIPAL
# ============================================

# Incluir el Makefile principal
include $(DEV8BP_PATH)/cfg/Makefile.mk
