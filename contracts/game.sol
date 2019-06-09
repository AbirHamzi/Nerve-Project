pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract game{
    struct Player {
        string amountBet;
    }  
    mapping(address => Player) public playerInfo;
    
    address payable[] public watchers;
    mapping (uint => string) Dares;
    //string[] Dares;
    event transferFund(address _sender,address _reciever,uint _amount);

    constructor()public {
        Dares[1]="Eat something and then talk with your mouth full";
        Dares[2]="Fill your mouth with water and try singing a song";
        Dares[3]="Call up your crush and declare your love for him";
        Dares[4]="Make an obscene phone call to a random number";
    }
  /*  function getDresNumber()public view returns(uint){
       return Dares.length;
    }*/
    function getDare(uint _index)public view returns(string memory){
      
        return Dares[_index];
        //return "Hello from getDares !!";
    }
    function getBalance() public view returns(uint){
         return (msg.sender.balance);
    }
      

    function send(address payable _reciever) public payable returns(bool){
        _reciever.transfer(msg.value);
        emit transferFund(msg.sender,_reciever,msg.value);
        return true;
    }
    function() external payable {}
}