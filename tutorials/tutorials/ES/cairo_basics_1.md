
Programando en la L2 de Ethereum: Básicos de Cairo pt. 1

🚀 El futuro de Ethereum es hoy y ya está aquí. Vamos a aprender a usar un ecosistema:

- Sostiene a dYdX, DeFi que ya hizo cuatrocientos billones de trades y representa alrededor de un cuarto del total de las transacciones hechas en ethereum. Funcionan apenas desde hace 18 meses y constantemente vencen a Coinbase en volumen de trades. Redujeron el precio de las transacciones de 500 a 1,000 veces. Son tan baratas que no necesitan cobrar el gas a los usuarios 💸.

- En la semana del 7 al 13 de marzo de 2022, por primera vez, logró tener 33% más transacciones que Ethereum 💣.

Y apenas es el comienzo. Aprende un poco más sobre el ecosistema de Starkware en este texto corto. Únete al mayor Meetup de habla hispana sobre StarkNet. Saluda en el el canal #🌮-español en el Discord de StarkNet.

---

Vamos a aprender a cómo instalar Cairo en nuestras máquinas y a dejar todo listo para comenzar a programar ❤️. También aprenderemos comandos básicos para interactuar con Cairo desde nuestra terminal.

La documentación de Cairo nos da instrucciones muy claras. Sin embargo, puede haber excepciones según tu máquina.

## 1. Instalando Cairo

La documentación de Cairo dice:

Recomendamos trabajar dentro de un entorno virtual de python, pero también puedes instalar el paquete de Cairo directamente. Para crear e ingresar al entorno virtual, escriba:

python3.7 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate

Asegúrate de que venv esté activado; deberías ver (cairo_venv) en la línea de comando.

Asegúrate de poder instalar los siguientes paquetes de pip: ecdsa, fastecdsa, sympy (usando pip3 install ecdsa fastecdsa sympy). En Ubuntu, por ejemplo, primero deberá ejecutar: sudo apt install -y libgmp3-dev.

En Mac, puedes usar brew: brew install gmp.

Instala el paquete de Python cairo-lang usando:

pip3 install cairo-lang

Si todo te salió bien con estas instrucciones, excelente 🥳. Es muy probable que no haya sido así. Yo instalé Cairo en Ubuntu y en MacOS y ninguna instalación salió a la primera 🙉. No te preocupes. Se resuelve.

1.1. MacOS

Si estás usando MacOS es probable que tengas problemas para instalar gmp con brew install gmp. Esta respuesta a un issue en el repositorio de Nile tiene cuatro formas diferentes de solucionarlo:

Yo usé CFLAGS=-I`brew --prefix gmp`/include LDFLAGS=-L`brew --prefix gmp`/lib pip install ecdsa fastecdsa sympy en mi terminal y funcionó de maravilla.

Otro artículo muy interesante recomienda instalar usando Docker:


# instala build tools
xcode-select --install

# instala brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# instala python3.7
brew install python@3.7 git gmp

# instala cairo
python3.7 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate
pip3 install ecdsa fastecdsa sympy cairo-lang

# instala docker: https://docs.docker.com/desktop/mac/install
# pull containers
docker pull shardlabs/starknet-devnet
docker pull trufflesuite/ganache-cli
docker pull eqlabs/pathfinder

# comienza ganache
# para ver los logs de ganache: docker logs -f $(docker ps | grep ganache-cli | awk '{print $1}')
docker run -d --rm --network host trufflesuite/ganache-cli

# comienza starknet-devnet
# to tail ganache logs: docker logs -f $(docker ps | grep starknet-devnet | awk '{print $1}')
docker run -d --rm --network host shardlabs/starknet-devnet

#  pathfinder
# para ver los logs de pathfinder: docker logs -f $(docker ps | grep pathfinder | awk '{print $1}')
git clone https://github.com/eqlabs/pathfinder.git
cd pathfinder; docker build -t pathfinder .
docker run -d --rm --network host -e RUST_LOG=info -e ETH_RPC_URL=https://mainnet.infura.io/v3/<INFURA_ID> pathfinder

