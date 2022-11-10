# Programação no Ethereum L2 (pt. 3): Básicas do Cairo 2

Antes de começar, recomendo que você prepare sua equipe para programar no Cairo ❤️ com o [primeiro tutorial](1_installation.md), e revise o [Cairo basics pt. 1](2_cairo_basics.md).

Este é o terceiro tutorial de uma série focada no desenvolvimento de contratos inteligentes com Cairo e StarkNet.

---

Na terceira parte da série de tutoriais básicos do Cairo, vamos nos aprofundar nos conceitos introduzidos na [segunda sessão](2_cairo_basics.md) como `builtin`, `felt` e `assert` e suas variações. Além disso, vamos introduzir arrays. Com o que aprendemos nesta sessão poderemos criar contratos básicos no Cairo 🚀.

## 1. Builtins e sua relação com pointers 

No programa a seguir estamos multiplicando dois números. O código inteiro está disponível em [src/multiplication.cairo](../../../src/multiplication.cairo). Lá você encontrará o código corretamente comentado.

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

func mult_two_nums(num1, num2) -> (prod : felt){
    return(prod = num1 * num2);
}

func main{output_ptr: felt*}(){
    let (prod) = mult_two_nums(2,2);
    serialize_word(prod);
    return ();
}
```

Lembra que introduzimos os `builtins` na última sessão junto com os argumentos implícitos?

Cada `builtin` lhe dá o direito de usar um pointer que terá o nome do `builtin` + “`_ptr`”. Por exemplo, o builtin output, que definimos `%builtins output` no início do nosso contrato, nos dá o direito de usar o pointer `output_ptr`. O `range_check` embutido nos permite usar o pointer `range_check_ptr`. Esses pointers são frequentemente usados como argumentos implícitos que são atualizados automaticamente durante uma função.

Na função para multiplicar dois números, usamos `%builtins output` e então usamos seu pointer ao definir main: `func main{output_ptr: felt*}():`.

## 2. Mais sobre como os felts são interessantes (raros?)

> O felt é o único tipo de dado que existe no Cairo, você pode até omiti-lo [sua declaração explícita] (StarkNet Bootcamp - Amsterdam - min 1:14:36).

Embora não seja necessário ser especialista nas qualidades matemáticas dos felts, é valioso saber como eles funcionam. No último tutorial, os apresentamos pela primeira vez, agora saberemos como eles afetam quando comparamos valores no Cairo.

> A definição de felt, em termos terrestres (a exata está aqui): um inteiro que pode se tornar enorme (mas tem limites). Por exemplo: {...,-4,-3,-2,-1,0,+1,+2,+3,...}. Sim, inclui 0 e números negativos.

Qualquer valor que não esteja dentro desse intervalo causará um "overflow": um erro que ocorre quando um programa recebe um número, valor ou variável fora do escopo de sua capacidade de manipulação ([Techopedia](https://www.techopedia . com/definition/663/overflow-error#:~:text=In%20computing%2C%20an%20overflow%20error,other%20numeric%20types%20of%20variables.)).

Agora entendemos os limites do felt. Se o valor for 0,5, por exemplo, temos um overflow. Onde experimentaremos overflows com frequência? Nas divisões. O contrato a seguir (o código completo está em [src/division1.cairo](../../../src/division1.cairo)) divide 9/3, verifica com `assert` que o resultado é 3 e imprime o resultado.

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}(){
    tempvar x = 9/3;
    assert x = 3;
    serialize_word(x);

    return();
}

```

Até agora tudo faz sentido. Mas e se o resultado da divisão não for um inteiro como no contrato a seguir (o código está em [src/division2.cairo](../../../src/division2.cairo))?

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}(){
    tempvar x = 10/3;
    assert x = 10/3;
    serialize_word(x);

    return();
}

```

Para começar, imprime o belo número 🌈 no console: `1206167596222043737899107594365023368541035738443865566657697352045290673497`. O que é isso e por que ele retorna para nós em vez de um ponto decimal considerável?

Na função acima `x` **não** é um `floating point`, 3.33, **ni** é um inteiro arredondado para o resultado, 3. É um inteiro que multiplicado por 3 nos dará 10 de volta ( veja como esta função `3 * x = 10`) ou também `x` pode ser um denominador que retorna 3 (`10 / x = 3`). Vamos ver isso com o seguinte contrato:

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

func main{output_ptr: felt*}(){
    tempvar x = 10/3;

    tempvar y = 3 * x;
    assert y = 10;
    serialize_word(y);

    tempvar z = 10 / x;
    assert z = 3;
    serialize_word(z);

    return();
}

```

Ao compilar e executar este contrato, obtemos exatamente o que estávamos procurando:

```python
Program output:
  10
  3

```
Cairo consegue isso voltando transbordando novamente. Não vamos entrar em detalhes matemáticos. isso é pouco intuitivo, mas não se preocupe, podemos deixar aqui.

