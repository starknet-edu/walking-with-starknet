import functools
import os

from starkware.crypto.signature.signature import get_random_private_key, private_to_stark_key
from starkware.starknet.definitions import fields
from starkware.starknet.core.os.contract_address.contract_address import (
    calculate_contract_address,
)
from starkware.starknet.services.api.contract_class import ContractClass


@functools.lru_cache(maxsize=None)
def get_contract_class(contract_name: str) -> ContractClass:
    main_dir_path = os.path.dirname(__file__)
    file_path = os.path.join(main_dir_path, contract_name + ".json")

    with open(file_path, "r") as fp:
        return ContractClass.loads(data=fp.read())


def get_account_contract_address(stark_signature: bool) -> int:
    # Get private and public keys
    if stark_signature:
        private_key = get_random_private_key()
        public_key = private_to_stark_key(private_key)
    
    salt = fields.ContractAddressSalt.get_random_value()
    contract_address = calculate_contract_address(
        salt=salt,
        contract_class=account_contract,
        constructor_calldata=[public_key],
        deployer_address=0,
    )

    # accounts_for_network[self.account_name] = {
    #     "private_key": hex(private_key),
    #     "public_key": hex(public_key),
    #     "salt": hex(salt),
    #     "address": hex(contract_address),
    #     "deployed": False,
    # }

    # Don't end sentences with '.', to allow easy double-click copy-pasting of the values.
    print(
        f"""\
Account address: 0x{contract_address:064x}
Public key: 0x{public_key:064x}
Move the appropriate amount of funds to the account, and then deploy the account
by invoking the 'starknet deploy_account' command.
NOTE: This is a modified version of the OpenZeppelin account contract. The signature is computed
differently.
"""
    )

    # os.makedirs(name=os.path.dirname(self.account_file), exist_ok=True)
    # with open(self.account_file, "w") as f:
    #     json.dump(accounts, f, indent=4)
    #     f.write("\n")

    return contract_address