#!/usr/bin/env bash
# ==============================================================================
# cdt.sh - Creación de archivos CDT (cintas)
# ==============================================================================
# 
# FUNCIONALIDADES:
# ----------------
# 1. Crear archivos CDT (formato de cinta para Amstrad CPC)
# 2. Añadir archivos en orden específico desde ${PROJECT_NAME}.map
# 3. Soporte para tipos: bin, scn, bas/ascii, raw
# 4. Nombres automáticos en MAYÚSCULAS sin extensión
# 5. Mostrar catálogo completo del CDT
#
# CONFIGURACIÓN EN devcpc.conf:
# ------------------------------
# CDT="${PROJECT_NAME}.cdt"              # Nombre del archivo CDT
# CDT_FILES="loader.bas 8BP0.bin main.bin"  # Orden de archivos
# RUN_MODE="auto"                        # o "dsk" o "cdt"
#
# USO:
# ----
# devcpc build                  # Crea DSK y CDT si está configurado
# devcpc run                    # Ejecuta según RUN_MODE (auto detecta CDT)
# devcpc run --dsk              # Fuerza ejecución desde DSK
# devcpc run --cdt              # Fuerza ejecución desde CDT (con -p auto-play)
#
# TIPOS DE ARCHIVOS:
# ------------------
# - bin/scn: Archivos binarios con load/execute address
# - bas/ascii: Archivos BASIC (tokenizados)
# - raw: Archivos sin encabezado AMSDOS
#
# EJEMPLO ${PROJECT_NAME}.map:
# -----------------------
# [loader.bas]
# type = ascii
#
# [8BP0.bin]
# type = bin
# load = 0x5C30
# execute = 0x5C30
#
# ==============================================================================
# shellcheck disable=SC2155

# Cargar utilidades si no están cargadas
if [[ -z "$(type -t register_in_map)" ]]; then
    source "${DEVCPC_LIB:-$(dirname "$0")}/utils.sh"
fi

# Crear archivo CDT con los archivos especificados
create_cdt() {
    # Verificar que CDT y CDT_FILES estén definidos
    if [[ -z "$CDT" ]]; then
        warning "CDT no está configurado, saltando creación de cinta"
        return 0
    fi
    
    if [[ -z "$CDT_FILES" ]]; then
        warning "CDT_FILES no está configurado, saltando creación de cinta"
        return 0
    fi
    
    header "Crear Cinta CDT"
    
    local cdt_path="$DIST_DIR/$CDT"
    local map_file="$OBJ_DIR/${PROJECT_NAME}.map"
    local cdt_tool="$DEVCPC_CLI_ROOT/tools/abasm/src/cdt.py"
    local map_tool="$DEVCPC_CLI_ROOT/tools/map/map.py"
    
    # Verificar herramientas
    if [[ ! -f "$cdt_tool" ]]; then
        error "cdt.py no encontrado en: $cdt_tool"
        return 1
    fi
    
    if [[ ! -f "$map_tool" ]]; then
        error "map.py no encontrado en: $map_tool"
        return 1
    fi
    
    if [[ ! -f "$map_file" ]]; then
        error "Map file no encontrado: $map_file"
        error "Asegúrate de compilar el proyecto primero"
        return 1
    fi
    
    local python_cmd=$(command -v python3 || command -v python)
    
    info "CDT: $CDT"
    info "Archivos: $CDT_FILES"
    echo ""
    
    # Crear nuevo CDT (eliminar si existe)
    step "Creando CDT vacío..."
    [[ -f "$cdt_path" ]] && rm -f "$cdt_path"
    
    if ! $python_cmd "$cdt_tool" "$cdt_path" --new > /dev/null 2>&1; then
        error "Error al crear CDT"
        return 1
    fi
    
    success "CDT creado: $cdt_path"
    echo ""
    
    # Procesar cada archivo en el orden especificado
    local file_count=0
    local IFS=' '
    read -ra files <<< "$CDT_FILES"
    
    for filename in "${files[@]}"; do
        step "Añadiendo $filename al CDT..."
        
        # Obtener datos del map.cfg
        local file_type=$($python_cmd "$map_tool" --file "$map_file" --get --section "$filename" --key "type" 2>/dev/null)
        local load_addr=$($python_cmd "$map_tool" --file "$map_file" --get --section "$filename" --key "load" 2>/dev/null)
        local exec_addr=$($python_cmd "$map_tool" --file "$map_file" --get --section "$filename" --key "execute" 2>/dev/null)
        
        # Verificar que el archivo existe en el map
        if [[ -z "$file_type" ]]; then
            error "Archivo '$filename' no encontrado en $map_file"
            error "Archivos disponibles:"
            $python_cmd "$map_tool" --file "$map_file" --list | grep "^\[" | sed 's/\[//g;s/\]//g' | while read -r sec; do
                echo "  - $sec"
            done
            return 1
        fi
        
        # Verificar que el archivo físico existe
        local file_path="$OBJ_DIR/$filename"
        if [[ ! -f "$file_path" ]]; then
            error "Archivo físico no encontrado: $file_path"
            return 1
        fi
        
        # Extraer nombre sin extensión y convertir a mayúsculas
        local name_upper=$(basename "$filename" | sed 's/\.[^.]*$//' | tr '[:lower:]' '[:upper:]')
        
        # Determinar cómo añadir según el tipo
        local add_result
        case "$file_type" in
            bin|scn)
                info "  Tipo: BINARIO"
                info "  Load: $load_addr"
                info "  Exec: $exec_addr"
                info "  Name: $name_upper"
                
                if ! $python_cmd "$cdt_tool" "$cdt_path" \
                    --put-bin "$file_path" \
                    --load-addr "$load_addr" \
                    --start-addr "$exec_addr" \
                    --name "$name_upper" > /dev/null 2>&1; then
                    error "Error al añadir $filename como binario"
                    return 1
                fi
                ;;
            bas|ascii)
                info "  Tipo: BASIC"
                info "  Name: $name_upper"
                
                if ! $python_cmd "$cdt_tool" "$cdt_path" \
                    --put-ascii "$file_path" \
                    --name "$name_upper" > /dev/null 2>&1; then
                    error "Error al añadir $filename como ASCII"
                    return 1
                fi
                ;;
            raw)
                info "  Tipo: RAW (sin encabezado)"
                
                if ! $python_cmd "$cdt_tool" "$cdt_path" \
                    --put-raw "$file_path" > /dev/null 2>&1; then
                    error "Error al añadir $filename como raw"
                    return 1
                fi
                ;;
            *)
                warning "Tipo desconocido '$file_type' para $filename, omitiendo"
                continue
                ;;
        esac
        
        success "$filename añadido"
        ((file_count++))
        echo ""
    done
    
    if [[ $file_count -eq 0 ]]; then
        error "No se añadió ningún archivo al CDT"
        return 1
    fi
    
    success "$file_count archivo(s) añadido(s) al CDT"
    echo ""
    
    return 0
}

# Mostrar catálogo del CDT
show_cdt_catalog() {
    if [[ -z "$CDT" || ! -f "$DIST_DIR/$CDT" ]]; then
        return 0
    fi
    
    local cdt_tool="$DEVCPC_CLI_ROOT/tools/abasm/src/cdt.py"
    local python_cmd=$(command -v python3 || command -v python)
    
    header "Contenido CDT: $CDT"
    
    if ! $python_cmd "$cdt_tool" "$DIST_DIR/$CDT" --cat 2>&1; then
        error "Error al listar el contenido del CDT"
        return 1
    fi
    
    echo ""
    return 0
}
