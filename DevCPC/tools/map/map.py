#!/usr/bin/env python3
"""
map.py - Herramienta para gestionar el archivo map de DevCPC
Permite agregar, eliminar y actualizar secciones y claves 
"""

import argparse
import configparser
import os
import sys


def add_entry(ini_file, section, key, value):
    """
    Añade una entrada al archivo INI.
    Si la sección no existe, la crea.
    """
    config = configparser.ConfigParser()
    
    # Leer archivo existente si existe
    if os.path.exists(ini_file):
        config.read(ini_file)
    
    # Crear sección si no existe
    if not config.has_section(section):
        config.add_section(section)
    
    # Añadir/actualizar la clave
    config.set(section, key, value)
    
    # Guardar archivo
    with open(ini_file, 'w') as f:
        config.write(f)
    
    print(f"✓ Entrada añadida: [{section}] {key} = {value}")


def remove_entry(ini_file, section, key=None):
    """
    Elimina una entrada o sección del archivo INI.
    Si solo se proporciona section, elimina toda la sección.
    Si se proporciona section y key, elimina solo esa clave.
    """
    if not os.path.exists(ini_file):
        print(f"✗ Error: El archivo '{ini_file}' no existe")
        sys.exit(1)
    
    config = configparser.ConfigParser()
    config.read(ini_file)
    
    if not config.has_section(section):
        print(f"✗ Error: La sección '[{section}]' no existe")
        sys.exit(1)
    
    if key is None:
        # Eliminar toda la sección
        config.remove_section(section)
        print(f"✓ Sección eliminada: [{section}]")
    else:
        # Eliminar solo la clave
        if config.has_option(section, key):
            config.remove_option(section, key)
            print(f"✓ Entrada eliminada: [{section}] {key}")
        else:
            print(f"✗ Error: La clave '{key}' no existe en la sección '[{section}]'")
            sys.exit(1)
    
    # Guardar archivo
    with open(ini_file, 'w') as f:
        config.write(f)


def update_entry(ini_file, section, key, value):
    """
    Actualiza una entrada en el archivo INI.
    Si la sección o la clave no existen, las crea.
    Si el archivo no existe, lo crea.
    """
    config = configparser.ConfigParser()
    
    # Leer archivo existente si existe
    if os.path.exists(ini_file):
        config.read(ini_file)
    
    # Crear sección si no existe
    if not config.has_section(section):
        config.add_section(section)
        print(f"→ Sección creada: [{section}]")
    
    # Actualizar/crear la clave
    config.set(section, key, value)
    
    # Guardar archivo
    with open(ini_file, 'w') as f:
        config.write(f)
    
    print(f"✓ Entrada actualizada: [{section}] {key} = {value}")


def get_entry(ini_file, section, key):
    """
    Obtiene el valor de una key específica del archivo INI.
    Si no existe, devuelve una cadena vacía.
    """
    if not os.path.exists(ini_file):
        print("")
        return
    
    config = configparser.ConfigParser()
    config.read(ini_file)
    
    if not config.has_section(section):
        print("")
        return
    
    if config.has_option(section, key):
        value = config.get(section, key)
        print(value)
    else:
        print("")


def list_entries(ini_file):
    """
    Lista todas las entradas del archivo INI
    """
    if not os.path.exists(ini_file):
        print(f"✗ Error: El archivo '{ini_file}' no existe")
        sys.exit(1)
    
    config = configparser.ConfigParser()
    config.read(ini_file)
    
    print(f"\n--- Contenido de {ini_file} ---\n")
    for section in config.sections():
        print(f"[{section}]")
        for key, value in config.items(section):
            print(f"  {key} = {value}")
        print()


def main():
    parser = argparse.ArgumentParser(
        description='Herramienta para gestionar archivos INI',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Ejemplos de uso:
  %(prog)s --file config.ini --add --section Server --key port --value 8080
  %(prog)s --file config.ini --update --section Server --key host --value localhost
  %(prog)s --file config.ini --get --section Server --key port
  %(prog)s --file config.ini --remove --section Server --key port
  %(prog)s --file config.ini --remove --section Server
  %(prog)s --file config.ini --list
        """
    )
    
    parser.add_argument('--file', '-f', required=True, help='Archivo INI a gestionar')
    
    # Operaciones
    operation = parser.add_mutually_exclusive_group(required=True)
    operation.add_argument('--add', '-a', action='store_true', help='Añadir una entrada')
    operation.add_argument('--remove', '-r', action='store_true', help='Eliminar una entrada o sección')
    operation.add_argument('--update', '-u', action='store_true', help='Actualizar una entrada (crea si no existe)')
    operation.add_argument('--get', '-g', action='store_true', help='Obtener el valor de una key (devuelve vacío si no existe)')
    operation.add_argument('--list', '-l', action='store_true', help='Listar todas las entradas')
    
    # Parámetros
    parser.add_argument('--section', '-s', help='Nombre de la sección')
    parser.add_argument('--key', '-k', help='Nombre de la clave')
    parser.add_argument('--value', '-v', help='Valor a asignar')
    
    args = parser.parse_args()
    
    # Validaciones
    if args.list:
        list_entries(args.file)
        return
    
    if args.get:
        if not args.section or not args.key:
            print("✗ Error: Se requiere --section y --key para leer una entrada")
            sys.exit(1)
        get_entry(args.file, args.section, args.key)
        return
    
    if not args.section:
        print("✗ Error: Se requiere --section para esta operación")
        sys.exit(1)
    
    if args.add:
        if not args.key or not args.value:
            print("✗ Error: Se requiere --key y --value para añadir una entrada")
            sys.exit(1)
        add_entry(args.file, args.section, args.key, args.value)
    
    elif args.remove:
        remove_entry(args.file, args.section, args.key)
    
    elif args.update:
        if not args.key or not args.value:
            print("✗ Error: Se requiere --key y --value para actualizar una entrada")
            sys.exit(1)
        update_entry(args.file, args.section, args.key, args.value)


if __name__ == '__main__':
    main()
