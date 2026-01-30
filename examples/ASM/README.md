# asm

Proyecto creado con **DevCPC CLI** (tipo: **ASM**).

## Tipo de Proyecto: ASM

Proyecto **ensamblador** puro para desarrollo en Z80.
Configuración mínima, activa las rutas que necesites en `devcpc.conf`.

## Estructura

```
asm/
├── devcpc.conf      # Configuración del proyecto
├── src/             # Código fuente



├── assets/          # Recursos (sprites, pantallas)
├── raw/             # Archivos binarios sin procesar

├── obj/             # Archivos intermedios (generado)
└── dist/            # DSK/CDT final (generado)
```

## Variables de Configuración Activas

Este proyecto **ASM** está preconfigurado para compilación ASM pura (sin 8BP):

### Variables Principales

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `PROJECT_NAME` | `"asm"` | Nombre del proyecto (se usa para DSK/CDT) |

### Variables de Compilación ASM (Activas)

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `LOADADDR` | `0x1200` | ✅ Dirección de carga en memoria (hex) |
| `SOURCE` | `"main"` | ✅ Archivo fuente (sin extensión .asm) |
| `TARGET` | `"helloworld"` | ✅ Nombre del binario generado |

> **Nota:** Estas variables solo se usan cuando `BUILD_LEVEL` **no está definido**. Para proyectos 8BP, `BUILD_LEVEL` define automáticamente estos valores.

### Variables Desactivadas (Comentadas)

**Todas las rutas de código están comentadas**. Activa las que necesites:

- `ASM_PATH` - Ruta al código ensamblador principal
- `BASIC_PATH` - Si necesitas archivos BASIC
- `RAW_PATH` - Archivos binarios sin encabezado
- `C_PATH` / `C_SOURCE` - Si quieres compilar código C
- `BUILD_LEVEL` - Solo para proyectos 8BP (desactiva LOADADDR/SOURCE/TARGET)

### Conversión de Gráficos (Opcional)

Para convertir gráficos PNG, descomenta en `devcpc.conf`:

```bash
SPRITES_PATH="assets/sprites"
SPRITES_OUT_FILE="src/sprites.asm"
LOADER_SCREEN="assets/screen"
MODE=0  # 0=16 colores, 1=4, 2=2
```

### Salida

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `DSK` | `"${PROJECT_NAME}.dsk"` | ✅ Imagen de disco |
| `CDT` | `"${PROJECT_NAME}.cdt"` | Imagen de cinta (opcional) |

### Ejemplo: Proyecto ASM sin 8BP

1. Edita `devcpc.conf`:

```bash
# Activar ruta ASM
ASM_PATH="src/main.asm"

# Configurar compilación
LOADADDR=0x4000      # Dirección de carga
SOURCE="main"       # Tu archivo main.asm
TARGET="myprog"     # Genera myprog.bin
```

2. Crea `src/main.asm` con tu código Z80
3. Compila: `devcpc build`

El resultado será `obj/myprog.bin` cargado en &4000.

## Uso Rápido

```bash
# Compilar proyecto
devcpc build

# Limpiar archivos generados
devcpc clean

# Ejecutar en emulador
devcpc run              # Auto-detecta DSK o CDT
devcpc run --dsk        # Forzar DSK
devcpc run --cdt        # Forzar CDT

# Ver información del proyecto
devcpc info

# Validar configuración
devcpc validate
```

## Emulador (Opcional)

Para usar `devcpc run`, configura en `devcpc.conf`:

```bash
RVM_PATH="/ruta/a/RetroVirtualMachine"
CPC_MODEL=464        # o 664, 6128
RUN_MODE="auto"      # auto, dsk o cdt
```

## 🔄 Conversión entre Tipos de Proyecto

> **Nota:** Este tipo de proyecto (ASM) es solo un punto de partida. Puedes **transformar cualquier proyecto en otro tipo** simplemente editando las variables en `devcpc.conf` y creando las carpetas necesarias.

**Ejemplos de conversión:**

- **BASIC → 8BP**: Descomenta `ASM_PATH`, añade `BUILD_LEVEL=0`, crea carpeta `asm/`
- **ASM → 8BP**: Descomenta `BUILD_LEVEL`, ajusta `ASM_PATH` para usar 8BP, añade `BASIC_PATH`
- **8BP → BASIC**: Comenta `ASM_PATH` y `BUILD_LEVEL`, usa solo `BASIC_PATH`
- **Cualquiera → Híbrido**: Activa múltiples rutas (`ASM_PATH`, `BASIC_PATH`, `C_PATH`) según necesites

**La configuración es completamente flexible.** Las plantillas solo preconfiguran las variables más comunes para cada tipo, pero puedes personalizar tu proyecto como prefieras.

## Documentación Completa

- **DevCPC**: https://github.com/destroyer-dcf/DevCPC

