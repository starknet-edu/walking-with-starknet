# Programando en la L2 de Ethereum (pt. 5): Creando smart contracts en StarkNet

Este tutorial es clave para que comiences a crear y desplegar tus propios contratos inteligentes. Ese es el objetivo aquí.

Antes de comenzar, te recomiendo que prepares tu equipo para programar en Cairo ❤️ con el [primer tutorial](1_instalacion.md), revises los [básicos de Cairo pt. 1](2_basicos_cairo.md) y [pt. 2](3_basicos_cairo.md), y uses [Protostar para compilar y desplegar contratos](4_protostar.md).

Únete a la comunidad de habla hispana de StarkNet ([Linktree](https://linktr.ee/starknet_es) con links a telegram, tutoriales, proyectos, etc.). Este es el cuarto tutorial en una serie enfocada en el desarrollo de smart cotracts con Cairo y StarkNet. Recomiendo que hagas los tutoriales pasados antes de pasar a este.

🚀 El futuro de Ethereum es hoy y ya está aquí. Y apenas es el comienzo. Aprende un poco más sobre el ecosistema de Starkware en [este texto corto](https://mirror.xyz/espejel.eth/PlDDEHJpp3Y0UhWVvGAnkk4JsBbJ8jr1oopGZFaRilI).

---

Crearemos una aplicación que permite a usuarios votar. El concepto original fue propuesto por [SWMansion](https://github.com/software-mansion-labs/protostar-tutorial) y se modificó ampliamente para este tutorial. Por fines didácticos, vamos a mostrar el código del contrato en partes; el contrato completo se encuentra en [este repositorio](../../../src/voting.cairo). Puedes ver e interactuar con el [contrato desplegado en Voyager](https://goerli.voyager.online/contract/0x01ab2d43fd8fe66f656aafb740f6a368cecb332b5e4e9bbc1983680a17971711). Al final de este tutorial tendrás tu propio contrato desplegado.



## 1. Estructura de un proyecto en StarkNet

Inicializa tu proyecto con `protostar init` y recuerda hacer primero el [tutorial sobre cómo usar Protostar](4_protostar.md).

Vamos a comenzar a crear código estándar de Cairo. Es decir, siguiendo las convenciones de programación de smart contracts en Cairo. Aún es muy nuevo todo pero las convenciones han adoptado un estilo similar al de Solidity. Por ejemplo, escribiremos nuestro contrato entero en un archivo llamado `voting.cairo`. Por lo tanto la ruta para nuestro contrato es [`src/voting.cairo`](../../../src/voting.cairo).

Dentro de nuestro contrato seguiremos la siguiente estructura, inspirada por Solidity y sugerida por [0xHyoga](https://hackmd.io/@0xHyoga/Skj7GGeyj), para los elementos del contrato:

1. Structs
2. Events
3. Storage variables
4. Constructor
5. Storage Getters
6. Constant functions: funciones que no cambian el estado
7. Non-Constant functions: funciones que cambian el estado

Aún no conocemos qué son estos elementos pero no te preocupes que aprenderemos sobre todos ellos en este y los siguientes tutoriales. Si tienes un background en creación de contratos verás las similitudes con Solidity. Por el momento, nos basta saber que seguiremos este orden en nuestro contrato.

## 2. ¡Vamos a votar!

Comencemos con el siguiente código (recuerda que el contrato completo está en [este repositorio](../../../src/voting.cairo).). Creamos dos `struct`. El primero, `VoteCounting`, va a llevar el conteo de votos: el número de votos con “sí” y el número de votos con “no”. El segundo, `VoterInfo`, indica si un votante tiene permitido votar. Luego crearemos storage variables (más adelante las veremos). 

- `voting_status`, lleva y actualiza el conteo de los votos. 
- `voter_info`, indica y actualiza la información de un votante (puede o no votar).
- `registered_voter`, indica si una address tiene permitido votar.

```
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero

from openzeppelin.access.ownable.library import Ownable
from openzeppelin.security.pausable.library import Pausable

// ------
// Structs
// ------

// struct that carries the status of the vote
struct VoteCounting{
    votes_yes : felt,
    votes_no : felt,
}

// struct indicating whether a voter is allowed to vote
struct VoterInfo{
    allowed : felt,
}

// ------
// Storage
// ------

// storage variable that takes no arguments and returns the current status of the vote
@storage_var
func voting_status() -> (res : VoteCounting){
}
 
// storage variable that receives an address and returns the information of that voter
@storage_var
func voter_info(user_address: felt) -> (res : VoterInfo){
}

// storage variable that receives an address and returns if an address is registered as a voter
@storage_var
func registered_voter(address: felt) -> (is_registered: felt) {
}
```

Vamos paso por paso notando las diferencias con los programas en Cairo que hemos creado antes.

Tenemos que declarar que queremos desplegar nuestro contrato en StarkNet. Al principio del contrato escribe `%lang starknet`. A diferencia de los contratos de Cairo que no son desplegados en StarkNet, no tenemos que mencionar los `builtins` al comienzo del contrato.

Aprenderemos sobre varias primitivas (marcadas con un `@`, como decoradores de Python) de StarkNet que no existen en Cairo puro. La primera es `@storage_var`.

## 3. Contract storage

¿Qué es el espacio de almenamiento de un contrato (contract storage)? Veamos la documentación:

> “El espacio de almacenamiento del contrato (contract storage) es un espacio de almacenamiento persistente donde se puede leer, escribir, modificar y conservar datos. El almacenamiento es un mapa con 2^{251} ranuras (slots), donde cada ranura es un felt que se inicializa en 0.” - Documentación de StarkNet.
> 

Para interactuar con el contract’s storage creamos variables de almacenamiento (storage variables). Podemos pensar de las storage variables como pares de key y values. Piensa el concepto de un diccionario en Python, por ejemplo. Estamos mapeando un key con, posiblemente varios, values.

La forma más común de interactuar con el contract’s storage y de crear storage variables es con el decorador (sí, igual que en Python) `@storage_var`. Automáticamente se crean los métodos (funciones) `.read(key)`, `.write(key, value)` y `.addr(key)` para la storage variable. Hagamos un ejemplo donde no tenemos una key pero sí un value (`res`), arriba creamos la storage variable `voting_status`:

```
@storage_var
func voting_status() -> (res : VoteCounting){
}
```

Podemos entonces obtener el value almacenado en `voting_status()`, un struct `VoteCounting`, con `let (status) = voting_status.read()`.  Nota que no tenemos que indicar ningún argumento en el read pues `voting_status()` no lo exige. También nota que `.read()` retorna una tupla por lo que que tenemos recibirla con un `let (variable_name) = …` (esto lo vimos en un tutorial anterior). Es lo mismo con  `voting_status.addr()` que nos regresa la dirección en el storage de la storage variable `voting_status`. No indicamos ningún argumento porque no es exigido.

Para escribir un nuevo estado en nuestra storage variable usamos `voting_status.write(new_voting_count)`, donde `new_voting_count` es un struct de tipo `VoteCounting`. Lo que hicimos fue almacenar el nuevo struct dentro de la storage variable.

Veamos una storage variable que tiene una key (`user_address`) y una value (`res`).

```
@storage_var
func voter_info(user_address: felt) -> (res : VoterInfo){
}
```

Con `let (caller_address) = get_caller_address()` y antes `from starkware.starknet.common.syscalls import get_caller_address`, podemos obtener la address de la cuenta que está interactuando con nuestro contrato. Pedimos información del caller: `let (caller_info) = voter_info.read(caller_address)`. Si no colocaramos la dirección del caller habríamos obtenido un error porque `voter_info(user_address: felt)` nos exige una key en formato felt, en este caso una dirección de contrato. Nota la diferencia con `voting_status()` que no requería key.

Podemos escribir con `voter_info.write(caller_address, new_voter_info)`, donde `new_voter_info` es un struct de tipo `VoterInfo`. Aquí indicamos que para la dirección `caller_address` tenemos un nuevo `VoterInfo` llamado `new_voter_info`. Podemos hacer lo mismo con una siguiente dirección. Con `voter_info.addr(caller_address)` obtenemos la dirección donde se almacena el primer elemento del value, en este caso `VoterInfo`.

También podemos usar las funciones `storage_read(key)` y `storage_write(key, value)` (importadas con `from starkware.starknet.common.syscalls import storage_read, storage_write`) para leer el/los value de una key y escribir un/unos value en una key, respectivamente. De hecho nuestro, decorador `@storage_value` usa por debajo estas funciones.

## 4. Los tres argumentos implícitos más usados

Pasemos al siguiente fragmento de código de nuestro contrato para votar (el código comentado lo encuentras en el [repositorio del tutorial](../../../src/voting.cairo)). En esta sección hablaremos de tres de los argumentos implícitos más frecuentes que encontrarás en contratos de StarkNet. Los tres son muy usados porque son requeridos por las storage variables para escribir y leer del especio de almacenamiento del contrato.

Creamos la función interna `_register_voters` (por default todas las funciones en StarkNet son privadas, a diferencia de Solidity). Con ella prepararemos nuestra lista de votantes. Asumimos que tenemos una lista de las addresses que tienen permitido votar. `_register_voters` usa la storage variable `voter_info` para asignar a cada address el estado de su votación: si tiene permitido votar.

```
ffunc _register_voters{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
    }(registered_addresses_len: felt, registered_addresses : felt*){
    
    // No more voters, recursion ends
    if (registered_addresses_len == 0){
        return ();
    }
    
    // Assign the voter at address 'registered_addresses[registered_addresses_len - 1]' a VoterInfo struct
    // indicating that they have not yet voted and can do so
    let votante_info = VoterInfo(
        allowed=1,
    );
    registered_voter.write(registered_addresses[registered_addresses_len - 1], 1);
    voter_info.write(registered_addresses[registered_addresses_len - 1], votante_info);
    
    // Go to next voter, we use recursion
    return _register_voters(registered_addresses_len - 1, registered_addresses);
}
```

Notamos es el uso de tres argumentos implícitos que no habíamos visto antes: `syscall_ptr : felt*`, `pedersen_ptr : HashBuiltin*`, y `range_check_ptr`. Los tres son pointers; nota que acaban su nombre con un `_ptr`.

`syscall_ptr` es usado cuando hacemos llamados al sistema. Lo incluimos en `_register_voters` porque `write` y `read` necesitan este argumento implícito. Al leer y escribir estamos consultando directamente el contract’s storage y en StarkNet esto se logra haciando llamadas al sistema. Es un pointer hacía un valor felt, `felt*`.

`range_check_ptr` permite que se comparen números enteros. En un tutorial siguiente examinaremos más a fondo pointers y funciones builtin clave en el desarrollo en StarkNet. Por ahora nos basta saber que los argumentos `write` y `read` de las storage variables necesitan comparar números; por lo tanto, necesitamos indicar el argumento implícito`range_check_ptr` en cualquier función que lea y escriba en el contract’s storage usando storage variables.

Es un buen momento para introducir los hashes:

> “Un hash es una función matemática que convierte una entrada de longitud arbitraria en una salida cifrada de longitud fija. Por lo tanto, independientemente de la cantidad original de datos o el tamaño del archivo involucrado, su hash único siempre tendrá el mismo tamaño. Además, los hash no se pueden usar para "hacer ingeniería inversa" de la entrada de la salida hash, ya que las funciones de hash son "unidireccionales" (como una picadora de carne; no se puede volver a poner la carne molida en un bistec).” - Investopedia.
> 

Junto con StarkNet Keccak (los primeros 250 bits del hash Keccak256), la Pedersen hash function es una de las dos funciones de hash que se usan en StarkNet. `pedersen_ptr` es usado cuando corremos una Pedersen hash function. Colocamos este pointer en `_register_voters` porque las storage variables realizan un hash Pedersen para calcular su dirección de memoria.

El argumento implícito `pedersen_ptr` es un pointer hacía una struct HashBuiltin definida en la [common library de Cairo](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/cairo_builtins.cairo):

```
struct HashBuiltin {
    x: felt,
    y: felt,
    result: felt,
}
```

¡Vamos excelente!

## 5. Manejando errores en Cairo

Dentro de una función podemos marcar un error en el contrato si una condición es falsa. Por ejemplo, en el siguiente código el error se activaría porque `assert_nn(amount)` es falso (`assert_nn` revisa si un valor es non-negative). Si `amount` fuera 10 entonces `assert_nn(amount)` sería verdadero y el error no se activaría.

```
let amount = -10

with_attr error_message(
            "Quantity should be positive. You have: {amount}."):
        assert_nn(amount)
    end
```

Crearemos una función, `_assert_allowed`, que revisará si un determinado votante tiene permitido votar y si no es así nos retornará un error.

```
from starkware.cairo.common.math import assert_not_zero

...

func _assert_allowed{
    syscall_ptr : felt*,
    //pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(info : VoterInfo){

    with_attr error_message("VoterInfo: Your address is not allowed to vote."){
        assert_not_zero(info.allowed);
    }

    return ();
}
```

Importamos `assert_not_zero`. El error regresará un mensaje si `assert_not_zero(info.allowed)` es falso. Recuerda que si un votante tiene permitido votar entonces `info.allowed` será 1.

## 6. Funciones external y view

Pasemos a la función principal de nuestra aplicación. Escribimos una función que recibe como argumento explícito un voto (1 o 0) y luego actualiza el conteo de votos total y el estado del votante de forma que no pueda votar de nuevo.

```
%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address

...

@external
func vote{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(vote : felt) -> (){
    alloc_locals;
    Pausable.assert_not_paused();

    // Know if a voter has already voted and continue if they have not voted
    let (caller) = get_caller_address();
    let (info) = voter_info.read(caller);
    _assert_allowed(info);

    // Mark that the voter has already voted and update in the storage
    let info_actualizada = VoterInfo(
        allowed=0,
    );
    voter_info.write(caller, info_actualizada);

    // Update the vote count with the new vote
    let (status) = voting_status.read();
    local updated_voting_status : VoteCounting;
    if (vote == 0){
        assert updated_voting_status.votes_no = status.votes_no + 1;
        assert updated_voting_status.votes_yes = status.votes_yes;
    }
    if (vote == 1){
        assert updated_voting_status.votes_no = status.votes_no;
        assert updated_voting_status.votes_yes = status.votes_yes + 1;
    }
    voting_status.write(updated_voting_status);
    return ();
}
```

En la biblioteca `common.syscalls` ([link a repo](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/starknet/common/syscalls.cairo)) encontramos funciones útiles para interactuar con el sistema. Por ejemplo, arriba usamos `get_caller_address` para obtener la address del contrato que está interactuando con el nuestro. Otras funciones interesantes son `get_block_number` (para obtener el número del bloque) o `get_contract_address` para obtener la address de nuestro contrato. Más adelante utilizaremos más funciones de esta biblioteca.

Lo siguiente nuevo es el decorator `@external` utilizado sobre la función `votar`. Nota que no hemos creado ninguna función `main` como hacíamos con Cairo solo. ¡Es porque StarkNet no usa la función `main`! Aquí usamos funciones `external` y `view` para interactuar con los contratos.

**Funciones external**. Usando el decorator `@external` definimos a una función como external. Otros contratos (incluidas accounts) pueden interactuar con las funciones externals; leer y escribir. Por ejemplo, nuestra función `votar` puede ser llamada por otros contratos para emitir un voto de 1 o 0; luego `vote` va a escribir sobre el storage del contrato. Por ejemplo, con `voter_info.write(caller, info_actualizada)` estamos escribiendo en la storage variable `voter_info`. Es decir, estamos modificando el estado del contrato. Aquí está la diferencia clave con las funciones `view`(las veremos más adelante), en el poder de escribir; modificar el estado del contrato.

## 7. Funciones getter

Escribamos funciones que permitan a otros contratos (incluidos accounts) revisar el estado de la votación actual. A estas funciones que permiten revisar el state se les llama `getters`. Primero, creamos un una getter, `get_voting_status`, que retorna el estado actual de la votación, es decir, regresa un struct `VoteCounting` con el conteo total de los votos. Después, creamos la getter `get_voter_status` que nos regresa el estado de una address (votante) en particular (si ya votó o no). Revisa el [contrato final](../../../src/voting.cairo) para ver otras funciones getter añadidas.

```
%lang starknet
from starkware.cairo.common.cairo_builtins import HashBuiltin

...
 
@view
func get_voting_status{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}() -> (status: VoteCounting){
    let (status) = voting_status.read();
    return (status = status);
}


@view
func get_voter_status{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(user_address: felt) -> (status: VoterInfo){
    let (status) = voter_info.read(user_address);
    return(status = status);
}
```

**Funciones view.** Usando el decorator `@view` definimos a una función como view. Otros contratos (incluidas accounts) pueden leer del estado del contrato; no pueden modificarlo (nota que las external sí pueden modificarlo). !Leer del storage no cuesta gas!

Nota que en Solidity el compilador crea getters para todas las variables de estado declaradas como public, en Cairo todas las storage variables son privadas. Por lo tanto, si queremos hacer públicas las storage variables, debemos hacer una funciones getter nosotros mismos.

## 8. Constructors

Los funciones constructor son utilizadas para inicializar una aplicación de StarkNet. Las definimos con el decorator `@constructor`. Recibe los inputs que necesita nuestro contrato para ser desplegado y realiza las operaciones necesarias para comenzar a operar con el contrato. Como ejemplo, nuestro contrato necesita tener un administrador de la votación y una lista de las addresses que pueden votar (no todos pueden votar para elegir a una presidente). Todo el mecanismo de nuestra aplicación está listo, solo falta que se le den las entradas que requiere para iniciar a funcionar.

Ojo, Cairo solo admite **1 constructor por contrato**.

```
from openzeppelin.access.ownable.library import Ownable

...

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    admin_address: felt, registered_addresses_len: felt, registered_addresses: felt*
) {
    alloc_locals;
    Ownable.initializer(admin_address);
    _register_voters(registered_addresses_len, registered_addresses);
    return ();
}
```

En el constructor estamos indicando que requerimos 3 inputs para inicializar el contrato: 

* `admin_address: felt` - La address del contrato administrador de la votación. Este contrato podrá, por ejemplo, pausar la votación en caso de ser necesario. Puedes agregarla en formato hex o felt (e acabará convirtiendo de todas formas a felt).
* `registered_addresses_len: felt` - Este valor es la longitud del array de addresses que pueden votar. Por ejemplo, si 10 addresses pueden participar en la votación entonce será 10.
* `registered_addresses: felt*` - Un array con las addresses que pueden votar. Los arrays se ingresan una tras otra sin coma, por ejemplo, `0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510 0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8512`.

¡Podemos ya probar nuestro contrato! En tu terminal corre:

```
protostar deploy ./build/vote.json --network testnet --inputs <admin_address> <registered_addresses_len> <registered_addresses>
```

O ya en la realidad:

```
protostar deploy ./build/vote.json --network testnet --inputs 111 2 222 333
```

Coloca tu address como admin del contrato e invita a tu DAO a votar on-chain con costos realmente bajos.

## 9. Conclusión

Felicidades. Ya sabes cómo crear contratos inteligentes en StarkNet. En este punto ya puedes asistir a cualquier hackathon y crear tus propios programas sobre la L2.

¡Apenas estamos comenzando!

