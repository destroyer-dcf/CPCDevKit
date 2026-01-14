# Changelog - Dev8BP

## v2.0.0 - Sistema CLI (2026-01-14)

### 🎉 Cambio Mayor: Migración de Make a CLI

**Dev8BP ahora usa un sistema basado en scripts bash en lugar de Makefiles.**

### 📝 Nota sobre Variables

- `ASM_PATH` ha sido renombrada a `BP_ASM_PATH` (las variables en bash no pueden empezar con números)
- Todas las demás variables mantienen sus nombres originales

### ✨ Nuevas Características

#### Sistema CLI
- ✅ Comando `dev8bp` con subcomandos intuitivos
- ✅ Mensajes coloridos y amigables
- ✅ Validaciones automáticas
- ✅ Configuración simple con `dev8bp.conf`
- ✅ Herramientas integradas (ABASM, dsk.py, hex2bin)

#### Comandos Disponibles
- `dev8bp new <nombre>` - Crear nuevo proyecto
- `dev8bp build` - Compilar proyecto
- `dev8bp clean` - Limpiar archivos generados
- `dev8bp info` - Mostrar configuración
- `dev8bp validate` - Validar proyecto
- `dev8bp run` - Ejecutar en RetroVirtualMachine
- `dev8bp help` - Ayuda
- `dev8bp version` - Versión

#### Características de Compilación
- ✅ Compilación ASM con ABASM
- ✅ Verificación de límites de gráficos (_END_GRAPH < 42040)
- ✅ Creación automática de DSK
- ✅ Soporte para archivos BASIC
- ✅ Soporte para archivos RAW
- ✅ Compilación C con SDCC
- ✅ Verificación de límites de memoria C
- ✅ Integración con RetroVirtualMachine

### 🔄 Cambios de Ruptura

#### Eliminado
- ❌ Sistema basado en Makefiles
- ❌ `Makefile.example`
- ❌ `Dev8bp/cfg/` (Makefile.mk, functions.mk, tool_paths.mk)
- ❌ Variable `DEV8BP_PATH` (ahora se configura automáticamente)

#### Reemplazado
- `Makefile` → `dev8bp.conf`
- `make` → `dev8bp build`
- `make clean` → `dev8bp clean`
- `make run` → `dev8bp run`
- `make info` → `dev8bp info`

### 📁 Nueva Estructura

```
Dev8BP/
├── Dev8bp/
│   ├── bin/
│   │   └── dev8bp          # Script principal
│   ├── lib/
│   │   ├── colors.sh       # Colores y formato
│   │   ├── utils.sh        # Utilidades
│   │   ├── config.sh       # Gestión de config
│   │   ├── build.sh        # Compilación
│   │   ├── compile_asm.sh  # Compilación ASM
│   │   ├── compile_c.sh    # Compilación C
│   │   ├── dsk.sh          # Gestión DSK
│   │   ├── clean.sh        # Limpieza
│   │   ├── validate.sh     # Validación
│   │   ├── run.sh          # Ejecución
│   │   └── new_project.sh  # Crear proyectos
│   ├── templates/
│   │   └── project.conf    # Template configuración
│   └── tools/
│       ├── abasm/          # ABASM incluido
│       └── hex2bin/        # hex2bin multiplataforma
├── examples/
│   ├── dev8bp.conf         # Configuración ejemplo
│   ├── ASM/                # Código ASM
│   ├── bas/                # Archivos BASIC
│   ├── raw/                # Archivos RAW
│   └── C/                  # Código C
├── setup.sh                # Script de instalación
└── README.md               # Documentación completa
```

### 🔧 Migración de Proyectos Existentes

#### Antes (Makefile)
```makefile
PROJECT_NAME := MI_JUEGO
BUILD_LEVEL := 0
ASM_PATH := $(CURDIR)/ASM
BASIC_PATH := $(CURDIR)/bas

include $(DEV8BP_PATH)/cfg/Makefile.mk
```

