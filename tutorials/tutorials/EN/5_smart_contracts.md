# Programming on Ethereum L2 (pt. 5): Creating smart contracts on StarkNet

This tutorial is key for you to start creating and deploying your own smart contracts. That is the goal here.

Before starting, I recommend that you prepare your machine to program in Cairo ❤️ with the [first tutorial](1_installation.md), check out the [Cairo basics pt. 1](2_cairo_basics.md), and [pt. 2](3_cairo_basics.md), and use [Protostar to compile and deploy contracts](4_protostar.md)

This is the fifth tutorial in a series focused on developing smart contracts with Cairo and StarkNet.

🚀 The future of Ethereum is today and it's already here. And it's just the beginning.

---

We will create an application that allows users to vote. The original concept was proposed by [SWMansion](https://github.com/software-mansion-labs/protostar-tutorial) and was extensively modified for this tutorial. For didactic purposes, we are going to show the contract code in parts; the full contract is in [this repository](../../../src/voting.cairo). You can view and interact with the [contract displayed on Voyager](https://goerli.voyager.online/contract/0x01ab2d43fd8fe66f656aafb740f6a368cecb332b5e4e9bbc1983680a17971711). At the end of this tutorial you will have your own contract displayed.

## 1. Structure of a project on StarkNet

Initialize your project with `protostar init` and remember to do the [tutorial on how to use Protostar](4_protostar.md) first. 

Let's start creating standard Cairo code. That is, following the smart contract programming conventions in Cairo. Everything is still very new but the conventions have adopted a style similar to that of Solidity. For example, we will write our entire contract to a file called `voting.cairo`. Therefore the path for our contract is [`src/voting.cairo`](../../../src/voting.cairo).

Within our contract we will follow the following structure, inspired by Solidity and suggested by [0xHyoga](https://hackmd.io/@0xHyoga/Skj7GGeyj), for contract elements:

1. Structs
2. Events
3. Storage variables
4. Constructor
5. Storage Getters
6. Constant functions: functions that do not change state
7. Non-Constant functions: functions that change state

We still don't know what these elements are but don't worry we will learn about all of them in this and the following tutorials. If you have a background in contract creation you will see the similarities with Solidity. For the moment, it is enough for us to know that we will follow this order in our contract.

## 2. Let's vote!

Let's start with the following code (remember that the full contract is in [this repository](../../../src/voting.cairo).). We create two `struct`. The first, `VoteCounting`, will keep track of the votes: the number of votes with “yes” and the number of votes with “no”. The second, `VoterInfo`, indicates whether a voter is allowed to vote. Then we will create storage variables (we will see them later).

- `voting_status`, keeps and updates the vote count.
- `voter_info`, indicates and updates the information of a voter (may or may not vote).
- `registered_voter`, indicates if an address is allowed to vote.

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

We go step by step noting the differences with the programs in Cairo that we have created before. 

We have to declare that we want to deploy our contract on StarkNet. At the beginning of the contract write `%lang starknet`. Unlike the Cairo contracts which are not deployed on StarkNet, we don't have to mention the `builtins` at the beginning of the contract.

We will learn about various StarkNet primitives (marked with an `@`, like Python decorators) that don't exist in pure Cairo. The first is `@storage_var`.

## 3. Contract storage

What is the storage space of a contract? Let's look at the documentation:

> “The storage space of the contract it is a persistent storage space where data can be read, written, modified and preserved. Storage is a map with 2^{251} slots, where each slot is a felt that is initialized to 0.” - StarkNet documentation.

To interact with the contract's storage we create storage variables. We can think of storage variables as pairs of key and values. Think of the concept of a dictionary in Python, for example. We are mapping a key with, possibly several, values.

The most common way to interact with the contract's storage and to create storage variables is with the decorator (yes, just like in Python) `@storage_var`. The methods (functions), `.read(key)`, `.write(key, value)` and `.addr(key)` are automatically created for the storage variable. Let's do an example where we don't have a key but we do have a value (`res`), above we create the storage variable `voting_status`:

```
@storage_var
func voting_status() -> (res : VoteCounting){
}
```

We can then get the value stored in `voting_status()`, a `VoteCounting` struct, with `let (status) = voting_status.read()`. Note that we don't have to provide any arguments to the read as `voting_status()` doesn't require it. Also note that `.read()` returns a tuple so we have to receive it with a `let (variable_name) = …` (we saw this in a previous tutorial). It's the same with `voting_status.addr()` which returns the address in the storage of the storage variable `voting_status`. We do not indicate any argument because it is not required.

To write a new status to our storage variable we use `voting_status.write(new_voting_count)`, where `new_voting_count` is a struct of type `VoteCounting`. What we did was store the new struct inside the storage variable. 

Let's look at a storage variable that has a key (`user_address`) and a value (`res`).

```
@storage_var
func voter_info(user_address: felt) -> (res : VoterInfo){
}
```

With `let (caller_address) = get_caller_address()` and before `from starkware.starknet.common.syscalls import get_caller_address`, we can obtain the address of the account that is interacting with our contract. We ask for caller information: `let (caller_info) = voter_info.read(caller_address)`. If we did not put the address of the caller we would have obtained an error because `voter_info(user_address: felt)` requires a key in felt format, in this case a contract address. Note the difference with `voting_status()` which did not require a key.

We can write with `voter_info.write(caller_address, new_voter_info)`, where `new_voter_info` is a struct of type `VoterInfo`. Here we indicate that for the `caller_address` we have a new `VoterInfo` called `new_voter_info`. We can do the same with a following address. With `voter_info.addr(caller_address)` we get the address where the first element of the value is stored, in this case `VoterInfo`. 

We can also use the functions `storage_read(key)` and `storage_write(key, value)` (imported with `from starkware.starknet.common.syscalls import storage_read, storage_write`) to read the value(s) from a key and write a value(s) to a key, respectively. In fact our `@storage_value` decorator uses these functions below.

## 4. The three most used implicit arguments

Let's move on to the next code snippet of our voting contract (you can find the commented code in the [tutorial repository](../../../src/voting.cairo)). In this section, we'll cover three of the most common implied arguments you'll find in StarkNet contracts. All three are widely used because they are required by the storage variables to write to and read from the contract's storage space. 

We create the inner function `_register_voters` (by default all functions in StarkNet are private, unlike Solidity). With it we will prepare our list of voters. We assume that we have a list of addresses that are allowed to vote. `_register_voters` uses the storage variable `voter_info` to assign each address its voting status: whether it is allowed to vote.

```
func _register_voters{
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

What we notice is the use of three implicit arguments that we had not seen before: `syscall_ptr : felt*`, `pedersen_ptr : HashBuiltin*`, and `range_check_ptr`. All three are pointers; note that they end their name with a `_ptr`.

`syscall_ptr` is used when we make system calls. We include it in `_register_voters` because `write` and `read` need this implicit argument. When reading and writing we are directly consulting the contract's storage and in StarkNet this is achieved by making system calls. It is a pointer to a felt value, `felt*`.

`range_check_ptr` permite que se comparen números enteros. In a subsequent tutorial we will take a closer look at pointers and key builtin functions in StarkNet development. For now it is enough for us to know that the `write` and `read` arguments of the storage variables need to compare numbers; therefore, we need to indicate the implicit `range_check_ptr` argument in any function that reads and writes to the contract's storage using storage variables.

This is a good time to introduce hashes:

> “A hash is a mathematical function that converts an input of arbitrary length into an encrypted output of fixed length. So regardless of the original amount of data or the size of the file involved, your unique hash will always be the same size. Also, hashes cannot be used to "reverse engineer" the input from the hash output, since hash functions are "unidirectionals". (like a meat grinder; you can't put ground beef back into a steak).” - Investopedia.
>

Along with StarkNet Keccak (the first 250 bits of the Keccak256 hash), the Pedersen hash function is one of two hash functions used on StarkNet. `pedersen_ptr` is used when running a Pedersen hash function. We put this pointer in `_register_voters` because storage variables perform a Pedersen hash to calculate their memory address.

The implicit argument `pedersen_ptr` is a pointer to a HashBuiltin struct defined in the [Cairo common library](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/cairo/common/cairo_builtins.cairo):

```
struct HashBuiltin {
    x: felt,
    y: felt,
    result: felt,
}
```

## 5. Handling errors in Cairo

Inside a function we can mark an error in the contract if a condition is false. For example, in the following code the error would be raised because `assert_nn(amount)` is false (`assert_nn` checks if a value is non-negative). If `amount` were 10 then `assert_nn(amount)` would be true and the error would not be raised.

```
let amount = -10

with_attr error_message(
            "Quantity should be positive. You have: {amount}."):
        assert_nn(amount)
    end
```

We will create a function, `_assert_allowed`, which will check if a certain voter is allowed to vote and if not, it will return an error.

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

We import `assert_not_zero`. The error will return a message if `assert_not_zero(info.allowed)` is false. Remember that if a voter is allowed to vote then `info.allowed` will be 1.

## 6. External functions and view

Let's move on to the main function of our application. We write a function that takes as an explicit argument a vote (1 or 0) and then updates the total vote count and the state of the voter so that they cannot vote again.

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

In the `common.syscalls` library ([link to repo](https://github.com/starkware-libs/cairo-lang/blob/master/src/starkware/starknet/common/syscalls.cairo)) we found useful functions to interact with the system. For example, above we used `get_caller_address` to get the address of the contract that is interacting with ours. Other interesting functions are `get_block_number` (to get the number of the block) or `get_contract_address` to get the address of our contract. Later we will use more functions of this library.

The next new thing is the `@external` decorator used on the `vote` function. Note that we haven't created any `main` functions like we did with just Cairo. It's because StarkNet doesn't use the `main` function! Here we use `external` and `view` functions to interact with the contracts. 

**External functions**. Using the `@external` decorator we define a function as external. Other contracts (including accounts) can interact with externals functions; read and write. For example, our `vote` function can be called by other contracts to cast a vote of 1 or 0; then `vote` will write to the storage of the contract. For example, with `voter_info.write(caller, updated_info)` we are writing to the storage variable `voter_info`. That is, we are modifying the state of the contract. Here's the key difference from `view` functions (we'll get to that later), in writing power; change the status of the contract.

## 7. Getter functions

Let's write functions that allow other contracts (including accounts) to check the status of the current vote. These functions that allow you to check the state are called `getters`. First, we create a getter, `get_voting_status`, which returns the current status of the vote, that is, it returns a struct `VoteCounting` with the total vote count. Next, we create the getter `get_voter_status` which returns the status of a particular address (voter) (whether they have already voted or not). Review the [final contract](../../../src/voting.cairo) to see other added getter functions.

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

**View functions.** Using the `@view` decorator we define a function as view. Other contracts (including accounts) can read from the contract status; they cannot modify it (note that externals can modify it). Reading from storage does not cost gas!

Note that in Solidity the compiler creates getters for all state variables declared as public, in Cairo all storage variables are private. Therefore, if we want to make the storage variables public, we must make a getter function ourselves.

## 8. Constructors

Constructor functions are used to initialize a StarkNet application. We define them with the `@constructor` decorator. It receives the inputs that our contract needs to be displayed and performs the necessary operations to start operating with the contract. As an example, our contract needs to have a voting administrator and a list of addresses that can vote (not everyone can vote for a president). All the mechanism of our application is ready, it only needs to be given the inputs it requires to start working.

Beware, Cairo only supports **1 constructor per contract**.

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

In the constructor we are indicating that we require 3 inputs to initialize the contract:

* `admin_address: felt` - The address of the voting administrator contract. This contract may, for example, pause voting if necessary. You can add it in hex or felt format (and it will end up being converted to felt anyway).
* `registered_addresses_len: felt` - This value is the length of the array of addresses that can vote. For example, if 10 addresses can participate in the vote then it will be 10.
* `registered_addresses: felt*` - An array with the addresses that can vote. Arrays are entered one after the other without a comma, for example, `0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510 0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8512`.

We can now see our contract! In your terminal run:

```
protostar deploy ./build/vote.json --network testnet --inputs <admin_address> <registered_addresses_len> <registered_addresses>
```

With actual values: 

```
protostar deploy ./build/vote.json --network testnet --inputs 111 2 222 333
```

Put your address as the admin of the contract and invite your DAO to vote on-chain with really low costs.

## 9. Conclusion

Congratulations. You already know how to create smart contracts on StarkNet. At this point you can attend any hackathon and create your own L2 programs.

We are just getting started!