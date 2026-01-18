# Proyecto de Ejemplo - Dev8BP

Este es un proyecto de ejemplo que muestra cómo usar Dev8BP CLI.

## Contenido

- **ASM/** - Código ensamblador 8BP
- **bas/** - Archivos BASIC
- **raw/** - Archivos RAW
- **C/** - Código C (ejemplo con SDCC)
- **MUSIC/** - Archivos de música
- **assets/sprites/** - Sprites PNG para convertir a ASM
- **assets/screen/** - Pantallas PNG para convertir a SCN
- **dev8bp.conf** - Configuración del proyecto

## Uso

### Compilar

```bash
# Desde el directorio examples
dev8bp build
```

### Limpiar

```bash
dev8bp clean
```

### Ver configuración

```bash
dev8bp info
```

### Validar

```bash
dev8bp validate
```

### Ejecutar en emulador

```bash
dev8bp run
```

## Estructura generada

Después de compilar, se crean:

- **obj/** - Archivos intermedios (bin, lst, map, scn, scn.info)
- **dist/** - Imagen DSK final con todos los archivos

### Archivos en obj/

- `8BP0.bin` - Binario compilado de 8BP
- `*.lst` - Listados de ensamblado
- `*.map` - Mapas de memoria
- `*.scn` - Pantallas convertidas (si LOADER_SCREEN está configurado)
- `*.scn.info` - Información de paleta de las pantallas
- `sprites.asm` - Sprites generados (si SPRITES_PATH está configurado)

## Configuración

Edita `dev8bp.conf` para cambiar:
- Nombre del proyecto
- Nivel de compilación
- Rutas de código
- Configuración del emulador
- Conversión de gráficos (sprites y pantallas)

### Conversión de Gráficos

Este proyecto de ejemplo incluye:

**Sprites (PNG → ASM):**
```bash
SPRITES_PATH="assets/sprites"    # Ruta a los PNG
SPRITES_OUT_FILE="ASM/sprites.asm"  # Archivo ASM generado
SPRITES_TOLERANCE=-1              # Tolerancia de color
```

**Pantallas de Carga (PNG → SCN):**
```bash
LOADER_SCREEN="assets/screen"     # Ruta a las pantallas PNG
MODE=0                            # Modo CPC (0=16 colores)
```

Las pantallas SCN se generan automáticamente y se añaden al DSK durante la compilación.

### Ver las pantallas en el emulador

Desde BASIC:
```basic
10 MODE 0
20 LOAD"DEV8BP.SCN",&C000
30 REM Configurar paleta (ver obj/dev8bp.scn.info)
```
