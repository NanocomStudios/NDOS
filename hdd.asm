DRIVE_AVAILABLE = %00000001
LBA48_AVAILABLE = %00000010

LBA_ON = %01000000
LBA_OFF = %10111111

MASTER = %00010000
SLAVE = %11101111

BUSY = %10000000
ERROR = %00000001
DATA_AVILABLE = %00001000

LBA48_LOC = $579

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

    lda #10
    jsr $FF03

    lda MASTER_DRIVE
    jsr $FF06

    lda #10
    jsr $FF03

    lda SLAVE_DRIVE
    jsr $FF06
    rts

;--------------------------------------------------------
;Set drive availablity status
;--------------------------------------------------------
check_available_drives:
    pha

    lda #0
    sta MASTER_SLAVE
    
    jsr set_drive
    sta SDH
    
    lda CMD_STS
    cmp #0
    beq no_slave_drive

    lda #DRIVE_AVAILABLE
    sta SLAVE_DRIVE

    lda #IDENTIFY
    sta CMD_STS

    jsr load_sector

    lda LBA48_LOC
    and #%00000010
    cmp #%00000010
    bne slave_lba_28

    lda SLAVE_DRIVE
    ora #LBA48_AVAILABLE
    sta SLAVE_DRIVE

slave_lba_28:

    jmp check_master_drive

no_slave_drive:
    lda #0
    sta SLAVE_DRIVE

check_master_drive:
    lda #1
    sta MASTER_SLAVE
    
    jsr set_drive
    sta SDH
    
    lda CMD_STS
    cmp #0
    beq no_master_drive

    lda #DRIVE_AVAILABLE
    sta MASTER_DRIVE

    lda #IDENTIFY
    sta CMD_STS

    jsr load_sector

    lda LBA48_LOC
    and #%00000010
    cmp #%00000010
    bne master_lba_28

    lda MASTER_DRIVE
    ora #LBA48_AVAILABLE
    sta MASTER_DRIVE

master_lba_28:

    pla
    rts

no_master_drive:

    lda #0
    sta MASTER_DRIVE

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
    beq set_drive_end

    pla
    ora #MASTER
    pha

set_drive_end:

    pla
    rts


;--------------------------------------------------------
;Set the LBA address with the given mode
;--------------------------------------------------------

set_addr:
    pha
    lda LBA_48
    cmp #0
    beq set_addr_28

    ;drop down to set_addr_48

;--------------------------------------------------------
;Set the LBA Address (48 bit)
;Requires a 'pha' before calling
;--------------------------------------------------------
set_addr_48:

    lda ADDR3
    sta DATA_H
    lda ADDR0
    sta LBA0

    lda ADDR4
    sta DATA_H
    lda ADDR1
    sta LBA0

    lda ADDR5
    sta DATA_H
    lda ADDR2
    sta LBA0

    lda #0
    sta DATA_H

    pla
    rts

;--------------------------------------------------------
;Set the LBA Address (28 bit)
;Requires a 'pha' before calling
;--------------------------------------------------------
set_addr_28:

    lda ADDR0
    sta LBA0

    lda ADDR1
    sta LBA0

    lda ADDR2
    sta LBA0

    lda ADDR3
    and #%00001111
    sta ADDR3

    jsr set_drive
    ora ADDR3

    sta SDH

    pla
    rts

;--------------------------------------------------------
;Wait until hdd becomes ready
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
read_sector:
    pha

    lda #1
    sta SEC_CNT

    lda READ_DATA
    sta CMD_STS

    pla

load_sector:

    pha

    lda #SECTOR_BUFFER_H
    sta AH

    lda #SECTOR_BUFFER_L
    sta AL

    lda #1
    sta MATH_ARG_8_1

read_sector_loop:

    jsr hdd_wait

    lda CMD_STS
    and #ERROR
    cmp #ERROR
    beq error_handler

    lda CMD_STS
    and #DATA_AVILABLE
    cmp #DATA_AVILABLE
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

    jmp read_sector_loop

load_data_end:

    pla
    rts

error_handler:
    lda #'E'
    jsr $FF03

LBA_MODE: .byte 1
MASTER_SLAVE: .byte 0

MASTER_DRIVE: .byte 0
SLAVE_DRIVE: .byte 0

LBA_48: .byte 0
TMP: .byte 0

ADDR0: .byte 0
ADDR1: .byte 0
ADDR2: .byte 0
ADDR3: .byte 0
ADDR4: .byte 0
ADDR5: .byte 0