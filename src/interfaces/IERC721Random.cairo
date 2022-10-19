%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IExerciseSolution {
    // Breeding function
    func owner() -> (owner: felt) {
    }
    func get_last_tokenID() -> (tokenID: Uint256) {
    }
    func register_me_as_breeder() -> (is_added: felt) {
    }
    func declare_animal(sex: felt, legs: felt, wings: felt) -> (token_id: Uint256) {
    }
    func get_animal_characteristics(token_id: Uint256) -> (sex: felt, legs: felt, wings: felt) {
    }
    func token_of_owner_by_index(account: felt, index: felt) -> (token_id: Uint256) {
    }
    func declare_dead_animal(token_id: Uint256) {
    }
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