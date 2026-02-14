# 8bp

Proyecto creado con **DevCPC CLI** (tipo: **8BP**).

## Tipo de Proyecto: 8BP

Proyecto completo con librería **8BP** para desarrollo de juegos.
Incluye soporte para ASM, BASIC, sprites PNG, pantallas de carga, música y código C.

## Estructura

```
8bp/
├── devcpc.conf      # Configuración del proyecto
├── src/             # Código fuente



├── assets/          # Recursos (sprites, pantallas)


├── obj/             # Archivos intermedios (generado)
└── dist/            # DSK/CDT final (generado)
```

## Variables de Configuración Activas

Este proyecto **8BP** tiene estas variables activas en `devcpc.conf`:

### Variables Principales

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `PROJECT_NAME` | `"8bp"` | Nombre del proyecto (se usa para DSK/CDT) |
| `BUILD_LEVEL` | `0` | ✅ **Nivel de compilación 8BP** (0-4) |

### Rutas de Código (Todas Activas)

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `ASM_PATH` | `"asm/make_all_mygame.asm"` | ✅ Código ASM principal de 8BP |
| `BASIC_PATH` | `"bas"` | ✅ Archivos BASIC (loaders) |
| `RAW_PATH` | `"raw"` | ✅ Archivos binarios sin encabezado AMSDOS |
| `C_PATH` | `"c"` | ✅ Código C (opcional) |
| `C_SOURCE` | `"ciclo.c"` | ✅ Archivo fuente C principal |
| `C_CODE_LOC` | `20000` | ✅ Dirección de carga del código C |

### Conversión de Gráficos

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `SPRITES_PATH` | `"assets/sprites"` | Ruta a PNG de sprites → ASM |
| `SPRITES_OUT_FILE` | `"asm/sprites.asm"` | Archivo ASM de salida para sprites |
| `MODE` | `0` | Modo CPC: 0=16 colores, 1=4, 2=2 |
| `LOADER_SCREEN` | `"assets/screen"` | Ruta a PNG de pantallas de carga → SCN |

### Salida

| Variable | Valor | Descripción |
|----------|-------|-------------|
| `DSK` | `"${PROJECT_NAME}.dsk"` | ✅ Imagen de disco |
| `CDT` | `"${PROJECT_NAME}.cdt"` | ✅ Imagen de cinta |
| `CDT_FILES` | `"loader.bas 8BP0.bin"` | Archivos a incluir en CDT (en orden) |

### Niveles de Compilación 8BP (BUILD_LEVEL)

| Nivel | Descripción | MEMORY | Funcionalidades |
|-------|-------------|--------|-----------------|
| 0 | Todas | 23599 | \|LAYOUT, \|COLAY, \|MAP2SP, \|UMA, \|3D |
| 1 | Laberintos | 24999 | \|LAYOUT, \|COLAY |
| 2 | Scroll | 24799 | \|MAP2SP, \|UMA |
| 3 | Pseudo-3D | 23999 | \|3D |
| 4 | Básico | 25299 | Sin scroll/layout |

Edita `BUILD_LEVEL` en `devcpc.conf` según las funcionalidades que necesites.

### Variables de Compilación ASM (Comentadas)

> **Nota:** `BUILD_LEVEL` define automáticamente estas variables. Solo descoméntalas si comentas `BUILD_LEVEL` y quieres compilación ASM sin 8BP.

| Variable | Descripción |
|----------|-------------|
| `LOADADDR` | Dirección de carga en memoria (hex) |
| `SOURCE` | Archivo fuente (sin .asm) |
| `TARGET` | Nombre del binario generado |

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

> **Nota:** Este tipo de proyecto (8BP) es solo un punto de partida. Puedes **transformar cualquier proyecto en otro tipo** simplemente editando las variables en `devcpc.conf` y creando las carpetas necesarias.

**Ejemplos de conversión:**

- **BASIC → 8BP**: Descomenta `ASM_PATH`, añade `BUILD_LEVEL=0`, crea carpeta `asm/`
- **ASM → 8BP**: Descomenta `BUILD_LEVEL`, ajusta `ASM_PATH` para usar 8BP, añade `BASIC_PATH`
- **8BP → BASIC**: Comenta `ASM_PATH` y `BUILD_LEVEL`, usa solo `BASIC_PATH`
- **Cualquiera → Híbrido**: Activa múltiples rutas (`ASM_PATH`, `BASIC_PATH`, `C_PATH`) según necesites

**La configuración es completamente flexible.** Las plantillas solo preconfiguran las variables más comunes para cada tipo, pero puedes personalizar tu proyecto como prefieras.

## Documentación Completa

- **DevCPC**: https://github.com/destroyer-dcf/DevCPC
- **8BP**: https://github.com/jjaranda13/8BP
