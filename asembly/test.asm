uinc r0
uinc r0
.LABEL y 1

.HERE k
.DATA n033
.DATA n155

.LABEL p 3

.PADDING 13
; .DATA n975
.DATA n550
.DATA n022
; .DATA n778878
.DATA d66
.DATA d8
; .DATA d-66
.DATA d37
.DATA d728

.MACRO G f
ce iz f
re $y
.ENDMACRO

; .DATA d800
uadd r0 r0
uadd r0 r0
uadd r0 r0
uadd r0 r0


!G $k

ce iz $p
!G $k

ce iz $k
re 2
re $y

re 3

halt
