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
    
add_loop:
    lda NUM1_0, y
    adc NUM2_0, y
    sta RES0, y
    
    inx
    
    cpx TMP1_0
    bne add_loop
    
    pla
    rts
    
subtract:
    pha
    sec
    stx TMP1_0
    ldx #0
    
subtract_loop:
    lda NUM1_0, y
    sbc NUM2_0, y
    sta RES0, y
    
    inx
    
    cpx TMP1_0
    bne subtract_loop
    
    pla
    rts
