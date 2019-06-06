pragma solidity ^0.5.0;

contract paiement {
    event transferFund(address _sender,address _reciever,uint _amount);

    function send(address payable _reciever) public payable returns(bool){
        _reciever.transfer(msg.value);
        emit transferFund(msg.sender,_reciever,msg.value);
        return true;
    }
    function getBalance() public view returns(uint){
         return msg.sender.balance;
    }
}