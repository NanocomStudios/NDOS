SEC_PER_CLUS_OFFSET = $50D  ;u8
RSVD_SEC_CNT_OFFSET = $50E  ;u16
NUM_OF_FAT_OFFSET = $510    ;u8
SEC_PER_FAT_OFFSET = $524   ;u32
ROOT_CLUS_OFFSET = $52C     ;u32


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
    
    asl
    asl

    ora TMP
    ora #$80

    ldy DRIVE_CNT
    sta C_DRIVE, y

    iny
    sty DRIVE_CNT

    rts


load_root:

    ldy CURRENT_PARTITION
    lda drive_info, y

    and #%00000100
    lsr
    lsr
    pha
    jsr print_hex
    pla
    sta MASTER_SLAVE

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

    ldx CURRENT_PARTITION
    lda drive_info, x

    and #%00000011
    asl
    asl
    asl
    asl

    tax
    lda $6C6, x
    sta ADDR0
    lda $6C7, x
    sta ADDR1
    lda $6C8, x
    sta ADDR2
    lda $6C9, x
    sta ADDR3

    lda #0
    sta ADDR4
    sta ADDR5

    jsr set_addr
    
    jsr read_sector

    lda SEC_PER_CLUS_OFFSET
    jsr calculate_sec_per_clus

    lda RSVD_SEC_CNT_OFFSET
    sta RSVD_SEC_CNT

    lda RSVD_SEC_CNT_OFFSET + 1
    sta RSVD_SEC_CNT + 1

    lda NUM_OF_FAT_OFFSET
    sta NUM_OF_FAT

    lda SEC_PER_FAT_OFFSET
    sta SEC_PER_FAT

    lda SEC_PER_FAT_OFFSET + 1
    sta SEC_PER_FAT + 1

    lda SEC_PER_FAT_OFFSET + 2
    sta SEC_PER_FAT + 2

    lda SEC_PER_FAT_OFFSET + 3
    sta SEC_PER_FAT + 3

    lda ROOT_CLUS_OFFSET
    sta ROOT_CLUS

    lda ROOT_CLUS_OFFSET + 1
    sta ROOT_CLUS + 1

    lda ROOT_CLUS_OFFSET + 2
    sta ROOT_CLUS + 2

    lda ROOT_CLUS_OFFSET + 3
    sta ROOT_CLUS + 3

    jsr calculate_data_area_begin

    rts

calculate_sec_per_clus:
    phx
    ldx #0

calculate_sec_per_clus_loop:

    lsr
    cmp #1
    beq calculate_sec_per_clus_end

    inx
    jmp calculate_sec_per_clus_loop

calculate_sec_per_clus_end:
    stx SEC_PER_CLUS
    plx
    rts

calculate_data_area_begin:

    ldx #4

    lda ADDR0
    sta NUM1_0

    lda ADDR1
    sta NUM1_1

    lda ADDR2
    sta NUM1_2

    lda ADDR3
    sta NUM1_3

    lda RSVD_SEC_CNT
    sta NUM2_0

    lda RSVD_SEC_CNT + 1
    sta NUM2_1

    lda #0
    sta NUM2_2
    sta NUM2_3

    jsr add

    jsr move_res_to_acc



    rts

drive_info:
    .export drive_info
C_DRIVE: .byte 0
D_DRIVE: .byte 0
E_DRIVE: .byte 0
F_DRIVE: .byte 0
G_DRIVE: .byte 0
H_DRIVE: .byte 0
I_DRIVE: .byte 0
J_DRIVE: .byte 0

DRIVE_CNT: .byte 0
CURRENT_PARTITION: .byte 0

SEC_PER_CLUS: .byte 0
RSVD_SEC_CNT: .byte 0, 0
NUM_OF_FAT: .byte 0
SEC_PER_FAT: .byte 0, 0, 0, 0
ROOT_CLUS:  .byte 0, 0, 0, 0
CURRENT_CLUSTER: .byte 0, 0, 0, 0
CURRENT_SECTOR_OFFSET: .byte 0
DATA_AREA_BEGIN: .byte 0, 0, 0, 0
;AV XX XX XX XX MS PT PT