.text
.globl _calcula

_calcula:
    pushl %ebp
    movl %esp, %ebp
    subl $16, %esp
    pushl %ebx
    pushl %esi
    pushl %edi

    movl $0, -4(%ebp)
    movl $0, -8(%ebp)
    movl $0, -12(%ebp)

loopTiros:
    movl -4(%ebp), %ecx
    cmpl 12(%ebp), %ecx
    jge fim

    movl 20(%ebp), %eax
    movl (%eax,%ecx,4), %eax
    imull %eax
    movl %eax, %ebx
    movl %edx, %esi

    movl 24(%ebp), %eax
    movl (%eax,%ecx,4), %eax
    imull %eax
    addl %eax, %ebx
    adcl %edx, %esi

    xorl %edi, %edi
    movl 8(%ebp), %ecx

busca:
    cmpl %ecx, %edi
    jge fimBusca

    leal (%edi,%ecx), %eax
    shrl $1, %eax
    movl %eax, -16(%ebp)

    movl 16(%ebp), %edx
    movl (%edx,%eax,4), %eax
    mull %eax

    cmpl  %esi, %edx
    jb raioMenor
    ja raioMaiorIgual
    cmpl %ebx, %eax
    jb raioMenor

raioMaiorIgual:
    movl -16(%ebp), %ecx
    jmp busca

raioMenor:
    movl -16(%ebp), %edi
    incl %edi
    jmp busca

fimBusca:
    movl 8(%ebp), %eax
    subl %edi, %eax

    addl %eax, -8(%ebp)
    adcl $0, -12(%ebp)

    incl -4(%ebp)
    jmp loopTiros

fim:
    movl -8(%ebp), %eax
    movl -12(%ebp), %edx
    popl %edi
    popl %esi
    popl %ebx
    movl %ebp, %esp
    popl %ebp
    ret