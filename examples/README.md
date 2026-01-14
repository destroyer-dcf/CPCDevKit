# Proyecto de Ejemplo - Dev8BP

Este es un proyecto de ejemplo que muestra cómo usar Dev8BP CLI.

## Contenido

- **ASM/** - Código ensamblador 8BP
- **bas/** - Archivos BASIC
- **raw/** - Archivos RAW
- **C/** - Código C (ejemplo con SDCC)
- **MUSIC/** - Archivos de música
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

- **obj/** - Archivos intermedios (bin, lst, map)
- **dist/** - Imagen DSK final

## Configuración

Edita `dev8bp.conf` para cambiar:
- Nombre del proyecto
- Nivel de compilación
- Rutas de código
- Configuración del emulador
