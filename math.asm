addr_inc:
	pha
	clc
	
	lda AL
	adc MATH_ARG_8_1
	sta AL
	
	lda AH
	adc #0
	sta AH
addr_inc_end:
	pla
	rts
	
multiply:
	
	rts
	
addr_dec:
	pha
	sec
	
	lda AL
	sbc MATH_ARG_8_1
	sta AL
	
	lda AH
	sbc #0
	sta AH
addr_dec_end:
	pla
	rts
    
add:
    pha
    clc
    stx TMP1_0
    ldx #0
    php

add_loop:
    plp
    lda NUM1_0, x
    adc NUM2_0, x
    sta RES0, x
    php

    inx
    
    cpx TMP1_0
    bne add_loop
    plp
    pla
    rts
    
subtract:
    pha
    sec
    stx TMP1_0
    ldx #0
    php

subtract_loop:
    plp
    lda NUM1_0, x
    sbc NUM2_0, x
    sta RES0, x
    php

    inx
    
    cpx TMP1_0
    bne subtract_loop
    
    plp
    pla
    rts

move_res_to_num1:
    pha
    phx
    ldx #0

move_res_to_num1_loop:
    
    lda RES0, x
    sta NUM1_0, X

    inx

    cpx #8
    bne move_res_to_num1_loop

    plx
    pla
    rts

move_res_to_num2:
    pha
    phx
    ldx #0

move_res_to_num2_loop:
    
    lda RES0, x
    sta NUM2_0, X

    inx

    cpx #8
    bne move_res_to_num2_loop

    plx
    pla
    rts

shift_left:
    clc
rotate_left:
    pha
    stx TMP1_0
    ldx #0
    php

shift_left_loop:
    plp
    lda NUM1_0, x
    rol
    sta NUM1_0, x
    php

    inx
    
    cpx TMP1_0
    bne shift_left_loop
    
    plp
    pla
    rts

shift_right:
    clc
rotate_right:
    pha
    stx TMP1_0
    ldx #0
    php

shift_right_loop:
    plp
    lda NUM1_0, x
    ror
    sta NUM1_0, x
    php

    inx
    
    cpx TMP1_0
    bne shift_right_loop
    
    plp
    pla
    rts

;--------------------------------------------------------
;Calculate the starting Sector from the Cluster
;--------------------------------------------------------

calculate_sec_from_clus:

    lda CURRENT_CLUSTER
    sta NUM1_0

    lda CURRENT_CLUSTER + 1
    sta NUM1_1

    lda CURRENT_CLUSTER + 2
    sta NUM1_2

    lda CURRENT_CLUSTER + 3
    sta NUM1_3

    ldx #4

    ldy #0

sec_from_clus_loop:

    jsr shift_left

    iny
    cpy SEC_PER_CLUS

    bne sec_from_clus_loop

    rts