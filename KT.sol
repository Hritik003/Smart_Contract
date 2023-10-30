// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/ERC20.sol";

//inheriting from another contract named ERC20. 
contract KT is ERC20 {
    address public  admin;
   
    constructor() ERC20("kryptToken", "KT") {
        admin = msg.sender;
        _mint(admin, 10000*10**18); //10000 KT tokens to admin
    }

}
