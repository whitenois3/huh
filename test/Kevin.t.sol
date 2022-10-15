pragma solidity ^0.8.15;

import "forge-std/Test.sol";
import "forge-std/console2.sol";

import {Stuart} from "contracts/mocks/Stuart.sol";

contract StuartTest is Test {

    Stuart stuart;

    function setUp() external {
        stuart = new Stuart();
    }

    function getBasicCommitmentRequest(string memory nullifier, string memory secret) public pure returns (string[] memory) {
        string[] memory inputs = new string[](5);
        inputs[0] = "npx";
        inputs[1] = "ts-node";
        inputs[2] = "test/utils/ffiCommitment.ts";
        inputs[3] = nullifier;
        inputs[4] = secret;
        return inputs;
    }

    function getBasicProofRequest(
        string memory acir,
        string memory nullifier,
        string memory secret,
        string memory nullifierHash,
        string memory recipient
    ) public pure returns (string[] memory) {
        string[] memory inputs = new string[](8);
        inputs[0] = "npx";
        inputs[1] = "ts-node";
        inputs[2] = "test/utils/ffiProof.ts";
        inputs[3] = acir;
        inputs[4] = nullifier;
        inputs[5] = secret;
        inputs[6] = nullifierHash;
        inputs[7] = recipient;
        return inputs;
    }

    function test_deposit() external {
        string[] memory inputs = getBasicCommitmentRequest("666", "420");
        bytes memory commitmentAndNullifierHash = vm.ffi(inputs);
        (bytes32 commitment, bytes32 nullifierHash) = abi.decode(commitmentAndNullifierHash, (bytes32, bytes32));
        stuart.buy{value: 0.08 ether}(commitment);
        assertTrue(stuart.commitments(commitment) == true);
        assertEq(stuart.available(), 999);
    }

    function testFail_cannotDepositSameCommitment() external {
        string[] memory inputs = getBasicCommitmentRequest("666", "420");
        bytes memory commitmentAndNullifierHash = vm.ffi(inputs);
        (bytes32 commitment, bytes32 nullifierHash) = abi.decode(commitmentAndNullifierHash, (bytes32, bytes32));
        stuart.buy{value: 0.08 ether}(commitment);
        stuart.buy{value: 0.08 ether}(commitment);
    }

    function test_mint() external {
        string[] memory inputs1 = getBasicCommitmentRequest("666", "420");
        bytes memory commitmentAndNullifierHash = vm.ffi(inputs1);
        (bytes32 commitment, bytes32 nullifierHash) = abi.decode(commitmentAndNullifierHash, (bytes32, bytes32));
        stuart.buy{value: 0.08 ether}(commitment);

        address recipient = address(0xbeef);
        string[] memory inputs2 = getBasicProofRequest("p", "666", "420", vm.toString(nullifierHash), vm.toString(recipient));
        bytes memory proof = vm.ffi(inputs2);
        stuart.mint(proof);

        assertEq(stuart.totalSupply(), 1);
        assertEq(stuart.balanceOf(recipient), 1);
        assertEq(stuart.ownerOf(0), recipient);
    }

    function testFail_cannotUseSameNullifierAgain() external {
        string[] memory inputs1 = getBasicCommitmentRequest("666", "420");
        bytes memory commitmentAndNullifierHash = vm.ffi(inputs1);
        (bytes32 commitment, bytes32 nullifierHash) = abi.decode(commitmentAndNullifierHash, (bytes32, bytes32));
        stuart.buy{value: 0.08 ether}(commitment);

        address recipient = address(0xbeef);
        string[] memory inputs2 = getBasicProofRequest("p", "666", "420", vm.toString(nullifierHash), vm.toString(recipient));
        bytes memory proof = vm.ffi(inputs2);
        stuart.mint(proof);
        stuart.mint(proof);
    }
}