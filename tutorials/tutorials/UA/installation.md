# Програмування на Ethereum's L2 (частина 1): Встановлення Cairo та StarkNet

Це перший туторіал з серії, що допоможе вам почати розробку смарт-контрактів за допомогою Cairo та StarkNet. В цій секції ви знайдете необхідні інструкції для початку роботи з Cairo; в другому і третьому туторіалі, ми розглянемо основи програмування в Cairo.

🚀 Майбутнє Ethereum починається вже зараз, і це лише початок!

---

Ми навчимося встановлювати Cairo на наші пристрої та приготуємося до початку розробки ❤️. Також ми вивчимо базові команди для взаємодії з Cairo через наш термінал.

Офіційна документація Cairo надає нам чіткі інструкції, проте, в залежності від вашого ПК, мождиві деякі помилки.

## 1. Встановлення Cairo

Згідно з документацією Cairo:

Ми рекомендуємо роботу з віртуальним середовищем python, але ви також можете виконати безпосередню установку Cairo. Для створення та входу у віртуальне середовище, виконайте команди:

```
python3.7 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate
```

Переконайтеся що venv активоване; ви маєте побачити (cairo_venv) у командній стрічці терміналу.

Переконайтеся що ви можете встановити наступні pip пакети: ecdsa, fastecdsa, sympy (використовуючи pip3 install ecdsa fastecdsa sympy). Для прикладу на Ubuntu, спочачтку вам потрібно виконати команду: sudo apt install -y libgmp3-dev.

На Mac, ви можете використати brew: 
```
brew install gmp.
```

Встановіть python пакет cairo-lang використовуючи:

```
pip3 install cairo-lang
```

Якщо все пройшло добре- чудово🥳! Але вірогідно ви стикнулися з певними помилками. Я встановлював Cairo на Ubuntu та MacOS, проте в обох випадках мені не вдалося це зробити з першого разу 🙉. Не переживайте, нижче ви побачите вирішення можливих проблем.

### 1.1. MacOS

Якщо ви використовуєте MacOS, скоріше за все у вас виникла проблема при встановленні `gmp` за допомогою `brew install gmp`.


Я використав наступний код з репозиторію Nile, і це вирішило мою проблему.

```
CFLAGS=-I`brew --prefix gmp`/include LDFLAGS=-L`brew --prefix gmp`/lib pip install ecdsa fastecdsa sympy
```
Також є варіант становлення за допомогою Docker:

```
# встановлення build tools
xcode-select --install

# встановлення brew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# встановлення python3.7
brew install python@3.7 git gmp

# встановлення cairo
python3.7 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate
pip3 install ecdsa fastecdsa sympy cairo-lang

# встановлення docker: https://docs.docker.com/desktop/mac/install
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

В тому самому репозиторії були наступні рекомендації з встановлення на Ubuntu:

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

Оскільки Cairo та StarkNet доступні лише для Ubuntu та MacOS, ви маєте встановити Windows Linux subsystem або Docker.

## 2. VSCode для Cairo 𓀀

Якщо ви наберете `cairo` в браузері плагінів для VSCode ([here](https://code.visualstudio.com/docs/editor/extension-marketplace#:~:text=You%20can%20browse%20and%20install,on%20the%20VS%20Code%20Marketplace.)) туторіал по встановленню плагінів) ви отримаєте лише 2 результати. Вони нам і потрібні 🚀:

Обидва плагіни корисні.

* Перший, `Cairo`, був створений безпосередньо StarkWare.
* Другий, `Cairo language support for StarkNet`, був створений Eric Lau з команди Open Zepellin.

Я рекомендую встановити обидва.

Тепер ви побачити що ваш код Cairo виглядає набагато краще, і його набагато простіше читати, а також ви одразу можете бачити помилки синтаксису, не чекаючи на помилки компіляції.

Чудово, тепер ваш ПК готовий до розробки за допомогою Cairo та StarkNet 🚀.

## 3. Заключення

В наступному туторіалі ми навчимося основ Cairo 🥳. І це буде ще цікавіше!

Ми більше дізнаємося про вказівники на управління пам'ятю; загальну бібліотеку Сairo; як працює компілятор Cairo; та багато іншого!

Будь які пропозиції щодо вдосконалення туторіалу надсилайте [@espejelomar](https://twitter.com/espejelomar) або робіть PR 🌈.
