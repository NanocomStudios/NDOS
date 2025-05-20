
init_partitions:

    lda MASTER_DRIVE
    and #1
    cmp #1
    bne init_slave

    lda #'M'
    jsr $FF03

    lda #1
    sta MASTER_SLAVE
    jsr read_fat_drive

init_slave:

    lda SLAVE_DRIVE
    and #1
    cmp #1
    bne init_partition_end

    lda #'S'
    jsr $FF03

    lda #0
    sta MASTER_SLAVE
    jsr read_fat_drive

init_partition_end:

    rts

read_fat_drive:

    lda #1
    sta LBA_MODE

    jsr set_drive
    sta SDH

    lda #0
    sta ADDR0
    sta ADDR1
    sta ADDR2
    sta ADDR3
    sta ADDR4
    sta ADDR5

    jsr set_addr

    jsr read_sector

    lda $6FE
    cmp #$55
    bne not_fat_drive

    lda $6FF
    cmp #$AA
    bne not_fat_drive

    jmp read_partitions

not_fat_drive:

    rts

read_partitions:

check_partition_1:

    lda $6C2
    cmp #$0C
    bne check_partition_2

    lda #0
    sta TMP
    jsr mount_partition

check_partition_2:

    lda $6D2
    cmp #$0C
    bne check_partition_3

    lda #0
    sta TMP
    jsr mount_partition

check_partition_3:

    lda $6E2
    cmp #$0C
    bne check_partition_4

    lda #0
    sta TMP
    jsr mount_partition

check_partition_4:

    lda $6F2
    cmp #$0C
    bne check_partition_end

    lda #0
    sta TMP
    jsr mount_partition

check_partition_end:
    rts

mount_partition:
    
    lda MASTER_SLAVE
    
    rol
    rol
    rol

    ora TMP
    ora #$80

    ldy DRIVE_CNT
    sta C_DRIVE, y

    iny
    sty DRIVE_CNT

    rts

C_DRIVE: .byte 0
D_DRIVE: .byte 0
E_DRIVE: .byte 0
F_DRIVE: .byte 0
G_DRIVE: .byte 0
H_DRIVE: .byte 0
I_DRIVE: .byte 0
J_DRIVE: .byte 0

DRIVE_CNT: .byte 0
;AV XX XX XX XX MS PT PT