# functions.mk - Funciones reutilizables para Dev8BP
# =====================================================
# Este archivo contiene funciones de Make que pueden ser
# llamadas desde el Makefile principal o desde proyectos
# =====================================================

# Función: create-dsk
# Descripción: Crea una nueva imagen DSK vacía (siempre recrea para evitar duplicados)
# Parámetros:
#   $(1) - Nombre del archivo DSK a crear (ej: game.dsk)
# Uso: $(call create-dsk,$(DSK))
define create-dsk
	echo "$(CYAN)Creando imagen DSK:$(NC) $(1)"; \
	if [ -f "$(DIST_DIR)/$(1)" ]; then \
		rm -f "$(DIST_DIR)/$(1)"; \
	fi; \
	$(PYTHON) "$(DSK_PATH)" "$(DIST_DIR)/$(1)" --new; \
	if [ -f "$(DIST_DIR)/$(1)" ]; then \
		echo "$(GREEN)✓ Imagen DSK creada: $(DIST_DIR)/$(1)$(NC)"; \
	else \
		echo "$(RED)✗ Error al crear la imagen DSK$(NC)"; \
		exit 1; \
	fi
endef

# Función: dsk-put-bin
# Descripción: Añade un archivo binario al DSK con encabezado AMSDOS
# Parámetros:
#   $(1) - Nombre del archivo DSK (ej: game.dsk)
#   $(2) - Archivo binario a añadir desde OBJ_DIR (ej: 8BP0.bin)
#   $(3) - Dirección de carga en hexadecimal (opcional, default: 0x4000)
#   $(4) - Dirección de inicio en hexadecimal (opcional, default: 0x4000)
# Uso: $(call dsk-put-bin,$(DSK),8BP0.bin,0x5C30,0x5C30)
define dsk-put-bin
	echo "$(CYAN)Añadiendo binario a DSK:$(NC) $(2) → $(1)"; \
	if [ ! -f "$(DIST_DIR)/$(1)" ]; then \
		echo "$(RED)✗ Error: La imagen DSK $(1) no existe$(NC)"; \
		exit 1; \
	fi; \
	if [ ! -f "$(OBJ_DIR)/$(2)" ]; then \
		echo "$(RED)✗ Error: El archivo $(2) no existe en $(OBJ_DIR)$(NC)"; \
		exit 1; \
	fi; \
	LOAD_ADDR=$(if $(3),$(3),0x4000); \
	START_ADDR=$(if $(4),$(4),0x4000); \
	cd "$(OBJ_DIR)" && $(PYTHON) "$(DSK_PATH)" "$(DIST_DIR)/$(1)" --put-bin "$(2)" --load-addr $$LOAD_ADDR --start-addr $$START_ADDR; \
	if [ $$? -eq 0 ]; then \
		echo "$(GREEN)✓ Binario añadido correctamente$(NC)"; \
		echo ""; \
		$(PYTHON) "$(DSK_PATH)" "$(DIST_DIR)/$(1)" --cat; \
		echo ""; \
	else \
		echo "$(RED)✗ Error al añadir el binario$(NC)"; \
		exit 1; \
	fi
endef

# Función: dsk-put-raw
# Descripción: Añade un archivo binario al DSK sin encabezado AMSDOS
# Parámetros:
#   $(1) - Nombre del archivo DSK (ej: game.dsk)
#   $(2) - Archivo a añadir desde OBJ_DIR (ej: data.bin)
# Uso: $(call dsk-put-raw,$(DSK),data.bin)
define dsk-put-raw
	echo "$(CYAN)Añadiendo archivo raw a DSK:$(NC) $(2) → $(1)"; \
	if [ ! -f "$(DIST_DIR)/$(1)" ]; then \
		echo "$(RED)✗ Error: La imagen DSK $(1) no existe$(NC)"; \
		exit 1; \
	fi; \
	if [ ! -f "$(OBJ_DIR)/$(2)" ]; then \
		echo "$(RED)✗ Error: El archivo $(2) no existe en $(OBJ_DIR)$(NC)"; \
		exit 1; \
	fi; \
	cd "$(OBJ_DIR)" && $(PYTHON) "$(DSK_PATH)" "$(DIST_DIR)/$(1)" --put-raw "$(2)"; \
	if [ $$? -eq 0 ]; then \
		echo "$(GREEN)✓ Archivo raw añadido correctamente$(NC)"; \
		echo ""; \
		$(PYTHON) "$(DSK_PATH)" "$(DIST_DIR)/$(1)" --cat; \
		echo ""; \
	else \
		echo "$(RED)✗ Error al añadir el archivo raw$(NC)"; \
		exit 1; \
	fi
endef

# Función: dsk-put-ascii
# Descripción: Añade un archivo ASCII (BASIC) al DSK
# Parámetros:
#   $(1) - Nombre del archivo DSK (ej: game.dsk)
#   $(2) - Archivo ASCII a añadir desde OBJ_DIR (ej: loader.bas)
# Uso: $(call dsk-put-ascii,$(DSK),loader.bas)
define dsk-put-ascii
	echo "$(CYAN)Añadiendo archivo ASCII a DSK:$(NC) $(2) → $(1)"; \
	if [ ! -f "$(DIST_DIR)/$(1)" ]; then \
		echo "$(RED)✗ Error: La imagen DSK $(1) no existe$(NC)"; \
		exit 1; \
	fi; \
	if [ ! -f "$(OBJ_DIR)/$(2)" ]; then \
		echo "$(RED)✗ Error: El archivo $(2) no existe en $(OBJ_DIR)$(NC)"; \
		exit 1; \
	fi; \
	cd "$(OBJ_DIR)" && $(PYTHON) "$(DSK_PATH)" "$(DIST_DIR)/$(1)" --put-ascii "$(2)"; \
	if [ $$? -eq 0 ]; then \
		echo "$(GREEN)✓ Archivo ASCII añadido correctamente$(NC)"; \
		echo ""; \
		$(PYTHON) "$(DSK_PATH)" "$(DIST_DIR)/$(1)" --cat; \
		echo ""; \
	else \
		echo "$(RED)✗ Error al añadir el archivo ASCII$(NC)"; \
		exit 1; \
	fi
endef

# Función: dsk-cat
# Descripción: Muestra el catálogo de una imagen DSK
# Parámetros:
#   $(1) - Nombre del archivo DSK (ej: game.dsk)
# Uso: $(call dsk-cat,$(DSK))
define dsk-cat
	if [ ! -f "$(DIST_DIR)/$(1)" ]; then \
		echo "$(RED)✗ Error: La imagen DSK $(1) no existe$(NC)"; \
		exit 1; \
	fi; \
	$(PYTHON) "$(DSK_PATH)" "$(DIST_DIR)/$(1)" --cat
endef
