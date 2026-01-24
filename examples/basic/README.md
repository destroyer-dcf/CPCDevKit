# basic

Proyecto creado con **DevCPC CLI** (tipo: **BASIC**).

## Tipo de Proyecto: BASIC

Proyecto **BASIC** puro para desarrollo sin ensamblador.
Incluye soporte para archivos BASIC (.bas) y recursos como pantalla de carga.

## Estructura

```
basic/
├── devcpc.conf      # Configuración del proyecto
├── src/             # Código fuente



├── assets/          # Recursos (sprites, pantallas)
├── raw/             # Archivos binarios sin procesar

├── obj/             # Archivos intermedios (generado)
└── dist/            # DSK/CDT final (generado)
```

## Variables de Configuración Activas

Este proyecto **BASIC** tiene estas variables activas en `devcpc.conf`:

### Variables Principales

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `PROJECT_NAME` | `"basic"` | Nombre del proyecto (se usa para DSK/CDT) |

### Rutas de Código (Activas)

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `BASIC_PATH` | `"src"` | ✅ Carpeta con archivos BASIC (.bas) |
| `RAW_PATH` | `"raw"` | ✅ Archivos binarios sin encabezado AMSDOS |

### Variables Desactivadas (Comentadas)

Estas variables están **comentadas** en `devcpc.conf`. Descoméntalas si las necesitas:

- `BUILD_LEVEL` - Solo para proyectos 8BP (no aplicable aquí)
- `ASM_PATH` - Si necesitas añadir código ensamblador
- `C_PATH` / `C_SOURCE` - Si quieres compilar código C
- `SPRITES_PATH` - Para convertir PNG a ASM
- `LOADER_SCREEN` - Para pantallas de carga PNG → SCN

### Conversión de Gráficos (Opcional)

Para usar pantallas de carga, descomenta en `devcpc.conf`:

```bash
LOADER_SCREEN="assets/screen"
MODE=0  # 0=16 colores, 1=4, 2=2
```

### Salida

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `DSK` | `"${PROJECT_NAME}.dsk"` | ✅ Imagen de disco |
| `CDT` | `"${PROJECT_NAME}.cdt"` | Imagen de cinta (opcional) |

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

## Documentación Completa

- **DevCPC**: https://github.com/destroyer-dcf/DevCPC

