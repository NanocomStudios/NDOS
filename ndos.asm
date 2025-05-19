.include "memory.asm"

    pha
    phx
    phy

main:
    jsr init_hdd
    jsr init_partitions

end:
    
    ply
    plx
    pla
    rts

.include "hdd.asm"
.include "fat.asm"
.include "math.asm"