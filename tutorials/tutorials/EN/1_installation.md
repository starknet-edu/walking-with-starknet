# Programming on Ethereum's L2 (pt. 1): Installing Cairo and StarkNet

This is the first tutorial of a series focused on developing smart contracts with Cairo and StarkNet. Here we prepare our team to program in Cairo; in the second and third tutorial we review the basics of programming in Cairo.

🚀 The future of Ethereum is today and it's already here. And it's just the beginning.

---

We are going to learn how to install Cairo on our machines and get everything ready to start creating ❤️. We will also learn basic commands to interact with Cairo from our terminal.

The Cairo documentation gives us very clear instructions. However, there may be exceptions depending on your machine.

## 1. Installing Cairo

The Cairo documentation says:

We recommend working inside a virtual python environment, but you can also install the Cairo package directly. To create and enter the virtual environment, type:

```
python3.7 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate
```

Make sure venv is enabled; you should see (cairo_venv) on the command line.

Make sure you can install the following pip packages: ecdsa, fastecdsa, sympy (using pip3 install ecdsa fastecdsa sympy). On Ubuntu, for example, you'll first need to run: sudo apt install -y libgmp3-dev.

On Mac, you can use brew: 
```
brew install gmp.
```

Install the cairo-lang python package using:

```
pip3 install cairo-lang
```

If all went well with these instructions, great 🥳. It is very likely that this was not the case. I installed Cairo on Ubuntu and MacOS and neither installation came out right away 🙉. Don't worry. It is solve.

### 1.1. MacOS

If you're using MacOS you'll probably have trouble installing `gmp` with `brew install gmp`.

This answer to an issue in the Nile repository has four different ways to fix it:

I used this code in my terminal and it worked.

```
CFLAGS=-I`brew --prefix gmp`/include LDFLAGS=-L`brew --prefix gmp`/lib pip install ecdsa fastecdsa sympy
```
Another very interesting article recommends installing using Docker:

```
# install build tools
xcode-select --install

# install brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install python3.7
brew install python@3.7 git gmp

# install cairo
python3.7 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate
pip3 install ecdsa fastecdsa sympy cairo-lang

# install docker: https://docs.docker.com/desktop/mac/install
# pull containers
docker pull shardlabs/starknet-devnet
docker pull trufflesuite/ganache-cli
docker pull eqlabs/pathfinder

# start ganache
# to see the ganache logs: docker logs -f $(docker ps | grep ganache-cli | awk '{print $1}')
docker run -d --rm --network host trufflesuite/ganache-cli

# start starknet-devnet
# to tail ganache logs: docker logs -f $(docker ps | grep starknet-devnet | awk '{print $1}')
docker run -d --rm --network host shardlabs/starknet-devnet

# pathfinder
# to see the pathfinder logs: docker logs -f $(docker ps | grep pathfinder | awk '{print $1}')
git clone https://github.com/eqlabs/pathfinder.git
cd pathfinder; docker build -t pathfinder .
docker run -d --rm --network host -e RUST_LOG=info -e ETH_RPC_URL=https://mainnet.infura.io/v3/<INFURA_ID> pathfinder

# cairo shortcuts
# NOTE: it is assumed that you use zsh
mkdir -p $HOME/cairo_libs
git clone git@github.com:OpenZeppelin/cairo-contracts.git $HOME/cairo_libs
ln -s $HOME/cairo_libs/cairo-contracts/src/openzeppelin $HOME/cairo_libs/openzeppelin
echo 'alias cairodev="python3.7 -m venv ~/cairo_venv; source ~/cairo_venv/bin/activate; export STARKNET_NETWORK=alpha-goerli; export CAIRO_PATH=~/cairo_libs; export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"' >> ~/.zshrc
echo 'alias cairoprod="python3.7 -m venv ~/cairo_venv; source ~/cairo_venv/bin/activate; export STARKNET_NETWORK=alpha-mainnet; export CAIRO_PATH=~/cairo_libs; export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount"' >> ~/.zshrc
source ~/.zshrc
```

### 1.2. Ubuntu

The same article recommends the following installation for Ubuntu:

```
# system setup
sudo apt update && sudo apt upgrade
sudo apt install -y software-properties-common git curl pkg-config build-essential libssl-dev libffi-dev libgmp3-dev

# install python3.7
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt install -y python3.7 python3.7-dev python3.7-venv python3-pip

# install cairo
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

Since Cairo and StarkNet are only available for Ubuntu and MacOS, you would have to use the Windows Linux subsystem or a Docker.

## 2. VSCode para tu Cairo 𓀀

If you type `cairo` in the VSCode plugin browser ([here](https://code.visualstudio.com/docs/editor/extension-marketplace#:~:text=You%20can%20browse%20and%20install,on%20the%20VS%20Code%20Marketplace.)) tutorial on how to install plugins) only two will appear. We are starting 🚀:

Both extensions are useful.

* The first, `Cairo`, was created by StarkWare.
* The second, `Cairo language support for StarkNet`, was created by Eric Lau who is part of Open Zepellin.

I recommend installing both in your VSCode.

Now you will see that your code in Cairo looks much better, is easier to read and returns errors in real time. You don't have to wait to compile your code to see if it has errors   .

Excellent, your machine is ready to create with Cairo and StarkNet 🚀.

## 3. Conclusion

In the next tutorial we will learn the basics of Cairo 🥳. We will use everything learned and prepared here. We're going to have even more fun.

In the following tutorials we will learn more about pointers and memory management; the cairo common library; how the Cairo compiler works; and more!

Any comments or improvements please comment with [@espejelomar](https://twitter.com/espejelomar) or make a PR 🌈.