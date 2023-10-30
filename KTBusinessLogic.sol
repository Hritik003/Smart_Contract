// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "https://github.com/Hritik003/Smart_Contract/blob/main/KT.sol";

contract KTBusinessLogic{

    kryptToken public KT_Token;

    struct Item{
        uint256 id;
        string name;
        uint256 price;
    }

    struct purchase{
        address buyer;
        string  seller;
        uint256 item_ID;

    }

    address constant public krypt_Address = 0xd5579429642437471df78c862d9143175a99324B;

    mapping(uint256 => Item) Items;
    mapping(address => uint256) clientTokens;
    mapping(address => uint256) tokensEarned;

    uint256 item_count;

    event EtherTransferred(address indexed from, address indexed to, uint256 amount);
    event LogMessage(uint256 message);
    event Recieved(address sender, uint256 amount);
    event sentToKrypt(uint256 amount);
    event Refunded(address reciever, uint256 amount);
    event KTEarned(address reciever, uint256 tokens);

    

    constructor(address _kryptTokenAddress) {
        KT_Token = kryptToken(_kryptTokenAddress);
        item_count=0;

        //adding the items in the company List.
        addItem("Item1", 0.008 ether);
        addItem("Item2", 0.0037 ether);
        addItem("Item3", 0.0018 ether);
        addItem("Item4", 0.012 ether);
        addItem("Item5", 0.01 ether);

    }

    function addItem(string memory _name, uint256 _price) private {
        //adds the item called from the Constructor.
        Items[item_count] = Item(item_count,  _name,  _price);
        item_count++;
    }

    function getItems() public view returns (Item[] memory){
        Item[] memory items_ = new Item[](item_count);

        for(uint i=0 ; i < item_count ; i++){
            items_[i] = Items[i];
        }

        return items_;
    }


    //Function to calculate the Number of Krypt Tokens in his account.
    function getNumberOfTokens(address _address) external view returns(uint256){
        return KT_Token.balanceOf(_address);
    }


    // Function to calculate the discount percentage based on the number of tokens
    function calculateDiscount(uint256 _price, uint256 tokens) public  returns (uint256 discount) {
        if (tokens >= 20) {

            clientTokens[msg.sender]-=20;
            return _price=(_price)/3;

        } else if (tokens >= 10) {

            clientTokens[msg.sender]-=10;
            return _price=(_price)/5;
            
        } else {
            return 0;
        }
    }

    // Function to earn tokens for a customer
    function earnTokens(uint256 amount) external payable{
        // Transfer tokens from the token contract to the customer
        kryptToken kt = kryptToken(_kryptTokenAddress);
        kt.transferFrom(krypt_Address, msg.sender, amount);
        
        // Update the tokens earned by the customer
        tokensEarned[msg.sender] += amount;
        
        // Emit the TokensEarned event
        emit KTEarned(msg.sender, amount);
    }

    function getBalance() public view returns(uint256){
        return address(this).balance;
    }

    receive() external payable {
        emit Recieved(msg.sender, msg.value);        
    }

    function buyProduct(uint256 _item_ID) public returns(uint256){

        //check if the Item Id is valid.
        require(_item_ID >= 0 && _item_ID <= item_count, "Invalid Item ID");

        //The company can't buy from itself.
        require(msg.sender != krypt_Address, " The Company can't buy from Itself.");

        uint256 tokenCount = 0;//getNumberOfTokens(msg.sender);
        uint256 discountedPrice =  calculateDiscount(Items[_item_ID].price, tokenCount);

        emit LogMessage(discountedPrice);

        uint256 balance = getBalance();
        if(discountedPrice<=balance){
            uint256 difference = balance - discountedPrice;

            //transfer the difference amount to the client from the third party metamask.
            if(difference > 0){

                payable(msg.sender).transfer(difference);
                emit Refunded(msg.sender, difference);

            }


            //transfer the amount after discount from client to Company.
            payable(krypt_Address).transfer(discountedPrice);
            emit sentToKrypt(discountedPrice);
        }

        else{

            payable(msg.sender).transfer(balance);
            emit Refunded(msg.sender, balance);
        }

        return discountedPrice;
    }

    
}
