


Vamos

1. Qué es OZ.
2. Desplegar un contrato ERC721 usando Open Zeppelin.
3. Qué es una interfaz.
4. Llamar el contrato desde otro contrato.
## Llamando un contrato desde otro contrato

For this let us deploy an ERC721 contract. We will save the address here.

## Iniciando con Open Zeppelin (OZ)
En pocas palabras, es una librería (framework) open-source para desarrollar smart contracts seguros. OZ marca el estándar de diversos tipos de contrato como los ERC20 o los ERC721. Son famosos por sus [contratos para Solidity](https://github.com/OpenZeppelin/openzeppelin-contracts). 

OZ ha estado trabajando en crear estándares, similares a los de Solidity y la L1, para Cairo. El repositorio [OpenZeppelin/cairo-contracts](https://github.com/OpenZeppelin/cairo-contracts) contiene contratos reusables para nuestros contratos en Cairo. 

Una vez iniciado tu espacio para trabajar con Cairo y StarkNet (ver tutorial sobre [instalación y creación del ambiente virtual](./1_instalacion.md)) puedes instalar `cairo-contracts` con: 

```
pip install openzeppelin-cairo-contracts
```

También lo puedes hacer desde Protostar con 

```
protostar install https://github.com/OpenZeppelin/cairo-contracts
```

Si inicializamos el proyecto con Prototostar, la biblioteca `cairo_contracts` está dentro de `lib` (nota que `src/main.cairo` y `tests/test_main.cairo` son crados como ejemplos por Protostar, los podemos eliminar):

```
❯ tree -L 2
.
├── lib
│   └── cairo_contracts
├── protostar.toml
├── src
│   └── main.cairo
└── tests
    └── test_main.cairo
```

Agreguemos en el `protostar.toml`, sección `["protostar.contracts"]`, el contrato a compilar.

```
["protostar.contracts"]
ERC721_original = [
    "lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo",
]
```

Con Protostar, al importar código de los contratos de OZ (por ejemplo, `from openzeppelin.token.erc721.library import ERC721`), necesitamos indicar dónde el compilador puede encontrar este código. Para ello al compilar con `protostar build` podemos indicar el `cairo-path` de esta manera (asumiendo que tengas el directorio `lib` creado y `cairo-contracts` instalado en él):

```
protostar build --cairo-path ./lib/cairo_contracts/src
```

Nos podemos ahorrar este paso cada vez que compilemos si colocamos en `protostar.toml` el path dentro de `["protostar.shared_command_configs"]` (para más detalles sobre cómo funciona Protostar y cómo usarlo revisa [este tutorial](4_protostar.md)).

```
["protostar.shared_command_configs"]
cairo-path = ["lib/cairo_contracts/src"]
```

## Desplegando un contrato

Desplegaremos un contrato para crear un ERC721 (non-fungible token).Puedes hacer este mismo ejercicio para desplegar un ERC20 (fungible token). Notar que los estándares de OZ van más allá de la creación de tokens solamente; por ejemplo, también trabajan con [accounts](https://docs.openzeppelin.com/contracts-cairo/0.4.0b/accounts).    

Los estándares de OZ buscan que los contratos de Cairo sean lo más similares posibles a sus implementaciones para EVM. Por ejemplo, no suelen utilizar felts y prefieren el struct `Uint265` definido en la [biblioteca common.uint256](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/uint256.cairo) de starkware (from starkware.cairo.common.uint256 import Uint256):

```
// Represents an integer in the range [0, 2^256).
struct Uint256 {
    // The low 128 bits of the value.
    low: felt,
    // The high 128 bits of the value.
    high: felt,
}
```
`common.uint256` también contiene funciones para realizar operaciones entre `Uint265`s. Por ejemplo, puedes sumarlos con `func uint256_add{range_check_ptr}(a: Uint256, b: Uint256) -> (res: Uint256, carry: felt)` o multiplicarlos con `func uint256_mul{range_check_ptr}(a: Uint256, b: Uint256) -> (low: Uint256, high: Uint256)`. Estas operaciones serán utilizadas en los contratos de OZ.

Compilamos con:

```
protostar build
```
Protostar guarda en `build` el código compilado:

```
❯ tree -L 2
.
├── build
│   ├── ERC721_original.json
│   └── ERC721_original_abi.json
├── lib
│   └── cairo_contracts
├── protostar.toml
├── src
│   └── main.cairo
├── tests
│   ├── test_deploy_ERC721.cairo
│   └── test_main.cairo
└--
```

Antes de desplegar (deploy) notamos que el constructor nos pide que agreguemos tres argumentos en la inicialización del contrato: `name: felt, symbol: felt, owner: felt`. Como no existen las `Strings` hasta el momento en Cairo (en próximas versiones sí existirán), tendemos que convertir el nombre y el símbolo de `String` a `felt`. Y también nos pide `owner` que originalmente es una address en valores hexadecimales que también convertiremos a `felt`.

Es común crear una biblioteca `src/utils.py` con funciones que nos ayuden a convertir de y hacía `felt`s:

```py
MAX_LEN_FELT = 31
 
def str_to_felt(text):
    if len(text) > MAX_LEN_FELT:
        raise Exception("Text length too long to convert to felt.")
    return int.from_bytes(text.encode(), "big")
 
def felt_to_str(felt):
    length = (felt.bit_length() + 7) // 8
    return felt.to_bytes(length, byteorder="big").decode("utf-8")
 
def str_to_felt_array(text):
    return [str_to_felt(text[i:i+MAX_LEN_FELT]) for i in range(0, len(text), MAX_LEN_FELT)]
 
def uint256_to_int(uint256):
    return uint256[0] + uint256[1]*2**128
 
def uint256(val):
    return (val & 2**128-1, (val & (2**256-2**128)) >> 128)
 
def hex_to_felt(val):
    return int(val, 16)
```

Desde la terminal podemos entrar a la consaola de Python y llamar las funciones que necesitamos:

```py
❯ python3 -i src/utils.py
>>> str_to_felt("New cute token")
1590066861370246896902429777552750
>>> str_to_felt("NCT")
5129044
>>> hex_to_felt("0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510")
1268012686959018685956609106358567178896598707960497706446056576062850827536
>>> exit()
```

Desplequegemos desde la terminal:

```
protostar deploy build/ERC721_original.json --inputs 1590066861370246896902429777552750 5129044 1268012686959018685956609106358567178896598707960497706446056576062850827536 --network testnet
```
```
17:28:41 [INFO] Deploy transaction was sent.                                                              
Contract address: 0x0175497da2abdd3e656b4d48ceda01b3381453f3a1308f7edd223dc25d742021
Transaction hash: 0x04ac0557213e5b58eef637576dc9312a59379c281cbdbc5577a6a78d6c8c351c

https://goerli.voyager.online/contract/0x0175497da2abdd3e656b4d48ceda01b3381453f3a1308f7edd223dc25d742021
17:28:41 [INFO] Execution time: 8.37 s
```

Podríamos desplegar el mismo contrato con el CLI de StarkNet usando:

```
starknet deploy --contract build/ERC721_original.json --inputs 1590066861370246896902429777552750 5129044 1268012686959018685956609106358567178896598707960497706446056576062850827536 --network alpha-goerli --no_wallet
```

Al entrar a [Voyager](https://goerli.voyager.online/contract/0x0175497da2abdd3e656b4d48ceda01b3381453f3a1308f7edd223dc25d742021) podemos interactuar con el contrato ERC721 desplegado. Podemos, por ejemplo, comprobar que el nombre es correcto al llamar la función view (getter) `name`. Al trabajar con la testnet puede tardar aproximadamente 5 minutos en aparecer.

[PONER IMAGEN GUARDAD XXX]

Ahora despleguemos desde un test en Protostar. Cremos el archivo `tests/test_ERC721_original.cairo` (el código comentado se encuentra en XXX):

```
%lang starknet

@contract_interface
namespace ERC721Original {
    func name() -> (name: felt) {
    }

    func symbol() -> (symbol: felt) {
    }

    func owner() -> (owner: felt) {
    }
}

@external
func test_ERC721Original{syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;

    local erc721_original_address: felt;

    %{  
        name = 1590066861370246896902429777552750
        symbol = 5129044
        owner = 1268012686959018685956609106358567178896598707960497706446056576062850827536

        declared = declare("lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo")
        prepared = prepare(declared, [name, symbol, owner])
        contract = deploy(prepared)
        ids.erc721_original_address = contract.contract_address

        print(f"ERC721Original contract address (felt): {ids.erc721_original_address}")
    %}

    let (name) = ERC721Original.name(contract_address=erc721_original_address);
    let (symbol) = ERC721Original.symbol(contract_address=erc721_original_address);
    let (owner) = ERC721Original.owner(contract_address=erc721_original_address);
    
    assert 1590066861370246896902429777552750 = name;
    assert 5129044 = symbol;
    assert 1268012686959018685956609106358567178896598707960497706446056576062850827536 = owner;

    return ();
}
```

¿Qué hicimos de nuevo? Dos cosas: 
1. Definir una interfaz para llamar funciones del contrato ERC721 original. 
2. Crear un test en Cairo que nos permite desplegar el ERC721 original y probarlo.

Vamos a explorar ambos puntos.

## Interfaces

Veamos dos excelentes definiciones:

> "Las interfaces son un bloque de construcción estándar y una característica de muchos lenguajes de programación. Su objetivo es separar la definición de funcionalidad (una función) del comportamiento real de la funcionalidad en sí." - [CoinMonks](https://medium.com/coinmonks/solidity-tutorial-all-about-interfaces-f547d2869499).

> "Las interfaces a menudo se encuentran en la parte superior de un contrato inteligente. Se identifican mediante la palabra clave "interfaz". La interfaz contiene firmas de funciones sin la implementación de la definición de función (los detalles de implementación son menos importantes). Puede usar una interfaz en su contrato para llamar funciones en otro contrato." - [CryptoMarketPool](https://cryptomarketpool.com/interface-in-solidity-smart-contracts/#:~:text=Interfaces%20are%20often%20found%20at,implementation%20details%20are%20less%20important).).

En Cairo:

1. Definimos una interface con el decorator `@contract_interface`.
2. No agregamos el cuerpo de las funciones.
3. No agregamos elos argumentos ímplicitos, solo los explícitos.
4. Agregamos lo que va a retornar la función.

Así luce la interface que creamos arriba.

```
@contract_interface
namespace ERC721Original {
    func name() -> (name: felt) {
    }

    func symbol() -> (symbol: felt) {
    }

    func owner() -> (owner: felt) {
    }
}
```

Podemos llamar las funciones una vez que el contrato este desplegado, y por lo tanto tengamos su address. Las funciones de una interface automáticamente tienen un primer argumento, `contract_address`, donde debemos indicar la address del contrato desplegado con el que queremos interactuar. Supongamos que la address del contrato se encuentra guardada en la variable `erc721_original_address`; así podemos leer del contrato.

```
let (name) = ERC721Original.name(contract_address=erc721_original_address);
let (symbol) = ERC721Original.symbol(contract_address=erc721_original_address);
let (owner) = ERC721Original.owner(contract_address=erc721_original_address);
```

Lo más normal en StarkNet es llamar contratos usando otros contratos. Para esto las interfaces son clave y elegante. Más adelante agregaremos más funciones a nuestra interfaz para interactuar con el ERC721.

## Desplegar contratos con tests desde Protostar

Protostar, al estar inspirado en [Foundry](https://github.com/foundry-rs/foundry), permite crear tests en Cairo. Normalmente para crear tests de código en Cairo se usa Python y no es difícil. Sin embargo, es un buen principio escribir los tests en el mismo lenguaje en el que se escribe el código principal (aunque veremos que siempre terminamos utilizando al menos un poco de Python).

Veamos de nuevo el test que definimos arriba:

```
@external
func test_ERC721Original{syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;

    local erc721_original_address: felt;

    %{  
        name = 1590066861370246896902429777552750
        symbol = 5129044
        owner = 1268012686959018685956609106358567178896598707960497706446056576062850827536

        declared = declare("lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo")
        prepared = prepare(declared, [name, symbol, owner])
        contract = deploy(prepared)
        ids.erc721_original_address = contract.contract_address

        print(f"ERC721Original contract address (felt): {ids.erc721_original_address}")
    %}

    let (name) = ERC721Original.name(contract_address=erc721_original_address);
    let (symbol) = ERC721Original.symbol(contract_address=erc721_original_address);
    let (owner) = ERC721Original.owner(contract_address=erc721_original_address);
    
    assert 1590066861370246896902429777552750 = name;
    assert 5129044 = symbol;
    assert 1268012686959018685956609106358567178896598707960497706446056576062850827536 = owner;

    return ();
}
```
Notamos:
1. El test debe ser una función external.
2. Los tests de Protostar dependen fuertemente de código de Python escrito en hints (ver tutorial 3 donde los introducimos XXX).
3. Los `assert` parecen estar al revés.

El punto 3. lo explicaremos en otro tutorial donde ahondamos en los tests de Protostar. Por el momento basta mencionar que es una buena práctica colocar el valor constante antes y luego la variable. Esto porque en Cairo `assert` sirve tanto para verificar como para asignar (ver Tutorial XXX).

Respecto al punto 2., el hint casi siempre tiene dos objetivos: desplegar el contrato y obtener la address. El código dentro del hint es bastante autoexplanatorio. ¡Finalmente terminamos desplegando con Python! Pero utilizando funciones definidas por Protostar como `declare`, `prepare` y `deploy`. La address la guardamos en una variable local `erc721_original_address`. 

Haremos dos cosas para mejorar la legibilidad y elegancia de nuestro test. 

1. En el despliegue podemos sustituir a `declare`, `prepare` y `deploy` con la unica llamada `deploy_contract`. Este punto es autoexplanatorio.
2. Vamos a desplegar el contrato al comienzo del test con los setup hooks. Ahondemos.

Si lo piensas, en el test `test_ERC721Original` nuestro objetivo es probar el funcionamiento de nuestro contrato; no buscamos probar el despliegue del contrato, son dos cosas que queremos separar. Para simplificar y mejorar la velocidad de los tests podemos desplegar del contrato antes de correr los tests. 

Así luce el test ahora:

```
%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace ERC721Original {
    func name() -> (name: felt) {
    }

    func symbol() -> (symbol: felt) {
    }

    func owner() -> (owner: felt) {
    }
}

@external
func __setup__() {
    // Desplegamos con deploy_contract y ponemos la address en una variable local.
    // El primer argumento es el path al contrato que vamos a desplegar (nota que la compilación se hace por debajo) 
    // El segundo argumento es una lista con los argumentos que lleva el constructor.
    %{ 
        name = 1590066861370246896902429777552750
        symbol = 5129044
        owner = 1268012686959018685956609106358567178896598707960497706446056576062850827536

        context.erc721_original_address = deploy_contract(
                "lib/cairo_contracts/src/openzeppelin/token/erc721/presets/ERC721MintableBurnable.cairo",
                [name, symbol, owner]
        ).contract_address 
    %}
    return ();
}

@external
func test_ERC721Original{syscall_ptr: felt*, range_check_ptr}() {
    alloc_locals;

    local erc721_original_address: felt;

    %{  
        print(f"ERC721Original contract address (felt): {context.erc721_original_address}")
        ids.erc721_original_address = context.erc721_original_address
    %}

    let (name) = ERC721Original.name(contract_address=erc721_original_address);
    let (symbol) = ERC721Original.symbol(contract_address=erc721_original_address);
    let (owner) = ERC721Original.owner(contract_address=erc721_original_address);
    
    assert 1590066861370246896902429777552750 = name;
    assert 5129044 = symbol;
    assert 1268012686959018685956609106358567178896598707960497706446056576062850827536 = owner;

    return ();
}
```

En la función external `__setup__()` desplegamos nuestro contrato con `deploy_contract`. Esta vez la address la guardamos en `context.erc721_original_address`. Lo que guardemos en `context` puede ser leido en otras partes del archivo. Así hacemos dentro de nuestro test `test_ERC721Original` donde guardamos en la variable `local` `erc721_original_address` la address del contrato que obtuvimos en el setup hook:

```
%{  
    print(f"ERC721Original contract address (felt): {context.erc721_original_address}")
    ids.erc721_original_address = context.erc721_original_address
%}
```



Lo más normal en StarkNet es llamar contratos usando otros contratos. Los contratos que son llamados pueden identificar la dirección del contrato que llama usando `get_caller_address` (analogo a `this.address` en Solidity).  


Colocar en tutorial XXX sobre votar.
Los storage variables solo pueden retornan un unico valor. No se puede crear algo como func animal_characteristics(token_id: Uint256) -> (sex: felt, legs: felt, wings: felt) {




