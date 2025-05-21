.include "memory.asm"
.include "bios.asm"
    pha
    phx
    phy

main:
    jsr init_hdd
    jsr init_partitions

    lda DRIVE_CNT
    cmp #0
    beq end

    lda #0
    sta CURRENT_PARTITION

    jsr load_root

    ;jmp shell

end:
    
    ply
    plx
    pla
    rts

shell:

    jsr print_prompt
    ldx #0

read_loop:
    phx
    jsr get_char
    plx

    pha
    jsr print_char
    pla

    sta INPUT_BUFFER, x

    cmp #$0A
    beq process_input

    cpx #255
    beq buffer_overflow

    inx
    jmp read_loop

buffer_overflow:
    lda #<buffer_overflow_text
	sta AL
	lda #>buffer_overflow_text
	sta AH
	jsr print

    jmp shell

process_input:

    cpx #0
    beq shell

    jmp shell
print_prompt:
    
    lda CURRENT_PARTITION
    clc
    adc #$43

    jsr print_char

    lda #':'
    jsr print_char

    lda #'>'
    jsr print_char

    rts

buffer_overflow_text: .byte $A,"Input Buffer Overflow!",$A,0
.include "hdd.asm"
.include "fat.asm"
.include "math.asm"