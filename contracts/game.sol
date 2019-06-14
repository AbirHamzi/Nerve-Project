pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import 'node_modules/openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract game is Ownable{
    /************************************* Global vars ***************************************/
    uint public minimumBet; //min bet for a watcher to play the game
    uint public requiredWatcherNumber = 3; //required number of watchers to play a dare

    /************************************* Structs *******************************************/

    struct User{
        string nickName;
        address Uaddress;
    }
    
    struct Watcher{
        uint BetAmount; 
        uint Poolkey;
        bool vote ; // true if proof is acceptes and 0 if not
    }
    struct PrizePool{
        uint PoolID;
        uint TotalAmount;
        string ProofID; // IPFS ID of the proof
        uint DareKey;
        uint NbWatchers;
    }
     
    /************************************* Arrays ***************************************/
    mapping(address => PrizePool) public PLayedDare; // mapping (player => prizepool)
    mapping(address => Watcher) public watcherInfo; // maaping(player-address => player-informations)
    
    //address[] public Users; // players are stored in blockchain as an array of adresses
    address payable[] public watchers; // watchers are stored in blockchain as an array of payable adresses
    address public player;
    
    mapping(uint => User) public Users;
    uint[] UsersKeyList;
   /* mapping(uint => PrizePool) PrizePools;
    uint[] PoolsKeyList;*/
    PrizePool[] PrizePools;
    mapping(uint => PrizePool) PoolKey;
    mapping (uint => string) Dares; // mapping(Dare-key => Dare-description)
    uint[] DaresKeyList; //array that store all Dares keys 

    /************************************* Events *******************************************/
    event transferFund(address _sender,address _reciever,uint _amount);
    event PoolCreated(uint PoolID,address _player);
    event proofUpdated(uint _poolID,string _ipfsID);
    

    constructor()public {
        User memory _user;
        PrizePool memory _pool;
        //Hard-coded list of dares for test
        Dares[1]="Eat something and then talk with your mouth full";
        DaresKeyList.push(1);
        Dares[2]="Fill your mouth with water and try singing a song";
        DaresKeyList.push(2);
        Dares[3]="Call up your crush and declare your love for him";
        DaresKeyList.push(3);
        Dares[4]="Make an obscene phone call to a random number";
        DaresKeyList.push(4);

        //Hard-coded list of users
        _user.nickName = 'abir';
        _user.Uaddress = 0xbd291142E71c7278DE5eb82D7CddC53AE704e1fa;
         Users[1] = _user;
         UsersKeyList.push(1);
         _user.nickName = 'hamza';
        _user.Uaddress = 0xBB9bc244D798123fDe783fCc1C72d3Bb8C189413;
         Users[2] = _user;
         UsersKeyList.push(2);
         _user.nickName = 'majd';
        _user.Uaddress = 0xde0B295669a9FD93d5F28D9Ec85E40f4cb697BAe;
         Users[3] = _user;
         UsersKeyList.push(3);
        // Initial Pool
        _pool.PoolID = 0 ;
        PrizePools.push(_pool);

    }
    function checkPlayerExists(address _player) private view returns(bool){
        return _player == player;
    }

    modifier OnlyPlayer(){
        require(checkPlayerExists(msg.sender));
         _;
    }
    function checkUserExists(address _user) private view returns(bool){
         for(uint i = 0; i < UsersKeyList.length; i++){
            if(keccak256(abi.encode(Users[UsersKeyList[i]]))==keccak256(abi.encode(_user)) ){
                return true;
                break;
            }
    
        }
        return false;
    }
    modifier OnlyUser(){
        require(checkUserExists(msg.sender));
         _;
    }
    function checkWatcherExists(address _watcher) private view returns(bool){
        for(uint i = 0; i < watchers.length; i++){
            if(watchers[i] == _watcher) {
                return true;
                 break;
            }
        }
        return false;
    }
  
    modifier OnlyWatcher() {
       require(checkWatcherExists(msg.sender));
         _;
    }
    modifier ExceptWatcher() {
       require(!checkWatcherExists(msg.sender));
         _;
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
   /// @dev function that returns key of selected dare
  /// @return uint=key in mapping(key => dare)
    function getDareKey(string memory _dare) public view returns(uint){
     uint _key;
        for(uint i = 0; i < DaresKeyList.length; i++){
             _key = DaresKeyList[i];
            if(keccak256(abi.encodePacked(Dares[_key]))==keccak256(abi.encodePacked(_dare)) )
            break;
        }
        return _key;
    }
    function getDareByKey(uint _key) private view returns(string memory){
       return Dares[_key];
    }  
    function getUsers()public view returns(User[] memory){
        User[] memory _users = new User[](UsersKeyList.length);
          for(uint i = 0; i < UsersKeyList.length; i++){
           _users[i] = Users[UsersKeyList[i]];
          }
       return _users;
    }

    function createWatcher(uint _BetAmount,uint _Poolkey,address payable _address)private {
     Watcher memory _watcher;
     _watcher.BetAmount = _BetAmount;
     _watcher.Poolkey = _Poolkey;
     watcherInfo[_address]=_watcher;
     watchers.push(_address);
     
    }
    function dareYou(uint _BetAmount,uint _DareKey,address _player) public payable returns(bool){
        //require(_BetAmount>minimumBet);
        PrizePool memory _Pool;
        //create the new prizepool
        _Pool.PoolID = PrizePools.length;
        _Pool.TotalAmount +=_BetAmount;
        _Pool.DareKey = _DareKey;
        _Pool.NbWatchers ++;
        //store the new prizepool
         PrizePools.push(_Pool);
         PoolKey[_Pool.PoolID] = _Pool;
        // create new watcher
        createWatcher(_BetAmount,_Pool.PoolID,msg.sender);
        // associate the game with the player
        PLayedDare[_player] = _Pool;
        emit PoolCreated(_Pool.PoolID,_player);
        return true;
    }
    function update(PrizePool[] storage _pools,uint _betAmount,uint _poolID)internal returns(bool){
          
           for(uint i = 0; i < PrizePools.length; i++){
             if(_pools[i].PoolID == _poolID){
               _pools[i].TotalAmount+=_betAmount;
               _pools[i].NbWatchers++;
               // create new watcher
               createWatcher(_betAmount,_poolID,msg.sender);
              }
            }
          return true;
    }
    function joinDare(uint _poolID,uint _betAmount)public payable returns(bool ){
       update(PrizePools,_betAmount,_poolID);
      return true;
      
    }
    
    function dareMe(uint _BetAmount,uint  _DareKey) public payable returns(bool){
        //require(_BetAmount>minimumBet);
        PrizePool memory _Pool;
        //create the new prizepool
        _Pool.PoolID = PrizePools.length;
        _Pool.TotalAmount +=_BetAmount;
        _Pool.DareKey = _DareKey;
        //store the new prizepool
         PrizePools.push(_Pool);
         PoolKey[PrizePools.length] = _Pool;
        // associate the game with the player
        PLayedDare[msg.sender] = _Pool;
        emit PoolCreated(PrizePools.length,msg.sender);
        return true;
    }
    // get all active dares
     function getPools()public view returns(PrizePool[] memory ){
        PrizePool[] memory _pools = new PrizePool[](PrizePools.length);
       for(uint i = 0; i < PrizePools.length; i++){
           _pools[i] = PrizePools[i];
       }
       return _pools;
    
    }  
// get active dares for a selected player
    function getMyDares() public view returns(PrizePool[] memory ){
      PrizePool[] memory _pools = new PrizePool[](PrizePools.length);
       for(uint i = 0; i < PrizePools.length; i++){
           if(PLayedDare[msg.sender].PoolID == PrizePools[i].PoolID)
           _pools[i] = PrizePools[i];
       }
       return _pools;

    }
// 4 functions to get dare informations
    function getActiveDareName(uint _pool) public view returns(string memory){
        uint _dareID;
        for(uint i = 0; i < PrizePools.length; i++){
           if(PrizePools[i].PoolID == _pool){
              _dareID = PrizePools[i].DareKey;
           }
       }
       return Dares[_dareID];
     } 
    function getActiveDarePlayer(uint _pool) public view returns(string memory){
      string memory _player;
        for(uint i = 0; i < UsersKeyList.length; i++){
           if(PLayedDare[Users[UsersKeyList[i]].Uaddress].PoolID == _pool){
              _player = Users[UsersKeyList[i]].nickName;
           }
       }
       return _player;
    }

      function getActiveDareAmount(uint _pool) public view returns(uint){
        uint _totalAMount;
        for(uint i = 0; i < PrizePools.length; i++){
           if(PrizePools[i].PoolID == _pool){
              _totalAMount = PrizePools[i].TotalAmount;
           }
       }
       return _totalAMount;
     } 
       function getActiveDareNBwatchers(uint _pool) public view returns(uint){
        uint _nbWatchers;
        for(uint i = 0; i < PrizePools.length; i++){
           if(PrizePools[i].PoolID == _pool){
              _nbWatchers = PrizePools[i].NbWatchers;
           }
       }
       return _nbWatchers;
     } 

    function getBalance() public view returns(uint){
         return (msg.sender.balance);
    }
    function send(address payable _reciever) public payable returns(bool){
        _reciever.transfer(msg.value);
        emit transferFund(msg.sender,_reciever,msg.value);
        return true;
    }
    function updateProof(PrizePool[] storage _pools,uint _poolID,string memory _ipfsID)internal {
        
           for(uint i = 0; i < PrizePools.length; i++){
             if(_pools[i].PoolID == _poolID){
               _pools[i].ProofID = _ipfsID;
              }
            }
    }
    function setProof(uint _poolID,string memory _ipfsID)public payable returns(bool){
        updateProof(PrizePools,_poolID,_ipfsID);
        emit proofUpdated(_poolID,_ipfsID);
        return true;

    }
    function getProof()public view returns(string memory){

    }
    function distributePrizes() public {

    } 
        // Fallback function in case someone sends ether to the contract so it doesn't get lost and to increase the treasury of this contract that will be distributed in each game
    function() external payable {}
}