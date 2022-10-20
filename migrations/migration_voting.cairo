%lang starknet

from starkware.cairo.common.alloc import alloc

// ---------
// CONSTANTS
// ---------

const VOTING_ADMIN = 0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510;
const NUMBER_VOTING_ADDRESSES = 2;
const VOTING_ADDRESS_1 = 0x02c7e70bbd22095ad396f13e265ef18fc78257957e3f4e7b897cd9b9e8da3e77;
const VOTING_ADDRESS_2 = 0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510;

// Deploy the following migration in the CLI with:
// protostar migrate migrations/migration_voting.cairo --network testnet --private-key-path pkey --account-address 0x02c7e70bbd22095ad396f13e265ef18fc78257957e3f4e7b897cd9b9e8da3e77

@external
func up() {
    %{  
        # Deploy voting contract. Wait for acceptance of in the testnet
        voting_contract_address = deploy_contract(
            contract="./build/vote.json", 
            constructor_args=[ids.VOTING_ADMIN, ids.NUMBER_VOTING_ADDRESSES, ids.VOTING_ADDRESS_1, ids.VOTING_ADDRESS_2],
            config={"wait_for_acceptance": True}
        ).contract_address

        # Assert if calling address can vote. The result from the getter function is a Python dict
        starting_voter_status = call(
                    contract_address=voting_contract_address, 
                    function_name="get_voter_status", 
                    inputs={"user_address": ids.VOTING_ADDRESS_1}
                    )
        assert voter_status.status["allowed"] == 1
        print(f"Voter with address {ids.VOTING_ADDRESS_1} is allowed to vote.")

        # Vote 1 with the address calling the voting contract (see migration code in CLI)
        invoke(
            contract_address=voting_contract_address,
            function_name="vote",
            inputs={"vote": 1},
            config={
                "wait_for_acceptance": True,
                "max_fee": "auto",
            }
        )
        print(f"Voter with address {ids.VOTING_ADDRESS_1} voted.")

        # Assert if calling address can no longer vote
        voter_status = call(
                    contract_address=voting_contract_address, 
                    function_name="get_voter_status", 
                    inputs={"user_address": ids.VOTING_ADDRESS_1}
                    )
        assert voter_status.status["allowed"] == 0
        print(f"Voter with address {ids.VOTING_ADDRESS_1} is not allowed to vote.")

        # Get the status of the vote after initial vote
        voting_status = call(
                    contract_address=voting_contract_address, 
                    function_name="get_voting_status", 
                    )
        assert voting_status.status["votes_yes"] == 1
        assert voting_status.status["votes_no"] == 0
        print(f"Voting status: YES - {voting_status.status["votes_yes"]}; NO - {voting_status.status["votes_no"]}.")
    %}
    return ();
}

@external
func down() {
    %{ assert False, "Not implemented" %}
    return ();
}