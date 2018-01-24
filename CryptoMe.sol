pragma solidity ^0.4.0;

// don't try doing anything with this yet, it's still under construction!
// https://ethereum.github.io/browser-solidity

contract CryptoMe {

    struct Identity {
        address addr;
        string name;
        string email;
        string ipfs;
    }

    address admin;
    mapping(address => Identity) addrs;
    mapping(string => Identity) names;
    mapping(string => Identity) emails;
    float basePrice=0.1;

  function CryptoMe()
  {
    admin=msg.sender;
  }

  function register(string name, String email) public {
    
      // verify name is legit
      // verify name is available
    
      // figure out how many registrations in the past week
      //if msg.amount < (recentCount*basePrice)(bytes(name).length)
      //  return "boo, lame, needs more money";
      
      Identity newID=Identity(name:name,email:email);
      
      addrs[msg.sender]=newID;
      names[name]=newID;
      emails[email]=newID;
    }
    
    function id(string name) public {
      return names[name];
    }
}
