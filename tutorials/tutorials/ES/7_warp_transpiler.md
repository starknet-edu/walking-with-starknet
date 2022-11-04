# Migrando Contratos de Solidity a Cairo usando WARP

![banner](https://mirror-media.imgix.net/publication-images/XzWA8JzeVCfO2ZXmbBxcK.png?height=1458&width=2916&h=1458&w=2916&auto=compress)

#### ¿Qué es WARP?

   Es la solución que Nethermind.io propone para migrar de forma sencilla de Solidity a Cairo sin pasar por la curva de aprendizaje que Cairo representa para los Solidity devs.  

   WARP funciona como un transpilador que convierte todo el código Solidity nativo de EVM a código Cairo nativo de Starknet esto permite que los desarrolladores de contratos inteligentes de Solidity puedan migrar y/o escribir contratos en Cairo de una forma sencilla y así tener una incorporación fácil al ecosistema de Starknet.  

#### Instalando WARP en MacOS

> Para esta sección se recomienda tener instalado [brew](https://brew.sh/index_es), un administrador de paquetes como [yarn](https://yarnpkg.com/) y una wallet instalada como [Argent X](https://www.argent.xyz/argent-x/) o [Bravoos](https://braavos.app/).  

1. WARP necesita de otras dependencias para funcionar correctamente
   * Instalar Python version 3.7
   * Instalar z3 con brew brew install z3, ver más sobre z3

2. Seguiremos el Método de instalación 1 de WARP para este tutorial
   * Descargamos el paquete de WARP a nuestra computadora  

    ```bash
      yarn global add @nethermindeth/warp
    ```

   * Verificamos que el paquete se instalo correctamente ejecutando  

    ```bash  
      warp version
    ```

    > Al momento de escribir este post la version es la 2.1.0  
  
   * Instalamos las dependencias  

    ```bash
      warp install
    ```

   * Creamos un nuevo directorio en donde vamos a trabajar el código, en mi caso el directorio será `warp-tutorial` y dentro de este directorio crearé una carpeta llamada `contracts` y en contracts un archivo llamado `ERC20.sol`, para mi contrato en solidity tomaré el código de ejemplo del [repositorio de WARP](https://github.com/NethermindEth/warp/blob/develop/example_contracts/ERC20.sol) y lo pegaré en el archivo que creamos.  

   ![ejemplo](https://mirror.xyz/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2FWRgjG_0seJom-wvESWrD8.png&w=3840&q=90)  

3. Para convertir el código Solidity de nuestro contrato ERC20.sol a Cairo tenemos   que ejecutar el siguiente comando en la terminal desde el directorio `warp-tutorial`:  

   ```bash
     warp transpile contracts/ERC20.sol
   ```

  si todo se transpila correctamente no nos arrojara ningún mensaje en la terminal y se crea un nuevo directorio con nombre: `warp-output` y dentro de este otro con nombre `contracts` que contiene el contrato transpilado a Cairo `ERC20__WC__WARP.cairo`  

   ![Codigo Transpilado](https://mirror.xyz/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2FUwwOXC2Dyd9hhObBMFBPL.png&w=3840&q=90)  

4. Para desplegar el contrato que acabamos de transpilar en la testnet de Staknet alpha-goerli crearemos nuestras variables de entrono con los comandos:  

   ```bash
     export STARKNET_NETWORK= alpha-goerli
     export STARKNET_WALLET= starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount
   ```

Con STARKNET_NETWORK le decimos en que red haremos el deploy de nuestros contratos, para propositos del tutorial lo haremos en la testnet.
Con STARKNET_WALLET usamos una libreria de OpenZeppelin para crear cuentas compratibles con Straknet

5. Crearemos una cuenta nueva desde la terminal con el comando `warp deploy_account`   

***La creación de la cuenta nueva tardó al rededor de 15 minutos en confirmarse la transacción**  

![deploy_account](https://mirror.xyz/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2F-MkdjVNf6kH0sRgAFAc5E.png&w=3840&q=90)  

Esto nos crea una nueva cuenta en la extension de Argent X (en mi caso).  

6. Por último desplegaremos el contrato a la red de pruebas `alpha-goerli` con el comando `warp deploy *ruta_del_contrato.cairo*`  

![deploy_contract](https://mirror.xyz/_next/image?url=https%3A%2F%2Fimages.mirror-media.xyz%2Fpublication-images%2FM8kujDttWvQgMcwrigaT7.png&w=3840&q=90)  

Una vez confirmada la transacción la podemos ver en explorador de bloques.

>  **[Starkscan](https://testnet.starkscan.co/tx/0x0596627fd3f7c5679d5c38aea4396a71e7d5d7ef023638cbbaaa522bd33216d3)**  

---  

### Algunos Errores que sucedieron al crear este tutorial

* [Error de Conexión por los certificados al tratar de desplegar los contratos.](https://github.com/NethermindEth/warp/issues/689)  

* Error al pasarle el parametro de la wallet.  

---   

### Disclaimer

> Actualmente hay features de Solidity que WARP no soporta y algunos de ellos no los planean soportar en un futuro cercano, *[ver lista](https://github.com/NethermindEth/warp#unsupported-solidity-features)*.
