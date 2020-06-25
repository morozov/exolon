CLS      equ $0d6b ; https://skoolkid.github.io/rom/asm/0D6B.html
BORDCR   equ $5c48 ; https://skoolkid.github.io/rom/asm/5C48.html
ATTR_P   equ $5c8d ; https://skoolkid.github.io/rom/asm/5C8D.html

dest     equ $6d60 ; final destination of the data block
                   ; and the entry point

; Clear screen
    ld      a, $00
    ld      (ATTR_P), a
    ld      (BORDCR), a
    xor     a
    out     ($fe), a
    call    CLS

; Load image
    ld      de, ($5cf4)     ; restore the FDD head position
    ld      bc, $1405       ; load 20 sectors of compressed image
    ld      hl, $9c40       ; destination address (40000)
    call    $3d13           ;
    call    $9c40           ; decompress the image

; Move stack pointer away form the data
    ld      sp, dest-2

; Load data
    ld      de, ($5cf4)     ; restore the FDD head position again
    ld      bc, $9305       ; load 147 sectors of the data
    ld      hl, dest        ; destination address (28000)
    call    $3d13           ;

; GO!
    jp      dest
