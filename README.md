# Dev8BP CLI - Sistema de Compilación para 8BP

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.md)
[![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20Windows%20WSL-lightgrey.svg)]()
[![Python](https://img.shields.io/badge/python-3.x-blue.svg)](https://www.python.org/)
[![ABASM](https://img.shields.io/badge/ABASM-1.4.0-green.svg)](https://github.com/fragarco/abasm)
[![Amstrad CPC](https://img.shields.io/badge/Amstrad-CPC-red.svg)]()
[![8BP](https://img.shields.io/badge/8BP-v0.43-purple.svg)](https://github.com/jjaranda13/8BP)

Sistema de compilación moderno basado en scripts bash para [8BP](https://github.com/jjaranda13/8BP). **Más simple, más amigable, más potente que Makefiles.**

---

## 🎯 ¿Por qué Dev8BP CLI?

Esta idea nace de la necesidad de poder compilar la librería [8BP](https://github.com/jjaranda13/8BP) para Amstrad CPC en sistemas operativos que no fueran Windows de forma nativa. Gracias al ensamblador [ABASM](https://github.com/fragarco/abasm) creado por [fragarco](https://github.com/fragarco) todo esto ha sido posible.

---

## � ¿Qué incluye?

### Compilación automatizada
- ✅ **8BP** - Librería de programación para Amstrad CPC
- ✅ **ASM** - Código ensamblador 8BP (make_all_*.asm)
- ✅ **BASIC** - Archivos BASIC (se añaden al DSK)
- ✅ **RAW** - Archivos binarios sin encabezado AMSDOS
- ✅ **C** - Código C compilado con SDCC
- ✅ **8BP0.BIN** - Archivo binario de 8BP (make_all_*.bin)
- ✅ **MI_JUEGO.DSK** - Generacion de DSK

### Herramientas integradas
- ✅ **ABASM** - Ensamblador para Z80
- ✅ **dsk.py** - Gestión de imágenes DSK
- ✅ **hex2bin** - Conversión para código C (multiplataforma)

### Plataformas soportadas
- ✅ macOS (ARM64 y x86_64)
- ✅ Linux (ARM64 y x86_64)
- ✅ Windows (WSL o Git Bash)

## 📦 Requisitos
- **Python 3.x** (para scripts)
- **ABASM** (ensamblador Z80) - instalado automáticamente
- **SDCC** (compilador C) - opcional, solo si usas C
- **RetroVirtualMachine** - opcional, solo si usas `dev8bp run`

### 📌 Roadmap
- 🚧 Conversion de imagenes a asm 
- 🚧 Muestra información de compilación
- 🚧 Pruebas sobre M4Board
- 🚧 Soporte para proyectos asm (No 8BP)


---

## 🚀 Como Empezar

### 1. Instalación

```bash
# Clonar el repositorio
git clone https://github.com/destroyer-dcf/Dev8BP.git
cd Dev8BP

# Ejecutar instalación
./setup.sh

# Recargar shell
source ~/.bashrc  # o ~/.zshrc en macOS
```

### 2. Crear tu primer proyecto

```bash
# Crear nuevo proyecto
dev8bp new mi-juego

# Ver la estructura creada
ls -la
```

### 3. Configurar el proyecto

Edita `dev8bp.conf` según tus necesidades:

```bash
# Configuración básica
PROJECT_NAME="mi-juego"
BUILD_LEVEL=0

# Rutas (comenta las que no uses)
BP_ASM_PATH="ASM"
BASIC_PATH="bas"
#RAW_PATH="raw"
#C_PATH="C"
```

### 4. Añadir tu código

```bash
# Copiar tus archivos ASM
cp /ruta/a/tus/archivos/*.asm ASM/

# Copiar archivos BASIC
cp /ruta/a/tus/archivos/*.bas bas/
```

### 5. Compilar

```bash
# Compilar todo
dev8bp build

# Ver el resultado
ls -la dist/
```

### 6. Ejecutar (opcional)

```bash
# Configurar emulador en dev8bp.conf
# RVM_PATH="/ruta/a/RetroVirtualMachine"
# CPC_MODEL=464
# RUN_FILE="8BP0.BIN"

# Ejecutar
dev8bp run
```

---

## 📚 Comandos Disponibles

### `dev8bp new <nombre>`
Crea un nuevo proyecto con estructura completa.

```bash
dev8bp new mi-super-juego
```

**Crea:**
- Directorios: `ASM/`, `bas/`, `obj/`, `dist/`
- Archivo de configuración: `dev8bp.conf`
- `README.md` con instrucciones
- `.gitignore` configurado

---

### `dev8bp build`
Compila el proyecto completo.

```bash
dev8bp build
```

**Proceso:**
1. ✅ Compila código ASM con ABASM (si `BP_ASM_PATH` está definido)
2. ✅ Verifica límites de gráficos (`_END_GRAPH < 42040`)
3. ✅ Crea imagen DSK
4. ✅ Añade binario ASM al DSK (8BP0.bin, 8BP1.bin, etc.)
5. ✅ Añade archivos BASIC al DSK (si `BASIC_PATH` está definido)
6. ✅ Añade archivos RAW al DSK (si `RAW_PATH` está definido)
7. ✅ Compila código C con SDCC (si `C_PATH` está definido)
8. ✅ Verifica límites de memoria C (< 23999)
9. ✅ Muestra catálogo del DSK


**Ejemplo de salida:**
```
═══════════════════════════════════════
  Compilar Proyecto: mi-juego
═══════════════════════════════════════

ℹ Build Level: 0 (Todas las funcionalidades)
ℹ Memoria BASIC: MEMORY 23599

✓ Compilación exitosa
✓ Límite de gráficos respetado (< 42040)
✓ DSK creado
✓ 1 archivo(s) BASIC añadidos

Catálogo del DSK:
0: 8BP0    .BIN  [ st: 0 extend: 0 data pages: 128 ]
1: LOADER  .BAS  [ st: 0 extend: 0 data pages: 3 ]

✓ Proyecto compilado exitosamente
```

---

### `dev8bp clean`
Limpia archivos generados.

```bash
dev8bp clean
```

**Elimina:**
- Directorio `obj/` (archivos intermedios)
- Directorio `dist/` (DSK generado)
- Archivos backup en `ASM/` (*.backup, *.bak)

---

### `dev8bp info`
Muestra la configuración del proyecto.

```bash
dev8bp info
```

**Muestra:**
- Nombre del proyecto
- Build level y descripción
- Rutas configuradas
- Directorios de salida
- Configuración del emulador

**Ejemplo:**
```
═══════════════════════════════════════
  Configuración del Proyecto
═══════════════════════════════════════

Proyecto:        mi-juego
Build Level:     0

Rutas configuradas:
  ✓ ASM:    ASM
  ✓ BASIC:  bas

Directorios:
  Objetos:  obj
  Salida:   dist
  DSK:      mi-juego.dsk
```

---

### `dev8bp validate`
Valida el proyecto antes de compilar.

```bash
dev8bp validate
```

**Verifica:**
- ✅ Configuración correcta
- ✅ Rutas existen
- ✅ Archivos necesarios presentes
- ✅ Herramientas instaladas (Python, SDCC)

**Ejemplo:**
```
═══════════════════════════════════════
  Validar Proyecto: mi-juego
═══════════════════════════════════════

→ Validando configuración...
✓ PROJECT_NAME: mi-juego
✓ BUILD_LEVEL: 0 (Todas las funcionalidades)

→ Validando rutas...
✓ BP_ASM_PATH: ASM
✓   make_all_mygame.asm encontrado
✓ BASIC_PATH: bas (2 archivo(s) .bas)

→ Validando herramientas...
✓ Python 3 instalado

═══════════════════════════════════════
  Resumen de Validación
═══════════════════════════════════════

✓ Proyecto válido - Sin errores ni advertencias
```

---

### `dev8bp run`
Ejecuta el DSK en RetroVirtualMachine.

```bash
dev8bp run
```

**Requisitos:**
- RetroVirtualMachine instalado
- `RVM_PATH` configurado en `dev8bp.conf`

**Características:**
- Cierra sesiones anteriores automáticamente
- Carga el DSK generado
- Auto-ejecuta archivo si `RUN_FILE` está configurado

> **‼️ Importante:**
> Para poder probar sobre el Emulador RetroVirtualMachine, es necesario tener instalada la version **v2.0 BETA-1 R7 10/07/2019** Que tal y como informa su desarrollador en la [Web](https://www.retrovirtualmachine.org/blog/future/) es la que tiene habilitada la funcionalidad para desarrollo.

---

### `dev8bp help`
Muestra ayuda general.

```bash
dev8bp help
```

---

### `dev8bp version`
Muestra la versión.

```bash
dev8bp version
```

---

## ⚙️ Configuración (dev8bp.conf)

### Configuración básica

```bash
# Nombre del proyecto (usado para el DSK)
PROJECT_NAME="MI_JUEGO"

# Nivel de compilación (0-4)
BUILD_LEVEL=0
```

### Niveles de compilación 8BP

| Nivel | Descripción | MEMORY | Comandos | Tamaño |
|-------|-------------|--------|----------|--------|
| **0** | Todas las funcionalidades | 23599 | \|LAYOUT, \|COLAY, \|MAP2SP, \|UMA, \|3D | 19120 bytes |
| **1** | Juegos de laberintos | 24999 | \|LAYOUT, \|COLAY | 17620 bytes |
| **2** | Juegos con scroll | 24799 | \|MAP2SP, \|UMA | 17820 bytes |
| **3** | Juegos pseudo-3D | 23999 | \|3D | 18620 bytes |
| **4** | Sin scroll/layout | 25299 | Básicos | 17320 bytes |

### Rutas opcionales

```bash
# Código ensamblador 8BP
BP_ASM_PATH="ASM"

# Archivos BASIC (se añaden al DSK automáticamente)
BASIC_PATH="bas"

# Archivos RAW (se añaden sin encabezado AMSDOS)
RAW_PATH="raw"

# Código C (se compila con SDCC)
C_PATH="C"
C_SOURCE="main.c"
C_CODE_LOC=20000
```

**Nota:** 
- `BP_ASM_PATH`: Ruta al código ensamblador 8BP (make_all_mygame.asm)
- Todas las rutas son opcionales - comenta las que no uses
- Solo se procesan las rutas definidas

### Directorios de salida

```bash
# Archivos intermedios (bin, lst, map, ihx)
OBJ_DIR="obj"

# DSK final
DIST_DIR="dist"

# Nombre del DSK
DSK="${PROJECT_NAME}.dsk"
```

### Emulador (opcional)

```bash
# macOS
RVM_PATH="/Applications/Retro Virtual Machine 2.app/Contents/MacOS/Retro Virtual Machine 2"

# Linux
#RVM_PATH="/usr/local/bin/RetroVirtualMachine"

# Windows WSL
#RVM_PATH="/mnt/c/Program Files/RetroVirtualMachine/RetroVirtualMachine.exe"

# Modelo de CPC
CPC_MODEL=464

# Archivo a ejecutar automáticamente
RUN_FILE="8BP0.BIN"
```

---

## 📁 Estructura de Proyecto

### Proyecto típico

```
mi-juego/
├── dev8bp.conf          # Configuración del proyecto
├── README.md            # Documentación
├── .gitignore          # Git ignore
│
├── ASM/                # Código ensamblador 8BP (BP_ASM_PATH)
│   ├── make_all_mygame.asm    # Archivo principal
│   ├── images_mygame.asm      # Gráficos
│   ├── music_mygame.asm       # Música
│   └── ...
│
├── bas/                # Archivos BASIC (BASIC_PATH)
│   ├── loader.bas      # Cargador
│   └── menu.bas        # Menú
│
├── raw/                # Archivos RAW (RAW_PATH) - opcional
│   └── data.bin        # Datos sin encabezado AMSDOS
│
├── C/                  # Código C (C_PATH) - opcional
│   ├── main.c          # Código principal
│   ├── 8BP_wrapper/    # Wrapper para 8BP
│   └── mini_BASIC/     # Mini BASIC
│
├── obj/                # Generado: archivos intermedios
│   ├── 8BP0.bin        # Binario compilado
│   ├── *.lst           # Listados
│   ├── *.map           # Mapas de memoria
│   └── *.ihx           # Intel HEX (C)
│
└── dist/               # Generado: DSK final
    └── mi-juego.dsk    # Imagen DSK lista para usar
```

### Variables de configuración

| Variable | Descripción | Ejemplo | Requerido |
|----------|-------------|---------|-----------|
| `PROJECT_NAME` | Nombre del proyecto | `"MI_JUEGO"` | ✅ Sí |
| `BUILD_LEVEL` | Nivel de compilación (0-4) | `0` | ✅ Sí |
| `BP_ASM_PATH` | Ruta al código ASM 8BP | `"ASM"` | ❌ Opcional |
| `BASIC_PATH` | Ruta a archivos BASIC | `"bas"` | ❌ Opcional |
| `RAW_PATH` | Ruta a archivos RAW | `"raw"` | ❌ Opcional |
| `C_PATH` | Ruta a código C | `"C"` | ❌ Opcional |
| `C_SOURCE` | Archivo C principal | `"main.c"` | ❌ Si C_PATH |
| `C_CODE_LOC` | Dirección de carga C | `20000` | ❌ Si C_PATH |
| `OBJ_DIR` | Directorio objetos | `"obj"` | ❌ Opcional |
| `DIST_DIR` | Directorio salida | `"dist"` | ❌ Opcional |
| `DSK` | Nombre del DSK | `"${PROJECT_NAME}.dsk"` | ❌ Opcional |
| `RVM_PATH` | Ruta al emulador | `"/path/to/RVM"` | ❌ Opcional |
| `CPC_MODEL` | Modelo de CPC | `464` | ❌ Opcional |
| `RUN_FILE` | Archivo a ejecutar | `"8BP0.BIN"` | ❌ Opcional |

---

## 🔧 Compilación de Código C

### Requisitos

1. **SDCC instalado**
   ```bash
   # macOS
   brew install sdcc
   
   # Linux
   sudo apt-get install sdcc
   
   # Verificar
   sdcc --version
   ```

2. **Estructura de carpetas**
   ```
   C/
   ├── main.c
   ├── 8BP_wrapper/
   │   └── 8BP.h
   └── mini_BASIC/
       └── minibasic.h
   ```

### Configuración

```bash
C_PATH="C"
C_SOURCE="main.c"
C_CODE_LOC=20000    # Dirección de carga (debe ser < 23999)
```

### Límites de memoria

‼️ **Importante:** El código C no debe exceder la dirección **23999 (0x5DBF)** para no destruir la librería 8BP.

**Si excedes el límite:**
```bash
# Usa una dirección más baja
C_CODE_LOC=19000

# Y en BASIC:
MEMORY 18999
```

### Uso desde BASIC

```basic
10 REM Cargar 8BP con gráficos
20 MEMORY 23599
30 LOAD"8BP0.bin"
40 CALL &6B78
50 REM Cargar tu código C
60 LOAD"main.BIN",20000
70 CALL &56B0    ' Dirección de _main (ver .map)
```

---

## 🎮 Uso con RetroVirtualMachine

### Configuración

```bash
# En dev8bp.conf
RVM_PATH="/Applications/Retro Virtual Machine 2.app/Contents/MacOS/Retro Virtual Machine 2"
CPC_MODEL=464
RUN_FILE="8BP0.BIN"
```

### Ejecutar

```bash
# Compilar y ejecutar
dev8bp build && dev8bp run

# Solo ejecutar (si ya compilaste)
dev8bp run
```

### Características

- ✅ Cierra sesiones anteriores automáticamente
- ✅ Carga el DSK generado
- ✅ Auto-ejecuta el archivo especificado
- ✅ Funciona en background

---

## ❓ Preguntas Frecuentes (FAQ)

### ¿Por qué BP_ASM_PATH y no ASM_PATH?

Las variables en bash no pueden empezar con números. `8BP_ASM_PATH` no es válido, por lo que usamos `BP_ASM_PATH` (BP = 8-Bit Power).

### ¿Puedo usar solo BASIC sin ASM?

Sí, todas las rutas son opcionales. Simplemente comenta `BP_ASM_PATH` en tu `dev8bp.conf`:

```bash
#BP_ASM_PATH="ASM"
BASIC_PATH="bas"
```

### ¿Qué es BUILD_LEVEL?

El BUILD_LEVEL determina qué funcionalidades de 8BP se incluyen:

- **0**: Todas las funcionalidades (19120 bytes, MEMORY 23599)
- **1**: Solo laberintos (17620 bytes, MEMORY 24999)
- **2**: Solo scroll (17820 bytes, MEMORY 24799)
- **3**: Solo pseudo-3D (18620 bytes, MEMORY 23999)
- **4**: Básico sin scroll/layout (17320 bytes, MEMORY 25299)

Usa el nivel más alto posible para tener más memoria BASIC disponible.

### ¿Cómo sé qué BUILD_LEVEL usar?

Depende de los comandos 8BP que uses en tu juego:

- Usas `|LAYOUT` o `|COLAY`? → Nivel 0 o 1
- Usas `|MAP2SP` o `|UMA`? → Nivel 0 o 2
- Usas `|3D`? → Nivel 0 o 3
- No usas ninguno? → Nivel 4

### ¿Puedo cambiar BUILD_LEVEL después?

Sí, simplemente cambia el valor en `dev8bp.conf` y recompila:

```bash
# Editar dev8bp.conf
BUILD_LEVEL=2

# Recompilar
dev8bp clean
dev8bp build
```

### ¿Qué hace make_all_mygame.asm?

Es el archivo principal que incluye todos los demás archivos ASM de tu proyecto. Dev8BP modifica automáticamente la variable `ASSEMBLING_OPTION` en este archivo según tu `BUILD_LEVEL`.

### ¿Puedo usar mi propio ensamblador?

No, Dev8BP está diseñado específicamente para usar ABASM con la librería 8BP. ABASM está incluido y no necesitas instalarlo.

### ¿Funciona en Windows?

Sí, pero necesitas WSL (Windows Subsystem for Linux) o Git Bash. El sistema está diseñado para entornos Unix (bash).

### ¿Cómo actualizo Dev8BP?

```bash
cd Dev8BP
git pull origin main
./setup.sh
```

### ¿Dónde está la documentación de 8BP?

La documentación completa de 8BP está en el [repositorio oficial de 8BP](https://github.com/jjaranda13/8BP).

### ¿Puedo contribuir al proyecto?

¡Por supuesto! Abre un issue o pull request en GitHub.

---

## 🐛 Solución de Problemas

### Error: "ABASM no encontrado"

```bash
# Verificar que Dev8bp/tools/abasm existe
ls -la Dev8bp/tools/abasm/

# Si no existe, reinstalar
./setup.sh
```

### Error: "Python no encontrado"

```bash
# Instalar Python 3
# macOS
brew install python3

# Linux
sudo apt-get install python3

# Verificar
python3 --version
```

### Error: "SDCC no instalado"

```bash
# Solo necesario si compilas código C
# macOS
brew install sdcc

# Linux
sudo apt-get install sdcc
```

### Error: "_END_GRAPH excede 42040"

Tu proyecto usa demasiados gráficos (más de 8440 bytes). **Soluciones:**

1. **Reducir gráficos** - Elimina sprites o tiles no usados
2. **Optimizar gráficos** - Comprime o reutiliza tiles
3. **Ensamblar en otra zona de memoria:**
   ```asm
   ; En tu código ASM (make_all_mygame.asm)
   org 22000
   ; Gráficos extra aquí
   incbin "extra_graphics.bin"
   ```
   ```basic
   ' En BASIC
   MEMORY 21999
   ```

**Explicación:** La librería 8BP usa memoria desde 33600 hasta 42040 (8440 bytes) para gráficos. Si `_END_GRAPH >= 42040`, estarás sobrescribiendo el intérprete BASIC.

### Error: "Código C excede 23999"

Tu código C es demasiado grande y sobrescribe la librería 8BP. **Soluciones:**

1. **Usar dirección más baja:**
   ```bash
   # En dev8bp.conf
   C_CODE_LOC=19000
   ```
   ```basic
   ' En BASIC
   MEMORY 18999
   ```

2. **Optimizar código:**
   - Usa flags de optimización de SDCC
   - Reduce el tamaño del código
   - Elimina funciones no usadas

3. **Verificar el .map:**
   ```bash
   # Ver el archivo obj/main.map
   cat obj/main.map | grep "Highest address"
   ```

**Explicación:** La librería 8BP se carga en 23600-42620. Tu código C debe estar por debajo de 23999 para no destruirla.

---

## 💡 Consejos y Trucos

### Workflow recomendado

```bash
# 1. Validar antes de compilar
dev8bp validate

# 2. Compilar
dev8bp build

# 3. Si hay errores, limpiar y reintentar
dev8bp clean
dev8bp build

# 4. Ejecutar para probar
dev8bp run
```

### Organización de código ASM

```
ASM/
├── make_all_mygame.asm      # Archivo principal (incluye todo)
├── images_mygame.asm        # Definición de gráficos
├── music_mygame.asm         # Música y efectos
├── sprites/                 # Sprites individuales
│   ├── player.asm
│   └── enemies.asm
└── tiles/                   # Tiles del mapa
    └── tileset.asm
```

### Variables importantes en make_all_mygame.asm

```asm
; Nivel de compilación (modificado automáticamente por dev8bp)
let ASSEMBLING_OPTION = 0

; Etiquetas importantes
_START_GRAPH:     ; Inicio de gráficos (33600)
_END_GRAPH:       ; Fin de gráficos (debe ser < 42040)
```

### Compilación rápida

```bash
# Alias útil (añadir a ~/.bashrc)
alias d8b='dev8bp'

# Uso
d8b build
d8b run
```

### Ver solo errores

```bash
dev8bp build 2>&1 | grep -E "(✗|Error)"
```

### Compilar múltiples niveles

```bash
# Compilar nivel 0
dev8bp build

# Cambiar a nivel 2 en dev8bp.conf
# BUILD_LEVEL=2

# Compilar nivel 2
dev8bp build
```

---

## 📖 Ejemplos Completos

### Ejemplo 1: Proyecto solo ASM

```bash
# Crear proyecto
dev8bp new juego-asm
cd juego-asm

# Configurar (dev8bp.conf)
PROJECT_NAME="juego-asm"
BUILD_LEVEL=0
BP_ASM_PATH="ASM"

# Copiar código
cp /ruta/a/make_all_mygame.asm ASM/

# Compilar
dev8bp build
```

### Ejemplo 2: Proyecto ASM + BASIC

```bash
# Crear proyecto
dev8bp new juego-completo
cd juego-completo

# Configurar
PROJECT_NAME="juego-completo"
BUILD_LEVEL=0
BP_ASM_PATH="ASM"
BASIC_PATH="bas"

# Copiar archivos
cp /ruta/a/*.asm ASM/
cp /ruta/a/*.bas bas/

# Compilar
dev8bp build
```

### Ejemplo 3: Proyecto con C

```bash
# Crear proyecto
dev8bp new juego-c
cd juego-c

# Configurar
PROJECT_NAME="juego-c"
BUILD_LEVEL=0
BP_ASM_PATH="ASM"
C_PATH="C"
C_SOURCE="main.c"
C_CODE_LOC=20000

# Copiar archivos
cp /ruta/a/*.asm ASM/
cp /ruta/a/main.c C/
cp -r /ruta/a/8BP_wrapper C/
cp -r /ruta/a/mini_BASIC C/

# Compilar
dev8bp build
```

---

## 📄 Licencia

MIT License - Copyright (c) 2026 Destroyer

---

## 🙏 Agradecimientos

- **[jjaranda13](https://github.com/jjaranda13)** - Creador de [8BP](https://github.com/jjaranda13/8BP)
- **[fragarco](https://github.com/fragarco)** - Creador de [ABASM](https://github.com/fragarco/abasm)

---

## 📚 Recursos Adicionales

### Documentación de 8BP

- [Repositorio oficial de 8BP](https://github.com/jjaranda13/8BP)
- [Manual de 8BP (PDF)](https://github.com/jjaranda13/8BP/blob/master/8BP_MANUAL.pdf)
- [Ejemplos de 8BP](https://github.com/jjaranda13/8BP/tree/master/examples)

### Herramientas

- [ABASM - Ensamblador Z80](https://github.com/fragarco/abasm)
- [SDCC - Small Device C Compiler](http://sdcc.sourceforge.net/)
- [RetroVirtualMachine](https://www.retrovirtualmachine.org/)

### Comunidad Amstrad CPC

- [CPCWiki](https://www.cpcwiki.eu/)
- [Amstrad.es](https://www.amstrad.es/)
- [CPCRulez](https://www.cpcrulez.fr/)

### Tutoriales

- [Programación en Z80 para CPC](https://www.cpcwiki.eu/index.php/Programming)
- [Gráficos en Amstrad CPC](https://www.cpcwiki.eu/index.php/Video_modes)
- [Música con WYZTracker](https://www.cpcwiki.eu/index.php/WYZTracker)

---

## 🎮 Showcase

¿Has creado algo con Dev8BP? ¡Compártelo!

Abre un issue en GitHub con:
- Nombre de tu proyecto
- Captura de pantalla o GIF
- Breve descripción
- Link al código (opcional)

---

## 📞 Contacto

© Destroyer 2026 - [destroyer.dcf@gmail.com](mailto:destroyer.dcf@gmail.com)
