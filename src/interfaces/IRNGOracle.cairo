%lang starknet

// Request random numbers: https://github.com/0xNonCents/VRF-StarkNet
@contract_interface
namespace IRNGOracle {
    func request_rng(beacon_address: felt) -> (requestId: felt) {
    }
}
