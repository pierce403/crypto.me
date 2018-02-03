pragma solidity ^0.4.19;

// don't try doing anything with this yet, it's still under construction!
// https://ethereum.github.io/browser-solidity

contract CryptoMe {

    struct identity {
        address addr;
        string addr_s;
        string name;
        string email;
        string ipfs;
    }

    address admin;
    mapping(address => identity) addrs;
    mapping(string => identity) names;
    mapping(string => identity) emails;
 
  function CryptoMe() public
  {
    admin=msg.sender;
  }

  function register(string name, string email) public returns(bool) {
    
      if(names[name].addr != address(0x0))
      {
          return false;
          //revert();
      }
    
      string memory addr_s = toAsciiString(msg.sender);
      identity memory newID = identity(msg.sender,addr_s,name,email,"potato");
      
      addrs[msg.sender]=newID;
      names[name]=newID;
      names[addr_s]=newID;
      //emails[email]=newID;
      
      return true;
    }
    
    function get(string name) public returns (string addr,string email,string ipfs){
        
      return (names[name].addr_s,names[name].email,names[name].ipfs);
    }
    
    function update(string email) returns(bool){
        
      identity id=addrs[msg.sender];
        
      id.email=email;
        
      addrs[msg.sender]=id;
      names[id.name]=id;
      names[id.addr_s]=id;
      //emails[email]=newID;
        
      return true;
    }
    
    // thanks tkeber
    // https://ethereum.stackexchange.com/questions/8346/convert-address-to-string
    function toAsciiString(address x) internal returns (string) {
    bytes memory s = new bytes(40);
    for (uint i = 0; i < 20; i++) {
        byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        byte hi = byte(uint8(b) / 16);
        byte lo = byte(uint8(b) - 16 * uint8(hi));
        s[2*i] = char(hi);
        s[2*i+1] = char(lo);            
    }
    return string(s);
    }

    function char(byte b) internal returns (byte c) {
      if (b < 10) return byte(uint8(b) + 0x30);
      else return byte(uint8(b) + 0x57);
    }

}
