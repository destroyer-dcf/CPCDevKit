# Parches de sintaxis para ABASM

Este documento explica las transformaciones que el script `patch_asm.sh` aplica a los archivos ASM para hacerlos compatibles con el ensamblador ABASM.

## ¿Por qué son necesarios estos parches?

Los archivos ASM del proyecto 8BP fueron escritos originalmente para el ensamblador WinAPE. ABASM tiene requisitos de sintaxis ligeramente diferentes, por lo que estos parches automatizan las correcciones necesarias.

## Transformaciones aplicadas

### 1. `and a,` → `and`

**Problema:** ABASM no acepta la coma después del registro implícito en operaciones lógicas.

**Antes:**
```asm
and a, 0x0F
and a, (HL)
```

**Después:**
```asm
and 0x0F
and (HL)
```

**Razón:** En Z80, cuando se usa `and`, el acumulador `a` es implícito. ABASM no requiere (y no acepta) especificarlo explícitamente con coma.

---

### 2. `or a,` → `or`

**Problema:** Similar a `and`, ABASM no acepta la coma con el registro implícito.

**Antes:**
```asm
or a, 0x80
or a, B
```

**Después:**
```asm
or 0x80
or B
```

**Razón:** El acumulador `a` es implícito en operaciones `or`.

---

### 3. `xor a,` → `xor`

**Problema:** ABASM no acepta la coma con el registro implícito en operaciones XOR.

**Antes:**
```asm
xor a, 0xFF
xor a, C
```

**Después:**
```asm
xor 0xFF
xor C
```

**Razón:** El acumulador `a` es implícito en operaciones `xor`.

---

### 4. `djnz,` → `djnz`

**Problema:** ABASM no acepta coma después de la instrucción `djnz`.

**Antes:**
```asm
djnz, loop_label
djnz, PSTR_scanh
```

**Después:**
```asm
djnz loop_label
djnz PSTR_scanh
```

**Razón:** La sintaxis correcta de Z80 no incluye coma entre la instrucción y la etiqueta. Este parche también maneja espacios extras después de la coma.

---

### 5. `ifnot X = Y` → `if X != Y`

**Problema:** ABASM no reconoce la directiva `ifnot` con comparación de igualdad.

**Antes:**
```asm
ifnot BUILD_MODE = 0
    ; código
endif
```

**Después:**
```asm
if BUILD_MODE != 0
    ; código
endif
```

**Razón:** ABASM usa sintaxis estándar de comparación con operadores `!=`, `==`, `<`, `>`, etc., en lugar de `ifnot` con `=`.

---

## Uso del script

### Ejecución básica

```bash
./patch_asm.sh <ruta_directorio_ASM>
```

### Ejemplo

```bash
./patch_asm.sh ./8BP_V43/ASM
```

### Con Makefile

```bash
make patch
```

## Comportamiento del script

1. **Procesa todos los archivos `.asm`** en el directorio especificado
2. **Crea backups automáticamente** con extensión `.backup` (solo la primera vez)
3. **Excluye archivos de backup** (`.backup`, `.bak`, `.BAK`)
4. **Aplica todos los parches** en cada archivo
5. **Reporta el número de cambios** realizados en cada archivo

## Archivos de respaldo

El script crea automáticamente archivos de backup antes de aplicar los parches:

```
8bitsDePoder_v043_001.asm          → Archivo modificado
8bitsDePoder_v043_001.asm.backup   → Backup original
```

**Importante:** Los backups solo se crean una vez. Si ejecutas el script múltiples veces, el backup original se preserva.

## Restaurar archivos originales

Si necesitas restaurar los archivos originales:

```bash
# En el directorio ASM
for f in *.backup; do 
    cp "$f" "${f%.backup}"
done
```

O simplemente copia manualmente los archivos `.backup`.

## Ejemplo de salida

```
═══════════════════════════════════════
  BUILD8BP - Patch
═══════════════════════════════════════

Directorio ASM: ./8BP_V43/ASM

📋 Backup creado: 8bitsDePoder_v043_001.asm.backup
✓ 8bitsDePoder_v043_001.asm: 42 correcciones
• make_graficos_mygame.asm: Sin cambios
• alphabet_default.asm: Sin cambios
...

Archivos procesados: 16
Total: 42 correcciones aplicadas
```

## Verificar compatibilidad

Después de aplicar los parches, puedes verificar que no hay errores de sintaxis compilando:

```bash
make 8bp0  # O cualquier nivel
```

Si hay errores de sintaxis no cubiertos por estos parches, reporta el problema para agregar nuevas transformaciones.

## Casos especiales

### Comentarios

El script **no modifica comentarios**, solo código ejecutable:

```asm
; and a, 0xFF  → No se modifica (es un comentario)
    and a, 0xFF  → Se modifica a: and 0xFF
```

### Strings

El script usa patrones específicos para evitar modificar strings o literales que contengan estas secuencias.

## Limitaciones conocidas

1. No procesa archivos incluidos con extensiones diferentes a `.asm`
2. Los patrones son sensibles a mayúsculas/minúsculas (instrucciones Z80 en minúsculas)
3. Asume formato de código estándar con espacios/tabs

## Solución de problemas

### "No se encontraron archivos .asm"

Verifica que estás ejecutando el script en el directorio correcto y que hay archivos `.asm` presentes.

### Errores de sintaxis después del patch

Algunos casos edge pueden no estar cubiertos. Revisa el error específico de ABASM y reporta para agregar nuevos parches.

### Archivos no se modifican

Si ejecutas el script múltiples veces, los archivos que ya fueron parcheados mostrarán "Sin cambios".

## Desarrollo

### Agregar nuevos parches

Para agregar una nueva transformación, edita `patch_asm.sh` y agrega un nuevo bloque en la sección de parches:

```bash
# 6. Nueva transformación
if grep -q 'patron_buscar' "$TEMP_FILE" 2>/dev/null; then
    COUNT=$(grep -o 'patron_buscar' "$TEMP_FILE" | wc -l | tr -d ' ')
    sed -i '' 's/patron_buscar/patron_reemplazar/g' "$TEMP_FILE" 2>/dev/null || \
    sed -i 's/patron_buscar/patron_reemplazar/g' "$TEMP_FILE"
    FILE_CHANGES=$((FILE_CHANGES + COUNT))
fi
```

### Probar cambios

1. Crea una copia del directorio ASM
2. Ejecuta el script en la copia
3. Compila con ABASM para verificar
4. Compara con el original si es necesario

## Referencias

- [Documentación de ABASM](https://github.com/fragarco/abasc/blob/main/docs/es/abasc.md)
- [Manual 8BP](https://github.com/jjaranda13/8BP/blob/master/Documentacion/manual/8bp_v043_r00_ES.pdf)

## Historial de cambios

- **v1.0** - Parches iniciales: `and a,`, `or a,`, `xor a,`, `djnz,`, `ifnot`
- **v1.1** - Soporte para espacios después de coma en `djnz`
- **v1.2** - Procesamiento de todos los archivos `.asm`
