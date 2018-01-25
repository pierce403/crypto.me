pragma solidity ^0.4.0;

// don't try doing anything with this yet, it's still under construction!
// https://ethereum.github.io/browser-solidity

contract CryptoMe {

    struct identity {
        address addr;
        string name;
        string email;
        string ipfs;
    }

    address admin;
    mapping(address => identity) addrs;
    mapping(string => identity) names;
    mapping(string => identity) emails;
 //   float basePrice=0.1;

  function CryptoMe() public
  {
    admin=msg.sender;
  }

  function register(string name, string email) public {
    
      // verify name is legit
      // verify name is available
    
      // figure out how many registrations in the past week
      //if msg.amount < (recentCount*basePrice)(bytes(name).length)
      //  return "boo, lame, needs more money";
      
      identity storage newID;// = identity(msg.sender,name,email,"potato");
      
      addrs[msg.sender]=newID;
      names[name]=newID;
      emails[email]=newID;
    }
    
    function id(string name) public returns (identity id){
      return names[name];
    }
}
