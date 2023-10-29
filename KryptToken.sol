// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.9.3/contracts/token/ERC20/ERC20.sol";

//inheriting from another contract named ERC20. 
contract kryptToken is ERC20 {
    address public  admin;
   
    constructor() ERC20("kryptToken", "KT") {
        admin = msg.sender;
        _mint(admin, 1000000 * 10**18); //1 million tokens to admin
    }

    function mint(address to, uint amount) external {
        require(msg.sender == admin, "only admin can mint");
        _mint(to, amount);
    }

    function burn(address from, uint amount) external {
        require(msg.sender == admin, "only admin can burn");
        _burn(from, amount);
    }
}

contract KTBusinessLogic{
    kryptToken public token;
    address public admin;
    mapping(address  =>  uint256) public tokenSpent;

    event purchaseRequested(address indexed customer, uint amount);
    event purchaseConfirmed(address indexed customer, uint amount, uint tokensRecieved);
    event discountAvailed(address indexed customer, uint discount);

    constructor(address tokenAddress){
        token = kryptToken(tokenAddress);
        admin = msg.sender;
    }

    function requestPurchase(address customer, uint amount) external {
        require(msg.sender == admin, "The admin alone can request a Purchase.");

        //Log the request
        emit purchaseRequested(customer, amount);
    }

    function confirmPurchase(address customer, uint amount) external{
        require(msg.sender == admin, "The admin alone can confirm a purchase.");

        //Issuing the tokens 
        uint tokens = amount/200; // For every $200 spent, 1 Token is issued.
        token.mint(customer, tokens);

        //Log the  Purchase that was confirmed
        emit purchaseConfirmed(customer, amount, tokens);
    }

    function availDiscount(address customer, uint tokens) external {
        require(msg.sender == customer, "The Customer Alone can avail Discounts.");
        require( tokens > 0, "You own zero tokens");


        uint historicalSpending = tokenSpent[customer];
        uint earnedTokens = token.balanceOf(customer);

        uint  base_discount = 5;
        uint discount = base_discount + (historicalSpending/1000);
        discount += earnedTokens/10;


        if(discount>20){
            discount=20;
        }

        //burn the tokens used for discount.
        token.burn(customer, tokens);

        //update
        tokenSpent[customer] += tokens;


        // Log the discount availed
        emit discountAvailed(customer, discount);

    }

    function customerBalance(address customer) external view returns (uint256) {
        return token.balanceOf(customer);
    }
    

}
