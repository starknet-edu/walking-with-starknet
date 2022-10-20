# Programando en la L2 de Ethereum (pt. 2): Básicos de Cairo 1

Antes de comenzar, te recomiendo que prepares tu equipo para programar en Cairo ❤️ con el [tutorial pasado](1_instalacion.md).

Únete a la comunidad de habla hispana de StarkNet ([Linktree](https://linktr.ee/starknet_es). Este es el segundo tutorial de una serie enfocada en el desarrollo de smart cotracts con Cairo y StarkNet. Recomiendo que hagas el tutorial pasado antes de pasar a este. 

🚀 El futuro de Ethereum es hoy y ya está aquí. Y apenas es el comienzo. Aprende un poco más sobre el ecosistema de Starkware en [este texto corto](https://mirror.xyz/espejel.eth/PlDDEHJpp3Y0UhWVvGAnkk4JsBbJ8jr1oopGZFaRilI).

---

## 1. Sumar dos números

Para aprender los básicos de Cairo crearemos juntos una función para sumar dos números 🎓. El código es muy sencillo pero nos ayudará a entender mejor muchos conceptos de Cairo. Nos basaremos fuertemente en la [documentación de Cairo](https://www.cairo-lang.org/docs/). La documentación es excelente, al día de hoy no está lista para fungir como un tutorial estructurado para principiantes. Aquí buscamos solucionar esto 🦙.

Aquí está nuestro código para sumar dos números. Puedes pegarlo directamente en tu editor de código o IDE. En mi caso estoy usando VSCode con la extensión de Cairo.

No te preocupes si no entiendes en este punto todo lo que está sucediendo. Pero [@espejelomar](https://twitter.com/espejelomar) se preocupará si al final del tutorial no comprendes cada línea de este código. Avísame si es así porque mejoraremos 🧐. Cairo es un lenguaje low-level por lo que será más díficil que aprender Python, por ejemplo. Pero valdrá la pena 🥅. Ojos en la meta.

Veamos línea por línea y con ejemplos adicionales lo que estamos haciendo. El programa entero para sumar los dos números está disponible en [src/sum.cairo](../../../src/suma.cairo). Ahí encontrarás el código correctamente comentado.

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

## 2. Los builtins**

Al comienzo de nuestro programa en Cairo escribimos `%builtins output`. Aquí estamos diciendo al compilador de Cairo que usaremos el `builtin` llamado `output`. La definición de `builtin` es bastante técnica y sale del alcance de este primer tutorial ([aquí esta](https://www.cairo-lang.org/docs/how_cairo_works/builtins.html#builtins) en la documentación). Por el momento, nos basta indicar que podemos convocar capacidades especiales de Cairo a través de los builtins. Si sabes C++ seguramente ya encontraste las similitudes.

> El builtin output es lo que permite que el programa se comunique con el mundo exterior. Puedes considerarlo como el equivalente de `print()` en Python o `std::cout` de C++ ([documentación de Cairo](https://www.cairo-lang.org/docs/hello_cairo/intro.html#writing-a-main-function)).
> 

La interacción entre `builtin` `output` y la función `serialize_word`, que importamos previamente, nos permitirá imprimir a la consola. En este caso con `serialize_word(sum)`. No te preocupes, más adelante lo veremos más de cerca.

## 3. Importando

Cairo está contruido arriba de Python por lo que importar funciones y variables es exactamente igual. La línea `from starkware.cairo.common.serialize import serialize_word` está importando la función `serialize_word` que se encuentra en `starkware.cairo.common.serialize`. Para ver el código fuente de esta función basta con ir al repositorio en Github de `cairo-lang` ([link](https://github.com/starkware-libs/cairo-lang)). Por ejemplo, la función serialize se encuentra [aquí](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/serialize.cairo) dentro del repositorio. Esto te será útil para encontrar errores en el código o comprender más a fondo Cairo.

> Varias funciones de la misma biblioteca se pueden separar con comas. Las funciones de diferentes bibliotecas se importan en diferentes líneas. Cairo busca cada módulo en una ruta de directorio predeterminada y en cualquier ruta adicional especificada en el momento de la compilación (documentación de Cairo).
> 

Así se importan varias funciones de una misma biblioteca: `from starkware.cairo.common.math import (assert_not_zero, assert_not_equal)`.

## 4. Los field elements (felt)

En Cairo cuando no se específica el type de una variable o argumento se le asigna automáticamente el tipo `felt`. En la [documentación de Cairo](https://www.cairo-lang.org/docs/hello_cairo/intro.html#the-primitive-type-field-element-felt) se entra en detalles técnicos sobre lo que es un `felt`. Para fines de este tutorial basta con decir que un `felt` funciona como un entero. En las divisiones podemos notar la diferencia entre los `felt` y los enteros. Sin embargo, citando la documentación:

> En la mayor parte de tu código (a menos que tengas la intención de escribir un código muy algebraico), no tendrás que lidiar con el hecho de que los valores en Cairo son felts y podrá tratarlos como si fueran números enteros normales.
> 

## 5. Los struct (los diccionarios de Cairo?)

Además de los `felt`, tenemos otras estructuras a nuestra disposición (más detalles en la [documentación](https://www.cairo-lang.org/docs/reference/syntax.html#type-system)).

Podemos crear nuestra propia estructura, estilo diccionario de Python:

```python
struct MyStruct{
    first_member : felt,
    second_member : felt,
}

```

Así definimos un nuevo tipo de datos llamado `MyStruct` con las propiedades `first_member` y `second_member`. Definimos que el `type` de ambas propiedades sea `felt` pero bien pudimos colocar otros types. Cuando creamos una `struct` es obligatorio agregar el `type`.

Podemos crear una variable de tipo `MyStruct`: `name = (first_member=1, second_member=4)`. Ahora la variable `name` tiene `type` `MyStruct`.

Con `name.first_member` podemos acceder al valor de este argumento, en este caso es 1.

## **6. Las tuplas (tuples, en inglés)**

Las tuplas en Cairo son prácticamente iguales a las tuplas en Python:

> Una tupla es una lista finita, ordenada e inalterable de elementos. Se representa como una lista de elementos separados por comas encerrados entre paréntesis (por ejemplo, (3, x)). Sus elementos pueden ser de cualquier combinación de tipos válidos. Una tupla que contiene solo un elemento debe definirse de una de las dos formas siguientes: el elemento es una tupla con nombre o tiene una coma final. Cuando se pasa una tupla como argumento, el tipo de cada elemento se puede especificar por elemento (por ejemplo, my_tuple : (felt, felt, MyStruct)). Se puede acceder a los valores de tupla con un índice basado en cero entre paréntesis [index], incluido el acceso a elementos de tupla anidados como se muestra a continuación (documentación de Cairo).
> 

La documentación de Cairo es muy clara en su definición de las tuplas. Aquí su ejemplo:

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

## 7. La estructura de las funciones y comentarios

La definición de una función en Cairo tiene el siguiente formato:

```python
func function(arg1: felt, arg2) -> (retornado: felt){
  // Cuerpo de la función
  let (sum) = sum_two_nums(num1 = NUM1, num2 = NUM2);
  return(returned=sum);
}

```

- **Definir el scope de la función** (alcance, en español). Comenzamos la función con `func`. El scope de nuestra función se define con llaves {}.
- **Argumentos y nombre**. Definimos los argumentos que recibe la función entre paréntesis a un lado del nombre que definimos para nuestra función, `function` en este caso. Los argumentos pueden llevar su type (tipo, en español) definido o no. En este caso `arg1` debe ser de type `felt` y `arg2` puede ser de cualquier type.
- **Retornar**. Necesariamente tenemos que agregar `return()`. Aunque la función no esté regresando algo. En este caso estamos retornando una variable llamada `returned` por lo que colocamos `return(returned=sum)` donde suma es el valor que tomará la variable `returned`.
- **Comentarios**. En Cairo comentamos con `//`. Este código no será interpretado al correr nuestro programa.

Como con otros lenguajes de programación. Necesitaremos una función `main()` que orqueste el uso de nuestro programa en Cairo. Se define exactamente igual a una función normal solo que con el nombre `main()`. Puede ir antes o después de las demás funciones que creamos en nuestro programa.

## 8. Interactuando con pointers (punteros, en español): parte 1

> Se utiliza un pointer para indicar la dirección del primer felt de un elemento en la memoria. El pointer se puede utilizar para acceder al elemento de manera eficiente. Por ejemplo, una función puede aceptar un puntero como argumento y luego acceder al elemento en la dirección del puntero (documentación de Cairo).
> 

Supongamos que tenemos una variable de nombre `var`:

- `var*` es un pointer a la dirección en memoria del objeto `var`.
- `[var]` es el valor guardado en la dirección `var*`.
- `&var` es la dirección al objeto `var`.
- `&[x]` es `x`. Puedes ver que `x` es una dirección?

## 9. Argumentos ímplicitos

Antes de explicar cómo funcionan los argumentos ímplicitos, una regla: Si una función `foo()` llama a una función con un argumento ímplicito, `foo()` también debe obtener y devolver el mismo argumento ímplicito.

Dicho esto, veamos cómo se ve una función con un argumento ímplicito. La función es serialize_word que se encuentra disponible en la biblioteca `starkware.cairo.common.serialize` y la utilizamos en nuestra función inicial para sumar dos números.

```python
%builtins output

func serialize_word{output_ptr : felt*}(word : felt):
    assert [output_ptr] = word
    let output_ptr = output_ptr + 1
    # The new value of output_ptr is implicitly
    # added in return.
    return ()
end

```

Esto será un poco confuso, prepárate. Intentaré de hacer todo muy claro 🤗. Para que una función reciba argumentos ímplicitos colocamos entre `{}` el argumento. En este y muchos otros casos se recibe `output_ptr` que es un pointer a un type felt. Cuando declaramos que una función recibe un argumento ímplicito, la función automáticamente retornará el valor del argumento ímplicito al terminar la función. Si no movieramos el valor del argumento ímplicito entonces retornaría automáticamente el mismo valor con el que inició. Sin embargo, si durante la función el valor del argumento ímplicito es alterado entonces se retornará automáticamente el nuevo valor.

En el ejemplo con la función `serialize_word` definimos que vamos a recibir un argumento ímplicito llamado `output_ptr`. Además, también recibimos un argumento explícito llamado `value`. Al finalizar la función vamos a retornar el valor que tenga `output_ptr` en ese momento. Durante la función vemos que `output_ptr` aumenta en 1: `let output_ptr = output_ptr + 1`. Entonces la función retornará implícitamente el nuevo valor de `output_ptr`.

Siguiendo la regla definida al comienzo, cualquier función que llame a `serialize_word` tendrá que también recibir el argumento ímplicito `output_ptr`. Por ejemplo, una parte de nuestra función para sumar dos números va así:

```python
func main{output_ptr: felt*}():
    alloc_locals

    const NUM1 = 1
    const NUM2 = 10

    let (sum) = sum_two_nums(num1 = NUM1, num2 = NUM2)
    serialize_word(word=sum)
    return ()
end

```

Vemos que llamamos a `serialize_word` por lo que necesariamente tenemos que también pedir el argumento ímplicito `output_ptr` en nuestra función `main`. Aquí entra en acción otra propiedad de los argumentos ímplicitos, y quizás la razón por la que se llaman así. Vemos que al llamar a `serialize_word` solo pasamos el argumento explícito `word`. El argumento ímplicito `output_ptr` se pasa autómaticamente 🤯! Ojo, también pudimos haber hecho explícito el argumento ímplicito así: `serialize_word{output_ptr=output_ptr}(word=a)`. Ya sabemos programar en Cairo? 🙉

Entonces, el argumento ímplicito es ímplicito porque:

1. Dentro de la función ímplicita, automáticamente se retorna el valor final del argumento ímplicito.
2. Cuando se llama a la función ímplicita, no necesitamos indicar que vamos a ingresar el argumento ímplicito. Automáticamente se incluye el valor ímplicito.

## 10. Locals (locales, en español)

Estamos casi listos para comprender al 100 lo que hicimos en nuestra función que suma dos números. Lo sé, ha sido un camino piedroso 🙉. Pero hay un arcoíris al final del tutorial 🌈.

Así definimos una variable local: `local a = 3`.

> Cualquier función que use una variable local debe tener la declaración alloc_locals, generalmente al comienzo de la función. Esta declaración es responsable de asignar las celdas de memoria utilizadas por las variables locales dentro del scope de la función (documentación de Cairo).
> 

Como ejemplo, mira esta parte de nuestra función que suma dos números:

```python
func sum_two_nums(num1: felt, num2: felt) -> (sum):
    alloc_locals
    local sum = num1+num2
    return(sum)
end

```

Es muy sencillo 💛.

Como no queremos que sea tan fácil, hablemos de memoria. Cairo guarda la variables locales en relación al frame pointer (`fp`) (en un siguiente tutorial entraremos en detalles sobre el `fp`). Por lo que si necesitaramos la dirección de una variable local no bastaría con `&sum` pues nos daría este error: `using the value fp directly requires defining a variable __fp__`. Podemos obtener este valor importando `from starkware.cairo.common.registers import get_fp_and_pc`. `get_fp_and_pc` nos regresa una tupla con los valores actuales de `fp` y `pc`. Al más estilo Python indicaremos que solo nos interesa el valor de `fp` y que lo guardaremos en una variable `__fp__`: `let (__fp__, _) = get_fp_and_pc()`. Listo ahora sí podríamos utilizar `&sum`. En otro tutorial veremos un ejemplo de esto.

## **11. Constants (constantes, en español)**

Muy simples. Solo recuerda que deben dar un entero (un field) cuando compilemos nuestro código. Crea una constant:

```python
const NUM1 = 1

```

## **12. References (referencias, en español)**

Este es el formato para definir una:

```python
let ref_name : ref_type = ref_expr

```

Donde `ref_type` es un type y `ref_expr` es una expresión de Cairo. Colocar la `ref_type` es opcional pero es recomedable hacerlo.

Una referencia se puede reasignar ([documentación](https://www.cairo-lang.org/docs/reference/syntax.html#references) de Cairo):

```python
let a = 7 # a is initially bound to the expression 7.
let a = 8 # a is now bound to the expression 8.

```

En nuestra suma de dos números creamos una referencia llamada `sum`. Vemos que asignamos a `sum` el `felt` que nos retorna la funcion `sum_two_nums`.

```python
let (sum) = sum_two_nums(num1 = NUM1, num2 = NUM2)

```

## 13. Compila y corre 𓀀

¡Ya sabes hacer funciones en Cairo! Ahora corramos nuestro primer programa.

Las herramientas que ofrece StarkNet para interactuar con la línea de comando son muchas 🙉. No entraremos en detalle hasta más adelante. Por ahora, solo mostraremos los comandos con los que podremos correr la aplicación que creamos en este tutorial 🧘‍♀️. Pero no te preocupes, los comandos para correr otras aplicaciones serán muy similares.

`cairo-compile` nos permite compilar nuestro código y exportar un json que leeremos en el siguiente comando. Si el nuestro se llama `src/sum.cairo` (porque se encuentra en el directorio `src` como en este repositorio) y queremos que el json se llame `build/sum.json` (porque se encuentra en el directorio `build` como en este repositorio) entonces usaríamos el siguiente código:

```
cairo-compile src/sum.cairo --output build/sum.json`
```

Sencillo, cierto? ❤️

Ok ahora corramos nuestro programa con `cairo-run`.

```
cairo-run --program=build/sum.json --print_output --layout=small
```

El resultado nos debe imprimir correctamente un 11 en nuestra terminal.

Aquí los detalles:

Indicamos en el argumento --program que queremos correr el build/sum.json que generamos antes.

Con --print_output indicamos que queremos imprimir algo de nuestro programa en la terminal. Por ejemplo, en el siguiente tutorial usaremos el builtin (más adelante los estudiaremos) output y la función serialize_word para imprimir en la terminal.

--layout nos permite indicar el layout a utilizar. Según los builtins que utilicemos, será el layout a utilizar. Más adelante estaremos usando el builtin output y para esto necesitamos el layout small. Abajo una foto de los builtins que cubre el layout small. Si no usaremos ningún builtin entonces podemos dejar este argumento vacío por lo que usaríamos el layout default, el plain.


## **14. Conclusión**

Felicidades 🚀. Hemos aprendido los básicos de 🏖 Cairo. Con este conocimiento podrías identificar lo que se hace en cada línea de nuestra función que sum dos enteros 🥳.

En los siguientes tutoriales aprenderemos más sobre los pointers y el manejo de la memoria; la common library de cairo; cómo funciona el compilador de Cairo; y más!

Cualquier comentario o mejora por favor comentar con [@espejelomar](https://twitter.com/espejelomar) o haz un PR 🌈.
