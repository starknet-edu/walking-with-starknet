# Programação em Ethereum L2 (pt. 2): Básicas do Cairo 1

Antes de começar, Eu recomendo que você prepare seu equipamento para programar no Cairo ❤️ com o [tutorial passado](1_installation.md).

Este é o segundo tutorial de uma série focada no desenvolvimento de contratos inteligentes com Cairo e StarkNet. Recomendo que você faça o último tutorial antes de passar para este.


---

## 1. Somar dois números

Para aprender o básico do Cairo vamos criar juntos uma função para somar dois números 🎓. O código é muito simples, mas nos ajudará a entender melhor muitos conceitos do Cairo. Dependeremos muito da [documentação do Cairo](https://www.cairo-lang.org/docs/). A documentação é excelente, até hoje não está pronta para servir como um tutorial estruturado para iniciantes. Aqui buscamos resolver isso.

Aqui está o nosso código para somar dois números. Você pode colá-lo diretamente em seu editor de código ou IDE. No meu caso estou usando o VSCode com a extensão Cairo.

Não se preocupe se você não entender tudo o que está acontecendo neste momento. Mas [@espejelomar](https://twitter.com/espejelomar) vai se preocupar se no final do tutorial você não entender cada linha deste código. Deixe-me saber se sim porque vamos melhorar 🧐. Cairo é uma linguagem low-level, então será mais difícil do que aprender Python, por exemplo. Mas vai valer a pena 🥅. Olhos no gol.

Vamos ver linha por linha e com exemplos adicionais o que estamos fazendo. Todo o programa para somar os dois números está disponível em [src/sum.cairo](../../../src/sum.cairo). Lá você encontrará o código corretamente comentado.

```python
%builtins output

from starkware.cairo.common.serialize import serialize_word

// @dev Add two numbers and return the result
// @param num1 (felt): first number to add
// @param num2 (felt): second number to add
// @return sum (felt): value of the sum of the two numbers
func sum_two_nums(num1: felt, num2: felt) -> (sum: felt) {
    alloc_locals;
    local sum = num1+num2;
    return (sum=sum);
}

func main{output_ptr: felt*}(){
    alloc_locals;
    
    const NUM1 = 1;
    const NUM2 = 10;

    let (sum) = sum_two_nums(num1 = NUM1, num2 = NUM2);
    serialize_word(sum);
    return ();
}

```

## 2. Os builtins

No início do nosso programa no Cairo escrevemos `%builtins output`. Aqui estamos dizendo ao compilador do Cairo que usaremos o `builtin` chamado `output`. A definição de `builtin` é bastante técnica e está além do escopo deste primeiro tutorial ([aqui está](https://www.cairo-lang.org/docs/how_cairo_works/builtins.html#builtins) na documentação) . Por enquanto, basta apontar que podemos convocar as habilidades especiais do Cairo através dos recursos internos. Se você conhece C++ certamente já encontrou as semelhanças.

> Builtin output é o que permite que o programa se comunique com o mundo exterior. Você pode pensar nisso como o equivalente a `print()` em Python ou `std::cout` em C++ ([documentação do Cairo](https://www.cairo-lang.org/docs/hello_cairo/intro.html #escrevendo -a-função-principal)).

A interação entre `builtin` `output` e a função `serialize_word`, que importamos anteriormente, nos permitirá imprimir no console. Neste caso com `serialize_word(sum)`. Não se preocupe, vamos dar uma olhada nisso mais tarde.


## 3. Importando

Cairo é construído em cima do Python, então importar funções e variáveis é exatamente o mesmo. A linha `from starkware.cairo.common.serialize import serialize_word` está importando a função `serialize_word` encontrada em `starkware.cairo.common.serialize`. Para visualizar o código fonte desta função, basta acessar o repositório do Github `cairo-lang` ([link](https://github.com/starkware-libs/cairo-lang)). Por exemplo, a função serialize é encontrada [aqui](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/serialize.cairo) dentro do repositório. Isso será útil para encontrar bugs no código ou entender o Cairo mais profundamente.

> Várias funções da mesma biblioteca podem ser separadas por vírgulas. Funções de diferentes bibliotecas são importadas em diferentes linhas. Cairo procura cada módulo em um caminho de diretório padrão e quaisquer caminhos adicionais especificados em tempo de compilação (documentação do Cairo).
>

É assim que várias funções são importadas da mesma biblioteca: `from starkware.cairo.common.math import (assert_not_zero, assert_not_equal)`.

## 4. Field elements (felt)

No Cairo, quando o type de uma variável ou argumento não é especificado, é atribuído automaticamente o tipo `felt`. A [documentação do Cairo](https://www.cairo-lang.org/docs/hello_cairo/intro.html#the-primitive-type-field-element-felt) entra em detalhes técnicos sobre o que um `sentido`. Para os propósitos deste tutorial, basta dizer que um `felt` funciona como um inteiro. Nas divisões podemos notar a diferença entre o `felt` e os inteiros. No entanto, citando a documentação:

> Na maior parte do seu código (a menos que você pretenda escrever código muito algébrico), você não terá que lidar com o fato de que os valores no Cairo são felts e você pode tratá-los como se fossem inteiros normais.
>

## 5. Struct (dicionários do Cairo?)

Além do `felt`, temos outras estruturas à nossa disposição (mais detalhes na [documentação](https://www.cairo-lang.org/docs/reference/syntax.html#type-system)).

Podemos criar nossa própria estrutura, estilo dicionário Python:

```python
struct MyStruct{
    first_member : felt,
    second_member : felt,
}

```

Então definimos um novo tipo de dados chamado `MyStruct` com as propriedades `first_member` e `second_member`. Definimos o `type` de ambas as propriedades como `felt`, mas também podemos ter colocado outros tipos. Quando criamos um `struct` é obrigatório adicionar o `type`.

Podemos criar uma variável do tipo `MyStruct`: `name = (first_member=1, second_member=4)`. Agora a variável `name` tem `type` `MyStruct`.

Com `name.first_member` podemos acessar o valor deste argumento, neste caso é 1.


## **6. As tuplas (tuples, em inglês)**

Tuplas no Cairo são praticamente as mesmas tuplas em Python:

> Uma tupla é uma lista finita, ordenada e inalterável de elementos. Ele é representado como uma lista de elementos separados por vírgulas entre parênteses (por exemplo, (3, x)). Seus elementos podem ser de qualquer combinação de tipos válidos. Uma tupla contendo apenas um elemento deve ser definida de duas maneiras: o elemento é uma tupla nomeada ou tem uma vírgula à direita. Ao passar uma tupla como argumento, o tipo de cada elemento pode ser especificado por elemento (por exemplo, my_tuple : (felt, felt, MyStruct)). Os valores de tupla podem ser acessados com um índice baseado em zero entre parênteses [índice], incluindo acesso a elementos de tupla aninhados conforme mostrado abaixo (documentação do Cairo).
>

A documentação do Cairo é muito clara em sua definição de tuplas. Aqui seu exemplo:

```python
# A tuple with three elements
local tuple0 : (felt, felt, felt) = (7, 9, 13)
local tuple1 : (felt) = (5,)  # (5) is not a valid tuple.

# A named tuple does not require a trailing comma
local tuple2 : (a : felt) = (a=5)

# Tuple containing another tuple.
local tuple3 : (felt, (felt, felt, felt), felt) = (1, tuple0, 5)
local tuple4 : ((felt, (felt, felt, felt), felt), felt, felt) = (
    tuple3, 2, 11)
let a = tuple0[2]  # let a = 13.
let b = tuple4[0][1][2]  # let b = 13.

```

## 7. A estrutura de funções e comentários

A definição de uma função no Cairo tem o seguinte formato:

```python
func function(arg1: felt, arg2) -> (retornado: felt){
  // Function body
  let (sum) = sum_two_nums(num1 = NUM1, num2 = NUM2);
  return(returned=sum);
}

```

- **Definir o scope da função**. Iniciamos a função com `func`. O scope de nossa função é definido com chaves {}.
- **Argumentos e nome**. Definimos os argumentos que a função recebe entre parênteses ao lado do nome que definimos para nossa função, `function` neste caso. Os argumentos podem levar seu type (tipo, em português) definido ou não. Neste caso, `arg1` deve ser do type `felt` e `arg2` pode ser de qualquer type.
- **Retornar**. Nós necessariamente temos que adicionar `return()`. Embora a função não esteja retornando nada. Neste caso estamos retornando uma variável chamada `returned` então colocamos `return(returned=sum)` onde sum é o valor que a variável `returned` irá receber.
- **Comentários**. No Cairo comentamos com `//`. Este código não será interpretado ao executar nosso programa.

Assim como outras linguagens de programação. Precisaremos de uma função `main()` que orquestre o uso do nosso programa no Cairo. Ela é definida exatamente da mesma forma que uma função normal apenas com o nome `main()`. Pode vir antes ou depois das outras funções que criamos em nosso programa.


## 8. Interagindo com pointers (ponteiros, em português): parte 1

> Um pointer é utilizado para indicar o endereço do primeiro felt de um elemento na memória. O pointer pode ser utilizado para aceder ao elemento de forma eficiente. Por exemplo, uma função pode aceitar um ponteiro como argumento e depois aceder ao elemento no endereço do ponteiro (documentação do Cairo).
>

Suponhamos que temos uma variável chamada `var`:

- `var*` é um pointer para o endereço de memória do objeto `var`.
- `[var]` é o valor armazenado no endereço `var*`.
- `&var` é o endereço para o objeto `var`.
- `&[x]` é `x`. Você pode ver que `x` é um endereço?

## 9. Argumentos implícitos

Antes de explicar como os argumentos implícitos funcionam, uma regra: Se uma função `foo()` chama uma função com um argumento implícito, `foo()` também deve obter e retornar o mesmo argumento implícito.

Com isso dito, vamos ver como é uma função com um argumento implícito. A função é serialize_word que está disponível na biblioteca `starkware.cairo.common.serialize` e nós a usamos em nossa função inicial para somar dois números.

```python
%builtins output

func serialize_word{output_ptr : felt*}(word : felt){
    assert [output_ptr] = word
    let output_ptr = output_ptr + 1
    # The new value of output_ptr is implicitly
    # added in return.
    return ()
}

```

Isso vai ser um pouco confuso, esteja preparado. Vou tentar deixar tudo bem claro 🤗. Para uma função receber argumentos implícitos, colocamos o argumento entre `{}`. Neste e em muitos outros casos, `output_ptr` é recebido, que é um pointer para um type felt. Quando declaramos que uma função recebe um argumento implícito, a função retornará automaticamente o valor do argumento implícito no término da função. Se não movermos o valor do argumento implícito, ele retornaria automaticamente o mesmo valor com o qual começou. No entanto, se durante a função o valor do argumento implícito for alterado, o novo valor será retornado automaticamente.

No exemplo com a função `serialize_word` definimos que vamos receber um argumento implícito chamado `output_ptr`. Além disso, também recebemos um argumento explícito chamado `value`. Ao final da função retornaremos o valor que `output_ptr` possui naquele momento. Durante a função vemos que `output_ptr` aumenta em 1: `let output_ptr = output_ptr + 1`. Então a função retornará implicitamente o novo valor de `output_ptr`.

Seguindo a regra definida no início, qualquer função que chame `serialize_word` também terá que receber o argumento implícito `output_ptr`. Por exemplo, parte da nossa função para somar dois números é assim:

```python
func main{output_ptr: felt*}(){
    alloc_locals

    const NUM1 = 1
    const NUM2 = 10

    let (sum) = sum_two_nums(num1 = NUM1, num2 = NUM2)
    serialize_word(word=sum)
    return ()
}

```
Vemos que chamamos `serialize_word` então necessariamente temos que pedir também o argumento `output_ptr` implícito em nossa função `main`. É aqui que outra propriedade dos argumentos implícitos entra em jogo, e talvez por que eles são chamados assim. Vemos que ao chamar `serialize_word` passamos apenas o argumento `word` explícito. O argumento implícito `output_ptr` é passado automaticamente 🤯! Tenha cuidado, também poderíamos ter tornado o argumento implícito explícito assim: `serialize_word{output_ptr=output_ptr}(word=a)`. Já sabemos programar no Cairo? 🙉

Portanto, o argumento implícito é implícito porque:

1. Dentro da função implícita, o valor final do argumento implícito é retornado automaticamente.
2. Quando a função implícita é chamada, não precisamos indicar que vamos passar o argumento implícito. O valor padrão é incluído automaticamente.

## 10. Locals (locais, em português)

Estamos quase prontos para entender 100% o que fizemos em nossa função que soma dois números. Eu sei, tem sido uma estrada rochosa 🙉. Mas há um arco-íris no final do tutorial 🌈.

Então definimos uma variável local: `local a = 3`.

> Qualquer função que use uma variável local deve ter uma declaração alloc_locals, geralmente no início da função. Esta instrução é responsável por alocar células de memória usadas por variáveis locais dentro do escopo da função (documentação do Cairo).
>

Como exemplo, veja esta parte da nossa função que adiciona dois números:

```python
func sum_two_nums(num1: felt, num2: felt) -> (sum){
    alloc_locals
    local sum = num1+num2
    return(sum)
}

```

É muito simples 💛.

Já que não queremos que seja tão fácil, vamos falar de memória. O Cairo armazena variáveis locais relativas ao frame pointer (`fp`) (entraremos em mais detalhes sobre `fp` em um tutorial posterior). Portanto, se precisássemos do endereço de uma variável local, `&sum` não seria suficiente, pois nos daria este erro: `usar o valor fp diretamente requer a definição de uma variável __fp__`. Podemos obter este valor importando `from starkware.cairo.common.registers import get_fp_and_pc`. `get_fp_and_pc` retorna uma tupla com os valores atuais de `fp` e `pc`. No estilo mais Python, indicaremos que estamos interessados apenas no valor de `fp` e que iremos armazená-lo em uma variável `__fp__`: `let (__fp__, _) = get_fp_and_pc()`. Feito agora podemos usar `&sum`. Em outro tutorial veremos um exemplo disso.

## **11. Constants (constantes, em português)**.

Muito simples. Apenas lembre-se que eles devem fornecer um inteiro (um field) quando compilamos nosso código. Crie uma constante:

```python
const NUM1 = 1

```

## **12. References (referências, em português)**

Este é o formato para definir um:

```python
let ref_name : ref_type = ref_expr

```

Onde `ref_type` é um type e `ref_expr` é uma expressão do Cairo. Colocar o `ref_type` é opcional, mas é recomendado fazê-lo.

Uma referência pode ser reatribuída ([documentação](https://www.cairo-lang.org/docs/reference/syntax.html#references) do Cairo):

```python
let a = 7 # a is initially bound to the expression 7.
let a = 8 # a is now bound to the expression 8.

```

Em nossa soma de dois números, criamos uma referência chamada `sum`. Vemos que atribuímos a `sum` o `felt` que a função `sum_two_nums` retorna.

```python
let (sum) = sum_two_nums(num1 = NUM1, num2 = NUM2)

```

## 13. Compile e execute 𓀀

Você já sabe como fazer funções no Cairo! Agora vamos executar nosso primeiro programa.

As ferramentas que a StarkNet oferece para interagir com a linha de comando são muitas 🙉. Não entraremos em detalhes até mais tarde. Por enquanto, mostraremos apenas os comandos com os quais podemos executar o aplicativo que criamos neste tutorial 🧘‍♀️. Mas não se preocupe, os comandos para rodar outros aplicativos serão bem parecidos.

`cairo-compile` nos permite compilar nosso código e exportar um json que leremos no próximo comando. Se o nosso é chamado `src/sum.cairo` (porque está no diretório `src` como neste repositório) e queremos que o json seja chamado `build/sum.json` (porque está no `build` como em este repositório), então usaríamos o seguinte código:

```
cairo-compile src/sum.cairo --output build/sum.json`
```

Simples, certo? ❤️

Ok, agora vamos executar nosso programa com `cairo-run`.

```
cairo-run --program=build/sum.json --print_output --layout=small
```

O resultado deve imprimir corretamente um 11 em nosso terminal.

Aqui os detalhes:

Indicamos no argumento --program que queremos executar o build/sum.json que geramos anteriormente.

Com --print_output indicamos que queremos imprimir algo do nosso programa no terminal. Por exemplo, no próximo tutorial usaremos builtin (vamos estudá-los mais tarde) output e a função serialize_word para imprimir no terminal.

--layout nos permite indicar o layout a ser usado. Dependendo dos builtins que usamos, será o layout a ser usado. Mais tarde estaremos usando builtin output e para isso precisamos do layout small. Se não usarmos nenhum builtin, podemos deixar este argumento vazio para que possamos usar o layout default, o layout plain.

## **14. Conclusão**

Parabéns 🚀. Aprendemos o básico do 🏖 Cairo. Com esse conhecimento você poderia identificar o que é feito em cada linha da nossa função que soma dois inteiros   .

Nos tutoriais a seguir, aprenderemos mais sobre pointers e gerenciamento de memória; a common library do Cairo; como funciona o compilador do Cairo; e mais!

Quaisquer comentários ou melhorias, por favor, comente com [@espejelomar](https://twitter.com/espejelomar) ou faça um PR 🌈.
