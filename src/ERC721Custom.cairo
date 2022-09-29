// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.4.0b (token/erc721/presets/ERC721MintableBurnable.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_not_zero


from openzeppelin.access.ownable.library import Ownable
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.token.erc721.library import ERC721


//
// Structs
//
struct Animal{
    sex : felt,
    legs : felt,
    wings : felt,
}

//
// Storage
//
@storage_var
func animal_characteristics(token_id: Uint256) -> (animal : Animal) {
}

@storage_var
func last_tokenID() -> (token_id: Uint256) {
}

@storage_var
func breeders(address: felt) -> (is_breeder: felt) {
}


//
// Constructor
//

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    name: felt, symbol: felt, owner: felt
) {
    ERC721.initializer(name, symbol);
    Ownable.initializer(owner);
    // declare last token equals 0
    last_tokenID.write(Uint256(0,0));
    // stablish owner as a breeder
    breeders.write(owner, 1);
    return ();
}

//
// Getters
//

@view
func is_breeder{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    account: felt
) -> (is_approved: felt){
    let is_approved :felt = breeders.read(account);
    return(is_approved=is_approved);
}

@view
func get_animal_characteristics{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    token_id: Uint256
) -> (sex: felt, legs: felt, wings: felt) {
    tempvar sex : felt;
    tempvar legs : felt;
    tempvar wings : felt;

    let (animal : Animal) = animal_characteristics.read(token_id=token_id); 
    
    return (sex=animal.sex, legs=animal.legs, wings=animal.wings);
    }

@view
func get_last_tokenID{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (tokenID: Uint256) {
    let last_token : Uint256 = last_tokenID.read();
    return (tokenID=last_token);
}

@view
func supportsInterface{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    interfaceId: felt
) -> (success: felt) {
    return ERC165.supports_interface(interfaceId);
}

@view
func name{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (name: felt) {
    return ERC721.name();
}

@view
func symbol{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (symbol: felt) {
    return ERC721.symbol();
}

@view
func balanceOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    balance: Uint256
) {
    return ERC721.balance_of(owner);
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(tokenId: Uint256) -> (
    owner: felt
) {
    return ERC721.owner_of(tokenId);
}

@view
func getApproved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (approved: felt) {
    return ERC721.get_approved(tokenId);
}

@view
func isApprovedForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    owner: felt, operator: felt
) -> (isApproved: felt) {
    let (isApproved: felt) = ERC721.is_approved_for_all(owner, operator);
    return (isApproved=isApproved);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    tokenId: Uint256
) -> (tokenURI: felt) {
    let (tokenURI: felt) = ERC721.token_uri(tokenId);
    return (tokenURI=tokenURI);
}

@view
func owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    return Ownable.owner();
}

//
// Externals
//

@external
func register_me_as_breeder{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (is_added: felt){
    let (new_breeder_address) = get_caller_address();
    breeders.write(
            address=new_breeder_address,
            value=1);
    return (is_added=1);
}

// Store in animal_characteristics characteristics of new animal
// Updates last_tokenID to new ID 

// @dev Mints a new animal with defined characteristics. Limitation: The caller will be owner
// @implicit range_check_ptr (felt)
// @implicit syscall_ptr (felt*)
// @implicit pedersen_ptr (HashBuiltin*)
// @param sex (felt): Sex of the declared animal
// @param legs (felt): Number of legs of the declared animal
// @param wings (felt): Number of wings of the declared animal
// @return token_id (Uint256): Token assigned to the minted animal
@external
func declare_animal{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    sex: felt, legs: felt, wings: felt) -> (token_id: Uint256) {
    
    alloc_locals;

    _assert_only_breeder();

    // Define the token ID corresponding to the newly minted animal
    let last_token : Uint256 = last_tokenID.read();
    let one_uint : Uint256 = Uint256(1,0);
    let (local new_tokenID, _ ) = uint256_add(a=last_token, b=one_uint);
    last_tokenID.write(new_tokenID);

    // Register characteristics of the new animal
    let animal : Animal = Animal(sex=sex,legs=legs,wings=wings);
    animal_characteristics.write(
                            new_tokenID, 
                            animal
                            );

    // The address that declares the new animal will be owner
    // TODO: allow for other accounts to also declare animals (breeders)
    let (sender_address) = get_caller_address();
    ERC721._mint(to=sender_address, token_id=new_tokenID);
    return (token_id=new_tokenID);
}


@external
func approve{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    to: felt, tokenId: Uint256
) {
    ERC721.approve(to, tokenId);
    return ();
}

@external
func setApprovalForAll{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    operator: felt, approved: felt
) {
    ERC721.set_approval_for_all(operator, approved);
    return ();
}

@external
func transferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256
) {
    ERC721.transfer_from(from_, to, tokenId);
    return ();
}

@external
func safeTransferFrom{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    from_: felt, to: felt, tokenId: Uint256, data_len: felt, data: felt*
) {
    ERC721.safe_transfer_from(from_, to, tokenId, data_len, data);
    return ();
}

// @external
// func mint{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
//     to: felt, tokenId: Uint256
// ) {
//     Ownable.assert_only_owner();
//     ERC721._mint(to, tokenId);
//     return ();
// }

@external
func burn{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(tokenId: Uint256) {
    ERC721.assert_only_token_owner(tokenId);
    ERC721._burn(tokenId);
    return ();
}

@external
func setTokenURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
    tokenId: Uint256, tokenURI: felt
) {
    Ownable.assert_only_owner();
    ERC721._set_token_uri(tokenId, tokenURI);
    return ();
}

@external
func transferOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    newOwner: felt
) {
    Ownable.transfer_ownership(newOwner);
    return ();
}

@external
func renounceOwnership{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    Ownable.renounce_ownership();
    return ();
}

//
// Internals
//

func _assert_only_breeder{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
        // let (owner) = Ownable.owner();
        let (caller) = get_caller_address();
        with_attr error_message("Breeder: caller is the zero address") {
            assert_not_zero(caller);
        }

        let breeder : felt = is_breeder(account=caller);

        with_attr error_message("Breeder: caller is not a registered breeder") {
            assert 1 = breeder;
        }
        return ();
    }