#!/usr/bin/env bash
# ==============================================================================
# update.sh - Actualización de DevCPC
# ==============================================================================

update_devcpc() {
    local github_api="https://api.github.com/repos/destroyer-dcf/DevCPC/releases/latest"
    local current_version
    current_version=$(get_version)
    
    echo ""
    info "DevCPC CLI v${current_version}"
    echo ""
    info "Verificando actualizaciones..."
    
    # Obtener última versión
    local latest_version
    latest_version=$(curl -fsSL "$github_api" 2>/dev/null | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/' 2>/dev/null)
    
    if [[ -z "$latest_version" ]]; then
        error "No se pudo conectar con GitHub para verificar actualizaciones"
        exit 1
    fi
    
    success "Última versión disponible: v${latest_version}"
    
    # Comparar versiones
    if [[ "$latest_version" == "$current_version" ]]; then
        success "Ya tienes la última versión instalada"
        exit 0
    fi
    
    echo ""
    warning "Nueva versión disponible: v${latest_version}"
    echo ""
    
    # Confirmar actualización
    if ! ask_yes_no "¿Deseas actualizar a v${latest_version}?" "y"; then
        info "Actualización cancelada"
        exit 0
    fi
    
    echo ""
    info "Iniciando actualización..."
    
    # URL de descarga
    local download_url="https://github.com/destroyer-dcf/DevCPC/releases/download/v${latest_version}/DevCPC-${latest_version}.tar.gz"
    local temp_dir
    temp_dir=$(mktemp -d)
    
    # Descargar
    info "Descargando DevCPC v${latest_version}..."
    if ! curl -fsSL "$download_url" -o "$temp_dir/devcpc.tar.gz"; then
        error "No se pudo descargar la actualización"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    success "Descarga completada"
    
    # Extraer
    info "Extrayendo archivos..."
    if ! tar -xzf "$temp_dir/devcpc.tar.gz" -C "$temp_dir"; then
        error "No se pudo extraer el archivo"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Verificar estructura
    if [[ ! -d "$temp_dir/DevCPC" ]]; then
        error "Estructura del archivo no válida"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Backup de configuración si existe
    local backup_dir="$temp_dir/backup"
    mkdir -p "$backup_dir"
    
    # Actualizar archivos
    info "Actualizando archivos en $DEVCPC_PATH..."
    
    # Copiar nuevos archivos sobrescribiendo
    cp -rf "$temp_dir/DevCPC/"* "$DEVCPC_PATH/"
    
    # Asegurar permisos de ejecución
    chmod +x "$DEVCPC_PATH/bin/devcpc"
    
    # Limpiar
    rm -rf "$temp_dir"
    
    echo ""
    success "DevCPC actualizado exitosamente a v${latest_version}"
    echo ""
    info "Verifica la instalación con: devcpc version"
    echo ""
}
