import os
from typing import Sequence, Optional, List

from starkware.cairo.common.hash_state import compute_hash_on_elements
from starkware.cairo.lang.vm.crypto import pedersen_hash
from starkware.python.utils import from_bytes
from starkware.starknet.core.os.class_hash import compute_class_hash
from starkware.starknet.core.os.contract_address.contract_address import (
    calculate_contract_address,
)
from starkware.starknet.services.api.contract_class import ContractClass
from starkware.starknet.services.api.gateway.transaction import InvokeFunction

CONTRACT_ADDRESS_PREFIX = from_bytes(b"STARKNET_CONTRACT_ADDRESS")


# Calculates the pedersen hash of a contract
def calculate_contract_hash(
    salt: int,
    class_hash: int,
    constructor_calldata: Sequence[int],
    deployer_address: int,
) -> int:

    # Hash constructor calldata
    constructor_calldata_hash = compute_hash_on_elements(
        data=constructor_calldata, hash_func=pedersen_hash
    )

    return compute_hash_on_elements(
        data=[
            CONTRACT_ADDRESS_PREFIX,
            deployer_address,
            salt,
            class_hash,
            constructor_calldata_hash,
        ],
        hash_func=pedersen_hash,
    )


# Gets the class of a contract using ContractClass.loads
def get_contract_class(contract_name: str) -> ContractClass:

    with open(contract_name, "r") as fp:
        contract_class = ContractClass.loads(data=fp.read())

    return contract_class


# Gets the address of the account contract
def get_address(
    contract_path_and_name: str,
    salt: int,
    constructor_calldata: Sequence[int],
    deployer_address: int = 0,
    compiled: bool = False,
) -> int:

    # Compile the account contract: must be in cairo environment
    # `compiled_account_contract` looks similar to "build/contract_compiled.json"
    if compiled:
        compiled_account_contract: str = contract_path_and_name
    else:
        os.system(
            f"starknet-compile {contract_path_and_name}.cairo --output {contract_path_and_name}_compiled.json"
        )
        compiled_account_contract: str = f"{contract_path_and_name}_compiled.json"

    # Get contract class
    contract_class = get_contract_class(contract_name=compiled_account_contract)

    # Get contract class hash for information purposes
    class_hash = compute_class_hash(
        contract_class=contract_class, hash_func=pedersen_hash
    )

    contract_address: int = calculate_contract_address(
        salt=salt,
        contract_class=contract_class,
        constructor_calldata=constructor_calldata,
        deployer_address=deployer_address,
    )

    print(
        f"""\
Account contract address: 0x{contract_address:064x}
Class contract hash: 0x{class_hash:064x}
Salt: 0x{salt:064x}
Constructor call data: {constructor_calldata}

Move the appropriate amount of funds to the account. Then deploy the account.
"""
    )

    return contract_address


# def invoke_fn(
#     signer_address: int,
#     calldata: Sequence[int],
#     max_fee: int,
#     nonce: Optional[int],
#     version: int,
#     signature: List[int],
# ):
#     return InvokeFunction(
#         contract_address=signer_address,
#         calldata=calldata,
#         max_fee=max_fee,
#         nonce=nonce,
#         signature=signature
#         version=version,
#     )

