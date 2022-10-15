pragma solidity ^0.8.15;

import {ERC721} from "solmate/tokens/ERC721.sol";
import {Huh} from "../Huh.sol";

contract Stuart is ERC721, Huh {

    uint256 public constant PRICE = 0.08 ether;
    uint256 public available = 1000;
    uint256 public totalSupply;

    constructor() ERC721("Stuart", "STU") Huh(0) {}

    function buy(bytes32 commitment) public payable {
        require(available > 0, "Sold out");
        require(msg.value == PRICE, "Wrong msg.value");
        available--;
        _deposit(commitment);
    }

    function mint(bytes calldata proof) public {
        (bool success, address recipient) = _claim(proof);
        require(success, "Proof failed");
        _mint(recipient, totalSupply);
        totalSupply++;
    }

    function tokenURI(uint256 id) public view override returns (string memory) {
        return "";
    }
}