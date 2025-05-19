.include "memory.asm"

LBA_ON = %01000000
LBA_OFF = %10111111

MASTER = %00010000
SLAVE = %11101111

BUSY = %10000000
ERROR = %00000001
DATA_AVILABLE = %00001000

DATA_L = $C010
DATA_H = $C018
ERROR_REG = $C011
SEC_CNT = $C012
LBA0 = $C013
LBA1 = $C014
LBA2 = $C015

;LBA3, LBA4, LBA5 -> DATA_H

SDH = $C016
CMD_STS = $C017

WRITE_DATA = $30
READ_DATA = $20
IDENTIFY = $EC


init_hdd:
    jsr check_available_drives

    

;--------------------------------------------------------
;RETURN REG_A ->  1 x - MASTER, x 1 - SLAVE
;--------------------------------------------------------
check_available_drives:
    lda #0
    sta MASTER_SLAVE
    
    jsr set_drive
    lda TMP
    sta SDH
    
    lda CMD_STS
    cmp #0
    beq no_slave_drive

    lda #1
    pha

    jmp check_slave_drive

no_slave_drive:
    lda #0
    pha

check_slave_drive:
    lda #1
    sta MASTER_SLAVE

    jsr set_drive
    lda TMP
    sta SDH

    lda CMD_STS
    cmp #0
    beq no_master_drive

    pla
    ora #%10

    rts

no_master_drive:

    pla
    rts


;--------------------------------------------------------
;INPUT -> LBA_MODE(1 - ON, 0 - OFF), MASTER_SLAVE(1 - ON, 0 - OFF)
;RETURN REG_A -> Value to set on the SHD Register
;--------------------------------------------------------
set_drive:

    lda #0
    pha

    lda LBA_MODE
    cmp #0
    beq check_ms

    pla
    lda #LBA_ON
    pha

check_ms:
    lda MASTER_SLAVE
    cmp #0
    beq check_lba28

    pla
    ora #MASTER
    pha

set_drive_end:

    pla
    rts


;--------------------------------------------------------
;
;--------------------------------------------------------
hdd_wait:
    pha
hdd_wait_loop:
    lda CMD_STS
    and #BUSY
    cmp #BUSY

    beq hdd_wait_loop

    pla
    rts

;--------------------------------------------------------
;Read a sector into $0500 - $06FF
;--------------------------------------------------------
load_data:
    pha
    lda #SECTOR_BUFFER_H
    sta AH

    lda #SECTOR_BUFFER_L
    sta AL

    lda #1
    sta MATH_ARG_8_1

load_data_loop:
    lda CMD_STS
    and #ERROR
    cmp #ERROR
    beq error_handler

    lda #CMD_STS
    and #DATA_AVILABLE
    cmd #DATA_AVILABLE
    bne load_data_end
    
    lda DATA_H
    lda DATA_H

    sta TMP

    lda DATA_L
    sta (AL)

    jsr addr_inc

    lda TMP
    sta (AL)

    jsr addr_inc

    jsr hdd_wait

load_data_end:

    pla
    rts

error_handler:
    lda #'E'
    jsr $FF03

LBA_MODE: .byte 1
MASTER_SLAVE: .byte 0

LBA_48: .byte 0
TMP: .byte 0


.include "math.asm"