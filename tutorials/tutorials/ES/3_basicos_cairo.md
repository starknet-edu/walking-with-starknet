# Programando en la L2 de Ethereum (pt. 3): Básicos de Cairo 2

Antes de comenzar, te recomiendo que prepares tu equipo para programar en Cairo ❤️ con el [primer tutorial](1_instalacion.md), y revises los [básicos de Cairo pt. 1](2_basicos_cairo.md).

Únete a la comunidad de habla hispana de StarkNet ([Linktree](https://linktr.ee/starknet_es) con links a telegram, tutoriales, proyectos, etc.). Este es el tercer tutorial de una serie enfocada en el desarrollo de smart cotracts con Cairo y StarkNet. 

🚀 El futuro de Ethereum es hoy y ya está aquí. Y apenas es el comienzo. Aprende un poco más sobre el ecosistema de Starkware en [este texto corto](https://mirror.xyz/espejel.eth/PlDDEHJpp3Y0UhWVvGAnkk4JsBbJ8jr1oopGZFaRilI).

---

En la tercera parte de la serie de tutoriales básicos de Cairo profundizaremos en conceptos introducidos en la [segunda sesión](https://github.com/starknet-edu/walking-with-starknet/blob/master/tutorials/tutorials/ES/2_basicos_cairo.md) como los `builtin`, los `felt` y `assert` y sus variaciones. Además, introduciremos los arrays. Con lo aprendido en esta sesión seremos capaces de crear contratos básicos en Cairo 🚀.

## 1. Los builtin y su relación con los pointers

En el siguiente programa estamos multiplicando dos números. El código entero está disponible en [src/multiplication.cairo](../../../src/multiplication.cairo). Ahí encontrarás el código correctamente comentado.

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

¿Recuerdas que introdujimos los `builtins` en la sesión pasada junto con los argumentos implícitos?

Cada `builtin` te da el derecho a usar un pointer que tendrá el nombre del `builtin` + “`_ptr`”. Por ejemplo, el builtin output, que definimos `%builtins output` al inicio de nuestro contrato, nos da derecho a usar el pointer `output_ptr`. El `builtin` `range_check` nos permite usar el pointer `range_check_ptr`. Estos pointers suelen usarse como argumentos implícitos que se actualizan automáticamente durante una función.

En la función para multiplicar dos números usamos `%builtins output` y, posteriormente, utilizamos su pointer al definir main: `func main{output_ptr: felt*}():`.

## 2. Más sobre lo interesante (raros?) que son los felts

> El felt es el único tipo de datos que existe en Cairo, incluso puedes omitirlo [su declaración explícita] (StarkNet Bootcamp - Amsterdam - min 1:14:36).

Si bien no es necesario ser un@ expert@ en las cualidades matemáticas de los felts, es valioso conocer cómo funcionan. En el tutorial pasado los introdujimos por primera vez, ahora conoceremos cómo afectan cuando comparamos valores en Cairo.

> La definición de un felt, en términos terrestres (la exacta esta aquí): un número entero que puede llegar a ser enorme (pero tiene límites). Por ejemplo: {...,-4,-3,-2,-1,0,+1,+2,+3,...}. Sí, incluye 0 y números negativos.

Cualquier valor que no se encuentre dentro de este rango causará un “overflow”: un error que ocurre cuando un programa recibe un número, valor o variable fuera del alcance de su capacidad para manejar ([Techopedia](https://www.techopedia.com/definition/663/overflow-error#:~:text=In%20computing%2C%20an%20overflow%20error,other%20numerical%20types%20of%20variables.)).

Ahora entendemos los límites de los felt. Si el valor es 0.5, por ejemplo, tenemos un overflow. ¿Dónde experimentaremos overflows frecuentemente? En las divisiones. El siguiente contrato (el código completo está en [src/division1.cairo](../../../src/division1.cairo)) divide 9/3, revisa con `assert` que el resultado sea 3, e imprime el resultado.

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

Hasta ahora todo hace sentido. ¿Pero qué pasa si el resultado de la división no es un entero como en el siguiente contrato (el código está en [src/division2.cairo](../../../src/division2.cairo))?

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

Para empezar, nos imprime en consola el hermoso número 🌈: `1206167596222043737899107594365023368541035738443865566657697352045290673497`. ¿Qué es esto y por qué nos lo retorna en vez de un apreciable punto decimal?

En la función arriba `x` **no** es un `floating point`, 3.33, **ni** es un entero redondeado con el resultado, 3. Es un entero que multiplicado por 3 nos dará 10 de vuelta (se ve como esta función `3 * x = 10`) o también `x` puede ser un denominador que nos devuelva 3 (`10 / x = 3`). Veamos esto con el siguiente contrato:

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

Al compilar y correr este contrato obtenemos exactamente lo que buscabamos:

```python
Program output:
  10
  3

```

Cairo logra esto al volver al realizar un overflowing de nuevo. No entremos en detalles matemáticos. Esto es algo poco intuitivo pero no te preocupes, hasta aquí lo podemos dejar.

> Una vez que estás escribiendo contratos con Cairo no necesitas estar pensando constantemente en esto [las particularidades de los felts cuando están en divisiones]. Pero es bueno estar consciente de cómo funcionan (StarkNet Bootcamp - Amsterdam - min 1:31:00).
> 

## **3. Comparando felts 💪**

Debido a las particularidades de los felts, comparar entre felts no es como en otros lenguajes de programación (como con `1 < 2`).

En la librería `starkware.cairo.common.math` encontramos funciones que nos servirán para comparar felts ([link a repositorio en GitHub](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/math.cairo)). Por ahora usaremos `assert_not_zero`, `assert_not_equal`, `assert_nn` y `assert_le`. Hay más funciones para comparar felts en esta librería, te recomiendo que veas el repositorio de GitHub para explorarlas. El [siguiente código del Bootcamp de StarkNet en Amsterdam](https://github.com/lightshiftdev/starknet-bootcamp/blob/main/packages/contracts/samples/04-cairo-math.cairo) sirve para entender lo que hace cada una de las funciones que importamos (lo alteré ligeramente). El código completo está en [src/asserts.cairo](../../../src/asserts.cairo).

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

¿Sencillo, cierto? Solo son formas diferentes de hacer asserts.

¿Pero qué pasa si queremos comparar `10/3 < 10`? Sabemos que esto es cierto, pero también sabemos que el resultado de la división `10/3` no es un entero por lo que cae fuera del rango de posibles valores que pueden tomar los felts. Habrá overflow y se generará un valor que resultará estar fuera de los enteros posibles que un felt puede tomar (por lo grande que es).

n efecto la siguiente función que compara `10/3 < 10` nos retornará un error: `AssertionError: a = 2412335192444087475798215188730046737082071476887731133315394704090581346994 is out of range.`

```python
%builtins range_check

from starkware.cairo.common.math import assert_lt

func main{range_check_ptr : felt}(){
    assert_lt(10/3, 10); // less than

    return ();
}

```

¿Cómo hacemos entonces para comparar `10/3 < 10`? Tenemos que volver a nuestras clases de secundaria/colegio. Simplemente eliminemos el 3 del denominador al multiplicar todo por 3; compararíamos `3*10/3 < 3*10` que es lo mismo que `10 < 30`. Así solo estamos comparando enteros y nos olvidamos de lo exéntricos que son los felt. La siguiente función corre sin problema.

```python
%builtins range_check

from starkware.cairo.common.math import assert_lt

func main{range_check_ptr : felt}(){
    assert_lt(3*10/3, 3*10);

    return ();
}

```

## 4. La doble naturaleza de assert

Como hemos visto, `assert` es clave para la programación en Cairo. En los ejemplos arriba lo utilizamos para confirmar una declaración, `assert y = 10`. Este es un uso común en otros lenguajes de programación como Python. Pero en Cairo cuando tratas de `assert` algo que no está asignado aún, `assert` funciona para asignar. Mira esté ejemplo adaptado del [Bootcamp de StarkNet en Amsterdam](https://github.com/lightshiftdev/starknet-bootcamp/blob/main/packages/contracts/samples/04-cairo-math.cairo) que también nos sirve para afianzar lo aprendido sobre las structs en el [tutorial pasado](2_basicos_cairo.md). El código completo está en [src/vector.cairo](../../../src/vector.cairo). 

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

Al correr `assert res.x = v1.x + v2.x`, el prover (más sobre esto más adelante) de Cairo detecta que `res.x` no existe por lo que le asigna el nuevo valor `v1.x + v2.x`. Si volvieramos a correr `assert res.x = v1.x + v2.x`, el prover sí compararía lo que encuentra asignado en `res.x` con lo que intentamos asignar. Es decir, el uso que ya conocíamos.

## 5. Arrays en Cairo

Cerremos este tutorial con una de las estructura de datos más importantes. Los arrays, arreglos en español, contienen elementos ordenados. Son muy comunes en programación. ¿Cómo funcionan en Cairo? Aprendamos **creando un array de matrices 🙉**. Sí, el escrito tiene un background en machine learning. El contrato abajo está comentado (se encuentra en [src/matrix.cairo](../../../src/matrix.cairo)) y examinaremos unicamente la parte de los arrays pues el lector ya conoce el resto.

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

    // Assigning values ​​to three elements of my_array.  
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

    // We use assert to test some values ​​in
    // our matrix_array.
    assert matrix_array[0].x.elements[0] = 1;
    assert matrix_array[1].x.elements[1] = 2;

    // What value do you think it will print? Answer: 3
    serialize_word(matrix_array[1].x.elements[2]);

    return();
}
```

Creamos un array de felts llamado `my_array`. Esta es la forma en que se define:

```
let (my_array : felt*) = alloc();
```

Es poco intuitivo en comparación con lo fácil que es en Python y otros lenguajes. `my_array : felt*` define una variable llamada `my_array` que contendrá un pointer (ver [tutorial pasado](2_basicos_cairo.md)) a un felt (aún no definimos a qué felt). ¿Por qué? La documentación de Cairo nos ayuda:

> “Los arrays se pueden definir como un pointer (felt*) al primer elemento del array. A medida que se llena el array, los elementos ocupan celdas de memoria contiguas. La función alloc() se usa para definir un segmento de memoria que expande su tamaño cada vez que se escribe un nuevo elemento en el array (documentación de Cairo)”.
> 

Entonces, en el caso de `my_array`, al colocar el `alloc()` estamos indicando que el segmento de memoria al que la expresión `my_array` apunta (recuerda que `my_array` es solo el nombre de un pointer, `felt*`, en memoria) será expandido cada vez que se escriba un nuevo elemento en `my_array`.

De hecho, si pasamos [al repo](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/alloc.cairo) donde se encuentra `alloc()` veremos que retorna `(ptr : felt*)`. Es decir, nos regresa una tupla de un solo miembro que es un `felt*` (un pointer a un `felt`). Por ser una tupla la recibimos con un `let` y con `my_array : felt*` entre paréntesis (ver [básicos de Cairo pt. 2](2_basicos_cairo.md)). Todo va haciendo sentido, ¿cierto 🙏?

Vemos que la definición de nuestro array de matrices es exactamente igual salvo que en vez de querer un array de `felt` queremos uno de `Matrix`:

```python
let (matrix_array : Matrix*) = alloc();
```

Ya pasamos lo complicado 😴. Ahora veamos cómo rellenar nuestro array con estructuras `Matrix`. Usamos `assert` y podemos indexar con `[]` la posición del array que queremos alterar o revisar:

```
assert matrix_array[0] = Matrix(x = v1, y = v2);
```

Lo que hicimos fue crear una `Matrix(x = v1, y = v2)` y asignarla a la posición 0 de nuestra `matrix_array`. Recuerda que empezamos a contar desde 0. Rellenar nuestro array de `felt` es aún más trivial: `assert my_array[0] = 1`.

Después simplemente llamamos de diferentes maneras a elementos dentro de `matrix_array`. Por ejemplo, con `matrix_array[1].x.elements[2]` indicamos estos pasos:

1. Llama al segundo, `[1]`, elemento de `matrix_array`. Es decir, a `Matrix(x = v1, y = v2)`.
2. Llama al `member` `x` de `Matrix`. Es decir, a `v1 = Vector(elements = my_array)`.
3. Llama al `member` `elements` de `v1`. Es decir, a `my_array`.
4. Llama al tercer, `[2]`, elemento de `my_array`. Es decir, a `3`.

No es tan complicado pero es lo suficientemente satisfactorio 🤭.

## **6. Conclusión**

Felicidades 🚀. Hemos profundizado en los básicos de 🏖 Cairo. Con este conocimiento puedes comenzar a hacer contratos sencillos en Cairo 🥳.

En los siguientes tutoriales aprenderemos más sobre los el manejo de la memoria; la common library de cairo; cómo funciona el compilador de Cairo; y más!

Cualquier comentario o mejora por favor comentar con [@espejelomar](https://twitter.com/espejelomar) o haz un PR 🌈.
