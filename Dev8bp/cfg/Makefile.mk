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

# Incluir rutas de herramientas
include $(dir $(lastword $(MAKEFILE_LIST)))/tool_paths.mk

# Incluir funciones reutilizables
include $(dir $(lastword $(MAKEFILE_LIST)))/functions.mk

# Ruta al directorio ASM (requerido)
8BP_ASM_PATH ?= ./8BP_V43/ASM

# Nivel de compilación (0-4)
BUILD_LEVEL ?= 0

# Directorio de objetos compilados (binarios, lst, map)
OBJ_DIR := ./obj

# Directorio de salida para DSK
DIST_DIR := ./dist

# Intérprete de Python
PYTHON := $(shell command -v python3 2> /dev/null || command -v python)

# Scripts
PATCH_SCRIPT := $(CURDIR)/Dev8bp/scripts/patch_asm.sh
CONVERT_SCRIPT := $(CURDIR)/Dev8bp/scripts/convert_to_utf8.sh

# Colores para output
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
RED := \033[0;31m
NC := \033[0m # No Color

#TARGETS PRINCIPALES

.PHONY: all help clean info dsk

# TARGET POR DEFECTO - Compilar proyecto completo
all: info _compile

# Crear directorios necesarios
$(OBJ_DIR):
	@mkdir -p $(OBJ_DIR)

$(DIST_DIR):
	@mkdir -p $(DIST_DIR)

# MOSTRAR AYUDA
help:
	@echo ""
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo "$(BLUE)  8BP - Makefile$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(CYAN)Uso:$(NC)"
	@echo "  make [target] [VARIABLE=valor]"
	@echo ""
	@echo "$(CYAN)Targets disponibles:$(NC)"
	@echo "  help        - Mostrar esta ayuda"
	@echo "  info        - Mostrar configuración actual"
	@echo "  all         - Mostrar info + compilar + crear DSK (por defecto)"
	@echo "  dsk         - Crear imagen DSK con binario compilado"
	@echo "  clean       - Limpiar archivos temporales, obj y dist"
	@echo ""
	@echo "$(CYAN)Variables:$(NC)"
	@echo "  8BP_ASM_PATH  Ruta al directorio ASM (actual: $(8BP_ASM_PATH))"
	@echo "  BUILD_LEVEL   Nivel de compilación 0-4 (actual: $(BUILD_LEVEL))"
	@echo "  ABASM_PATH    Ruta a abasm.py (actual: $(ABASM_PATH))"
	@echo "  OBJ_DIR       Directorio de objetos (actual: $(OBJ_DIR))"
	@echo "  DIST_DIR      Directorio de salida DSK (actual: $(DIST_DIR))"
	@echo "  DSK           Nombre de la imagen DSK (actual: $(DSK))"
	@echo ""
	@echo "$(CYAN)Ejemplos:$(NC)"
	@echo "  make                        # Compilar proyecto (info + compile + dsk)"
	@echo "  make clean                  # Limpiar archivos generados"
	@echo "  make info                   # Ver configuración"
	@echo ""
	@echo "$(CYAN)Niveles de compilación:$(NC)"
	@echo "  0 = Todas las funcionalidades (MEMORY 23600)"
	@echo "  1 = Juegos de laberintos (MEMORY 25000)"
	@echo "  2 = Juegos con scroll (MEMORY 24800)"
	@echo "  3 = Juegos pseudo-3D (MEMORY 24000)"
	@echo "  4 = Sin scroll/layout +500 bytes (MEMORY 25500)"
	@echo ""

# INFORMACION DE CONFIGURACION
info:
	@echo ""
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo "$(BLUE)  8BP - Configuración$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(CYAN)Directorio ASM:$(NC)     $(8BP_ASM_PATH)"
	@echo "$(CYAN)ABASM:$(NC)              $(ABASM_PATH)"
	@echo "$(CYAN)DSK Tool:$(NC)           $(DSK_PATH)"
	@echo "$(CYAN)Nivel de build:$(NC)     $(BUILD_LEVEL)"
	@echo "$(CYAN)Directorio obj:$(NC)     $(OBJ_DIR)"
	@echo "$(CYAN)Directorio dist:$(NC)    $(DIST_DIR)"
	@echo "$(CYAN)Python:$(NC)             $(PYTHON)"
	@echo ""

# Compilar con el nivel especificado
_compile: $(OBJ_DIR) $(DIST_DIR)
	@echo "$(YELLOW)\nCompilando nivel $(BUILD_LEVEL)...$(NC)\n"
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo "$(BLUE)  8BP - Build $(BUILD_LEVEL)$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo ""
	@# Información del build
	@case $(BUILD_LEVEL) in \
		0) DESC="Todas las funcionalidades"; MEMORY="MEMORY 23600"; COMMANDS="|LAYOUT, |COLAY, |MAP2SP, |UMA, |3D" ;; \
		1) DESC="Juegos de laberintos"; MEMORY="MEMORY 25000"; COMMANDS="|LAYOUT, |COLAY" ;; \
		2) DESC="Juegos con scroll"; MEMORY="MEMORY 24800"; COMMANDS="|MAP2SP, |UMA" ;; \
		3) DESC="Juegos pseudo-3D"; MEMORY="MEMORY 24000"; COMMANDS="|3D" ;; \
		4) DESC="Sin scroll/layout (+500 bytes)"; MEMORY="MEMORY 25500"; COMMANDS="Básicos" ;; \
	esac; \
	echo "$(CYAN)Descripción:$(NC)     $$DESC"; \
	echo "$(CYAN)Memoria BASIC:$(NC)   $$MEMORY"; \
	echo "$(CYAN)Comandos:$(NC)        $$COMMANDS"; \
	echo "$(CYAN)Directorio ASM:$(NC)  $(8BP_ASM_PATH)"; \
	echo "$(CYAN)ABASM:$(NC)           $(ABASM_PATH)"; \
	echo ""
	@# Verificar que existe make_all_mygame.asm
	@if [ ! -f "$(8BP_ASM_PATH)/make_all_mygame.asm" ]; then \
		echo "$(RED)Error: No existe el archivo $(8BP_ASM_PATH)/make_all_mygame.asm$(NC)"; \
		exit 1; \
	fi
	@# Hacer backup y modificar ASSEMBLING_OPTION
	@echo "$(YELLOW)Configurando ASSEMBLING_OPTION = $(BUILD_LEVEL)...\n$(NC)"
	@cp "$(8BP_ASM_PATH)/make_all_mygame.asm" "$(8BP_ASM_PATH)/make_all_mygame.asm.backup_build"
	@# Modificar ASSEMBLING_OPTION
	@if [[ "$(shell uname)" == "Darwin" ]]; then \
		sed -i '' 's/let ASSEMBLING_OPTION = [0-9]/let ASSEMBLING_OPTION = $(BUILD_LEVEL)/' "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
	else \
		sed -i 's/let ASSEMBLING_OPTION = [0-9]/let ASSEMBLING_OPTION = $(BUILD_LEVEL)/' "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
	fi
	@# Añadir directivas SAVE condicionales si no existen
	@if ! grep -q "if ASSEMBLING_OPTION = 0" "$(8BP_ASM_PATH)/make_all_mygame.asm"; then \
		if grep -q "^SAVE " "$(8BP_ASM_PATH)/make_all_mygame.asm"; then \
			if [[ "$(shell uname)" == "Darwin" ]]; then \
				sed -i '' '/^SAVE /d' "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
			else \
				sed -i '/^SAVE /d' "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
			fi; \
		fi; \
		echo "" >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo "if ASSEMBLING_OPTION = 0" >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo 'SAVE "8BP0.bin",23600,19120' >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo "elseif ASSEMBLING_OPTION = 1" >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo 'SAVE "8BP1.bin",25000,17620' >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo "elseif ASSEMBLING_OPTION = 2" >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo 'SAVE "8BP2.bin",24800,17820' >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo "elseif ASSEMBLING_OPTION = 3" >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo 'SAVE "8BP3.bin",24000,18620' >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo "elseif ASSEMBLING_OPTION = 4" >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo 'SAVE "8BP4.bin",25300,17320' >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo "endif" >> "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo "$(CYAN)Añadidas directivas SAVE condicionales:$(NC)"; \
		echo "  $(CYAN)0:$(NC) 8BP0.bin, 23600, 19120"; \
		echo "  $(CYAN)1:$(NC) 8BP1.bin, 25000, 17620"; \
		echo "  $(CYAN)2:$(NC) 8BP2.bin, 24800, 17820"; \
		echo "  $(CYAN)3:$(NC) 8BP3.bin, 24000, 18620"; \
		echo "  $(CYAN)4:$(NC) 8BP4.bin, 25300, 17320"; \
	fi
	@echo "$(CYAN)Archivo a compilar:$(NC)  make_all_mygame.asm"
	@echo "$(CYAN)Carpeta obj:$(NC)         $(OBJ_DIR)"
	@echo "\n$(YELLOW)Compilando con ABASM...$(NC)\n"
	@# Compilar con ABASM
	@cd "$(8BP_ASM_PATH)" && $(PYTHON) "$(ABASM_PATH)" "make_all_mygame.asm" --tolerance 2 && \
	if [ -f "8BP$(BUILD_LEVEL).bin" ]; then \
		mv "8BP$(BUILD_LEVEL).bin" "$(OBJ_DIR)/"; \
		if [ -f "make_all_mygame.bin" ]; then mv "make_all_mygame.bin" "$(OBJ_DIR)/"; fi; \
		for ext in lst map; do \
			for file in *.$$ext; do \
				if [ -f "$$file" ]; then mv "$$file" "$(OBJ_DIR)/" 2>/dev/null || true; fi; \
			done; \
		done; \
		rm -f *.bin; \
		SIZE=$$(stat -f%z "$(OBJ_DIR)/8BP$(BUILD_LEVEL).bin" 2>/dev/null || stat -c%s "$(OBJ_DIR)/8BP$(BUILD_LEVEL).bin" 2>/dev/null); \
		mv "$(8BP_ASM_PATH)/make_all_mygame.asm.backup_build" "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo ""; \
		echo "$(GREEN)  Archivo:    8BP$(BUILD_LEVEL).bin$(NC)"; \
		echo "$(GREEN)  Ubicación:  $(OBJ_DIR)/8BP$(BUILD_LEVEL).bin$(NC)"; \
		echo "$(GREEN)  Tamaño:     $$SIZE bytes$(NC)"; \
		echo ""; \
		case $(BUILD_LEVEL) in \
			0) MEMORY="MEMORY 23600" ;; \
			1) MEMORY="MEMORY 25000" ;; \
			2) MEMORY="MEMORY 24800" ;; \
			3) MEMORY="MEMORY 24000" ;; \
			4) MEMORY="MEMORY 25300" ;; \
		esac; \
		echo "$(CYAN)Uso desde BASIC:$(NC)"; \
		echo "  $$MEMORY"; \
		echo "  LOAD\"8BP$(BUILD_LEVEL).bin\""; \
		echo "  CALL &6B78"; \
		echo ""; \
	else \
		mv "$(8BP_ASM_PATH)/make_all_mygame.asm.backup_build" "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo "$(YELLOW)Advertencia: No se encontró el binario 8BP$(BUILD_LEVEL).bin$(NC)"; \
		exit 1; \
	fi || (mv "$(8BP_ASM_PATH)/make_all_mygame.asm.backup_build" "$(8BP_ASM_PATH)/make_all_mygame.asm" 2>/dev/null; exit 1)
	@# Verificar que el binario se generó correctamente
	@if [ -f "$(OBJ_DIR)/8BP$(BUILD_LEVEL).bin" ]; then \
		echo "$(GREEN)✓ Build Successful!!$(NC)"; \
		echo ""; \
	else \
		echo "$(YELLOW)⚠ Binario no encontrado en obj, buscando...$(NC)"; \
		if [ -f "$(8BP_ASM_PATH)/8BP$(BUILD_LEVEL).bin" ]; then \
			mv "$(8BP_ASM_PATH)/8BP$(BUILD_LEVEL).bin" "$(OBJ_DIR)/" && \
			echo "$(GREEN)✓ Binario movido a: $(OBJ_DIR)/8BP$(BUILD_LEVEL).bin$(NC)"; \
		fi \
	fi
	@# Crear/actualizar DSK automáticamente
	@$(MAKE) dsk --no-print-directory

