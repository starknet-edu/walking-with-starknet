%lang starknet


from starkware.cairo.common.uint256 import Uint256, uint256_add
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import unsigned_div_rem, split_felt
from starkware.cairo.common.cairo_secp.bigint import BigInt3
from starkware.cairo.common.alloc import alloc


from openzeppelin.access.ownable.library import Ownable
from openzeppelin.introspection.erc165.library import ERC165
from openzeppelin.token.erc721.library import ERC721

from src.interfaces.IRNGOracle import IRNGOracle
from src.utils.Array import concat_arr

// ------
// Constants
// ------

const PASSWORD = 654;

// ------
// Storage
// ------

@storage_var
func oracle_address() -> (addr: felt) {
}

@storage_var
func beacon_address() -> (address: felt) {
}

@storage_var
func rn_request_id() -> (id: felt) {
}

@storage_var
func request_id_to_tokenId(rn_request_id: felt) -> (tokenId: Uint256) {
}

@storage_var
func request_id_to_sender(rn_request_id: felt) -> (address: felt) {
}

@storage_var
func request_id_to_tokenURI(rn_request_id: felt) -> (tokenURI: felt) {
}

@storage_var
func token_counter() -> (number: Uint256) {
}

@storage_var
func tokenID_to_random_number(tokenID: Uint256) -> (number: felt) {
}

@storage_var
func erc721_baseURI(array_index: felt) -> (text: felt) {
}

@storage_var
func erc721_baseURI_len() -> (len: felt) {
}

@storage_var
func erc721_base_tokenURI_suffix() -> (suffix: felt) {
}

// ------
// Constructor
// ------

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    oracle_addr: felt, _beacon_address: felt
) {
    alloc_locals;
    // "L2 coleccion octubre"
    let name = 435001157271749608490168255869766614643032355429;
    // "BBB"
    let symbol = 4342338;
    let owner = 1268012686959018685956609106358567178896598707960497706446056576062850827536;
    
    // Replace with real values
    local base_token_uri: felt*;
    // "https://gateway.pinata.cloud/ip"
    assert base_token_uri[0] = 184555836509371486644298270517380613565396767415278678887948391494588524912;
    // "fs/QmZLkgkToULVeKdbMic3XsepXj2X"
    assert base_token_uri[1] = 181013377130050200990509839903581994934108262384437805722120074606286615128;
    // "xxMukhUAUEYzBEBDMV/"
    assert base_token_uri[2] = 2686569255955106314754156739605748156359071279;

    let base_token_uri_len = 3;
    // .jpeg
    let token_uri_suffix = 1199354246503;

    token_counter.write(Uint256(0,0));
    ERC721.initializer(name, symbol);
    Ownable.initializer(owner);
    set_base_tokenURI(base_token_uri_len, base_token_uri, token_uri_suffix);

    // Requirements for randomness
    oracle_address.write(oracle_addr);
    beacon_address.write(_beacon_address);

    return ();
}

// ------
// Getters
// ------

@view
func owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (owner: felt) {
    return Ownable.owner();
}

