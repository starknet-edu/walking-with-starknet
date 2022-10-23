# Programando en la L2 de Ethereum (pt. 4): Protostar y desplegando contratos

Antes de comenzar, te recomiendo que prepares tu equipo para programar en Cairo ❤️ con el [primer tutorial](1_instalacion.md), y revises los [básicos de Cairo pt. 1](2_basicos_cairo.md) y [pt. 2](3_basicos_cairo.md).

Únete a la comunidad de habla hispana de StarkNet ([Linktree](https://linktr.ee/starknet_es) con links a telegram, tutoriales, proyectos, etc.). Este es el cuarto tutorial en una serie enfocada en el desarrollo de smart cotracts con Cairo y StarkNet. Recomiendo que hagas los tutoriales pasados antes de pasar a este.

🚀 El futuro de Ethereum es hoy y ya está aquí. Y apenas es el comienzo. Aprende un poco más sobre el ecosistema de Starkware en [este texto corto](https://mirror.xyz/espejel.eth/PlDDEHJpp3Y0UhWVvGAnkk4JsBbJ8jr1oopGZFaRilI).

---

> “StarkNet es un ZK-Rollup descentralizado sin permiso que funciona como una red L2 sobre Ethereum, donde cualquier dApp puede escalar ilimitadamente para su cálculo, sin comprometer la compatibilidad y la seguridad de Ethereum.” - [Documentación de StarkNet](https://starknet.io/docs/hello_starknet/index.html#hello-starknet).

¡Felicidades! 🚀 Ya tenemos un nivel intermedio de Cairo. Cairo es para StarkNet lo que Solidity es para Ethereum. Es hora de desplegar nuestros contratos en StarkNet. También aprenderemos a utilizar [Protostar](https://github.com/software-mansion/protostar), herramienta inspirada en [Foundry](https://github.com/foundry-rs/foundry) y clave para compilar, hacer tests y desplegar.

Actualmente podemos operar con el Alpha de StarkNet. Los pasos recomendados para el despliegue de contratos son:

1. Unit tests - Protostar.
2. Devnet - [Shard Lab’s](https://github.com/Shard-Labs/starknet-devnet) `starknet-devnet` (revisado aquí).
3. Testnet - Alpha Goerli, `alpha-goerli` (revisado aquí).
4. Mainnet - Alpha StarkNet, `alpha-mainnnet`.

En este tutorial aprenderemos a desplegar contratos a la devnet y la testnet. En un texto siguiente aprenderemos a crear unit tests con Protostar; y a interactuar con la devnet y testnet.

¡Comencemos!

---

## 1. Instalación de Protostar

En este punto ya tenemos instalado `cairo-lang`. Si no, puedes revisar [nuestro tutorial](https://medium.com/starknet-en-espa%C3%B1ol/programando-en-la-l2-de-ethereum-b%C3%A1sicos-de-cairo-pt-1-8cc6c94571f1) sobre cómo instalarlo.

En Ubuntu o MacOS (no está disponible para Windows) corre el siguiente comando:

`curl -L https://raw.githubusercontent.com/software-mansion/protostar/master/install.sh | bash`

Reinicia tu terminal y corre `protostar -v` para ver la versión de tu `protostar` y `cairo-lang`.

Si más adelante quieres actualizar tu protostar usa `protostar upgrade`. Si te encuentras con problemas en las instalación te recomiendo que revises la [documentación de Protostar](https://docs.swmansion.com/protostar/docs/tutorials/installation).

## 2. Primeros pasos con Protostar

¿Qué significa inicializar un proyecto con Protostar?

- **Git**. Se creará un nuevo directorio (carpeta) que será un repositorio de git (tendrá un archivo `.git`).
- `protostar.toml`. Aquí tendremos información necesaria para configurar nuestro proyecto. ¿Conoces Python? Bueno ya sabes por donde vamos con esto.
- **Se crearán tres directorios src** (donde estará tu código), lib (para dependencias externas), y tests (donde estarán los tests).

Puedes inicializar tu proyecto con el comando  `protostar init`, o puedes indicar que un proyecto existente utilizará Protostar con `protostar init --existing`. Básicamente, solo necesitas que tu directorio sea un repositorio de git y tenga un archivo `protostar.toml` con la configuración del proyecto. Incluso, podríamos crear nosotr@s mism@s el archivo `protostar.toml` desde nuestro editor de texto.

Corramos `protostar init` para inicializar un proyecto de Protostar. Nos pide indicar dos cosas:

- `project directory name`: ¿Cuál es el nombre del directorio donde se encuentra tu proyecto?
- `libraries directory name`: ¿Cuál es el nombre del directorio donde se instalarán dependencias externas?

Así luce la estructura de nuestro proyecto:

```
❯ tree -L 2
.
├── lib
├── protostar.toml
├── src
│   └── main.cairo
└── tests
    └── test_main.cairo
```

- Inicialmente, aquí se encuentra información sobre la versión de protostar utilizada `[“protostar.config“]`, dónde se encontrarán las librerías externas utilizadas

## 3. Instalando dependencias (bibliotecas) externas

Protostar utiliza submodules de git para instalar dependencias externas. Próximamente se hará con un package manager. Instalemos un par de dependencias.

Instalando `cairo-contracts` indicamos el repositorio donde se encuentran, es decir, [github.com/OpenZeppelin/cairo-contracts](http://github.com/OpenZeppelin/cairo-contracts). Usemos `protostar install`:

`protostar install https://github.com/OpenZeppelin/cairo-contracts`

Instalemos una dependencia más, `cairopen_contracts`:

`protostar install https://github.com/CairOpen/cairopen-contracts`

Nuestras nuevas dependencias se almacenan el directorio `lib`:

```
❯ tree -L 2
.
├── lib
│   ├── cairo_contracts
│   └── cairopen_contracts
├── protostar.toml
├── src
│   └── main.cairo
└── tests
    └── test_main.cairo
```

Por último, agrega en `protostar.toml` la siguiente sección:

```
["protostar.shared_command_configs"]
cairo-path = ["lib/cairo_contracts/src", "lib/cairopen_contracts/src"]
```

Esto nos permite que Protostar use esos paths para encontrar las librerías de interés. Cuando importes, por ejemplo `from openzeppelin.access.ownable.library import Ownable`, Protostar buscará `Ownable` en el path `lib/cairo_contracts/src/openzeppelin/access/ownable/library`. Si cambias el nombre del directorio donde almacenas tus dependencias externas entonces no usarías `lib` sino el nombre de ese directorio.


¡Maravilloso! 

## 4. Compilando

En el pasado hemos estado compilando nuestros contratos con `cairo-compile`. Cuando corremos `cairo-compile sum2Numbers.cairo --output x.json` para compilar un contrato `sum2Numbers.cairo` de Cairo, el resultado es un nuevo archivo en nuestro directorio de trabajo llamado `x.json`. El archivo json es utilizado por `cairo-run` cuando corremos nuestro programa.

En Protostar podemos compilar todos nuestros contratos de StarkNet a la vez con `protostar build`. Pero antes debemos indicar en la sección `[“protostar.contracts”]` de `protostar.toml` los contratos que queremos compilar (o build). Imagina que tenemos un contrato `ERC721MintableBurnable.cairo` en nuestra carpeta `src` (donde están los contratos).

> Nota: No lograrás compilar código de Cairo puro utilizando `protostar build`. Solamente es para contratos de StarkNet (tienen la señal `%lang starknet` al comienzo). Para compilar y correr aplicaciones de Cairo puro necesitas usar `cairo-compile` y `cairo-run` ([ver tutorial de Cairo](3_basicos_cairo.md)). En siguientes tutoriales aprenderemos cómo crear contratos de StarkNet.

Colocamos en `protostar.toml` que queremos compilar el contrato en `src/ERC721MintableBurnable.cairo` y que lo queremos llamar `ERC721_original`:

```
["protostar.contracts"]
ERC721_original = [
    "src/ERC721MintableBurnable.cairo",
]
```

Corremos `protostar build`. Veremos que tenemos un nuevo directorio `build` con un archivo `ERC721MintableBurnable.json`. ¡Esto es lo que buscábamos!

Moraleja: si tu contrato no está en la sección `[“protostar.contracts“]` del `protostar.toml` no será compilado.

En este punto podemos pasar a desplegar contratos de StarkNet con Protostar.

## 5. La devnet: starknet-devnet

Las transacciones en la testnet toman tiempo para completarse por lo que es mejor comenzar desarrollando y probando localmente. Utilizaremos la [devnet desarollada por Shard Labs](https://github.com/Shard-Labs/starknet-devnet). Podemos pensar en este paso como un equivalente de Ganache. Es decir, emula la testnet (alpha goerli) de StarkNet.

Instala usando:

`pip install starknet-devnet`

Reinicia tu terminal y corre `starknet-devnet --version` para revisar que la instalación fue correcta. Revisa que tengas [la versión más actualizada](https://github.com/Shard-Labs/starknet-devnet/releases). Si no la tienes entonces corre `pip install --upgrade starknet-devnet`.

Inicializa la devnet en una shell separada (o una pestaña) con `starknet-devnet --accounts 3 --gas-price 250 --seed 0`:

```
❯ starknet-devnet --accounts 3 --gas-price 250 --seed 0
Account #0
Address: 0x7e00d496e324876bbc8531f2d9a82bf154d1a04a50218ee74cdd372f75a551a
Public key: 0x7e52885445756b313ea16849145363ccb73fb4ab0440dbac333cf9d13de82b9
Private key: 0xe3e70682c2094cac629f6fbed82c07cd

Account #1
Address: 0x69b49c2cc8b16e80e86bfc5b0614a59aa8c9b601569c7b80dde04d3f3151b79
Public key: 0x175666e92f540a19eb24fa299ce04c23f3b75cb2d2332e3ff2021bf6d615fa5
Private key: 0xf728b4fa42485e3a0a5d2f346baa9455

Account #2
Address: 0x7447084f620ba316a42c72ca5b8eefb3fe9a05ca5fe6430c65a69ecc4349b3b
Public key: 0x58100ffde2b924de16520921f6bfe13a8bdde9d296a338b9469dd7370ade6cb
Private key: 0xeb1167b367a9c3787c65c1e582e2e662

Initial balance of each account: 1000000000000000000000 WEI
Seed to replicate this account sequence: 0
WARNING: Use these accounts and their keys ONLY for local testing. DO NOT use them on mainnet or other live networks because you will LOSE FUNDS.

 * Listening on http://127.0.0.1:5050/ (Press CTRL+C to quit)
 ```

Puedes correr `curl http://127.0.0.1:5050/is_alive` para revisar si la devnet está activa. Si se encuentra activa recibirás `Alive!!!%` de vuelta.

Con esto estamos indicando que crearemos tres cuentas y que las transacciones costarán 250 wei per gas. Colocamos un número en seed para tener las mismas cuentas cada vez que activemos nuestra devnet. Estas cuentas están basadas en el código y estándares desarrollados por [Open Zepellin para Cairo](https://github.com/OpenZeppelin/cairo-contracts/tree/v0.2.1).

Es clave que tengamos a la mano la dirección en donde está corriendo nuestra devnet. En la foto arriba es: `http://127.0.0.1:5050/`. Más adelante la utilizaremos.

La interacción con la devnet y la testnet es muy similar. Si quieres ver todos los argumentos disponibles en la llamada `starknet-devnet` puedes llamar `starknet-devnet --help`.

## Desplegando en la devnet y testnet

Utilicemos un ejemplo real. Cuando inicializamos un proyecto de Protostar, se crea automáticamente un contrato `main.cairo` en el directorio `src`. Puedes usarlo como ejemplo de un contrato para desplegar en la devnet y después en la testnet. Solo necesitas asegurarte de que en `protostar.toml` definas que será compilado. En este tutorial vamos a desplegar un contrato para un ERC721 (NFT) que se encuentra en [este repositorio](../../../src/ERC721MintableBurnable.cairo). En `protostar.toml` colocamos: 

```
["protostar.contracts"]
ERC721_original = [
    "src/ERC721MintableBurnable.cairo",
]
```

Corre `protostar build` para compilar y crear el `build/ERC721_original.json` que usaremos para el despliegue.

Para hacer deploy de nuestros contratos en la devnet desde Protostar podemos crear configuration profiles. En el `protostar.toml` creamos una sección `[profile.devnet.protostar.deploy]` donde colocamos el url donde desplegamos nuestra devnet localmente: `gateway-url=”http://127.0.0.1:5050/”` y `chain-id="1"`. Para la testnet la sección sería `[profile.testnet.protostar.deploy]` y colocamos `network="testnet"`.


```
[profile.devnet.protostar.deploy]
gateway-url="http://127.0.0.1:5050/"
chain-id="1"

[profile.testnet.protostar.deploy]
network="testnet"
```

Para la devnet corremos:

```
protostar -p devnet deploy ./build/ERC721.json --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536
```

Para la testnet corremos:

```
protostar -p testnet deploy build/ERC721_original.json --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536
```

Todo es intuitivo, excepto quizás:
- `-p` hace referencia a los profiles que creamos en `protostar.toml`
- `--inputs` son los argumentos del constructor para el contrato que estamos desplegando. No te preocupes en el siguiente tutorial aprendemos qué es un constructor. En este caso el constructor del ERC721 nos pide tres felts (`name`, `symbol` y `owner`)

También podríamos desplegar sin ayuda de los profiles en el `protostar.toml`. En el caso de la testnet puede ser eficiente pues solo agregamos `--network testnet`:

```
protostar deploy ./build/ERC721.json --network testnet --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536
```

Pero en el caso de la devnet tendríamos que agregar dos argumentos por lo que quizás los profiles convienen más:

```
protostar deploy ./build/ERC721.json --gateway-url "http://127.0.0.1:5050/" --chain-id "1" --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536
```

Cuando desplegamos en la devnet o testnet obtenemos el contract address y el transaction hash:

```
Contract address: 0x002454c7b1f60f52a383963633dff767fd5372c43aad53028a5a8a2b9e04646d
Transaction hash: 0x05a2f78261444b97b155417a5734210abe2ee1081b7f12f39f660321fd10e670
```

Es importante guardar el contract address pues interactuaremos con él en siguientes funciones. Esto lo revisaremos en otros tutoriales.

Si desplegaste en la testnet puedes usar la contract address para interactuar con tu contrato en un block explorer: [Voyager](https://goerli.voyager.online/) o [StarkScan](https://testnet.starkscan.co/). Estos block explorers son equivalentes a [Etherscan](https://goerli.voyager.online/) para la L1.

La ventaja de desplegar en la devnet primero es que podemos interactuar más rápidamente con nuestros contratos. Para la testnet tendremos que esperar cerca de unos minutos.

## 7. Desplegando con la CLI de `starknet`

Por debajo, Protostar está utilizando el CLI de `starknet` para desplegar. Hay ocasiones en las que no queremos depender completamente de Protostar, por ejemplo cuando hay una actualización de StarkNet y aún no es aplicada en la biblioteca de Protostar.

Más adelate exploraremos a fondo la CLI de `starknet`. Por ahora veamos cómo desplegar exactamente el mismo contrato.

Para la devnet, una vez que la encendiste en el gateway http://127.0.0.1:5050, sería:

```
starknet deploy --contract ./build/ERC721_original.json --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536 --gateway_url "http://127.0.0.1:5050" --no_wallet
```

Para la testnet:

```
starknet deploy --contract ./build/ERC721_original.json --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536 --network alpha-goerli --no_wallet
```

En ambos casos obtenemos el contract address y el transaction hash; igual que al desplegar con Protostar.


## 7. Conclusión

Felicidades 🦾. ¡Acabas de dar tus primeros pasos en StarkNet! Estás aprovechando todo lo aprendido en los tutoriales pasados sobre Cairo.

En los siguientes tutoriales aprenderemos más sobre la creación de smart contracts en StarkNet 🚀.

Cualquier comentario o mejora por favor comentar con [@espejelomar](https://twitter.com/espejelomar) 🌈.
