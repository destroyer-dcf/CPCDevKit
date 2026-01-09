# Makefile.example - Ejemplo de configuración para un proyecto específico
# ==========================================================================
# Copia este archivo como "Makefile" en tu proyecto y ajusta las variables
# ==========================================================================

# Incluir el Makefile principal
MAKEFILE_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
include $(MAKEFILE_DIR)/Dev8BP/cfg/Makefile.mk

# Sobrescribir variables con valores específicos del proyecto
# Descomenta y ajusta según tu proyecto:

# Versión de ABASM a utilizar
ABASM_VERSION := 1.4.0

8BP_ASM_PATH := "/Users/destroyer/PROJECTS/CPCReady/CPCDevKit/testing/ASM"
DIST_DIR := "/Users/destroyer/PROJECTS/CPCReady/CPCDevKit/testing/dist"