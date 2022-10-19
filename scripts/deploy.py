from starknet_py.net import AccountClient, KeyPair
from starknet_py.net.models.chains import StarknetChainId
from starknet_py.net.gateway_client import GatewayClient
from starknet_py.contract import Contract

import asyncio
from typing import List, Optional
from console import fg




OWNER_ADDRESS = "0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510" 
NETWORK = "tesnet"
CHAIN_ID = StarknetChainId.TESTNET
DEVNET = ""
TESTNET_ACCOUNT = {"ADDRESS" : 0, "PUBLIC" : 0, "PRIVATE" : 0}
VOTING_CONTRACT = "src/voting.cairo"
# VOTING_CONSTRUCTOR_ARGS = {
#     "admin_address": "0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510", 
#     "registered_addresses_len": "1",
#     "registered_addresses": "0x02c7e70bbd22095ad396f13e265ef18fc78257957e3f4e7b897cd9b9e8da3e77" 
# }
VOTING_CONSTRUCTOR_ARGS = {
    "admin_address": 0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510, 
    # "registered_addresses_len": 1,
    "registered_addresses": [1,0x02c7e70bbd22095ad396f13e265ef18fc78257957e3f4e7b897cd9b9e8da3e77] 
}
# VOTING_CONSTRUCTOR_ARGS = dict(
#     admin_address=0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510,
#     registered_addresses_len=1,
#     registered_addresses=0x02c7e70bbd22095ad396f13e265ef18fc78257957e3f4e7b897cd9b9e8da3e77
# )


# from starknet_py.net.networks import TESTNET

# Use testnet for playing with Starknet
# testnet_client = GatewayClient(TESTNET)
# or

## Connect to the testnet
client = GatewayClient(NETWORK)

# Creates an account on testnet and returns an instance
async def deploy_account_contract(client, contract: str, constructor_args: Optional[List[str]] = None):
    # acc_client = await AccountClient.create_account(
    #     client=client, chain=StarknetChainId.TESTNET
    #     )
    acc_client = AccountClient(
        client=client,
        address=TESTNET_ACCOUNT["ADDRESS"],
        key_pair=KeyPair(private_key=TESTNET_ACCOUNT["PRIVATE"], public_key=TESTNET_ACCOUNT["PUBLIC"]),
        chain=StarknetChainId.TESTNET,
        supported_tx_version=1
        )

    deployment_result = await Contract.deploy(
        client=acc_client, compilation_source=[contract], constructor_args=constructor_args
        )
    
    # Wait until deployment transaction is accepted
    res = await deployment_result.wait_for_acceptance()

    fg.cyan.print(f"Deployment Initialized: 0x{hex(deployment_result.hash)}")
    fg.cyan.print("\tWaiting for successful deployment...")
    fg.cyan.print("\tPatience is bitter, but its fruit is sweet...\n")

    return acc_client, res.deployed_contract.address


async def main():
    registry, reg_addr = await deploy_account_contract(
        client=client,
        contract=VOTING_CONTRACT,
        constructor_args=VOTING_CONSTRUCTOR_ARGS,
    )
    fg.blue.print("\tRegistry - 0x{:x}".format(reg_addr))

asyncio.run(main())

# # Deploy an example contract which implements a simple k-v store. Deploy transaction is not being signed.
# async def deploy_contract():
#     deployment_result = await Contract.deploy(
#         client=acc_client, compilation_source=VOTING_CONTRACT, constructor_args=VOTING_CONSTRUCTOR_ARGS
#         )


# account_client_testnet = AccountClient(
#     client=testnet_client,
#     address=TESTNET_ACCOUNT["ADDRESS"],
#     key_pair=KeyPair(private_key=TESTNET_ACCOUNT["PRIVATE"], public_key=TESTNET_ACCOUNT["PUBLIC"]),
#     chain=StarknetChainId.TESTNET,
#     supported_tx_version=0,
# )

# account_client = await AccountClient.create_account(
#     client=testnet_client, chain=StarknetChainId.TESTNET
# )


# Local network
# local_network_client = GatewayClient("http://localhost:5000")

# call_result = await testnet_client.get_block(
#     "0x495c670c53e4e76d08292524299de3ba078348d861dd7b2c7cc4933dbc27943"
# )