# LIMPIAR ARCHIVOS TEMPORALES
clean:
	@echo "\n$(YELLOW)Limpiando archivos temporales...$(NC)"
	@rm -f "$(8BP_ASM_PATH)"/*.backup
	@rm -f "$(8BP_ASM_PATH)"/*.backup_build
	@rm -f "$(8BP_ASM_PATH)"/*.encoding_backup
	@rm -f "$(8BP_ASM_PATH)"/make_all_mygame.bin
	@rm -f "$(8BP_ASM_PATH)"/*.lst
	@rm -f "$(8BP_ASM_PATH)"/*.map
	@rm -rf $(OBJ_DIR)
	@rm -rf $(DIST_DIR)
	@echo "$(GREEN)✓ Limpieza completada (obj y dist eliminados)$(NC)\n"

# CREAR IMAGEN DSK
dsk: $(DIST_DIR)
	@echo ""
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo "$(BLUE)  8BP - Crear imagen DSK$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(CYAN)Nombre DSK:$(NC)         $(DSK)"
	@echo "$(CYAN)DSK Tool:$(NC)           $(DSK_PATH)"
	@echo ""
	@if [ ! -f "$(DSK_PATH)" ]; then \
		echo "$(RED)Error: dsk.py no encontrado en $(DSK_PATH)$(NC)"; \
		exit 1; \
	fi
	@$(call create-dsk,$(DSK))
	@echo ""
	@if [ ! -f "$(OBJ_DIR)/8BP$(BUILD_LEVEL).bin" ]; then \
		echo "$(YELLOW)⚠ No se encontró 8BP$(BUILD_LEVEL).bin en $(OBJ_DIR) - ejecuta make primero$(NC)"; \
		echo ""; \
		exit 1; \
	fi
	@case $(BUILD_LEVEL) in \
		0) LOAD_ADDR="0x5C30" ;; \
		1) LOAD_ADDR="0x61A8" ;; \
		2) LOAD_ADDR="0x60E0" ;; \
		3) LOAD_ADDR="0x5DC0" ;; \
		4) LOAD_ADDR="0x62D4" ;; \
	esac; \
	$(call dsk-put-bin,$(DSK),8BP$(BUILD_LEVEL).bin,$$LOAD_ADDR,$$LOAD_ADDR)
	@echo "$(YELLOW)Nota:$(NC) Los archivos >16KB se dividen en múltiples extents (extensiones)"
	@echo "       Cada extent puede contener hasta 128 páginas de datos (16KB)"
	@echo ""
