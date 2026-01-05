# Makefile.example - Ejemplo de configuración para un proyecto específico
# ==========================================================================
# Copia este archivo como "Makefile" en tu proyecto y ajusta las variables
# ==========================================================================

# Incluir el Makefile principal
MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(MAKEFILE_DIR)/CPCDevKit/cfg/Makefile.mk

# Sobrescribir variables con valores específicos del proyecto
# Descomenta y ajusta según tu proyecto:

8BP_ASM_PATH := "/Users/destroyer/Downloads/IDE_8BP222222/IDE_8BP/Proyecto/8BP_V43/ASM"
# ABASM_PATH := ./mi_proyecto/abasm/src/abasm.py
# BUILD_LEVEL := 1
DIST_DIR := ./dist
