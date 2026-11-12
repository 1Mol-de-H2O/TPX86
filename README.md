# TP X86 – Tiro ao Alvo

**Disciplina:** Arquitetura e Organização de Computadores II – UFCIMG

## 1. Objetivo

Calcular a pontuação total de Juquinha no jogo Tiro ao Alvo. O alvo tem C círculos concêntricos centrados na origem, e são feitos T tiros. Cada tiro vale um ponto por círculo que o contém (tiro exatamente na borda conta como contido). O programa lê os dados, calcula o total e imprime um único inteiro.

## 2. Estrutura do projeto

| Arquivo | Linguagem | Função |
| --- | --- | --- |
| `main.c` | C | Leitura da entrada (`scanf`), chamada da função de cálculo e impressão do resultado (`printf`) |
| `calcula.s` | Assembly x86 32 bits (sintaxe AT&T) | Cálculo da pontuação |

A função em assembly é declarada em C como:

```c
long long calcula(int C, int T, int *raios, int *xs, int *ys);
```

## 3. Entrada e saída

**Entrada:** primeira linha com C e T; depois C linhas com os raios (em ordem crescente); depois T linhas com o par X Y de cada tiro.

**Saída:** uma linha com o total de pontos.

## 4. Algoritmo

1. Para cada tiro, calcular a distância ao quadrado: `d² = x² + y²`. Não se usa raiz quadrada, e a comparação é feita com `R²`.
2. Um círculo contém o tiro se `R² ≥ d²` (o `≥` faz a borda contar).
3. Como os raios são crescentes, os círculos que contêm o tiro são todos a partir do primeiro com `R² ≥ d²`. Esse índice é encontrado por **busca binária**.
4. Pontos do tiro = `C − índice encontrado`.
5. Somar os pontos de todos os tiros.

**Complexidade:** O(T · log C), contra O(T · C) de uma solução ingênua.

## 5. Decisões de implementação

### Arquitetura de 32 bits

O código usa apenas registradores de 32 bits (`%eax`, `%ebx`, `%ecx`, `%edx`, `%esi`, `%edi`, `%ebp`, `%esp`), instruções com sufixo `l` e é compilado com `gcc -m32`.

### Valores de 64 bits em máquina de 32 bits

Os limites do problema estouram 32 bits:

- `R` até 10⁶, logo `R²` até 10¹².
- `x² + y²` até 2·10¹⁰.
- O total de pontos pode chegar a T·C, ou seja, até cerca de 10¹¹.

Por isso:

- `imull` e `mull` com um operando produzem o resultado de 64 bits em `%edx:%eax`.
- A soma de 64 bits usa `addl` na parte baixa e `adcl` na parte alta (propaga o "vai um").
- A comparação de 64 bits compara primeiro a parte alta e, se iguais, a parte baixa (`cmpl` com `jb`/`ja`).
- O total é acumulado em duas variáveis locais de 32 bits e devolvido em `%edx:%eax`.

### Convenção de chamada (cdecl)

Os parâmetros chegam pela pilha e são lidos a partir de `%ebp`:

| Posição | Conteúdo |
| --- | --- |
| `8(%ebp)` | C |
| `12(%ebp)` | T |
| `16(%ebp)` | endereço do vetor de raios |
| `20(%ebp)` | endereço do vetor de X |
| `24(%ebp)` | endereço do vetor de Y |

Variáveis locais:

| Posição | Conteúdo |
| --- | --- |
| `-4(%ebp)` | índice do tiro atual |
| `-8(%ebp)` | total, parte baixa |
| `-12(%ebp)` | total, parte alta |
| `-16(%ebp)` | posição do meio na busca binária |

Os registradores `%ebx`, `%esi` e `%edi` são salvos na entrada e restaurados na saída, como exige a convenção.

### Uso dos registradores

| Registrador | Papel |
| --- | --- |
| `%esi:%ebx` | `d²` (64 bits) |
| `%edi` | limite inferior da busca binária |
| `%ecx` | limite superior da busca (e índice do tiro no início de cada volta) |
| `%edx:%eax` | resultado das multiplicações |

## 6. Como compilar e executar

**Linux ou WSL:**

```bash
gcc -m32 -o tp main.c calcula.s
./tp < entrada.txt
```

**Windows com MinGW 32 bits:** o símbolo da função precisa de sublinhado em `calcula.s` (`.globl _calcula` e rótulo `_calcula:`). O `main.c` não muda.

```bash
gcc -o tp main.c calcula.s
./tp < entrada.txt
```

## 7. Testes

| Entrada | Saída esperada |
| --- | --- |
| Exemplo 1 do enunciado (3 círculos, 10 tiros) | 13 |
| Exemplo 2 do enunciado (3 círculos, 6 tiros) | 11 |

Testes adicionais sugeridos:

- Tiro exatamente na borda de um círculo (deve contar).
- Tiro na origem `(0, 0)` (conta todos os círculos).
- Tiro fora de todos os círculos (zero pontos).
- Valores extremos (`X = Y = 100000`, raios até 10⁶) para validar a aritmética de 64 bits.

## 8. Observações

- O enunciado cita o simulador MARS, que é de MIPS. Neste trabalho foi seguida a orientação do professor: entrada e saída em C e processamento em assembly x86 de 32 bits.
- Restrições do problema (garantidas pela entrada, não verificadas pelo programa): `1 ≤ Rᵢ ≤ 10⁶`, raios estritamente crescentes, `1 ≤ T ≤ 10⁵`, `−10⁵ ≤ X, Y ≤ 10⁵`.
