// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract MyContract is Ownable {
    string public name;
    uint256 public value;

    event ValueChanged(uint256 newValue);

    constructor(string memory _name, uint256 _initialValue) {
        name = _name;
        value = _initialValue;
    }

    function setValue(uint256 _value) external onlyOwner {
        value = _value;
        emit ValueChanged(_value);
    }

    function getValue() external view returns (uint256) {
        return value;
    }
}