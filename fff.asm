.model small
.code

half db 1
xc equ word ptr [bp+10]
yc equ word ptr [bp+8]
rad equ word ptr [bp+6]
color equ byte ptr [bp+4]
circX equ word ptr [bp-2]
circY equ word ptr [bp-4]
circD equ word ptr [bp-6]
circX2 equ word ptr [bp-8]
circY2 equ word ptr [bp-10]

drawCircle:
    cmp half,0
    jnz DrawCircleHalf
    mov cx, xc
    add cx, circX
    mov dx, yc
    add dx, circY
    call plot
    mov cx, xc
    sub cx, circY
    mov dx, yc
    add dx, circY
    call plot
    mov cx, xc
    add cx, circX
    mov dx, yc
    sub dx, circY
    call plot
    mov cx, xc
    sub cx, circX
    mov dx, yc
    sub dx, circY
    call plot
    mov cx, xc
    add cx, circX
    mov dx, yc
    add dx, circX
    call plot
    mov cx, xc
    sub cx, circY
    mov dx, yc
    add dx, circX
    call plot
    mov cx, xc
    add cx, circY
    mov dx, yc
    sub dx, circX
    call plot
    mov cx, xc
    sub cx, circY
    mov dx, yc
    sub dx, circX
    call plot
    ret

DrawCircleHalf:
    mov cx, circX
    shr cx, 1
    mov circX2, cx
    mov dx, circY
    shr dx, 1
    mov circY2, dx
    mov cx, xc
    add cx, circX
    mov dx, yc
    add dx, circY2
    call plot
    mov cx, xc
    sub cx, circX
    mov dx, yc
    add dx, circY2
    call plot

    if 1
        push ax
        mov al, 8
        mov cx, xc
        add cx, circX
        mov dx, yc
        sub dx, circY2
        call plot
        mov cx, xc
        sub cx, circX
        mov dx, yc
        sub dx, circY2
        call plot
        pop ax
    endif

    mov cx, xc
    add cx, circY
    mov dx, yc
    add dx, circX2
    call plot
    mov cx, xc
    sub cx, circY
    mov dx, yc
    add dx, circX2
    call plot

    if 1
        push ax
        mov al, 8
        mov cx, xc
        add cx, circY
        mov dx, yc
        sub dx, circX2
        call plot
        mov cx, xc
        sub cx, circY
        mov dx, yc
        sub dx, circX2
        call plot
        pop ax
    endif

    ret

circle proc
    push bp
    mov bp, sp
    sub sp, 16
    push ax
    push bx
    push cx
    push dx

    mov ax, 0
    mov circX, ax
    mov ax, rad
    mov circY, ax
    mov ax, rad
    add ax, ax
    sub ax, 3
    neg ax
    mov circD, ax
    mov al, color
    call drawCircle

    circle0:
        mov ax, circY
        cmp ax, circX
        jl circle1
        inc circX
        cmp circD, 0
        jle circle2
        dec circY
        mov ax, circX
        sub ax, circY
        add ax, ax
        add ax, ax
        add ax, circD
        add ax, 10
        mov circD, ax
        jmp circle3

    circle2:
        mov ax, circX
        add ax, ax
        add ax, ax
        add ax, circD
        add ax, 6
        mov circD, ax

    circle3:
        mov al, color
        call drawCircle
        jmp circle0

    circle1:
        pop dx
        pop cx
        pop bx
        pop ax
        mov sp, bp
        pop bp
        ret 8
circle endp

x1 equ word ptr [bp+12]
y1 equ word ptr [bp+10]
x2 equ word ptr [bp+8]
y2 equ word ptr [bp+6]
col equ byte ptr [bp+4]
deltaX equ word ptr [bp-2]
deltaY equ word ptr [bp-4]
signX equ word ptr [bp-6]
signY equ word ptr [bp-8]
er equ word ptr [bp-10]
er2 equ word ptr [bp-12]