> Uma vez que você está escrevendo contratos com Cairo, você não precisa ficar pensando constantemente sobre isso [as peculiaridades dos felts quando estão em divisões]. Mas é bom estar ciente de como eles funcionam (StarkNet Bootcamp - Amsterdam - min 1:31:00).
>

## **3. Comparando felts 💪**

Devido às particularidades dos felts, comparar entre felts não é como em outras linguagens de programação (como com `1 < 2`).

Na biblioteca `starkware.cairo.common.math` encontramos funções que nos ajudarão a comparar felts ([link para o repositório GitHub](https://github.com/starkware-libs/cairo-lang/blob/master/src /starkware/cairo/common/math.cairo)). Por enquanto vamos usar `assert_not_zero`, `assert_not_equal`, `assert_nn` e `assert_le`. Existem mais recursos para comparar felts nesta biblioteca, recomendo que você veja o repositório do GitHub para explorá-los. O [seguinte código do StarkNet Bootcamp Amsterdam](https://github.com/lightshiftdev/starknet-bootcamp/blob/main/packages/contracts/samples/04-cairo-math.cairo) ajuda a entender o que cada um faz as funções que importamos (alterei um pouco). O código completo está em [src/asserts.cairo](../../../src/asserts.cairo).

```python
%builtins range_check

from starkware.cairo.common.math import assert_not_zero, assert_not_equal, assert_nn, assert_le

func main{range_check_ptr : felt}(){
    assert_not_zero(1);  // not zero
    assert_not_equal(1, 2);  // not equal
    assert_nn(1); // non-negative
    assert_le(1, 10);  // less or equal
    
    return ();
}

```

Simples, certo? São apenas maneiras diferentes de fazer asserts.

Mas e se quisermos comparar `10/3 < 10`? Sabemos que isso é verdade, mas também sabemos que o resultado de `10/3` não é um número inteiro, por isso está fora do intervalo de valores possíveis que os felts podem assumir. Haverá overflow e será gerado o grande inteiro, que naturalmente será maior que 10 ou até mesmo se tornará fora dos possíveis inteiros que um felt pode levar (devido ao tamanho).

De fato, a seguinte função que compara `10/3 < 10` retornará um erro: `AssertionError: a = 2412335192444087475798215188730046737082071476887731133315394704090581346994 is out of range.`

```python
%builtins range_check

from starkware.cairo.common.math import assert_lt

func main{range_check_ptr : felt}(){
    assert_lt(10/3, 10); // less than

    return ();
}

```

Como então comparamos `10/3 < 10`? Temos que voltar para nossas aulas de ensino médio/faculdade. Vamos apenas remover o 3 do denominador multiplicando tudo por 3; compararíamos `3*10/3 < 3*10` que é o mesmo que `10 < 30`. Então, estamos apenas comparando números inteiros e esquecemos como os felts são excêntricos. A função a seguir é executada sem problemas.

```python
%builtins range_check

from starkware.cairo.common.math import assert_lt

func main{range_check_ptr : felt}(){
    assert_lt(3*10/3, 3*10);

    return ();
}

```

## 4. A natureza dual de assert

Como vimos, `assert` é a chave para a programação no Cairo. Nos exemplos acima, usamos para confirmar uma declaração, `assert y = 10`. Este é um uso comum em outras linguagens de programação como Python. Mas no Cairo quando você tenta `assert` algo que ainda não foi atribuído, `assert` funciona para atribuir. Dê uma olhada neste exemplo adaptado de [StarkNet Bootcamp Amsterdam](https://github.com/lightshiftdev/starknet-bootcamp/blob/main/packages/contracts/samples/04-cairo-math.cairo) que também é útil para consolidar o que você aprendeu sobre structs no [tutorial anterior](2_basicos_cairo.md). O código completo está em [src/vector.cairo](../../../src/vector.cairo).

```python
 %builtins output

from starkware.cairo.common.serialize import serialize_word

struct Vector2d{
    x : felt,
    y : felt,
}

func add_2d(v1 : Vector2d, v2 : Vector2d) -> (r : Vector2d){
    alloc_locals;

    local res : Vector2d;
    assert res.x = v1.x + v2.x;
    assert res.y = v1.y + v2.y;

    return (r=res);
}

func main{output_ptr: felt*}(){
    
    let v1 = Vector2d(x = 1, y = 2);
    let v2 = Vector2d(x = 3, y = 4);

    let (sum) = add_2d(v1, v2);

    serialize_word(sum.x);
    serialize_word(sum.y);

    return();
}
```

Ao executar `assert res.x = v1.x + v2.x`, o prover do Cairo (mais sobre isso depois) detecta que `res.x` não existe e atribui o novo valor `v1.x + v2.x` . Se fôssemos executar `assert res.x = v1.x + v2.x` novamente, o prover realmente compararia o que encontra atribuído em `res.x` com o que tentamos atribuir. Ou seja, o uso que já sabíamos.

## 5. Arrays no Cairo

Vamos fechar este tutorial com uma das estruturas de dados mais importantes. Arrays, contêm elementos ordenados. Eles são muito comuns na programação. Como eles funcionam no Cairo? Vamos aprender a **criar array de matrizes 🙉**. Sim, o escritor tem background em machine learning. O contrato abaixo está comentado (pode ser encontrado em [src/matrix.cairo](../../../src/matrix.cairo)) e examinaremos apenas a parte dos arrays, pois o leitor já sabe o resto.

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.alloc import alloc

struct Vector{
    elements : felt*,
}

struct Matrix{
    x : Vector,
    y : Vector,
}

func main{output_ptr: felt*}(){

    // Defining an array, my_array, of felts.
    let (my_array : felt*) = alloc();

    // Assigning values to three elements of my_array.  
    assert my_array[0] = 1;
    assert my_array[1] = 2;
    assert my_array[2] = 3;

    // Creating the vectors Vector, by
    // simplicity we use the same my_array for both.
    let v1 = Vector(elements = my_array);
    let v2 = Vector(elements = my_array);

    // Defining an array of Matrix matrices
    let (matrix_array : Matrix*) = alloc();

    // Filling matrix_array with Matrix instances.
    // Each instance of Matrix contains as members
    // Vector instances.
    assert matrix_array[0] = Matrix(x = v1, y = v2);
    assert matrix_array[1] = Matrix(x = v1, y = v2);

    // We use assert to test some values in
    // our matrix_array.
    assert matrix_array[0].x.elements[0] = 1;
    assert matrix_array[1].x.elements[1] = 2;

    // What value do you think it will print? Answer: 3
    serialize_word(matrix_array[1].x.elements[2]);

    return();
}
```

Criamos um array de feltros chamado `my_array`. Assim é definido:

```
let (my_array : felt*) = alloc();
```

é pouco intuitivo em comparação com o quão fácil é em Python e outras linguagens. `my_array : felt*` define uma variável chamada `my_array` que conterá um pointer (veja [tutorial anterior](2_basicos_cairo.md)) para um felt (ainda não definimos qual felt). Por quê? A documentação do Cairo nos ajuda:

> “Arrays podem ser definidos como um pointer (felt*) para o primeiro elemento do array. À medida que array é preenchida, os elementos ocupam células de memória contíguas. A função alloc() é usada para definir um segmento de memória que se expande em tamanho cada vez que um novo elemento é gravado no array (documentação do Cairo)."
>

Então, no caso de `my_array`, colocando o `alloc()` estamos indicando o segmento de memória para o qual a expressão `my_array` aponta (lembre-se que `my_array` é apenas o nome de um pointer, `felt* ` , na memória) será expandido cada vez que um novo elemento for escrito em `my_array`.

De fato, se formos [ao repositório](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/alloc.cairo) onde `alloc()` está localizado veremos que ele retorna `(ptr : felt*)`. Ou seja, ele retorna uma tupla de membro único que é um `felt*` (um ponteiro para um `felt`). Por ser uma tupla, nós a recebemos com um `let` e com `my_array : felt*` entre parênteses (veja [basicos de Cairo pt. 2](2_basicos_cairo.md y)). Tudo está fazendo sentido, certo 🙏?

Vemos que a definição do nosso array de matrizes é exatamente a mesma, exceto que ao invés de querer um array de `felt` nós queremos um de `Matrix`:

```python
let (matrix_array : Matrix*) = alloc();
```

Já passamos o complicado 😴. Agora vamos ver como preencher nosso array com estruturas `Matrix`. Usamos `assert` e podemos indexar com `[]` a posição do array que queremos alterar ou revisar:

```
assert matrix_array[0] = Matrix(x = v1, y = v2);
```

O que fizemos foi criar um `Matrix(x = v1, y = v2)` e atribuí-lo à posição 0 do nosso `matrix_array`. Lembre-se que começamos a contar de 0. Preencher nosso array `felt` é ainda mais trivial: `assert my_array[0] = 1`.

Então nós simplesmente chamamos os elementos dentro do `matrix_array` de diferentes maneiras. Por exemplo, com `matrix_array[1].x.elements[2]` indicamos estas etapas:

1. Chame o segundo, `[1]`, elemento de `matrix_array`. Ou seja, para `Matriz(x = v1, y = v2)`.
2. Chame o `membro` `x` de `Matrix`. Ou seja, para `v1 = Vector(elements = my_array)`.
3. Chame o `membro` `elementos` de `v1`. Ou seja, para `my_array`.
4. Chame o terceiro, `[2]`, elemento de `my_array`. Ou seja, para `3`.

Não é tão complicado assim mas é satisfatório o suficiente 🤭.

## **6. Conclusão**

Parabéns 🚀. Nós mergulhamos no básico do 🏖 Cairo. Com esse conhecimento você pode começar a fazer contratos simples no Cairo   .

Nos tutoriais a seguir, aprenderemos mais sobre gerenciamento de memória; a common library do Cairo; como funciona o compilador do Cairo; e mais!

Quaisquer comentários ou melhorias, por favor, comente com [@espejelomar](https://twitter.com/espejelomar) ou faça um PR 🌈.