# cairo shortcuts
# NOTA: se asume que usas zsh
mkdir -p $HOME/cairo_libs
git clone git@github.com:OpenZeppelin/cairo-contracts.git $HOME/cairo_libs
ln -s $HOME/cairo_libs/cairo-contracts/src/openzeppelin $HOME/cairo_libs/openzeppelin
echo 'alias cairodev="python3.7 -m venv ~/cairo_venv; source ~/cairo_venv/bin/activate; export STARKNET_NETWORK=alpha-goerli; export CAIRO_PATH=~/cairo_libs; export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"' >> ~/.zshrc
echo 'alias cairoprod="python3.7 -m venv ~/cairo_venv; source ~/cairo_venv/bin/activate; export STARKNET_NETWORK=alpha-mainnet; export CAIRO_PATH=~/cairo_libs; export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"' >> ~/.zshrc
source ~/.zshrc

1.2. Ubuntu

El mismo artículo recomienda la siguiente instalación para Ubuntu:

# system setup
sudo apt update && sudo apt upgrade
sudo apt install -y software-properties-common git curl pkg-config build-essential libssl-dev libffi-dev libgmp3-dev

# instala python3.7
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install -y python3.7 python3.7-dev python3.7-venv python3-pip

# instala cairo
python3.7 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate
pip3 install ecdsa fastecdsa sympy cairo-lang

# cairo shortcuts
mkdir -p $HOME/cairo_libs
git clone git@github.com:OpenZeppelin/cairo-contracts.git $HOME/cairo_libs
ln -s $HOME/cairo_libs/cairo-contracts/src/openzeppelin $HOME/cairo_libs/openzeppelin
echo 'alias cairodev="python3.7 -m venv ~/cairo_venv; source ~/cairo_venv/bin/activate; export STARKNET_NETWORK=alpha-goerli; export CAIRO_PATH=~/cairo_libs; export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"' >> ~/.bashrc
echo 'alias cairoprod="python3.7 -m venv ~/cairo_venv; source ~/cairo_venv/bin/activate; export STARKNET_NETWORK=alpha-mainnet; export CAIRO_PATH=~/cairo_libs; export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"' >> ~/.bashrc
source ~/.bashrc

1.3. Windows

🧐 … 🧐

2. VSCode para tu Cairo 𓀀

Si escribes cairo en el buscador de plugins de VSCode (aquí tutorial sobre cómo instalar plugins) te aparecerán solo dos. Estamos comenzando 🚀:

Ambas extensiones son útiles.

La primera, Cairo, fue creada por StarkWare.

La segunda, Cairo language support for StarkNet, fue creada por Eric Lau quien es parte de Open Zepellin.

Recomiendo instalar ambas en tu VSCode.

Ahora verás que tu código en Cairo se ve mucho mejor, es más fácil de leer y te retorna errores en tiempo real. No tienes que esperar a compilar tu código para observar si tiene errores 🥳.

3. Compila y corre tu código de Cairo 𓀀

Las herramientas que ofrece StarkNet para interactuar con la línea de comando son muchas 🙉. No entraremos en detalle hasta más adelante. Por ahora, solo mostraremos los comandos con los que podremos correr la aplicación que haremos en el siguiente tutorial 🧘‍♀️. Pero no te preocupes, los comandos para correr otras aplicaciones serán muy similares.

cairo-compile nos permite compilar nuestro código y exportar un json que leeremos en el siguiente comando. Si tenemos un programa llamado array_sum.cairo y queremos que el json se llame x.json entonces usaríamos el siguiente código:

cairo-compile array_sum.cairo --output x.json

Sencillo, cierto? ❤️

Ok ahora corramos nuestro código con cairo-run.

cairo-run --program=x.json
    --print_output --layout=small

Aquí los detalles:

Indicamos en el argumento --program que queremos correr el x.json que generamos antes.

Con --print_output indicamos que queremos imprimir algo de nuestro programa en la terminal. Por ejemplo, en el siguiente tutorial usaremos el builtin (más adelante los estudiaremos) output y la función serialize_word para imprimir en la terminal.

--layout nos permite indicar el layout a utilizar. Según los builtins que utilicemos, será el layout a utilizar. Más adelante estaremos usando el builtin output y para esto necesitamos el layout small. Abajo una foto de los builtins que cubre el layout small. Si no usaremos ningún builtin entonces podemos dejar este argumento vacío por lo que usaríamos el layout default, el plain.

Ahora sí…

En el siguiente tutorial aprenderemos los básicos de Cairo 🥳. Usaremos todo lo aprendido y preparado aquí. Nos vamos a divertir aún más.

En los siguientes tutoriales aprenderemos más sobre los pointers y el manejo de la memoria; la common library de cairo; cómo funciona el compilador de Cairo; y más!

Cualquier comentario o mejora por favor comentar con @espejelomar 🌈.