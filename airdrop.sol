pragma solidity ^0.8.0;

contract getmoney {


    mapping(address => uint) addressStatic;

    receive() external payable{}

    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    function getMoney() public jianCha{
        address payable recipent = payable(msg.sender);
        recipent.transfer(100000000000000000);
        addressStatic[msg.sender]++;
    }

    modifier jianCha(){
        require(address(this).balance>=100000000000000000,"wo yi jin yi di dou mei you la , qiu fan guo");
        require(addressStatic[msg.sender]<5,"FUCK !ni bu yao tai tan xing");
        _;
    }
