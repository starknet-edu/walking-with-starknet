%lang starknet

from starkware.cairo.common.uint256 import Uint256

from src.interfaces.IERC721Custom import IERC721Custom

// ---------
// CONSTANTS
// ---------

const oracle_addr = 111;
const _beacon_address = 222;

// ---------
// INTERFACES
// ---------

@contract_interface
namespace IEvaluator {
    func assigned_legs_number(player_address: felt) -> (legs: felt) {
    }
}

// ---------
// TESTS
// ---------


@external
func __setup__() {
    %{ 
        declared = declare("src/contracts/random721.cairo")
        prepared = prepare(declared, [ids.oracle_addr, ids._beacon_address])
        context.erc721_custom_address = deploy(prepared).contract_address
    %}
    return ();
}

@external
func test_erc721_random_deploy{syscall_ptr: felt*, range_check_ptr}() {

    tempvar erc721_custom_address: felt;

    %{  
        ids.erc721_custom_address = context.erc721_custom_address
    %}

    let (name) = IERC721Custom.name(contract_address=erc721_custom_address);
    let (symbol) = IERC721Custom.symbol(contract_address=erc721_custom_address);
    let (owner) = IERC721Custom.owner(contract_address=erc721_custom_address);
    
    assert NAME = name;
    assert SYMBOL = symbol;
    assert OWNER = owner;

    return ();
}


// Test minting an animal with certain characteristics and get back their characteristics
@external
func test_declare_animals{syscall_ptr: felt*, range_check_ptr}(){
    alloc_locals;
    tempvar erc721_custom_address: felt;

    // Mock call to evaluator contract to get number of legs
    tempvar external_contract_address = 123;

    %{ stop_mock = mock_call(ids.external_contract_address, "assigned_legs_number", [10]) %}
    let (n_legs) = IEvaluator.assigned_legs_number(external_contract_address, OWNER);
    %{ stop_mock() %}

    assert 10 = n_legs;

    // Get ERC721 contract address
    %{  
        ids.erc721_custom_address = context.erc721_custom_address
    %}

    // Declare two animals
    %{ stop_prank_owner = start_prank(ids.OWNER, ids.erc721_custom_address) %}
    let first_animal_token : Uint256 = IERC721Custom.declare_animal(
                                                        contract_address=erc721_custom_address, 
                                                        sex=SEX,
                                                        legs=n_legs,
                                                        wings=WINGS
                                                        );
    let second_animal_token : Uint256 = IERC721Custom.declare_animal(
                                                        contract_address=erc721_custom_address, 
                                                        sex=SEX+1,
                                                        legs=n_legs-1,
                                                        wings=WINGS+1
                                                        );
    %{ stop_prank_owner() %}

    // Assert that the last tokenID minted is 2 and equals "second_animal_token"
    let two_uint : Uint256 = Uint256(2,0);
    let one_uint : Uint256 = Uint256(1,0);
    let last_minted_tokenID : Uint256 = IERC721Custom.get_last_tokenID(
                                                        contract_address=erc721_custom_address
                                                        );
    assert two_uint = last_minted_tokenID;
    assert two_uint = second_animal_token;

    // Assert that the animal characteristics corresponds to the declared ones
    let (local sex, legs, wings) = IERC721Custom.get_animal_characteristics(contract_address=erc721_custom_address, token_id=one_uint);
    assert SEX = sex;
    assert n_legs = legs;
    assert WINGS = wings;

    let (local sex, legs, wings) = IERC721Custom.get_animal_characteristics(contract_address=erc721_custom_address, token_id=two_uint);
    assert SEX+1 = sex;
    assert n_legs-1 = legs;
    assert WINGS+1 = wings;

    return ();
}
