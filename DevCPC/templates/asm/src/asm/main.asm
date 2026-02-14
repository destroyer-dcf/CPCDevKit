; Logo example
; A modified version from http://www.chibiakumas.com/z80/helloworld.php
; A good resource for tutorials regarding the assembly programming of the Z80

; Files can use the directive ORG to set the initial loading address. However,
; most of the time would be better to set that using the --start parameter in the
; ABASM call
;
; org &1200

; Firmware routines
print_char equ &BB5A    ; Amstrad Firmware routine for char printing
scr_set_mode equ &BC0E  ; Set screen mode
scr_set_ink equ &BC32   ; Set ink color
wait_key equ &BB18      ; Wait for key press
wait_vsync equ &BD19    ; Wait for vertical sync

main:
    ; Configurar modo 1 (320x200, 4 colores)
    ld a, 1
    call scr_set_mode
    
    ; Configurar paleta según el sprite devcpc
    ld a, 0
    ld b, 0
    ld c, 0
    call scr_set_ink
    
    ld a, 1
    ld b, 1
    ld c, 24             ; Rojo
    call scr_set_ink
    
    ld a, 2
    ld b, 2
    ld c, 6              ; Cian
    call scr_set_ink
    
    ; Esperar VSYNC para evitar parpadeo
    call wait_vsync
    
    ; Dibujar sprite devcpc centrado
    ; Pantalla modo 1: 320 píxeles = 80 bytes de ancho, 200 píxeles alto
    ; Sprite: 120 píxeles = 30 bytes de ancho, 40 píxeles alto
    ; Centro X en píxeles: (320 - 120) / 2 = 100 píxeles = 25 bytes
    ; Centro Y en píxeles: (200 - 40) / 2 = 80 píxeles
    ld hl, devcpc
    ld c, (hl)          ; C = ancho (30)
    inc hl
    ld b, (hl)          ; B = alto (40)
    inc hl              ; HL = puntero a datos del sprite
    push hl             ; Guardar puntero a datos
    
    ; Calcular dirección de video centrada usando ancho/alto del sprite
    ; X_bytes = (80 - ancho) / 2
    ; Y = (200 - alto) / 2
    ; Dirección: &C000 + &50 * (Y / 8) + &800 * (Y % 8) + X_bytes
    push bc
    ld a, 200
    sub b
    srl a
    ld d, a             ; D = Y centrado
    
    ld a, 80
    sub c
    srl a
    ld e, a             ; E = X en bytes centrado
    
    ld hl, &C000
    ld a, l
    add a, e
    ld l, a
    jr nc, ps_x_ok
    inc h
ps_x_ok:
    ; Añadir &0800 * (Y % 8)
    ld a, d
    and 7
    ld b, a
ps_y_mod_loop:
    ld a, b
    or a
    jr z, ps_y_mod_done
    ld de, &0800
    add hl, de
    dec b
    jr ps_y_mod_loop
ps_y_mod_done:
    ; Añadir &0050 * (Y / 8)
    ld a, d
    srl a
    srl a
    srl a
    ld c, a
ps_y_div_loop:
    ld a, c
    or a
    jr z, ps_y_div_done
    ld de, &0050
    add hl, de
    dec c
    jr ps_y_div_loop
ps_y_div_done:
    pop bc
    pop de              ; DE = puntero a datos
    call putsprite
    
    ; Posicionar cursor y mostrar mensaje (debajo del sprite, centrado)
    ld hl, devcpc
    ld c, (hl)          ; C = ancho en bytes
    inc hl
    ld b, (hl)          ; B = alto en píxeles
    
    ; Línea = (( (200 - alto)/2 + alto + TEXT_MARGIN ) / 8) + 1
    ld a, 200
    sub b
    srl a
    add a, b
    add a, TEXT_MARGIN
    srl a
    srl a
    srl a
    inc a
    ld h, a             ; Línea 1-based
    
    ; X_bytes = (80 - ancho) / 2
    ld a, 80
    sub c
    srl a
    ld e, a             ; E = X_bytes
    
    ; Columna = (X_bytes/2) + (ancho/4) - (TEXT_LEN/2) + 1
    ld a, e
    srl a               ; X_bytes/2
    ld d, a
    ld a, c
    srl a
    srl a               ; ancho/4
    add a, d
    sub TEXT_HALF
    inc a
    ld l, a             ; Columna 1-based
    
    ld a, 1             ; Mover cursor
    call &BB75          ; TXT SET CURSOR
    
    ; Imprimir mensaje
    ld hl, message
    call print_string
    
    ; Esperar tecla
    call wait_key
    
loop:
    jp loop

TEXT_LEN equ 20
TEXT_HALF equ 3
TEXT_MARGIN equ 1
message: db "SDK from Amstrad CPC",&FF

; Rutina CPCRSLIB adaptada para dibujar sprites
; Entradas:
;   HL = dirección de video RAM
;   DE = puntero a datos del sprite
;   B  = alto en bytes
;   C  = ancho en bytes
putsprite:
    ld a, c
    ld (ps_width+1), a      ; Guardar ancho (self-modifying code)
    ld a, c
    neg
    ld (ps_nextline+1), a   ; Guardar salto de línea (self-modifying code)
    
    ; Usar IY como contador de alto
    ld a, b
    ld iyh, a
    ld b, 7                 ; B = contador de líneas dentro de bloque
    
ps_line_loop:
ps_width:
    ld c, 0                 ; Ancho (se modifica arriba)
ps_byte_loop:
    ld a, (de)              ; Leer byte del sprite
    ld (hl), a              ; Escribir en video RAM
    inc de
    inc hl
    dec c
    jr nz, ps_byte_loop
    
    ; Siguiente línea
    dec iyh                 ; Decrementar contador de alto
    ret z                   ; Terminar si llegamos a 0
    
ps_nextline:
    ld c, 0                 ; Salto de línea (se modifica arriba)
    add hl, bc              ; HL += salto
    jr nc, ps_line_loop     ; Si no hay carry, seguir
    
    ; Salimos de bloque de 8 líneas, ajustar
    ld bc, &C050
    add hl, bc
    ld b, 7
    jr ps_line_loop
    
print_string:
    ld a, (hl)
    cp &FF
    ret z
    inc hl
    call print_char
    jr print_string

; Incluir datos del sprite
READ "sprites.asm"
