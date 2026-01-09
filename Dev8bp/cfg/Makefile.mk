# Makefile para BUILD8BP
# =====================================================
# Variables de configuración (se pueden sobrescribir)
# =====================================================

# Ruta al directorio ASM (requerido)
8BP_ASM_PATH ?= ./8BP_V43/ASM

# Versión de ABASM (informativa)
ABASM_VERSION ?= 1.4.0

# Ruta a abasm.py
ABASM_PATH ?= $(CURDIR)/Dev8BP/tools/abasm/src/abasm.py

# Nivel de compilación (0-4)
BUILD_LEVEL ?= 0

# Directorio de salida (relativo al Makefile)
DIST_DIR := ./dist

# Intérprete de Python
PYTHON := $(shell command -v python3 2> /dev/null || command -v python)

# Scripts
PATCH_SCRIPT := $(CURDIR)/CPCDevKit/scripts/patch_asm.sh
CONVERT_SCRIPT := $(CURDIR)/CPCDevKit/scripts/convert_to_utf8.sh

# Colores para output
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
CYAN := \033[0;36m
RED := \033[0;31m
NC := \033[0m # No Color

# =====================================================
# Targets principales
# =====================================================

.PHONY: all help compile clean info build-all

# Target por defecto
all: info compile

# Mostrar ayuda
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
	@echo "  all         - Mostrar info + compilar nivel 0 (por defecto)"
	@echo "  build-all   - Compilar todos los niveles (0-4)"
	@echo "  8bp0-8bp4   - Compilar nivel específico (ej: make 8bp2)"
	@echo "  clean       - Limpiar archivos temporales y dist"
	@echo ""
	@echo "$(CYAN)Variables:$(NC)"
	@echo "  8BP_ASM_PATH  Ruta al directorio ASM (actual: $(8BP_ASM_PATH))"
	@echo "  ABASM_PATH    Ruta a abasm.py (actual: $(ABASM_PATH))"
	@echo "  DIST_DIR      Directorio de salida (actual: $(DIST_DIR))"
	@echo ""
	@echo "$(CYAN)Ejemplos:$(NC)"
	@echo "  make all                                  # Info + compilar nivel 0"
	@echo "  make 8bp2                                 # Solo compilar nivel 2"
	@echo "  make build-all                            # Compilar todos los niveles"
	@echo "  make all 8BP_ASM_PATH=./mi_proyecto/ASM"
	@echo ""
	@echo "$(CYAN)Niveles de compilación:$(NC)"
	@echo "  0 = Todas las funcionalidades (MEMORY 23600)"
	@echo "  1 = Juegos de laberintos (MEMORY 25000)"
	@echo "  2 = Juegos con scroll (MEMORY 24800)"
	@echo "  3 = Juegos pseudo-3D (MEMORY 24000)"
	@echo "  4 = Sin scroll/layout +500 bytes (MEMORY 25500)"
	@echo ""

# Mostrar información de configuración
info:
	@echo ""
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo "$(BLUE)  8BP - Configuración$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(CYAN)Directorio ASM:$(NC)     $(8BP_ASM_PATH)"
	@echo "$(CYAN)ABASM:$(NC)              $(ABASM_PATH)"
	@echo "$(CYAN)ABASM Version:$(NC)      $(ABASM_VERSION)"
	@echo "$(CYAN)Nivel de build:$(NC)     $(BUILD_LEVEL)"
	@echo "$(CYAN)Directorio salida:$(NC)  $(DIST_DIR)"
	@echo "$(CYAN)Python:$(NC)             $(PYTHON)"
	@echo ""

# Compilar con el nivel especificado
compile: $(DIST_DIR)
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
	@mkdir -p "$(DIST_DIR)"
	@echo "$(CYAN)Carpeta de salida:$(NC)   $(DIST_DIR)"
	@echo "\n$(YELLOW)Compilando con ABASM...$(NC)\n"
	@# Compilar con ABASM
	@cd "$(8BP_ASM_PATH)" && $(PYTHON) "$(ABASM_PATH)" "make_all_mygame.asm" --tolerance 2 && \
	if [ -f "8BP$(BUILD_LEVEL).bin" ]; then \
		cp "8BP$(BUILD_LEVEL).bin" "$(DIST_DIR)/"; \
		if [ -f "make_all_mygame.bin" ]; then mv "make_all_mygame.bin" "$(DIST_DIR)/"; fi; \
		for ext in lst map; do \
			for file in *.$$ext; do \
				if [ -f "$$file" ]; then mv "$$file" "$(DIST_DIR)/" 2>/dev/null || true; fi; \
			done; \
		done; \
		rm -f *.bin; \
		SIZE=$$(stat -f%z "$(DIST_DIR)/8BP$(BUILD_LEVEL).bin" 2>/dev/null || stat -c%s "$(DIST_DIR)/8BP$(BUILD_LEVEL).bin" 2>/dev/null); \
		mv "$(8BP_ASM_PATH)/make_all_mygame.asm.backup_build" "$(8BP_ASM_PATH)/make_all_mygame.asm"; \
		echo ""; \
		echo "$(GREEN)  Archivo:    8BP$(BUILD_LEVEL).bin$(NC)"; \
		echo "$(GREEN)  Ubicación:  $(DIST_DIR)/8BP$(BUILD_LEVEL).bin$(NC)"; \
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
	@if [ -f "$(DIST_DIR)/8BP$(BUILD_LEVEL).bin" ]; then \
		echo "$(GREEN)✓ Build Successful!!\n"; \
	else \
		echo "$(YELLOW)⚠ Binario no encontrado en dist, buscando...$(NC)"; \
		if [ -f "$(8BP_ASM_PATH)/8BP$(BUILD_LEVEL).bin" ]; then \
			cp "$(8BP_ASM_PATH)/8BP$(BUILD_LEVEL).bin" "$(DIST_DIR)/" && \
			echo "$(GREEN)✓ Binario movido a: $(DIST_DIR)/8BP$(BUILD_LEVEL).bin$(NC)"; \
		fi \
	fi

# Compilar todos los niveles
build-all: $(DIST_DIR)
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo "$(BLUE)  Compilando todos los niveles$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo ""
	@for level in 0 1 2 3 4; do \
		echo "$(CYAN)Compilando nivel $$level...$(NC)"; \
		$(MAKE) compile BUILD_LEVEL=$$level --no-print-directory || exit 1; \
		echo ""; \
	done
	@echo "$(GREEN)✓ Todos los niveles compilados exitosamente$(NC)"
	@echo ""
	@echo "$(CYAN)Binarios generados:$(NC)"
	@ls -lh $(DIST_DIR)/8BP*.bin 2>/dev/null || echo "  No se encontraron binarios"
	@echo ""

# Crear directorio dist
$(DIST_DIR):
	@mkdir -p $(DIST_DIR)

# Limpiar archivos temporales
clean:
	@echo "\n$(YELLOW)Limpiando archivos temporales...$(NC)"
	@rm -f "$(8BP_ASM_PATH)"/*.backup
	@rm -f "$(8BP_ASM_PATH)"/*.backup_build
	@rm -f "$(8BP_ASM_PATH)"/*.encoding_backup
	@rm -f "$(8BP_ASM_PATH)"/make_all_mygame.bin
	@rm -f "$(8BP_ASM_PATH)"/*.lst
	@rm -f "$(8BP_ASM_PATH)"/*.map
	@rm -rf $(DIST_DIR)
	@echo "$(GREEN)✓ Limpieza completada (incluye $(DIST_DIR))$(NC)\n"

# =====================================================
# Targets específicos por nivel (alias para compilar)
# =====================================================

.PHONY: 8bp0 8bp1 8bp2 8bp3 8bp4

8bp0:
	@$(MAKE) compile BUILD_LEVEL=0 --no-print-directory

8bp1:
	@$(MAKE) compile BUILD_LEVEL=1 --no-print-directory

8bp2:
	@$(MAKE) compile BUILD_LEVEL=2 --no-print-directory

8bp3:
	@$(MAKE) compile BUILD_LEVEL=3 --no-print-directory

8bp4:
	@$(MAKE) compile BUILD_LEVEL=4 --no-print-directory

# =====================================================
# Validaciones
# =====================================================

.PHONY: check

check:
	@echo "$(CYAN)Verificando configuración...$(NC)"
	@if [ ! -d "$(8BP_ASM_PATH)" ]; then \
		echo "$(RED)Error: Directorio ASM no existe: $(8BP_ASM_PATH)$(NC)"; \
		exit 1; \
	fi
	@if [ ! -f "$(ABASM_PATH)" ]; then \
		echo "$(RED)Error: abasm.py no existe: $(ABASM_PATH)$(NC)"; \
		exit 1; \
	fi
	@if [ -z "$(PYTHON)" ]; then \
		echo "$(RED)Error: Python no está instalado$(NC)"; \
		exit 1; \
	fi
	@if [ ! -x "$(PATCH_SCRIPT)" ]; then \
		echo "$(RED)Error: Script de patch no ejecutable: $(PATCH_SCRIPT)$(NC)"; \
		exit 1; \
	fi
	@if [ ! -x "$(CONVERT_SCRIPT)" ]; then \
		echo "$(RED)Error: Script de conversión no ejecutable: $(CONVERT_SCRIPT)$(NC)"; \
		exit 1; \
	fi
	@if [ ! -x "$(COMPILE_SCRIPT)" ]; then \
		echo "$(RED)Error: Script de compilación no ejecutable: $(COMPILE_SCRIPT)$(NC)"; \
		exit 1; \
	fi
	@echo "$(GREEN)✓ Configuración válida$(NC)"