drawline proc
    push bp
    mov bp, sp
    sub sp, 16
    push ax
    push bx
    push cx
    push dx

    mov ax, x2
    sub ax, x1
    jge lin1
    neg ax

lin1:
    mov deltaX, ax
    mov ax, y2
    sub ax, y1
    jge lin2
    neg ax

lin2:
    mov deltaY, ax
    mov bx, 1
    mov ax, x1
    cmp ax, x2
    jl lin3
    neg bx

lin3:
    mov signX, bx
    mov bx, 1
    mov ax, y1
    cmp ax, y2
    jl lin4
    neg bx

lin4:
    mov signY, bx
    mov ax, deltaX
    sub ax, deltaY
    mov er, ax
    mov cx, x2
    mov dx, y2
    mov al, col
    call plot

will:
    mov ax, x1
    cmp ax, x2
    jnz wil2
    mov ax, y1
    cmp ax, y2
    jnz wil2
    jmp wend

wil2:
    mov cx, x1
    mov dx, y1
    mov al, col
    call plot
    mov ax, er
    add ax, ax
    mov er2, ax
    mov ax, er2
    add ax, deltaY
    jle lin5
    mov ax, er
    sub ax, deltaY
    mov er, ax
    mov ax, x1
    add ax, signX
    mov x1, ax

lin5:
    mov ax, er2
    add ax, deltaX
    jge lin6
    mov ax, er
    add ax, deltaX
    mov er, ax
    mov ax, y1
    add ax, signY
    mov y1, ax

lin6:
    jmp will

wend:
    pop dx
    pop cx
    pop bx
    pop ax
    mov sp, bp
    pop bp
    ret 10
drawline endp

invoke macro proc_name, param_list
    irp param, <param_list>
        mov ax, param
        push ax
    endm
    call proc_name
endm


oldbank dw 0

setgraf:
    mov ax, 4F02h
    mov bx, 103h  ;800x600x256
    int 10h
    mov oldbank, -1
    ret

settxt:
    mov ax, 3
    int 10h
    ret

setbank:
    cmp dx, oldbank
    jz setbl
    push ax
    push bx
    mov ax, 4F05h
    mov bx, 0
    int 10h
    pop bx
    pop ax
    mov oldbank, dx

setbl:
    ret

plot:
    cmp cx, 800
    jnc plotl
    cmp dx, 600
    jnc plotl
    push ax
    push cx
    push dx
    push di
    push es
    push ax
    mov ax, 0A000h
    mov es, ax
    mov ax, 800
    mul dx
    add ax, cx
    adc dx, 0
    call setbank
    mov di, ax
    pop ax
    mov es:[di], al
    pop es
    pop di
    pop dx
    pop cx
    pop ax

plotl:
    ret

start:
    call setgraf
    invoke drawline, <300, 200, 300, 400, 15>  ; ?????? ???????????? ?????, ???????? ???? ?? 100
    invoke drawline, <500, 200, 500, 400, 15>  ; ?????? ???????????? ?????, ???????? ?? ??? X ?? 100 ? ???? ?? 100
    invoke drawline, <350, 200, 350, 400, 15>  ; ?????? ???????????? ?????, ???????? ???? ?? 100
    invoke drawline, <450, 200, 450, 400, 15>
    invoke circle, <400, 400, 100, 15>          ; ??????? ???? (???????) ? ??????? ? (400, 400) ? ???????? 100
    invoke circle, <400, 200, 100, 15>          ; ?????? ????, ??????? ???? ?? ??? X
    invoke circle, <400, 400, 50, 15>           ; ?????????? ??????? ????, ? ???????? 50, ?????? ??????? ????????
    invoke circle, <400, 200, 50, 15>           ; ?????????? ??????? ????, ? ???????? 50, ?????? ??????? ????????
    mov ah, 0
    int 16h
    call settxt
    int 20h
end start
