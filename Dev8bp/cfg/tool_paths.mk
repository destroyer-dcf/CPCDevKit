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

# tool_paths.mk - Rutas a las herramientas de Dev8BP
# =====================================================
# Este archivo centraliza las rutas a todas las herramientas
# incluidas como submódulos en Dev8bp/tools/
# =====================================================

# Directorio base de Dev8bp (relativo a este archivo)
DEV8BP_ROOT := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))..

# Detectar sistema operativo y arquitectura
UNAME_S := $(shell uname -s)
UNAME_M := $(shell uname -m)

# Determinar plataforma para iDSK
ifeq ($(UNAME_S),Darwin)
    # macOS
    ifeq ($(UNAME_M),arm64)
        IDSK_PLATFORM := macos-arm64
    else
        IDSK_PLATFORM := macos-x64
    endif
    IDSK_BINARY := iDSK20
else ifeq ($(UNAME_S),Linux)
    # Linux
    ifeq ($(UNAME_M),aarch64)
        IDSK_PLATFORM := linux-arm64
    else
        IDSK_PLATFORM := linux-x64
    endif
    IDSK_BINARY := iDSK20
else
    # Windows (asumiendo que se ejecuta desde Git Bash, WSL, o similar)
    IDSK_PLATFORM := windows-x64
    IDSK_BINARY := iDSK20.exe
endif

# ABASM - Ensamblador Z80 para Amstrad CPC
ABASM_PATH ?= $(DEV8BP_ROOT)/tools/abasm/src/abasm.py

# iDSK - Herramienta para crear y manipular imágenes DSK de Amstrad CPC
IDSK_PATH ?= $(DEV8BP_ROOT)/tools/iDSK20/$(IDSK_PLATFORM)/$(IDSK_BINARY)

# 8BP Graphics Converter - Conversor de gráficos ASM <-> PNG
GRAPHICS_CONVERTER_PATH ?= $(DEV8BP_ROOT)/tools/8bp-graphics-converter
ASM2PNG ?= $(GRAPHICS_CONVERTER_PATH)/asm2png.py
ASM2PNGS ?= $(GRAPHICS_CONVERTER_PATH)/asm2pngs.py
PNG2ASM ?= $(GRAPHICS_CONVERTER_PATH)/png2asm.py