@view
func ownerOf{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(tokenId: Uint256) -> (
    owner: felt
) {
    return ERC721.owner_of(tokenId);
}

@view
func get_last_tokenID{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (tokenID: Uint256) {
    let last_token : Uint256 = token_counter.read();
    return (tokenID=last_token);
}

@view
func get_random_number{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(tokenID: Uint256) -> (number: felt) {
    let number : felt = tokenID_to_random_number.read(tokenID);
    return (number=number);
}

@view
func tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256
) -> (token_uri_len: felt, token_uri: felt*) {
    let random_number : felt = tokenID_to_random_number.read(token_id);
    let (token_uri_len, token_uri) = ERC721_Metadata_tokenURI(token_id, random_number);
    return (token_uri_len=token_uri_len, token_uri=token_uri);
}

// ------
// Constant Functions: non state-changing functions
// ------

func ERC721_Metadata_tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_id: Uint256, random_number: felt
) -> (token_uri_len: felt, token_uri: felt*) {
    alloc_locals;

    let exists = ERC721._exists(token_id);
    assert exists = 1;

    // TODO XXX Might be missing to read the storage with the base_token_uri
    let (local base_token_uri) = alloc();
    let (local base_token_uri_len) = erc721_baseURI_len.read();

    // Save in storage the URI base
    _store_base_tokenURI(base_token_uri_len, base_token_uri);

    // let (token_id_ss_len, token_id_ss) = uint256_to_ss(token_id);

    // Concatenate in an array the URI's base len, and base, the token_id's len and body 
    let (local number) = alloc();
    [number] = random_number;

    let (token_uri_temp, token_uri_len_temp) = concat_arr(
        base_token_uri_len, base_token_uri, 1, number
    );

    // Store in suffix the array containing the suffix
    let (ERC721_base_token_uri_suffix_local) = erc721_base_tokenURI_suffix.read();
    let (local suffix) = alloc();
    [suffix] = ERC721_base_token_uri_suffix_local;

    // Concatenate the previous array now with the suffix
    let (token_uri, token_uri_len) = concat_arr(token_uri_len_temp, token_uri_temp, 1, suffix);

    return (token_uri_len=token_uri_len, token_uri=token_uri);
}


// set the random value corresponding to the NFT as URI
// @external
// func setTokenURI{pedersen_ptr: HashBuiltin*, syscall_ptr: felt*, range_check_ptr}(
//     tokenId: Uint256, tokenURI: felt
// ) {
//     Ownable.assert_only_owner();
//     ERC721._set_token_uri(tokenId, tokenURI);
//     return ();
// }

func create_random_number{syscall_ptr: felt*, range_check_ptr}(rng: felt) -> (roll: felt) {
    // Take the lower 128 bits of the random string
    let (_, low) = split_felt(rng);
    let (_, number) = unsigned_div_rem(low, 3);
    return (number + 1,);
}

// ------
// Non-Constant Functions: state-changing functions
// ------


// Save in storage all the base and suffix of the token URI
func set_base_tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_uri_len: felt, token_uri: felt*, token_uri_suffix: felt
    ) {
    
    // store the baseURI string into the erc721_baseURI storage variable 
    _store_base_tokenURI(token_uri_len, token_uri);

    // store the baseURI string length the erc721_baseURI_len storage variable 
    erc721_baseURI_len.write(token_uri_len);

    // store the tokenURI suffix (e.g. json) in the erc721_base_tokenURI_suffix storage variable
    erc721_base_tokenURI_suffix.write(token_uri_suffix);
    return ();
}

// Store the value of an array into an storage variable
func _store_base_tokenURI{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    token_uri_len: felt, token_uri: felt*
    ) {
    if (token_uri_len == 0) {
        return ();
    }
    // At position "token_uri_len" of the array "token_uri" store [token_uri]
    erc721_baseURI.write(token_uri_len, [token_uri]);
    _store_base_tokenURI(token_uri_len=token_uri_len - 1, token_uri=token_uri + 1);
    return ();
}

@external
func create_collectible{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    // password: felt
) {

    // with_attr error_message("Create Collectible: Wrong password") {
    //     assert PASSWORD = password;
    // }

    let (requestID: felt) = request_rng();
    let (caller_address: felt) = get_caller_address();
    
    request_id_to_sender.write(requestID, caller_address);
    // request_id_to_tokenURI.write(requestID, tokenURI);
    return();
}

// @external
func request_rng{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    request_id: felt
) {
    let (oracle) = oracle_address.read();
    let (_beacon_address) = beacon_address.read();
    let (request_id) = IRNGOracle.request_rng(
        contract_address=oracle, beacon_address=_beacon_address
    );
    rn_request_id.write(request_id);
    return (request_id,);
}

// Function called by the oracle
@external
func will_recieve_rng{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    rng: BigInt3, request_id: felt
) {
    // Assert the caller is the oracle
    let (oracle) = oracle_address.read();
    let (caller_address) = get_caller_address();
    assert oracle = caller_address;

    // Get new nft owner address and the tokenURI for this random request
    // Each nft owner has a random request map to they
    let (nft_owner: felt) = request_id_to_sender.read(request_id);
    // let (tokenURI: felt) = request_id_to_tokenURI.read(request_id);
    // xxx replace, this is while we set URI
    let tokenURI: felt = 2;

    // Update new tokenID
    let last_token : Uint256 = token_counter.read();
    let one_uint : Uint256 = Uint256(1,0);
    let (new_tokenID, _ ) = uint256_add(a=last_token, b=one_uint);
    token_counter.write(new_tokenID);

    // Mint to nft owner and set the URI of the tokenID
    ERC721._mint(to=nft_owner, token_id=new_tokenID);
    ERC721._set_token_uri(token_id=new_tokenID, token_uri=tokenURI);

    // Set random number corresponding to the tokenID
    let (random_number) = create_random_number(rng.d0);
    tokenID_to_random_number.write(new_tokenID, random_number);
    
    // Save random number obtained
    // rn_number.write(random_number);

    // Map request id to tokenID
    request_id_to_tokenId.write(request_id, new_tokenID);

    // rng_request_resolved.emit(rng, request_id, roll);
    return ();
}