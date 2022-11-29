# WIP!!! Escalamiento de la autocustodia con abstracción de cuenta y StarkNet: imprescindible para el futuro de Ethereum

**Descargos de responsabilidad: este tutorial cita a varias partes interesadas, cualquier error o malentendido en este tutorial es culpa de la interpretación.*

> **Si no tenemos AA, Ethereum está en juego.**

* La mayoría de los usuarios de Ethereum usan intercambios centralizados porque administrar una billetera de autocustodia es difícil; esto no es auto-custodia. El statu quo actual corre el riesgo de hacer que la próxima ola de usuarios dependa de intercambios centralizados ([Julien, Devcon 6](https://www.youtube.com/watch?v=OwppworJGzs)).
* La llegada inminente de las computadoras cuánticas obligará al ecosistema criptográfico a pasar a firmas a prueba de cuánticas. La curva de Stark es una forma que se puede hacer.

En 5 años sería extraño que usáramos para asegurar nuestros activos escribiendo 12 palabras en papel. StarkNet está liderando el camino en la implementación de AA a nivel de protocolo (no a nivel de aplicación como con los EIP actuales en L1): es el "campo de pruebas" de cómo se verá AA en el futuro ([AA Panel, Devcon 6](https://app.devcon.org/schedule/9mvqce)).


## ¿Qué es la abstracción de cuenta?

> Definición 1: AA es cuando un **contrato inteligente puede pagar sus propias transacciones** ([Martin Triay, Devcon 6](https://www.youtube.com/watch?v=Osc_gwNW3Fw)). En otras palabras, los contratos abstractos (o contratos inteligentes de cuentas) pueden pagar las transacciones. Tenga en cuenta que no es lo mismo que cuentas de propiedad externa o billeteras inteligentes.

> Definición 2: AA es **abstracción de validación**. En L1 solo hay una forma de validar transacciones (recuperar una dirección de una firma, mirar esa dirección en el estado, determinar si el nonce está bien para la transacción que se envió y si la cuenta tiene saldo suficiente para realizar la transacción) . Con AA, **abstrae el proceso de validación**: utiliza diferentes tipos de firmas, primitivas criptográficas, procesos de ejecución, etc. ([lightclient, Devcon 6](https://app.devcon.org/schedule/9mvqce)) .

**Nota: En computación, el término abstracción se usa para generalizar algo. En este caso, estamos generalizando los contratos inteligentes: de la existencia de Externally Owned Contracts (EOA) y Contract Accounts (CA)  a simplemente contratos inteligentes.*


## ¿Y qué?

De acuerdo a:
* Martin Triay (Open Zepellin), AA significa [grandes mejoras en la incorporación, la experiencia del usuario y la seguridad](https://www.youtube.com/watch?v=Osc_gwNW3Fw). AA es el futuro de la criptografía UX y la seguridad.
* Julien Niset (Argent), AA significa escalar la autocustodia, que es [un requisito para incorporar a los próximos mil millones de usuarios](https://www.youtube.com/watch?v=OwppworJGzs).
* Vitalik, [las billeteras inteligentes deben ser las predeterminadas](https://app.devcon.org/schedule/9mvqce) y AA es el paso clave.
* Yoav (Fundación Ethereum), [AA es seguridad clave](https://app.devcon.org/schedule/9mvqce).  

### Autocustodia: poseer las llaves, poseer los activos

La auto-custodia es dura y necesaria. Crypto se trata de propiedad digital: usted es dueño de sus activos. El principio normalmente se representa con el lema: Si no tiene sus llaves, no tiene sus activos. El principio es genial. Sin embargo, los humanos siempre perderán y olvidarán las contraseñas ([Julien, Devcon 6](https://www.youtube.com/watch?v=OwppworJGzs)). Desde expertos hasta principiantes, todos pierden sus contraseñas o claves. Es tan cierto desde web2 y seguirá siendo cierto en web3. Julien va tan lejos como para decir que "los usuarios comunes nunca deberían manejar la administración de claves, y si Ethereum no se aleja de los EOA, viviremos en un mundo donde solo unos pocos usan la autocustodia y el resto usa intercambios centralizados" ([ 2022](https://www.argent.xyz/blog/part-2-wtf-is-account-abstraction/)).

En Ethereum y otras L1, los usuarios pierden sus claves y frases de recuperación; y eso es todo, el usuario no puede recuperar los activos de su cuenta. No hay "Olvidé mis llaves, ayúdame a recuperar mi cuenta". ¿De quién fue la idea de que la clave privada era un requisito estricto? Según [Julien](https://www.youtube.com/watch?v=OwppworJGzs), el problema está en el corazón de la EVM (Ethereum Virtual Machine). Volveremos a esto más tarde. Con AA, la clave privada pronto será cosa del pasado.


## Casos de uso (algunos de ellos, ¡inventa uno!)

AA promete poner capacidad de programación en cada billetera Ethereum y desbloquear nuevas fronteras tanto para desarrolladores como para usuarios ([Panel AA, Devcon 6](https://app.devcon.org/schedule/9mvqce)).

Entre otras cosas, AA permite:
* Recuperación social: en caso de pérdida o compromiso de la clave privada de un usuario, AA permite que las billeteras agreguen mecanismos para reemplazar de manera segura la clave que controla la cuenta. ¡Nunca más te preocupes por las frases iniciales ([Julien Niset, 2022](https://www.argent.xyz/blog/part-2-wtf-is-account-abstraction/))!
* Rotación de claves: si sus claves están comprometidas, en lugar de mover todos los activos, puede rotar las claves y eso es todo. (XXX mira más sobre esto)
* Teclas de sesión: Firmar con la cara o el dedo en el móvil o en tus apps favoritas es posible con AA. Las claves de sesión son un conjunto de permisos otorgados a un sitio web, por ejemplo, puede iniciar sesión una vez y luego el sitio web puede actuar en nuestro nombre sin tener que firmar cada transacción. Esta es la experiencia Web2.
* Guardianes: XXX
* Esquemas personalizados de validación de transacciones.
  * Diferentes esquemas de firma: puede usar firmas de ethereum, firmas de Bitcoin, ambas si lo desea. El usuario podría preferir una firma con mayor eficiencia de gas o una resistente a la cuántica. Use el enclave seguro de dispositivos iOS y Android para convertir cada teléfono en una billetera de hardware ([Martin Triay (Devcon 6)](https://www.youtube.com/watch?v=Osc_gwNW3Fw), [Julien (2022)](https://www.argent.xyz/blog/part-2-wtf-is-account-abstraction/)).
  * Multifirma: Cambia quién puede firmar cada semana. Soporte de monitoreo de fraude; inspeccione cada transacción para asegurarse de que cumpla con las reglas de seguridad definidas y evite que los usuarios envíen activos a una dirección fraudulenta o contrato incorrecto. ([Martin Triay (Devcon 6)](https://www.youtube.com/watch?v=Osc_gwNW3Fw), [Julien (2022)](https://www.argent.xyz/blog/part-2-wtf-is-cuenta-abstracción)).

Estas son solo algunas ideas. Aún queda más por venir.

## Seguridad

Hay muchas formas en que AA ayuda a la seguridad en Ethereum. [Yoav en Devcon 6](https://app.devcon.org/schedule/9mvqce) mencionó lo siguiente:

* Manejo de claves: Poder agregar dispositivos a tu billetera para que tu billetera no se asocie con la frase semilla, pero si pierdes tu phone puedes acceder con tu computadora. Esto mejora la seguridad,
* Diferentes esquemas de firma y validación: podría, por ejemplo, gastar pequeñas cantidades libremente, pero si está enviando una gran cantidad, la dapp o la billetera podrían solicitar otro tipo de firma similar a la Autorización de 2 factores. Esto es común en intercambios centralizados.
* Diferentes políticas de seguridad para diferentes tipos de usuarios: Con EOAs (L1) solo tenemos una única política; si tienes la llave entonces haz algo si no la tienes entonces no puedes hacer nada. Con AA, por ejemplo, podríamos crear un esquema de seguridad para cuentas empresariales y otro para usuarios individuales. De nuevo, copia buenas prácticas en el sector bancario y web2.
* Diferentes políticas de seguridad para diferentes dispositivos: Por ejemplo, un teléfono puede enviar una cantidad máxima de tokens y una computadora tiene un límite a menos que lo valides de alguna manera (2FA). Para que esto suceda, debemos poder implementar diferentes esquemas de firma según cada dispositivo (por ejemplo, una computadora no usa la misma curva que un teléfono Android). Los EOA solo admiten un tipo de curva que es incompatible con la mayoría de los dispositivos. Con AA puedes usar varios dispositivos con la misma cuenta. Los usuarios ya no tendrán una billetera diferente en cada dispositivo; uno para la computadora, uno para el teléfono, uno para el Ledger.

## ¿Por qué aún no se ha implementado en la L1 de Ethereum?

Según Julien Niset ([2022](https://www.argent.xyz/blog/part-2-wtf-is-account-abstraction/)), la clave es eliminar los EOA. Ningún EIP ha abordado esto todavía. Es comprensible ya que esto implicaría múltiples cambios en el corazón del protocolo; y día a día, a medida que aumenta el valor asegurado por Ethereum, la implementación de AA se vuelve más difícil debido a la coordinación requerida([Julien Niset, 2022](https://www.argent.xyz/blog/part-2-wtf-is-account-abstraction/)).

Si es tan importante, ¿por qué Ethereum ya lo admite? Este es un ejemplo de las limitaciones de la EVM que pueden ser superadas por una nueva Máquina Virtual como la Cairo VM. Se han hecho propuestas para implementar AA desde los primeros días de Ethereum y constantemente han sido "rechazadas repetidamente a favor de cambios más urgentes". ([Julien Niset, 2022](https://www.argent.xyz/blog/part-2-wtf-is-account-abstraction/)). No está claro que se implementará en las próximas versiones de Ethereum, incluso después de la fusión.

La creación de nuevas VM L2 enfocadas en la escalabilidad permitió avanzar en su implementación; StarkNet y ZKSync cuentan con AA nativa inspirada en EIP4337, considerada la mejor propuesta por expertos como Julien Niset de Argent ([2022](https://www.argent.xyz/blog/part-2-wtf-is-account-abstraction/)). Parece que los defensores clave de AA, como Julien, han perdido la esperanza de que se eliminen los EOA y se implemente AA en el núcleo de Ethereum; Argent ahora está impulsando la adopción generalizada de AA a través de L2 como StarkNet.


## AA ya está aquí, disfrútalo!

Ahora que conocemos mejor el concepto de AA, codifiquémoslo en StarkNet.

Como se mencionó anteriormente, StarkNet posee AA de forma nativa. El diseño ha sido liderado notablemente por Starkware, Open Zeppellin y Argent.

### El proceso

Realizaremos **implementación contrafactual**. Eso es:

1. Calcular la dirección del contrato de cuenta antes de la implementación.

Una dirección de contrato en la red StarkNet es un identificador único del contrato y es un hash de (más detalles en [la documentación](mentation/develop/Contracts/contract-address/) y [implementación real en Python](https://github.com/starkware-libs/cairo-lang/blob/13cef109cd811474de114925ee61fd5ac84a25eb/src/starkware/starknet/core/os/contract_address/contract_address.py#L40)):
* Prefix: la codificación ASCII de la cadena "STARKNET_CONTRACT_ADDRESS".
* Deployer address: actualmente siempre cero.
* Salt - número aleatorio (felt) utilizado para distinguir entre diferentes instancias del contrato.
* Class Hash: cadena hash de la definición de la clase (más [aquí](https://docs.starknet.io/documentation/develop/Contracts/contract-hash/)).
* Constructor calldata hash: hash de array de las entradas al constructor.

Esto significa que podemos calcular la dirección del contrato del contrato de cuenta que queremos implementar incluso antes de la implementación. Esto es lo que hacemos cuando inicializamos un contrato de cuenta:

```Bash
starknet new_account --network alpha-goerli --account ALIAS --wallet starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount
```

Esto produce algo como:

```Bash
Account address: 0x006b27f2455d175f1c9b39568838ee0c1dfba34ca29f489690e40ee69220f15c
Public key: 0x07f90c757da3498bfa61b393e1048ace09d9729f9fc75d2a5dc6eb590852643e
Move the appropriate amount of funds to the account, and then deploy the account
by invoking the 'starknet deploy_account' command.

NOTE: This is a modified version of the OpenZeppelin account contract. The signature is computed
differently.
```

Ahora tenemos la dirección del contrato de cuenta (([esta es la línea](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/starknet/wallets/open_zeppelin.py#L107) donde la dirección se calcula en el repositorio)) que podemos financiar; si usamos testnet podemos usar el[faucet](https://faucet.goerli.starknet.io/). Estamos utilizando la estructura de contrato de cuenta predeterminada creada por Open Zeppelin (un poco modificada) que puede encontrar en la [third_party library](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/starknet/third_party/open_zeppelin/Account.cairo). En las siguientes secciones crearemos nuestros propios contratos de cuenta. 

2. Enviar fondos a esa dirección, aunque aún no tenga contrato (aún no se haya desplegado);

Por ejemplo, podemos enviar fondos usando el [testnet faucet](https://faucet.goerli.starknet.io/).

3. El contrato paga por su transacción de implementación si pasa `__validate_deploy__`; y 

Implementar el contrato de cuenta con:

```Bash
starknet deploy_account --network alpha-goerli --account ALIAS --wallet starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount
```

Si las condiciones definidas en el `__validate_deploy__` se cumplen los puntos de entrada, se implementa el contrato de cuenta. En el caso del contrato de cuenta Open Zeppelin la firma debe ser válida para el despliegue del contrato:

```Bash
@external
func __validate_deploy__{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, ecdsa_ptr: SignatureBuiltin*
}(class_hash: felt, contract_address_salt: felt, _public_key: felt) {
    let (tx_info) = get_tx_info();
    is_valid_signature(tx_info.transaction_hash, tx_info.signature_len, tx_info.signature);
    return ();
}
```

4. El contrato de cuenta está desplegado ([Martin Triay, (Devcon 6)](https://www.youtube.com/watch?v=Osc_gwNW3Fw)).

Si se implementa con éxito, obtenemos:

```Bash
Sending the transaction with max_fee: 0.000000 ETH (323076307108 WEI).
Sent deploy account contract transaction.

Contract address: 0x006b27f2455d175f1c9b39568838ee0c1dfba34ca29f489690e40ee69220f15c
Transaction hash: 0x3dc6e579d7b4204907de859d1a12e42132853b9827e7203487740d51e957eed
```

Tenga en cuenta que actualmente la CLI de StarkNet solo funciona con el [OpenZeppelin account contract](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/starknet/third_party/open_zeppelin/Account.cairo). Si queremos implementar nuestros propios contratos de cuenta, debemos implementarlos usando un método diferente. Más en las siguientes secciones.

Ahora examinaremos el funcionamiento interno del contrato Open Zeppelin y procederemos a crear nuestros propios contratos de cuenta.

### Uso de los estándares de Open Zeppelin

Aunque los contratos de cuenta no son más que contratos inteligentes, tienen métodos que los diferencian de otros contratos inteligentes. Este es el [Open Zeppelin IAccount contract interface](https://github.com/OpenZeppelin/cairo-contracts/blob/release-v0.4.0b/src/openzeppelin/account/IAccount.cairo) Adoptada también por Argent (implementa [EIP-1271](https://eips.ethereum.org/EIPS/eip-1271)):

```Rust
struct Call {
    to: felt,
    selector: felt,
    calldata_len: felt,
    calldata: felt*,
}

// Tmp struct introduced while we wait for Cairo to support passing `[Call]` to __execute__
struct CallArray {
    to: felt,
    selector: felt,
    data_offset: felt,
    data_len: felt,
}


@contract_interface
namespace IAccount {
    func supportsInterface(interfaceId: felt) -> (success: felt) {
    }

    func isValidSignature(hash: felt, signature_len: felt, signature: felt*) -> (isValid: felt) {
    }

    func __validate__(
        call_array_len: felt, call_array: AccountCallArray*, calldata_len: felt, calldata: felt*
    ) {
    }

    func __validate_declare__(class_hash: felt) {
    }

    func __execute__(
        call_array_len: felt, call_array: AccountCallArray*, calldata_len: felt, calldata: felt*
    ) -> (response_len: felt, response: felt*) {
    }
}
```

Y esta es la API pública ([encuentre el preajuste completo aquí](https://github.com/OpenZeppelin/cairo-contracts/blob/release-v0.4.0b/src/openzeppelin/account/presets/Account.cairo)):

```Rust
namespace Account {
    func constructor(publicKey: felt) {
    }

    func getPublicKey() -> (publicKey: felt) {
    }

    func supportsInterface(interfaceId: felt) -> (success: felt) {
    }

    func setPublicKey(newPublicKey: felt) {
    }

    func isValidSignature(hash: felt, signature_len: felt, signature: felt*) -> (isValid: felt) {
    }

    func __validate__(
        call_array_len: felt, call_array: AccountCallArray*, calldata_len: felt, calldata: felt*
    ) -> (response_len: felt, response: felt*) {
    }

    func __validate_declare__(
        call_array_len: felt, call_array: AccountCallArray*, calldata_len: felt, calldata: felt*
    ) -> (response_len: felt, response: felt*) {
    }

    func __execute__(
        call_array_len: felt, call_array: AccountCallArray*, calldata_len: felt, calldata: felt*
    ) -> (response_len: felt, response: felt*) {
}
```

Tenga en cuenta que el [contrato de cuenta predeterminado](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/starknet/third_party/open_zeppelin/Account.cairo) utilizado por StarkNet y desarrollado principalmente por Open Zeppelin tiene esta misma estructura.

Examinemos los puntos de entrada (funciones):

* `constructor`: No es un requisito.
  * `publicKey: felt`: Si bien la interfaz es independiente de los esquemas de validación de firmas, esta implementación asume que hay un par de claves públicas y privadas que controlan la cuenta. Es por eso que la función constructora espera un `public_key` parámetro para configurarlo. Como también hay un método `setPublicKey()`, las cuentas se pueden transferir de manera efectiva ([Open Zeppelin Docs, 2022](https://docs.openzeppelin.com/contracts-cairo/0.5.0/accounts)).
* `getPublicKey`: Devuelve la clave pública asociada a la Cuenta ([Open Zeppelin Docs, 2022](https://docs.openzeppelin.com/contracts-cairo/0.5.0/accounts)).
* `supportsInterface`: Devuelve TRUE si este contrato implementa la interfaz definida por `interfaceId`. Los contratos de cuentas ahora implementan ERC165 a través de soporte estático (consulte [Diferenciación de cuentas con ERC165](https://docs.openzeppelin.com/contracts-cairo/0.5.0/accounts#account_differentiation_with_erc165)) ([Open Zeppelin Docs, 2022](https://docs.openzeppelin.com/contracts-cairo/0.5.0/accounts)).
* `setPublicKey`: Establece la clave pública que controlará esta Cuenta. Se puede usar para rotar claves por seguridad, cambiarlas en caso de claves comprometidas o incluso transferir la propiedad de la cuenta. ([Open Zeppelin Docs, 2022](https://docs.openzeppelin.com/contracts-cairo/0.5.0/accounts)).
* `isValidSignature`: Esta función está inspirada en EIP-1271 y devuelve TRUE si una firma determinada es válida; de lo contrario, se revierte. En el futuro devolverá FALSE si una firma dada no es válida([Open Zeppelin Docs, 2022](https://docs.openzeppelin.com/contracts-cairo/0.5.0/accounts)).
* `__validate__`: Le permite definir una lógica arbitraria para determinar si una transacción es válida o no. No pueden leer otros contratos de almacenamiento, esto ayuda como antispam. Por ejemplo, muchas transacciones pueden depender del almacenamiento de un contrato, por lo tanto, si el almacenamiento cambia, todo lo que depende de él comienza a fallar. El contrato de cuenta llamará primero `__validate__` al recibir una transacción. Recibe como argumentos (calldata):
  * `call_array_len: felt` - número de llamadas
  * `call_array: AccountCallArray*` - array que representa a cada  `Call`.
  * `calldata_len: felt` - número de parámetros de datos de llamada. Recuerde que los datos de llamada son los argumentos utilizados para llamar a una función.
  * `calldata: felt*` - array que representa los parámetros de la función.
* `__validate_declare__`: Valida la firma de la declaración antes de la declaración. A partir de Cairo v0.10.0, las clases de contrato deben declararse desde un contrato de Cuenta([Open Zeppelin Docs, 2022](https://docs.openzeppelin.com/contracts-cairo/0.5.0/accounts)). Las transacciones de declaración ahora requieren que las cuentas paguen tarifas.
  * `class_hash: felt`:
* `__execute__`: Este es el único punto de entrada externo para interactuar con el contrato de Cuenta. Si `__validate__` es exitoso `__execute__` sera llamado. Actúa como el punto de entrada de cambio de estado para todas las interacciones del usuario con cualquier contrato, incluida la gestión del contrato de la cuenta en sí. ([Open Zeppelin Docs, 2022](https://docs.openzeppelin.com/contracts-cairo/0.5.0/accounts)).
  * Mismos argumentos que `__validate__`. Sin embargo, `__execute__` devuelve una respuesta de transacción.

También estamos usando nuevas estructuras:

1. Una sola `Call`:

```Rust
struct Call {
    to: felt
    selector: felt
    calldata_len: felt
    calldata: felt*
}
```
Dónde:

* `to` es la dirección del contrato de destino del mensaje.
* `selector` es el selector de la función que se llamará en el contrato de destino.
* `calldata_len` es el número de parámetros de calldata.
* `calldata` es una array (matriz) que representa los parámetros de la función ([Open Zeppelin Docs, 2022](https://docs.openzeppelin.com/contracts-cairo/0.5.0/accounts)).


2. `AccountCallArray`, una calls array:

```Rust
struct AccountCallArray {
    to: felt
    selector: felt
    data_offset: felt
    data_len: felt
}
```
Dónde:

* `to` y `selector` son los mismas que en `Call`.
* `data_offset` es la posición inicial de la array de datos de llamada que contiene los datos de llamada de `Call`.
* `data_len` es el número de elementos calldata en el `Call`.


## Despliegue contrafactual desde adentro

Implementemos el contrato de cuenta predeterminado, inspirado en la implementación de Open Zeppelin, con el alias  `second-account`, en la red de prueba de Goerli 2. El indicador `--wallet starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount` indica que usaremos el contrato de cuenta predeterminado, actualmente solo podemos usar este contrato con la CLI.

```Bash
starknet new_account --feeder_gateway_url https://alpha4-2.starknet.io --gateway_url https://alpha4-2.starknet.io --network_id 1536727068981429685321 --account second-account --wallet starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount
```

Obtenemos:

```Bash
Account address: 0x02b0fc135cae406bbc27766c189972dd3aae5fc79a66d5191a8d6ac76a0ce8f9
Public key: 0x066ed5a84f995a2dcd714b505dc165a8df71473ebc374dbe5fe973631198ba72
Move the appropriate amount of funds to the account, and then deploy the account
by invoking the 'starknet deploy_account' command.

NOTE: This is a modified version of the OpenZeppelin account contract. The signature is computed
differently.
```

[OPCIONAL] Podemos profundizar en el examen del contrato de cuenta predeterminado de Open Zeppelin para obtener class hash, salt y los datos de llamada del constructor que se utilizan para calcular su dirección. [`src/utils/contract_address.py`](../../../src/utils/contract_address.py) es una copia del [`contract_address.py`](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/starknet/core/os/contract_address/contract_address.py) biblioteca de la biblioteca de Starkware. Agregamos declaraciones de impresión en el `calculate_contract_address()` function to get the class hash, salt, and constructor calldata. y los datos de llamada del constructor. Si desea usarlo, vaya a donde su sistema operativo almacena sus paquetes de Python (probablemente `site-packages`) y reemplace `/starkware/starknet/core/os/contract_address/contract_address.py` con nuestro [`src/utils/contract_address.py`](../../../src/utils/contract_address.py). Luego, cuando definimos nuestro contrato de cuenta con `starknet new_account ...` también obtenemos:

```Bash
Class Hash: 895370652103566112291566439803611591116951595367594863638369163604569619773
Salt: 462250451139519919709009935198618602877233823783070820758189518720702799406
Constructor calldata: [2909704878250883580952868877137725986814034606621060536770963048574421088882]
```

Las tres propiedades están en formato de felt. Puede convertirlos manualmente en sus representaciones hexadecimales, si lo desea, con el [stark-utils](https://www.stark-utils.xyz/converter) converter. El contrato de cuenta predeterminado de Open Zeppelin requiere una clave pública en su constructor ([see implementation](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/starknet/third_party/open_zeppelin/Account.cairo#L105)), si lo deseamos, con contratos de cuenta propia, no podemos añadir este requisito. El contrato que definimos arriba tiene una clave pública `0x066ed5a84f995a2dcd714b505dc165a8df71473ebc374dbe5fe973631198ba72` una vez que convertimos el felt anterior en formato hexadecimal.

Calcular la dirección es la clave de este primer paso en el despliegue contrafáctico. Recuerde, aún no se ha implementado, solo calculamos la dirección y agregamos esta nueva cuenta a la `.starknet_accounts/starknet_open_zeppelin_accounts.json` expediente. Es clave seguir de cerca la `starknet_open_zeppelin_accounts.json` ya que allí podemos encontrar nuestros contratos de cuenta creados; lo encontrará en su directorio raíz, por ejemplo, `/Users/espejelomar/.starknet_accounts/starknet_open_zeppelin_accounts.json`. `starknet_open_zeppelin_accounts.json` muestra información relevante para la creación de cada contrato de cuenta. Por ejemplo, para la  `first-account`  que creamos anteriormente tenemos:

```Bash
"1536727068981429685321": {
        "second-account": {
            "private_key": "XXX",
            "public_key": "0x66ed5a84f995a2dcd714b505dc165a8df71473ebc374dbe5fe973631198ba72",
            "salt": "0x1059fde2a4da7c421dd6dbe8af873a2977c6008c7a09e61db1c5a45d25ede2e",
            "address": "0x2b0fc135cae406bbc27766c189972dd3aae5fc79a66d5191a8d6ac76a0ce8f9",
            "deployed": false
        }
    },
```
`1536727068981429685321` es el chain_id para goerli. Nota que dice `"deployed": false` ya que no hemos desplegado el contrato.

Si usamos el mismo código compilado, salt (esta es la función principal de la salt) y los datos de llamada del constructor, entonces deberíamos poder calcular la misma dirección. los `get_address` función en [`src/utils/accounts_utils.py`](../../../src/utils/accounts_utils.py) (siguiente paso: crear una nueva biblioteca para ayudar a los usuarios a crear contratos de cuenta más fácilmente 🚀) puede calcular la dirección de cualquier contrato sin implementarlo. Obtendremos la misma dirección para el contrato de cuenta de Open Zeppelin si entramos en modo Python en nuestra terminal, `python3.9 -i src/utils/accounts_utils.py` (Estoy usando `python 3.9`), y call (observe que reutilizamos el `salt` y `constructor_calldata` obtuvimos arriba, y que estamos usando el código compilado del contrato de cuenta predeterminado de Open Zeppelin en [`assets/compiled_open_zeppeling_account_contract.json`](../../../assets/compiled_open_zeppeling_account_contract.json).

```Python
get_address(
    contract_path_and_name = "assets/compiled_open_zeppeling_account_contract.json",
    salt = 462250451139519919709009935198618602877233823783070820758189518720702799406,
    constructor_calldata = [2909704878250883580952868877137725986814034606621060536770963048574421088882],
    deployer_address = 0,
    compiled = True,
)
```

Nosotros obtenemos:

```Bash
Account contract address: 0x02b0fc135cae406bbc27766c189972dd3aae5fc79a66d5191a8d6ac76a0ce8f9
Class contract hash: 0x01fac3074c9d5282f0acc5c69a4781a1c711efea5e73c550c5d9fb253cf7fd3d
Salt: 0x01059fde2a4da7c421dd6dbe8af873a2977c6008c7a09e61db1c5a45d25ede2e
Constructor call data: [2909704878250883580952868877137725986814034606621060536770963048574421088882]

Move the appropriate amount of funds to the account. Then deploy the account.
```

Todo coincide, incluida la dirección del contrato de la cuenta, con nuestro cálculo utilizando `starknet new_account ...`. ¡Excelente! Ahora sabemos cómo podemos calcular las direcciones antes de la implementación. Esta es la parte más importante del despliegue contrafáctico.

Vamos a financiar la dirección calculada. Podemos hacer esto uniendo Goerli ETH de L1 a Goerli 2 en L2. Primero, financie su billetera L1 con Goerli ETH (puede usar el [Paradigm faucet](https://faucet.paradigm.xyz/api/auth/signin)). Now go into the [Goerli 2 contract in the L1](https://goerli.etherscan.io/address/0xaea4513378eb6023cf9ce730a26255d0e3f075b9#writeProxyContract) y en la función de `deposit`" externo, escriba la cantidad de ETH que desea vincular y el destinatario L2 (nuestra dirección de contrato calculada: 0x02b0fc135cae406bbc27766c189972dd3aae5fc79a66d5191a8d6ac76a0ce8f9). Ahora este contrato puede pagar su propio despliegue.

Desplegamos el contrato de cuenta a Goerli 2 usando Protostar. Agregue (1) como entrada los datos de llamada del constructor y (2) como salt nuestro valor que teníamos antes. Si no especificamos el valor de la salt, Protostar genera un valor aleatorio y no lo implementaremos en nuestra dirección de contrato definida.

```Bash
protostar deploy assets/compiled_open_zeppeling_account_contract.json --inputs 2909704878250883580952868877137725986814034606621060536770963048574421088882 --salt 462250451139519919709009935198618602877233823783070820758189518720702799406 --gateway-url https://alpha4-2.starknet.io --chain-id 1536727068981429685321
```

Nosotros obtenemos:

```Bash
[INFO] Deploy transaction was sent.
Contract address: 0x02b0fc135cae406bbc27766c189972dd3aae5fc79a66d5191a8d6ac76a0ce8f9
Transaction hash: 0x070326e2bed2746fe92847eacf9d04a05cf7b943369afb99f4ad09839f0281c0
```

The contract address is still the same. And now our contract is [deployed in Goerli 2](https://testnet-2.starkscan.co/contract/0x02b0fc135cae406bbc27766c189972dd3aae5fc79a66d5191a8d6ac76a0ce8f9#overview). Inside StarkScan go to the Portfolio tab to see the ETH we transferred to this address before the deployment.

Now we dominate the Open Zeppelin account contract and how to counterfactually deploy it.

*********
**WIP** NO TENGA EN CUENTA LO SIGUIENTE
*********

## Ejemplos

Obtener el nonce con

```Bash
starknet get_nonce --contract_address 0x02b0fc135cae406bbc27766c189972dd3aae5fc79a66d5191a8d6ac76a0ce8f9 --feeder_gateway_url https://alpha4-2.starknet.io --gateway_url https://alpha4-2.starknet.io --network_id 1536727068981429685321
```

Esto devuelve un `0`. ¿Qué es un nonce? Un número secuencial adjunto al contrato de la cuenta, que evita la reproducción de la transacción y garantiza el orden de ejecución y la unicidad del hash de la transacción.



A diferencia de Ethereum [EOAs](https://ethereum.org/en/developers/docs/accounts/#externally-owned-accounts-and-key-pairs), Las cuentas de StarkNet no tienen un requisito estricto de ser administradas por un par de claves pública/privada.

AA se preocupa más por "quién" (es decir, la dirección del contrato) que por "cómo" (es decir, la firma).

Esto deja el esquema de firma ECDSA al desarrollador y normalmente se implementa usando el [pedersen hash](https://docs.starknet.io/docs/Hashing/hash-functions) y curva Stark nativa:

Los `signature_1` contrato no tiene concepto de un par de claves pública/privada. Toda la firma se realizó "fuera de la cadena" y, sin embargo, con AA aún podemos operar una cuenta en funcionamiento con un campo de firma completo.




.
.
.
.
.



A diferencia de Ethereum, donde las cuentas se derivan directamente de una clave privada, no existe un concepto de cuenta nativo en StarkNet.

En cambio, la validación de la firma debe realizarse a nivel de contrato. Para liberar de esta responsabilidad a las aplicaciones de contratos inteligentes, como los tokens ERC20 o los intercambios, hacemos uso de los contratos de cuenta para gestionar la autenticación de transacciones.

## Devcon 6

AA fue uno de los temas más candentes en Devcon 6 (2022). Se realizaron al menos 6 charlas, talleres y paneles (uno de ellos con Vitalik) sobre el tema. De estos dos fueron abordados directamente desde AA en StarkNet, y todos reconocen a AA en StarkNet.
* [Martin Triay, Open Zeppelin: Account Abstraction in StarkNet](https://www.youtube.com/watch?v=Osc_gwNW3Fw) (StarkNet oriented).
* [Vitalik Buterin, David Hoffman (Bankless), Julien Niset (Argent), Yoav Weiss (Ethereum Foundation), lightclient (Geth): Account Abstraction Panel](https://www.youtube.com/watch?v=WsZBymiyT-8&feature=emb_imp_woyt).
* [Liraz, Yoav Weiss (Ethereum Foundation): ELI5: Account Abstraction](https://www.youtube.com/watch?v=QuYZWJj65AY).
* [(ETH Global) Yoav Weiss (Ethereum Foundation), Dror Tirosh: Ethereum Foundation 🛠 Account abstraction: building an ERC-4337 wallet](https://www.youtube.com/watch?v=xHWlJiL_iZA).
* [Dror Tirosh, Liraz: Account Abstraction: Making Accounts Smarter](https://app.devcon.org/schedule/nz3pyp).
* [Ivo Georgiev, Ambire Wallet: The Future of Wallets: MPC vs Smart Wallets](https://archive.devcon.org/archive/watch/6/the-future-of-wallets-mpc-vs-smart-wallets/?tab=YouTube).
* [Danno Ferrin, Hedera Hashgrap: What Alternative Blockchains Compatibility with Ethereum Tooling Can Teach Us About Ethereum's Future](https://www.youtube.com/watch?v=KqE9HN4QGpM).
