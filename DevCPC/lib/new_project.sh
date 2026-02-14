#!/usr/bin/env bash
# ==============================================================================
# DevCPC CLI - Sistema de compilación para Amstrad CPC
# Copyright (c) 2026 Destroyer
# new_project.sh - Crear nuevo proyecto
# ==============================================================================

new_project() {
    local project_name="$1"
    
    if [[ -z "$project_name" ]]; then
        error "Debes especificar un nombre para el proyecto"
        echo ""
        echo "Uso: devcpc new <nombre>"
        echo ""
        echo "Ejemplo:"
        echo "  devcpc new mi-juego"
        exit 1
    fi
    
    # Validar nombre
    if [[ ! "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        error "El nombre del proyecto solo puede contener letras, números, guiones y guiones bajos"
        exit 1
    fi
    
    # Verificar que no existe
    if [[ -d "$project_name" ]]; then
        error "El directorio '$project_name' ya existe"
        exit 1
    fi
    
    header "Crear Nuevo Proyecto"
    
    info "Nombre del proyecto: $project_name"
    echo ""
    
    # Preguntar tipo de proyecto
    echo -e "${CYAN}¿Qué tipo de proyecto deseas crear?${NC}"
    echo ""
    echo "  1) 8BP       - Proyecto con librería 8BP (ASM + BASIC + sprites + música)"
    echo "  2) BASIC     - Proyecto BASIC puro (solo BASIC + recursos)"
    echo "  3) ASM       - Proyecto ASM sin 8bp (solo ensamblador + recursos)"
    echo ""
    echo -ne "${YELLOW}Selecciona una opción [1-3]:${NC} "
    
    local project_type
    read -r project_type
    
    # Validar selección
    local template_dir
    case "$project_type" in
        1)
            template_dir="8bp"
            info "Tipo seleccionado: 8BP"
            ;;
        2)
            template_dir="basic"
            info "Tipo seleccionado: BASIC"
            ;;
        3)
            template_dir="asm"
            info "Tipo seleccionado: ASM"
            ;;
        *)
            error "Opción inválida. Usa 1, 2 o 3"
            exit 1
            ;;
    esac
    
    echo ""
    
    # Verificar que la plantilla existe
    local template_path="$DEVCPC_CLI_ROOT/templates/$template_dir"
    if [[ ! -d "$template_path" ]]; then
        error "La plantilla '$template_dir' no existe en: $template_path"
        exit 1
    fi
    
    # Copiar estructura de la plantilla
    step "Copiando estructura de plantilla '$template_dir'..."
    cp -r "$template_path" "$project_name"
    success "Estructura copiada"

    # Reemplazar {{PROJECT_NAME}} en el project.conf
    step "Configurando proyecto..."
    if [[ -f "$project_name/project.conf" ]]; then
        sed -i.bak "s/{{PROJECT_NAME}}/$project_name/g" "$project_name/project.conf"
        rm -f "$project_name/project.conf.bak"
        
        # Renombrar project.conf a devcpc.conf
        mv "$project_name/project.conf" "$project_name/devcpc.conf"
    else
        error "No se encontró project.conf en la plantilla"
        exit 1
    fi
    success "Configuración ajustada"
    
    # Crear README específico por tipo
    step "Creando README..."
    
    # Generar sección de configuración específica por tipo
    local readme_config=""
    
    case "$template_dir" in
        8bp)
            readme_config="## Variables de Configuración Activas

