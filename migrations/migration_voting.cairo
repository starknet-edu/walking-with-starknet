%lang starknet

from starkware.cairo.common.alloc import alloc

// ---------
// CONSTANTS
// ---------

const VOTING_ADMIN = 0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510;
const NUMBER_VOTING_ADDRESSES = 2;
const VOTING_ADDRESS_1 = 0x02c7e70bbd22095ad396f13e265ef18fc78257957e3f4e7b897cd9b9e8da3e77;
const VOTING_ADDRESS_2 = 0x02cdAb749380950e7a7c0deFf5ea8eDD716fEb3a2952aDd4E5659655077B8510;

// ---------
// MIGRATION
// ---------

// Deploy the following migration in the CLI with:
// protostar migrate migrations/migration_voting.cairo --network testnet --private-key-path pkey --account-address 0x02c7e70bbd22095ad396f13e265ef18fc78257957e3f4e7b897cd9b9e8da3e77
// protostar migrate migrations/migration_voting.cairo --gateway-url "http://127.0.0.1:5050/" --chain-id "1" --private-key-path pkey --account-address 0x02c7e70bbd22095ad396f13e265ef18fc78257957e3f4e7b897cd9b9e8da3e77
@external
func up() {

    tempvar before_voting_status : felt;
    tempvar after_voting_status : felt;
    tempvar votes_yes : felt;
    tempvar votes_no : felt;

    %{  
        # Deploy voting contract. Wait for acceptance of in the testnet
        voting_contract_address = deploy_contract(
            contract="./build/vote.json", 
            constructor_args=[ids.VOTING_ADMIN, ids.NUMBER_VOTING_ADDRESSES, ids.VOTING_ADDRESS_1, ids.VOTING_ADDRESS_2],
            config={"wait_for_acceptance": True}
        ).contract_address

        # Assert if calling address can vote. The result from the getter function is a Python dict
        voter_status = call(
                    contract_address=voting_contract_address, 
                    function_name="get_voter_status", 
                    inputs={"user_address": ids.VOTING_ADDRESS_1},
                    )
        ids.before_voting_status = voter_status.status["allowed"]
    %}

    // Assert voter is allowed to vote. Print this in next hint
    assert 1 = before_voting_status;

    %{
        from console import fg
        
        print(fg.green, fx.italic, f"Voter with address {ids.VOTING_ADDRESS_1} is allowed to vote.", fx.end, sep='')
        
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
        ids.after_voting_status = voter_status.status["allowed"]
    %}

    // Assert voter is no longer allowed to vote. Print this in next hint
    assert 0 = after_voting_status;

    %{
        print(f"Voter with address {ids.VOTING_ADDRESS_1} is not allowed to vote.")

        # Get the status of the vote after initial vote
        voting_status = call(
                    contract_address=voting_contract_address, 
                    function_name="get_voting_status", 
                    )
        ids.votes_yes = voting_status.status["votes_yes"]
        ids.votes_no = voting_status.status["votes_no"]
    %}

    // Assert we have 1 YES and 0 NOs.
    assert 1 = votes_yes;
    assert 0 = votes_no;
     
    return ();
}

@external
func down() {
    %{ assert False, "Not implemented" %}
    return ();
}