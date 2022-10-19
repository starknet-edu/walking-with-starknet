%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256

from openzeppelin.token.erc721.library import ERC721

from src.utils.array import concat_arr

// ------
// Storage
// ------

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
// Non-Constant Functions: state-changing functions
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