Este proyecto **8BP** tiene estas variables activas en \`devcpc.conf\`:

### Variables Principales

| Variable | Valor | Descripción |
|----------|-------|-------------|
| \`PROJECT_NAME\` | \`\"$project_name\"\` | Nombre del proyecto (se usa para DSK/CDT) |
| \`BUILD_LEVEL\` | \`0\` | ✅ **Nivel de compilación 8BP** (0-4) |

### Rutas de Código (Todas Activas)

| Variable | Valor | Descripción |
|----------|-------|-------------|
| \`ASM_PATH\` | \`\"asm/make_all_mygame.asm\"\` | ✅ Código ASM principal de 8BP |
| \`BASIC_PATH\` | \`\"bas\"\` | ✅ Archivos BASIC (loaders) |
| \`RAW_PATH\` | \`\"raw\"\` | ✅ Archivos binarios sin encabezado AMSDOS |
| \`C_PATH\` | \`\"c\"\` | ✅ Código C (opcional) |
| \`C_SOURCE\` | \`\"ciclo.c\"\` | ✅ Archivo fuente C principal |
| \`C_CODE_LOC\` | \`20000\` | ✅ Dirección de carga del código C |

### Conversión de Gráficos

| Variable | Valor | Descripción |
|----------|-------|-------------|
| \`SPRITES_PATH\` | \`\"assets/sprites\"\` | Ruta a PNG de sprites → ASM |
| \`SPRITES_OUT_FILE\` | \`\"asm/sprites.asm\"\` | Archivo ASM de salida para sprites |
| \`MODE\` | \`0\` | Modo CPC: 0=16 colores, 1=4, 2=2 |
| \`LOADER_SCREEN\` | \`\"assets/screen\"\` | Ruta a PNG de pantallas de carga → SCN |

### Salida

| Variable | Valor | Descripción |
|----------|-------|-------------|
| \`DSK\` | \`\"\${PROJECT_NAME}.dsk\"\` | ✅ Imagen de disco |
| \`CDT\` | \`\"\${PROJECT_NAME}.cdt\"\` | ✅ Imagen de cinta |
| \`CDT_FILES\` | \`\"loader.bas 8BP0.bin\"\` | Archivos a incluir en CDT (en orden) |

### Niveles de Compilación 8BP (BUILD_LEVEL)

| Nivel | Descripción | MEMORY | Funcionalidades |
|-------|-------------|--------|-----------------|
| 0 | Todas | 23599 | \|LAYOUT, \|COLAY, \|MAP2SP, \|UMA, \|3D |
| 1 | Laberintos | 24999 | \|LAYOUT, \|COLAY |
| 2 | Scroll | 24799 | \|MAP2SP, \|UMA |
| 3 | Pseudo-3D | 23999 | \|3D |
| 4 | Básico | 25299 | Sin scroll/layout |

Edita \`BUILD_LEVEL\` en \`devcpc.conf\` según las funcionalidades que necesites.

### Variables de Compilación ASM (Comentadas)

> **Nota:** \`BUILD_LEVEL\` define automáticamente estas variables. Solo descoméntalas si comentas \`BUILD_LEVEL\` y quieres compilación ASM sin 8BP.

| Variable | Descripción |
|----------|-------------|
| \`LOADADDR\` | Dirección de carga en memoria (hex) |
| \`SOURCE\` | Archivo fuente (sin .asm) |
| \`TARGET\` | Nombre del binario generado |"
            ;;
        basic)
            readme_config="## Variables de Configuración Activas

Este proyecto **BASIC** tiene estas variables activas en \`devcpc.conf\`:

### Variables Principales

| Variable | Valor | Descripción |
|----------|-------|-------------|
| \`PROJECT_NAME\` | \`\"$project_name\"\` | Nombre del proyecto (se usa para DSK/CDT) |

### Rutas de Código (Activas)

| Variable | Valor | Descripción |
|----------|-------|-------------|
| \`BASIC_PATH\` | \`\"src\"\` | ✅ Carpeta con archivos BASIC (.bas) |
| \`RAW_PATH\` | \`\"raw\"\` | ✅ Archivos binarios sin encabezado AMSDOS |

### Variables Desactivadas (Comentadas)

Estas variables están **comentadas** en \`devcpc.conf\`. Descoméntalas si las necesitas:

- \`BUILD_LEVEL\` - Solo para proyectos 8BP (no aplicable aquí)
- \`ASM_PATH\` - Si necesitas añadir código ensamblador
- \`LOADADDR\` / \`SOURCE\` / \`TARGET\` - Para compilación ASM sin 8BP
- \`C_PATH\` / \`C_SOURCE\` - Si quieres compilar código C
- \`SPRITES_PATH\` - Para convertir PNG a ASM
- \`LOADER_SCREEN\` - Para pantallas de carga PNG → SCN

### Conversión de Gráficos (Opcional)

Para usar pantallas de carga, descomenta en \`devcpc.conf\`:

\`\`\`bash
LOADER_SCREEN=\"assets/screen\"
MODE=0  # 0=16 colores, 1=4, 2=2
\`\`\`

### Salida

| Variable | Valor | Descripción |
|----------|-------|-------------|
| \`DSK\` | \`\"\${PROJECT_NAME}.dsk\"\` | ✅ Imagen de disco |
| \`CDT\` | \`\"\${PROJECT_NAME}.cdt\"\` | Imagen de cinta (opcional) |"
            ;;
        asm)
            readme_config="## Variables de Configuración Activas

Este proyecto **ASM** está preconfigurado para compilación ASM pura (sin 8BP):

### Variables Principales

| Variable | Valor | Descripción |
|----------|-------|-------------|
| \`PROJECT_NAME\` | \`\"$project_name\"\` | Nombre del proyecto (se usa para DSK/CDT) |

### Variables de Compilación ASM (Activas)

| Variable | Valor | Descripción |
|----------|-------|-------------|
| \`LOADADDR\` | \`0x1200\` | ✅ Dirección de carga en memoria (hex) |
| \`SOURCE\` | \`\"main\"\` | ✅ Archivo fuente (sin extensión .asm) |
| \`TARGET\` | \`\"helloworld\"\` | ✅ Nombre del binario generado |

> **Nota:** Estas variables solo se usan cuando \`BUILD_LEVEL\` **no está definido**. Para proyectos 8BP, \`BUILD_LEVEL\` define automáticamente estos valores.

### Variables Desactivadas (Comentadas)

**Todas las rutas de código están comentadas**. Activa las que necesites:

- \`ASM_PATH\` - Ruta al código ensamblador principal
- \`BASIC_PATH\` - Si necesitas archivos BASIC
- \`RAW_PATH\` - Archivos binarios sin encabezado
- \`C_PATH\` / \`C_SOURCE\` - Si quieres compilar código C
- \`BUILD_LEVEL\` - Solo para proyectos 8BP (desactiva LOADADDR/SOURCE/TARGET)

### Conversión de Gráficos (Opcional)

Para convertir gráficos PNG, descomenta en \`devcpc.conf\`:

\`\`\`bash
SPRITES_PATH=\"assets/sprites\"
SPRITES_OUT_FILE=\"src/sprites.asm\"
LOADER_SCREEN=\"assets/screen\"
MODE=0  # 0=16 colores, 1=4, 2=2
\`\`\`

### Salida

| Variable | Valor | Descripción |
|----------|-------|-------------|
| \`DSK\` | \`\"\${PROJECT_NAME}.dsk\"\` | ✅ Imagen de disco |
| \`CDT\` | \`\"\${PROJECT_NAME}.cdt\"\` | Imagen de cinta (opcional) |

### Ejemplo: Proyecto ASM sin 8BP

1. Edita \`devcpc.conf\`:

\`\`\`bash
# Activar ruta ASM
ASM_PATH=\"src/main.asm\"

# Configurar compilación
LOADADDR=0x4000      # Dirección de carga
SOURCE=\"main\"       # Tu archivo main.asm
TARGET=\"myprog\"     # Genera myprog.bin
\`\`\`

2. Crea \`src/main.asm\` con tu código Z80
3. Compila: \`devcpc build\`

El resultado será \`obj/myprog.bin\` cargado en &4000."
            ;;
    esac
    
    cat > "$project_name/README.md" << EOF
# $project_name

Proyecto creado con **DevCPC CLI** (tipo: **${template_dir^^}**).

## Tipo de Proyecto: ${template_dir^^}

$(case "$template_dir" in
    8bp)
        echo "Proyecto completo con librería **8BP** para desarrollo de juegos."
        echo "Incluye soporte para ASM, BASIC, sprites PNG, pantallas de carga, música y código C."
        ;;
    basic)
        echo "Proyecto **BASIC** puro para desarrollo sin ensamblador."
        echo "Incluye soporte para archivos BASIC (.bas) y recursos como pantalla de carga."
        ;;
    asm)
        echo "Proyecto **ensamblador** puro para desarrollo en Z80."
        echo "Configuración mínima, activa las rutas que necesites en \`devcpc.conf\`."
        ;;
esac)

## Estructura

\`\`\`
$project_name/
├── devcpc.conf      # Configuración del proyecto
$(if [[ -d "$project_name/src" ]]; then echo "├── src/             # Código fuente"; fi)
$(if [[ -d "$project_name/asm" ]]; then echo "├── asm/             # Código ensamblador 8BP"; fi)
$(if [[ -d "$project_name/bas" ]]; then echo "├── bas/             # Archivos BASIC"; fi)
$(if [[ -d "$project_name/c" ]]; then echo "├── c/               # Código C"; fi)
$(if [[ -d "$project_name/assets" ]]; then echo "├── assets/          # Recursos (sprites, pantallas)"; fi)
$(if [[ -d "$project_name/raw" ]]; then echo "├── raw/             # Archivos binarios sin procesar"; fi)
$(if [[ -d "$project_name/music" ]]; then echo "├── music/           # Archivos de música (.wyz, .mus)"; fi)
├── obj/             # Archivos intermedios (generado)
└── dist/            # DSK/CDT final (generado)
\`\`\`

$readme_config

## Uso Rápido

\`\`\`bash
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
\`\`\`

## Emulador (Opcional)

Para usar \`devcpc run\`, configura en \`devcpc.conf\`:

\`\`\`bash
RVM_PATH="/ruta/a/RetroVirtualMachine"
CPC_MODEL=464        # o 664, 6128
RUN_MODE="auto"      # auto, dsk o cdt
\`\`\`

## 🔄 Conversión entre Tipos de Proyecto

> **Nota:** Este tipo de proyecto (${template_dir^^}) es solo un punto de partida. Puedes **transformar cualquier proyecto en otro tipo** simplemente editando las variables en \`devcpc.conf\` y creando las carpetas necesarias.

**Ejemplos de conversión:**

- **BASIC → 8BP**: Descomenta \`ASM_PATH\`, añade \`BUILD_LEVEL=0\`, crea carpeta \`asm/\`
- **ASM → 8BP**: Descomenta \`BUILD_LEVEL\`, ajusta \`ASM_PATH\` para usar 8BP, añade \`BASIC_PATH\`
- **8BP → BASIC**: Comenta \`ASM_PATH\` y \`BUILD_LEVEL\`, usa solo \`BASIC_PATH\`
- **Cualquiera → Híbrido**: Activa múltiples rutas (\`ASM_PATH\`, \`BASIC_PATH\`, \`C_PATH\`) según necesites

**La configuración es completamente flexible.** Las plantillas solo preconfiguran las variables más comunes para cada tipo, pero puedes personalizar tu proyecto como prefieras.

## Documentación Completa

- **DevCPC**: https://github.com/destroyer-dcf/DevCPC
$(if [[ "$template_dir" == "8bp" ]]; then echo "- **8BP**: https://github.com/jjaranda13/8BP"; fi)
EOF
    success "README.md creado"
    
    # Crear .gitignore
    step "Creando .gitignore..."
    cat > "$project_name/.gitignore" << EOF
# Archivos generados
obj/
dist/
*.bin
*.lst
*.map
*.ihx
*.lk
*.noi
*.rel
*.sym

# ASM generados automáticamente (sprites)
asm/sprites.asm
src/sprites.asm

# Backups
*.backup
*.backup_build
*.bak
*.BAK

# Sistema
.DS_Store
Thumbs.db
EOF
    success ".gitignore creado"
    
    echo ""
    success "Proyecto '$project_name' ($template_dir) creado exitosamente!"
    echo ""
    
    info "Próximos pasos:"
    echo ""
    echo "  1. cd $project_name"
    echo "  2. Edita devcpc.conf según tus necesidades"
    case "$template_dir" in
        8bp)
            echo "  3. Añade tu código en asm/, bas/, assets/, etc."
            echo "  4. Configura BUILD_LEVEL en devcpc.conf (0-4)"
            ;;
        basic)
            echo "  3. Añade tus archivos BASIC en src/"
            echo "  4. Añade recursos en assets/ si es necesario"
            ;;
        asm)
            echo "  3. Añade tu código ASM en src/"
            echo "  4. Añade recursos en assets/ si es necesario"
            ;;
    esac
    echo "  5. devcpc build"
    echo ""
    
    info "Para más ayuda: devcpc help"
    echo ""
}
