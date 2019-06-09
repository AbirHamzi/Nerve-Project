pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract game{
    struct Player {
        string amountBet;
    }  
    mapping(address => Player) public playerInfo;
    
    address payable[] public watchers;
    //mapping (uint => string) Dares;
    string[] Dares;
    event transferFund(address _sender,address _reciever,uint _amount);

    constructor()public {
        Dares.push("Eat something and then talk with your mouth full");
        Dares.push("Fill your mouth with water and try singing a song");
        Dares.push("Call up your crush and declare your love for him");
        Dares.push("Make an obscene phone call to a random number");
    }
  
    function getDares()public view returns(string[] memory){
      string[] memory _Dares = new string[](Dares.length);
       for(uint i = 0; i < Dares.length; i++){
          _Dares[i] = Dares[i];
       }
       return _Dares;
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