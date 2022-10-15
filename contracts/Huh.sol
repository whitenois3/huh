pragma solidity ^0.8.15;

import {TurboVerifier} from "./Verifier.sol";

abstract contract Huh is TurboVerifier {

    /// @notice Time after which claims can be executed.
    /// @notice Should better anonynimty.
    uint256 public immutable START;
    mapping(bytes32 => bool) public nullifierHashes;
    mapping(bytes32 => bool) public commitments;

    constructor(uint256 start) {
        START = start;
    }
    
    /// @notice Deposit.
    /// @param commitment The commitment.
    function _deposit(bytes32 commitment) internal {
        require(!commitments[commitment], "Commitment already used");
        commitments[commitment] = true;
    }

    /// @notice Claim ... well ... anything?
    /// @param proof The proof.
    /// @return success If verification of proof was successful (will revert if not anyways).
    /// @return recipient The address of the recipient.
    function _claim(bytes calldata proof) internal returns (bool success, address recipient) {
        require(block.timestamp >= START, "Too early");
        (bytes32 nullifierHash, address _recipient) = abi.decode(proof, (bytes32, address));
        require(!nullifierHashes[nullifierHash], "Nullifier already used");
        require(this.verify(proof), "Invalid proof");
        nullifierHashes[nullifierHash] = true;
        return (true, _recipient);
    }


}