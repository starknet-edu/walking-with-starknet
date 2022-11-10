# Programação no Ethereum L2 (pt. 1): Instalação da Cairo e StarkNet

Este é o primeiro tutorial de uma série centrada no desenvolvimento de contratos inteligentes com Cairo e a StarkNet. Aqui preparamos a nossa máquina para a programação em Cairo; no segundo e terceiro tutoriais revemos as noções básicas da programação do Cairo.

🚀 O futuro do Ethereum é hoje e já está aqui. E é apenas o começo.

---

Aprenderemos a instalar Cairo nas nossas máquinas e a preparar tudo para começar a criar ❤️. Também aprenderemos comandos básicos para interagir com Cairo a partir do nosso terminal.

A documentação do Cairo dá instruções muito claras. No entanto, pode haver excepções dependendo da sua máquina.

## 1. instalação do Cairo

A documentação do Cairo afirma:

Recomendamos trabalhar num ambiente virtual python, mas também se pode instalar directamente o pacote do Cairo. Para criar e entrar no ambiente virtual, digite:

```
python3.7 -m venv ~/cairo_venv 
source ~/cairo_venv/bin/activate
```

Certifique-se de que venv esteja ativado; você deve ver (`cairo_venv`) na linha de comando.

Certifique-se de poder instalar os seguintes pacotes pip: `ecdsa`, `fastecdsa`, `sympy` (usando `pip3 install ecdsa fastecdsa sympy`). No Ubuntu, por exemplo, primeiro você precisa executar: sudo apt install -y libgmp3-dev.

No Mac, você pode usar brew: `brew install gmp`.

Instale o pacote python cairo-lang usando:

```
pip3 install cairo-lang
```

Se tudo correu bem com essas instruções, ótimo 🥳. É muito provável que não tenha sido assim. Instalei o Cairo no Ubuntu e no MacOS e nenhuma instalação funcionou na primeira vez 🙉. Não te preocupes. Se resolve.

### 1.1. MacOS

Se você estiver usando MacOS, provavelmente terá problemas para instalar o `gmp` com o `brew install gmp`. 

Esta resposta a um issue no repositório do Nile tem quatro maneiras diferentes de corrigi-lo:

Eu usei este código no meu terminal e funcionou.

```
CFLAGS=-I`brew --prefix gmp`/include LDFLAGS=-L`brew --prefix gmp`/lib pip install ecdsa fastecdsa sympy
```

Outro artigo muito interessante recomenda a instalação usando o Docker:

```
# instale build tools
xcode-select --install

# instale brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# instale python3.7
brew install python@3.7 git gmp

# instale cairo
python3.7 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate
pip3 install ecdsa fastecdsa sympy cairo-lang

# instale docker: https://docs.docker.com/desktop/mac/install
# pull containers
docker pull shardlabs/starknet-devnet
docker pull trufflesuite/ganache-cli
docker pull eqlabs/pathfinder

# comece ganache
# para ver os logs do ganache: docker logs -f $(docker ps | grep ganache-cli | awk '{print $1}')
docker run -d --rm --network host trufflesuite/ganache-cli

# comece starknet-devnet
# to tail ganache logs: docker logs -f $(docker ps | grep starknet-devnet | awk '{print $1}')
docker run -d --rm --network host shardlabs/starknet-devnet

# pathfinder
# para ver os logs do pathfinder: docker logs -f $(docker ps | grep pathfinder | awk '{print $1}')
git clone https://github.com/eqlabs/pathfinder.git
cd pathfinder; docker build -t pathfinder .
docker run -d --rm --network host -e RUST_LOG=info -e ETH_RPC_URL=https://mainnet.infura.io/v3/<INFURA_ID> pathfinder

# cairo shortcuts
# NOTA: Presume-se que você use zsh
mkdir -p $HOME/cairo_libs
git clone git@github.com:OpenZeppelin/cairo-contracts.git $HOME/cairo_libs
ln -s $HOME/cairo_libs/cairo-contracts/src/openzeppelin $HOME/cairo_libs/openzeppelin
echo 'alias cairodev="python3.7 -m venv ~/cairo_venv; source ~/cairo_venv/bin/activate; export STARKNET_NETWORK=alpha-goerli; export CAIRO_PATH=~/cairo_libs; export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"' >> ~/.zshrc
echo 'alias cairoprod="python3.7 -m venv ~/cairo_venv; source ~/cairo_venv/bin/activate; export STARKNET_NETWORK=alpha-mainnet; export CAIRO_PATH=~/cairo_libs; export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"' >> ~/.zshrc
source ~/.zshrc
```

### 1.2. Ubuntu

O mesmo artigo recomenda a seguinte instalação para o Ubuntu:

```
# system setup
sudo apt update && sudo apt upgrade
sudo apt install -y software-properties-common git curl pkg-config build-essential libssl-dev libffi-dev libgmp3-dev

# instale python3.7
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install -y python3.7 python3.7-dev python3.7-venv python3-pip

# instale cairo
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
```

### 1.3. Windows

Como Cairo e StarkNet estão disponíveis apenas para Ubuntu e MacOS, você teria que usar o subsistema Windows Linux ou um Docker.

## 2. VSCode para o seu Cairo 𓀀

Se você digitar `cairo` no navegador do plug-in VSCode ([aqui](https://code.visualstudio.com/docs/editor/extension-marketplace#:~:text=You%20can%20browse%20and%20install , em %20the%20VS%20Code%20Marketplace.)) tutorial de instalação do plugin) apenas dois aparecerão. estamos começando🚀:

Ambas as extensões são úteis.

* O primeiro, 'Cairo', foi criado pela StarkWare.
* O segundo, `Cairo language support for StarkNet`, foi criado por Eric Lau, que faz parte do Open Zepellin.

Eu recomendo instalar ambos no seu VSCode.

Agora você verá que seu código no Cairo parece muito melhor, é mais fácil de ler e retorna erros em tempo real. Você não precisa esperar para compilar seu código para ver se tem erros   .

Ótimo, sua equipe está pronta para criar com Cairo e StarkNet 🚀.

## 3. Conclusão

Agora sim…

No próximo tutorial vamos aprender o básico do Cairo   . Usaremos tudo o que aprendemos e preparamos aqui. Vamos nos divertir ainda mais.

Nos tutoriais a seguir, aprenderemos mais sobre pointers e gerenciamento de memória; a common library do Cairo; como funciona o compilador do Cairo; e mais!

Quaisquer comentários ou melhorias, por favor, comente com [@espejelomar](https://twitter.com/espejelomar) ou faça um PR 🌈.
