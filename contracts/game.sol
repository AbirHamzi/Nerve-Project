pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract game{
    //Struct that represents a player/watcher
    struct Player {
        string nickName;
    }  
    mapping(address => Player) public playerInfo; // maaping(user-address => user-informations)
    address[] public players; // players are stored in blockchain as an array of adresses
    address payable[] public watchers; // watchers are stored in blockchain as an array of payable adresses
    mapping (uint => string) Dares; // mapping(Dare-key => Dare-description)
    uint[] DaresKeyList; //array that store all Dares keys 

    event transferFund(address _sender,address _reciever,uint _amount);
    

    constructor()public {
        //Hard-coded list of dares for test
        Dares[1]="Eat something and then talk with your mouth full";
        DaresKeyList.push(1);
        Dares[2]="Fill your mouth with water and try singing a song";
        DaresKeyList.push(2);
        Dares[3]="Call up your crush and declare your love for him";
        DaresKeyList.push(3);
        Dares[4]="Make an obscene phone call to a random number";
        DaresKeyList.push(4);

    }
  
  /// @dev function that returns all dares 
  /// @return array of string new experimental blockchain feature 
    function getDares()public view returns(string[] memory){
      string[] memory _Dares = new string[](DaresKeyList.length);
       for(uint i = 0; i < DaresKeyList.length; i++){
           _Dares[i] = Dares[DaresKeyList[i]];
       }
       return _Dares;
    }
    function getDareKey(string memory _dare) public view returns(uint){
     uint _key;
        for(uint i = 0; i < DaresKeyList.length; i++){
             _key = DaresKeyList[i];
            if(keccak256(abi.encodePacked(Dares[_key]))==keccak256(abi.encodePacked(_dare)) )
            break;
        }
        return _key;
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