#### Ahora (dev8bp.conf)
```bash
PROJECT_NAME="MI_JUEGO"
BUILD_LEVEL=0
BP_ASM_PATH="ASM"    # Nota: renombrada de ASM_PATH
BASIC_PATH="bas"
```

#### Pasos de Migración
1. Eliminar `Makefile`
2. Crear `dev8bp.conf` con la configuración
3. **Importante:** Renombrar `ASM_PATH` a `BP_ASM_PATH`
4. Usar `dev8bp build` en lugar de `make`

#### Tabla de Cambios de Variables

| Antes (Makefile) | Ahora (dev8bp.conf) | Notas |
|------------------|---------------------|-------|
| `ASM_PATH` | `BP_ASM_PATH` | ⚠️ Renombrada |
| `BASIC_PATH` | `BASIC_PATH` | ✅ Sin cambios |
| `RAW_PATH` | `RAW_PATH` | ✅ Sin cambios |
| `C_PATH` | `C_PATH` | ✅ Sin cambios |
| `BUILD_LEVEL` | `BUILD_LEVEL` | ✅ Sin cambios |
| `PROJECT_NAME` | `PROJECT_NAME` | ✅ Sin cambios |

#### Script de Migración Automática

```bash
#!/bin/bash
# migrate-to-cli.sh - Migrar proyecto de Make a CLI

if [[ ! -f "Makefile" ]]; then
    echo "No se encontró Makefile"
    exit 1
fi

# Extraer variables del Makefile
PROJECT_NAME=$(grep "PROJECT_NAME" Makefile | cut -d'=' -f2 | tr -d ' ')
BUILD_LEVEL=$(grep "BUILD_LEVEL" Makefile | cut -d'=' -f2 | tr -d ' ')
ASM_PATH=$(grep "ASM_PATH" Makefile | cut -d'=' -f2 | sed 's/$(CURDIR)\///' | tr -d ' ')
BASIC_PATH=$(grep "BASIC_PATH" Makefile | cut -d'=' -f2 | sed 's/$(CURDIR)\///' | tr -d ' ')

# Crear dev8bp.conf
cat > dev8bp.conf << EOF
PROJECT_NAME=$PROJECT_NAME
BUILD_LEVEL=$BUILD_LEVEL
BP_ASM_PATH="$ASM_PATH"
BASIC_PATH="$BASIC_PATH"
OBJ_DIR="obj"
DIST_DIR="dist"
DSK="\${PROJECT_NAME}.dsk"
EOF

echo "✓ dev8bp.conf creado"
echo "✓ Puedes eliminar el Makefile"
echo "✓ Usa 'dev8bp build' para compilar"
```

### 📚 Documentación

- README.md actualizado con guía completa
- Ejemplos de uso para cada comando
- Solución de problemas
- Guía de configuración detallada

### 🎯 Ventajas del Nuevo Sistema

#### Para Usuarios
- ✅ Más simple de usar
- ✅ Mensajes más claros
- ✅ Validaciones automáticas
- ✅ Configuración más intuitiva
- ✅ No necesitas aprender Make

#### Para Desarrolladores
- ✅ Código más fácil de mantener
- ✅ Más fácil de debuggear
- ✅ Más flexible y extensible
- ✅ Mejor separación de responsabilidades

### 🐛 Bugs Corregidos

- ✅ Verificación correcta de límites de gráficos
- ✅ Manejo correcto de rutas con espacios
- ✅ Detección automática de plataforma y arquitectura
- ✅ Cierre correcto de sesiones anteriores del emulador

### 🙏 Agradecimientos

- **[jjaranda13](https://github.com/jjaranda13)** - Creador de 8BP
- **[fragarco](https://github.com/fragarco)** - Creador de ABASM

---

## v1.x - Sistema Make (Histórico)

Sistema anterior basado en Makefiles. Ver commits anteriores para más información.

---

**Nota:** Este es un cambio mayor que mejora significativamente la experiencia de usuario. El sistema anterior basado en Make ya no está soportado.
