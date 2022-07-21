// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Airdrop is ERC20, Ownable {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(msg.sender, 10 * 10 ** decimals());
    }

    function makeAirdrop(address[] memory _addresses, uint256 _amount) public onlyOwner {
        for (uint32 i = 0; i < _addresses.length; i++) {
            transfer(_addresses[i], _amount);
        }
    }
}