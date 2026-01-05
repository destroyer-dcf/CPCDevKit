# Makefile para BUILD8BP
# =====================================================
# Variables de configuración (se pueden sobrescribir)
# =====================================================

# Ruta al directorio ASM (requerido)
8BP_ASM_PATH ?= ./8BP_V43/ASM

# Ruta a abasm.py (requerido)
ABASM_PATH ?= $(CURDIR)/CPCDevKit/tools/abasm/src/abasm.py

# Nivel de compilación (0-4)
BUILD_LEVEL ?= 0

# Directorio de salida (relativo al Makefile)
DIST_DIR := ./dist

# Intérprete de Python
PYTHON := $(shell command -v python3 2> /dev/null || command -v python)

# Scripts
PATCH_SCRIPT := $(CURDIR)/CPCDevKit/scripts/patch_asm.sh
CONVERT_SCRIPT := $(CURDIR)/CPCDevKit/scripts/convert_to_utf8.sh
COMPILE_SCRIPT := $(CURDIR)/CPCDevKit/scripts/compile_asm.sh

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

.PHONY: all help patch compile clean info build-all

# Target por defecto
all: info patch compile

# Mostrar ayuda
help:
	@echo ""
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo "$(BLUE)  BUILD8BP - Makefile$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(CYAN)Uso:$(NC)"
	@echo "  make [target] [VARIABLE=valor]"
	@echo ""
	@echo "$(CYAN)Targets disponibles:$(NC)"
	@echo "  help        - Mostrar esta ayuda"
	@echo "  info        - Mostrar configuración actual"
	@echo "  patch       - Convertir a UTF-8 y aplicar parches de sintaxis"
	@echo "  all         - Ejecutar patch + compilar nivel 0 (por defecto)"
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
	@echo "  make all                                  # Parchear + compilar nivel 0"
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
	@echo "$(BLUE)  BUILD8BP - Configuración$(NC)"
	@echo "$(BLUE)═══════════════════════════════════════$(NC)"
	@echo ""
	@echo "$(CYAN)Directorio ASM:$(NC)     $(8BP_ASM_PATH)"
	@echo "$(CYAN)ABASM:$(NC)              $(ABASM_PATH)"
	@echo "$(CYAN)Nivel de build:$(NC)     $(BUILD_LEVEL)"
	@echo "$(CYAN)Directorio salida:$(NC)  $(DIST_DIR)"
	@echo "$(CYAN)Python:$(NC)             $(PYTHON)"
	@echo ""

# Convertir a UTF-8 y aplicar parches de sintaxis
patch:
	@echo "$(YELLOW)Convirtiendo archivos ASM a UTF-8...$(NC)"
	@$(CONVERT_SCRIPT) "$(8BP_ASM_PATH)"
	@echo "$(YELLOW)Aplicando parches de sintaxis...$(NC)"
	@$(PATCH_SCRIPT) "$(8BP_ASM_PATH)"

# Compilar con el nivel especificado
compile: $(DIST_DIR)
	@echo "$(YELLOW)Compilando nivel $(BUILD_LEVEL)...$(NC)"
	@# Crear enlace simbólico de ASM/dist a DIST_DIR
	@rm -rf "$(8BP_ASM_PATH)/dist"
	@mkdir -p "$(DIST_DIR)"
	@ln -sf "$(shell cd $(DIST_DIR) && pwd)" "$(8BP_ASM_PATH)/dist"
	@$(COMPILE_SCRIPT) $(BUILD_LEVEL) "$(8BP_ASM_PATH)" "$(ABASM_PATH)"
	@# Verificar que el binario se generó correctamente
	@if [ -f "$(DIST_DIR)/8BP$(BUILD_LEVEL).bin" ]; then \
		echo "$(GREEN)✓ Binario generado: $(DIST_DIR)/8BP$(BUILD_LEVEL).bin ($(shell ls -lh $(DIST_DIR)/8BP$(BUILD_LEVEL).bin 2>/dev/null | awk '{print $$5}'))$(NC)"; \
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
	@echo "$(YELLOW)Limpiando archivos temporales...$(NC)"
	@rm -f "$(8BP_ASM_PATH)"/*.backup
	@rm -f "$(8BP_ASM_PATH)"/*.encoding_backup
	@rm -f "$(8BP_ASM_PATH)"/build_8bp.asm
	@rm -f "$(8BP_ASM_PATH)"/make_all_mygame_temp_build*.asm
	@rm -f "$(8BP_ASM_PATH)"/make_all_mygame.bin
	@rm -f "$(8BP_ASM_PATH)"/*.lst
	@rm -f "$(8BP_ASM_PATH)"/*.map
	@rm -rf "$(8BP_ASM_PATH)/dist"
	@rm -rf $(DIST_DIR)
	@echo "$(GREEN)✓ Limpieza completada (incluye dist/)$(NC)"

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
