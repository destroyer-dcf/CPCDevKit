# my_game

Proyecto creado con DevCPC CLI.

## Estructura

```
my_game/
├── devcpc.conf      # Configuración del proyecto
├── ASM/             # Código ensamblador 8BP
├── bas/             # Archivos BASIC
├── assets/          # Recursos del proyecto
│   ├── sprites/     # Sprites PNG (se convierten a ASM automáticamente)
│   └── screen/      # Pantallas de carga PNG (se convierten a SCN)
├── raw/             # Archivos binarios sin procesar
├── MUSIC/           # Archivos de música
├── obj/             # Archivos intermedios (generado)
└── dist/            # Imagen DSK final (generado)
```

## Uso

```bash
# Compilar
devcpc build

# Limpiar
devcpc clean

# Ejecutar en emulador
devcpc run

# Ver configuración
devcpc info
```

## Configuración

Edita `devcpc.conf` para configurar tu proyecto:
- Nivel de compilación (BUILD_LEVEL)
- Rutas de código (ASM_PATH, BASIC_PATH, etc.)
- Configuración del emulador

## Documentación

https://github.com/destroyer-dcf/DevCPC
