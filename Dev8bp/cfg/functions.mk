# functions.mk - Funciones reutilizables para Dev8BP
# =====================================================
# Este archivo contiene funciones de Make que pueden ser
# llamadas desde el Makefile principal o desde proyectos
# =====================================================

# Función: create-dsk
# Descripción: Crea una nueva imagen DSK vacía solo si NO existe
# Parámetros:
#   $(1) - Nombre del archivo DSK a crear (ej: game.dsk)
# Uso: $(call create-dsk,$(DSK))
define create-dsk
	@if [ -f "$(DIST_DIR)/$(1)" ]; then \
		echo "$(CYAN)Imagen DSK ya existe:$(NC) $(DIST_DIR)/$(1)"; \
	else \
		echo "$(CYAN)Creando imagen DSK:$(NC) $(1)"; \
		"$(IDSK_PATH)" new "$(DIST_DIR)/$(1)"; \
		if [ -f "$(DIST_DIR)/$(1)" ]; then \
			echo "$(GREEN)✓ Imagen DSK creada: $(DIST_DIR)/$(1)$(NC)"; \
		else \
			echo "$(RED)✗ Error al crear la imagen DSK$(NC)"; \
			exit 1; \
		fi; \
	fi
endef

# Función: add-file-to-dsk
# Descripción: Añade un archivo a una imagen DSK existente
# Parámetros:
#   $(1) - Nombre del archivo DSK (ej: game.dsk)
#   $(2) - Archivo a añadir (ej: 8BP0.bin)
#   $(3) - Tipo de archivo: A=ASCII, B=Binary, R=Raw (opcional, default: B)
#   $(4) - Dirección de carga en hexadecimal (opcional, ej: 4000)
#   $(5) - Dirección de ejecución en hexadecimal (opcional, ej: 4000)
# Uso: $(call add-file-to-dsk,$(DSK),8BP0.bin,B,4000,4000)
define add-file-to-dsk
	echo "$(CYAN)Añadiendo archivo a DSK:$(NC) $(2) → $(1)"; \
	if [ ! -f "$(DIST_DIR)/$(1)" ]; then \
		echo "$(RED)✗ Error: La imagen DSK $(1) no existe$(NC)"; \
		exit 1; \
	fi; \
	if [ ! -f "$(DIST_DIR)/$(2)" ]; then \
		echo "$(RED)✗ Error: El archivo $(2) no existe en $(DIST_DIR)$(NC)"; \
		exit 1; \
	fi; \
	FILE_TYPE=$(if $(3),$(3),B); \
	cd "$(DIST_DIR)" && \
	if [ -n "$(4)" ] && [ -n "$(5)" ]; then \
		"$(IDSK_PATH)" save "$(1)" "$(2)",$$FILE_TYPE,$(4),$(5) -f; \
	elif [ -n "$(4)" ]; then \
		"$(IDSK_PATH)" save "$(1)" "$(2)",$$FILE_TYPE,$(4) -f; \
	else \
		"$(IDSK_PATH)" save "$(1)" "$(2)",$$FILE_TYPE -f; \
	fi; \
	if [ $$? -eq 0 ]; then \
		echo "$(GREEN)✓ Archivo añadido correctamente$(NC)"; \
	else \
		echo "$(RED)✗ Error al añadir el archivo$(NC)"; \
		exit 1; \
	fi
endef

# Función: list-dsk-catalog
# Descripción: Muestra el catálogo de una imagen DSK
# Parámetros:
#   $(1) - Nombre del archivo DSK (ej: game.dsk)
# Uso: $(call list-dsk-catalog,$(DSK))
define list-dsk-catalog
	@echo "$(CYAN)Catálogo de:$(NC) $(1)"
	@if [ ! -f "$(DIST_DIR)/$(1)" ]; then \
		echo "$(RED)✗ Error: La imagen DSK $(1) no existe$(NC)"; \
		exit 1; \
	fi
	@"$(IDSK_PATH)" cat "$(DIST_DIR)/$(1)"
endef

# Función: extract-file-from-dsk
# Descripción: Extrae un archivo de una imagen DSK
# Parámetros:
#   $(1) - Nombre del archivo DSK (ej: game.dsk)
#   $(2) - Nombre del archivo a extraer (ej: program.bas)
#   $(3) - Directorio de destino (opcional, default: DIST_DIR)
# Uso: $(call extract-file-from-dsk,$(DSK),program.bas)
define extract-file-from-dsk
	@echo "$(CYAN)Extrayendo de DSK:$(NC) $(2) ← $(1)"
	@if [ ! -f "$(DIST_DIR)/$(1)" ]; then \
		echo "$(RED)✗ Error: La imagen DSK $(1) no existe$(NC)"; \
		exit 1; \
	fi
	@DEST_DIR=$(if $(3),$(3),$(DIST_DIR)); \
	cd "$$DEST_DIR" && "$(IDSK_PATH)" get "$(DIST_DIR)/$(1)" "$(2)"
	@if [ $$? -eq 0 ]; then \
		echo "$(GREEN)✓ Archivo extraído a: $$DEST_DIR/$(2)$(NC)"; \
	else \
		echo "$(RED)✗ Error al extraer el archivo$(NC)"; \
		exit 1; \
	fi
endef

# Función: create-game-dsk
# Descripción: Crea una imagen DSK completa con todos los binarios de un nivel
# Parámetros:
#   $(1) - Nivel de compilación (0-4)
#   $(2) - Nombre del DSK (opcional, default: game_level$(1).dsk)
# Uso: $(call create-game-dsk,0,$(DSK))
define create-game-dsk
	@DSK_NAME=$(if $(2),$(2),game_level$(1).dsk); \
	echo ""; \
	echo "$(BLUE)═══════════════════════════════════════$(NC)"; \
	echo "$(BLUE)  Crear DSK para nivel $(1)$(NC)"; \
	echo "$(BLUE)═══════════════════════════════════════$(NC)"; \
	echo ""; \
	$(call create-dsk,$$DSK_NAME); \
	if [ -f "$(DIST_DIR)/8BP$(1).bin" ]; then \
		case $(1) in \
			0) LOAD_ADDR="5C30" ;; \
			1) LOAD_ADDR="61A8" ;; \
			2) LOAD_ADDR="60E0" ;; \
			3) LOAD_ADDR="5DC0" ;; \
			4) LOAD_ADDR="62D4" ;; \
		esac; \
		$(call add-file-to-dsk,$$DSK_NAME,8BP$(1).bin,B,$$LOAD_ADDR,$$LOAD_ADDR); \
	else \
		echo "$(YELLOW)⚠ No se encontró 8BP$(1).bin$(NC)"; \
	fi; \
	echo ""; \
	$(call list-dsk-catalog,$$DSK_NAME); \
	echo ""; \
	echo "$(GREEN)✓ DSK creado: $(DIST_DIR)/$$DSK_NAME$(NC)"; \
	echo ""
endef
