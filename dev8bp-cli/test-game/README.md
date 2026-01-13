# test-game

Proyecto creado con Dev8BP CLI.

## Estructura

```
test-game/
├── dev8bp.conf      # Configuración del proyecto
├── ASM/             # Código ensamblador 8BP
├── bas/             # Archivos BASIC
├── obj/             # Archivos intermedios (generado)
└── dist/            # Imagen DSK final (generado)
```

## Uso

```bash
# Compilar
dev8bp build

# Limpiar
dev8bp clean

# Ejecutar en emulador
dev8bp run

# Ver configuración
dev8bp info
```

## Configuración

Edita `dev8bp.conf` para configurar tu proyecto:
- Nivel de compilación (BUILD_LEVEL)
- Rutas de código (ASM_PATH, BASIC_PATH, etc.)
- Configuración del emulador

## Documentación

https://github.com/destroyer-dcf/Dev8BP
