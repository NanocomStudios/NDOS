.include "memory.asm"

main:
    jsr init_hdd

.include "hdd.asm"
.include "fat.asm"
.include "math.asm"