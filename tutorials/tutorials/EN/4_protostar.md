# Programming on the Ethereum's L2 (pt. 4): Protostar and deploying contracts

Before starting, I recommend that you prepare your machine to program in Cairo ❤️ with the [first tutorial](1_installation.md), and review the [Cairo Basics pt. 1](2_cairo_basics.md) and [pt. 2](3_cairo_basics.md).

This is the fourth tutorial in a series focused on developing smart contracts with Cairo and StarkNet.

🚀 The future of Ethereum is today and it's already here. And it's just the beginning.

---

> “StarkNet is a permissionless decentralized ZK-Rollup operating as an L2 network over Ethereum, where any dApp can achieve unlimited scale for its computation, without compromising Ethereum’s composability and security.” - [StarkNet Documentation](https://starknet.io/docs/hello_starknet/index.html#hello-starknet).

Congratulations! 🚀 We already have an intermediate level from Cairo. Cairo is to StarkNet what Solidity is to Ethereum. It's time to deploy our contracts on StarkNet. We will also learn how to use [Protostar](https://github.com/software-mansion/protostar), tool inspired by [Foundry](https://github.com/foundry-rs/foundry) and key to compile, tests and deploy. 

We are currently able to operate with the StarkNet Alpha. The recommended steps for deploying contracts are:

1. Unit tests - Protostar.
2. Devnet - [Shard Lab’s](https://github.com/Shard-Labs/starknet-devnet) `starknet-devnet` (reviewed here).
3. Testnet - Alpha Goerli, `alpha-goerli` (reviewed here).
4. Mainnet - Alpha StarkNet, `alpha-mainnnet`.

In this tutorial we will learn how to deploy contracts to the devnet and the testnet. In a following text we will learn how to create unit tests with Protostar; and to interact with the devnet and testnet.

Let's get started!

---

## 1. Installing Protostar

At this point we already have `cairo-lang` installed. If not, you can check [our tutorial](1_installation.md) about how to install it. 

On Ubuntu or MacOS (not available for Windows) run the following command:

`curl -L https://raw.githubusercontent.com/software-mansion/protostar/master/install.sh | bash`

Restart your terminal and run `protostar -v` to see the version of your `protostar` and `cairo-lang`.

If you later want to upgrade your protostar use `protostar upgrade`. If you run into installation problems I recommend that you review the [Protostar documentation](https://docs.swmansion.com/protostar/docs/tutorials/installation).

## 2. First steps with Protostar

What does it mean to initialize a project with Protostar?

- **Git**. A new directory (folder) will be created which will be a git repository (it will have a `.git` file).
- `protostar.toml`. Here we will have information necessary to configure our project. Do you know Python? Well you know where we're going with this.
- **Three src directories will be created** (where will your code be), lib (for external dependencies), and tests (where the tests will be).

You can initialize your project with the `protostar init` command, or you can indicate that an existing project will use Protostar with `protostar init --existing`. Basically, you just need your directory to be a git repository and have a `protostar.toml` file with the project settings. We could even create the `protostar.toml` file ourselves from our text editor.

Let's run `protostar init` to initialize a Protostar project. It asks us to indicate two things:

- `project directory name`: What is the name of the directory where your project is located?
- `libraries directory name`: What is the name of the directory where external dependencies will be installed?

This is what the structure of our project looks like:

```
❯ tree -L 2
.
├── lib
├── protostar.toml
├── src
│   └── main.cairo
└── tests
    └── test_main.cairo
```

- Initially, information about the version of protostar used is found here `[“protostar.config“]`, where the external libraries used will be found.

## 3. Installing external dependencies (libraries)

Protostar uses git submodules to install external dependencies. Soon it will be done with a package manager. Let's install a couple of dependencies.

Installing `cairo-contracts` we indicate the repository where they are, that is, [github.com/OpenZeppelin/cairo-contracts](http://github.com/OpenZeppelin/cairo-contracts). Let's use `protostar install`:

`protostar install https://github.com/OpenZeppelin/cairo-contracts`

Let's install one more dependency, `cairopen_contracts`:

`protostar install https://github.com/CairOpen/cairopen-contracts`

Our new dependencies are stored in the `lib` directory:

```
❯ tree -L 2
.
├── lib
│   ├── cairo_contracts
│   └── cairopen_contracts
├── protostar.toml
├── src
│   └── main.cairo
└── tests
    └── test_main.cairo
```

Finally, add the following section to `protostar.toml`:

```
["protostar.shared_command_configs"]
cairo-path = ["lib/cairo_contracts/src", "lib/cairopen_contracts/src"]
```

This allows Protostar to use those paths to find the libraries of interest. When you import, for example `from openzeppelin.access.ownable.library import Ownable`, Protostar will look for `Ownable` in the path `lib/cairo_contracts/src/openzeppelin/access/ownable/library`. If you change the name of the directory where you store your external dependencies then you would not use `lib` but the name of that directory.

Wonderful!

## 4. Compiling

In the past we have been compiling our contracts with `cairo-compile`. When we run `cairo-compile sum2Numbers.cairo --output x.json` to compile a Cairo `sum2Numbers.cairo` contract, the result is a new file in our working directory called `x.json`. The json file is used by `cairo-run` when we run our program.

In Protostar we can compile all our StarkNet contracts at once with `protostar build`. But first we must indicate in the `[“protostar.contracts”]` section of `protostar.toml` the contracts we want to compile (or build). Imagine we have a `ERC721MintableBurnable.cairo` contract in our `src` folder (where the contracts are).

> Note: You will not be able to compile pure Cairo code using `protostar build`. It is only for StarkNet contracts (they have the `%lang starknet` signal at the beginning). To compile and run pure Cairo applications you need to use `cairo-compile` and `cairo-run` ([see Cairo tutorial](3_cairo_basics.md). In following tutorials we will learn how to create StarkNet contracts.

We put in `protostar.toml` that we want to compile the contract in `src/ERC721MintableBurnable.cairo` and that we want to call it `ERC721_original`:

```
["protostar.contracts"]
ERC721_original = [
    "src/ERC721MintableBurnable.cairo",
]
```
We run `protostar build`. We will see that we have a new `build` directory with an `ERC721MintableBurnable.json` file. This is what we were looking for!

Moral: if your contract is not in the `[“protostar.contracts“]` section of `protostar.toml` it will not be compiled.

At this point we can move on to deploying StarkNet contracts with Protostar.

## 5. The devnet: starknet-devnet

Transactions on the testnet take time to complete so it's best to start developing and testing locally. We will use the [devnet developed by Shard Labs](https://github.com/Shard-Labs/starknet-devnet). We can think of this step as an equivalent of Ganache. That is, it emulates the testnet (alpha goerli) of StarkNet. 

Install using:

`pip install starknet-devnet`

Restart your terminal and run `starknet-devnet --version` to check that the installation was successful. Check that you have [the most up-to-date version](https://github.com/Shard-Labs/starknet-devnet/releases). If you don't have it then run `pip install --upgrade starknet-devnet`.

Initialize the devnet in a separate shell (or tab) with `starknet-devnet --accounts 3 --gas-price 250 --seed 0`:

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

You can run `curl http://127.0.0.1:5050/is_alive` to check if the devnet is active. If it is active you will receive `Alive!!!%` back.

With this we are indicating that we will create three accounts and that the transactions will cost 250 wei per gas. We put a number in seed to have the same accounts every time we activate our devnet. These accounts are based on the code and standards developed by [Open Zepellin for Cairo](https://github.com/OpenZeppelin/cairo-contracts/tree/v0.2.1).

It is key that we have at hand the address where our devnet is running. In the photo above it is: `http://127.0.0.1:5050/`. We will use it later.

The interaction with the devnet and the testnet is very similar. If you want to see all the arguments available in the `starknet-devnet` call you can call `starknet-devnet --help`.

## 6. Deploying to the devnet and testnet

Let's use a real example. When we initialize a Protostar project, a `main.cairo` contract is automatically created in the `src` directory. You can use it as an example of a contract to deploy to the devnet and then to the testnet. You just need to make sure that in `protostar.toml` you define what will be compiled. In this tutorial we are going to deploy a contract for an ERC721 (NFT) found in [this repository](../../../src/ERC721MintableBurnable.cairo). In `protostar.toml` we place:

```
["protostar.contracts"]
ERC721_original = [
    "src/ERC721MintableBurnable.cairo",
]
```
Run `protostar build` to compile and create the `build/ERC721_original.json` that we will use for deployment.

To deploy our contracts on the devnet from Protostar we can create configuration profiles. In the `protostar.toml` we create a section `[profile.devnet.protostar.deploy]` where we put the url where we deploy our devnet locally: `gateway-url=”http://127.0.0.1:5050/”` and `chain-id="1"`. For the testnet the section would be `[profile.testnet.protostar.deploy]` and we put `network="testnet"`.

```
[profile.devnet.protostar.deploy]
gateway-url="http://127.0.0.1:5050/"
chain-id="1"

[profile.testnet.protostar.deploy]
network="testnet"
```

For the devnet we run:

```
protostar -p devnet deploy ./build/ERC721.json --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536
```

For the testnet we run:

```
protostar -p testnet deploy build/ERC721_original.json --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536
```

Everything is intuitive, except perhaps:
- `-p` refers to the profiles we created in `protostar.toml`
- `--inputs` are the constructor arguments for the contract we are deploying. Don't worry in the next tutorial we learn what a constructor is. In this case the ERC721 constructor asks us for three felts (`name`, `symbol` and `owner`).

We could also deploy without the help of the profiles in `protostar.toml`. In the case of the testnet it can be efficient because we just add `--network testnet`:

```
protostar deploy ./build/ERC721.json --network testnet --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536
```

But in the case of the devnet we would have to add two arguments so perhaps the profiles are more convenient:

```
protostar deploy ./build/ERC721.json --gateway-url "http://127.0.0.1:5050/" --chain-id "1" --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536
```

When we deploy to the devnet or testnet we get the contract address and the transaction hash:

```
Contract address: 0x002454c7b1f60f52a383963633dff767fd5372c43aad53028a5a8a2b9e04646d
Transaction hash: 0x05a2f78261444b97b155417a5734210abe2ee1081b7f12f39f660321fd10e670
```

It is important to save the contract address as we will interact with it in following functions. We will review this in other tutorials.

If you deployed to the testnet you can use the contract address to interact with your contract in an block explorer: [Voyager](https://goerli.voyager.online/) or [StarkScan](https://testnet.starkscan.co/). These block explorers are equivalent to [Etherscan](https://goerli.voyager.online/) for L1.

The advantage of deploying to the devnet first is that we can interact more quickly with our contracts. For the testnet we will have to wait about a few minutes.

## 7. Deploying with the `starknet` CLI

Below, Protostar is using the `starknet` CLI to deploy. There are times when we don't want to fully depend on Protostar, for example when there is an update from StarkNet and it hasn't been applied to the Protostar library yet.

We will explore the `starknet` CLI in more detail later. For now let's see how to deploy the exact same contract.

For the devnet, once you turned it on at the gateway http://127.0.0.1:5050, it would be:

```
starknet deploy --contract ./build/ERC721_original.json --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536 --gateway_url "http://127.0.0.1:5050" --no_wallet
```

For the testnet:

```
starknet deploy --contract ./build/ERC721_original.json --inputs 27424471826656371 4279885 1268012686959018685956609106358567178896598707960497706446056576062850827536 --network alpha-goerli --no_wallet
```

In both cases we get the contract address and the transaction hash; same as deploying with Protostar.

## 8. Conclusion

Congratulations 🦾. You've just taken your first steps on StarkNet! You are taking advantage of everything learned in the past tutorials on Cairo.

In the following tutorials we will learn more about creating smart contracts on StarkNet 🚀.

Any comments or improvements please comment with [@espejelomar](https://twitter.com/espejelomar) 🌈.