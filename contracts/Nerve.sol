pragma solidity ^0.5.0;

/// @title Base contract for Nerve.
/// @author A.Hamzi
/// @dev  Holds all common structs, events and base variables.

contract NerveBase{
 
/****************************************** DATA TYPES **************************************************/
    /// Player struct represents all informations about a Nerve-user (Can be player or watcher) .

    struct Player{
    string nickname;
    uint PlayerID;
    address[] followers;
    }
    mapping(address => Player) PlayerInfo; /// Mapping: user-address => user-Info    

    /// Nerve watcher is every Nerve-User that will send ETH to watch .
    address payable[] public Watchers;
 

    /// The main PrizePool struct. Every PrizePool in Nerve is represented by 
    /// a copy of this structure.
    struct PrizePool{
     uint prizePoolID;
     uint TotalAmount;
     mapping (address => Player) player;
    }

    /// Dare struct, every Dare in Nerve is represented by a copy of this structure.
    /// Dares-Description storage will be handled by ipfs to minimize costs . 
    struct Dare{
       uint DareId;
       bytes32 Description; // hash of ipfs stored description
    } 


    mapping(address => PrizePool) PlayerTOPrizePool;

/****************************************** STORAGE ****************************************************/

     /// An array containing the Dare struct for all Dares available. The ID
    ///  of each Dare is actually an index into this array.Memory here refers
    /// that dares storage is permanently
    Dare[]  Dares;
 
}

/// @title NerveCore .
/// @author A.Hamzi
/// @dev This is the main Nerve contract.
/// A contract documentation needed here to explain how the various contract facets are arranged.
contract NerveCore {

}