pragma solidity ^0.4.0;

// don't try doing anything with this yet, it's still under construction!
// https://ethereum.github.io/browser-solidity

contract CryptoMe {

    struct Identity {
        address addr;
        string name;
        string ipfs;
    }

    address admin;
    mapping(address => Identity) addrs;
    mapping(string => Identity) names;
    float basePrice=0.1;

    /// Create a new ballot with $(_numProposals) different proposals.
    function Register(string name) public {
    
      // figure out how many registrations in the past week
      
      if msg.amount < (recentCount*basePrice)(bytes(name).length)
        return "boo, lame, needs more money";
      
      addrs[msg.sender]=new Identity();
      addrs[msg.sender].idName=name;
    }
}
