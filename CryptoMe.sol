pragma solidity ^0.4.19;

contract CryptoMe {

    struct identity {
        address addr;
        string addr_s;
        string name;
        string email;
        string ipfs;
        
        string[] aliases;
        string[] connections;
    }

    address admin;

    mapping(string => string) addrs; // map names to addrs    
    mapping(string => identity) ids; // map addrs to ids
 
  function CryptoMe() public
  {
    admin=msg.sender;
  }

  function register(string name) public returns(bool) {
    
      // TODO verify legit name here:
    
      // make sure we haven't seen this name before
      if(bytes(addrs[name]).length!=0)
      {
          return false;
      }

      // get string value of address    
      string memory addr_s = ascii(msg.sender);
      identity lookup = ids[addr_s];
      
      // does this address already have an identity?
      if(lookup.addr != address(0x0))
      {
          // we already know this ID, just add aliases
          lookup.aliases.push(name);
          
          ids[addr_s]=lookup;
          addrs[name]=addr_s;
          
          return true;
      }

      identity storage newid; //= identity(msg.sender,addr_s,name,"email","ipfs",aliases,connections);
      newid.addr = msg.sender;
      newid.addr_s = addr_s;
      newid.email="email";
      newid.ipfs="ipfs";
      newid.aliases.push(name);
      
      ids[addr_s]=newid;
      addrs[name]=addr_s;
      addrs[addr_s]=addr_s;
      
      return true;
    }
    
    // primary identity lookup function
    function get(string name) public constant returns (string primary, string addr,string email,string ipfs, uint aliasCount, uint connectionCount){
      identity memory id = ids[addrs[name]];
      
      return (id.name,id.addr_s,id.email,id.ipfs,id.aliases.length, id.connections.length);
    }
    
    // id'd like to return all of them at once,
    // but arrays of strings can't be passed around
    function getAlias(string name,uint offset) public constant returns (string alias){
      return ids[addrs[name]].aliases[offset];  
    }
    
    function getConnection(string name,uint offset) public constant returns (string connection){
      return ids[addrs[name]].connections[offset];  
    }
    
    function update(string email, string ipfs) public returns(bool){
        
      identity memory id=ids[ascii(msg.sender)];
      id.email=email;
      id.ipfs=ipfs;
      ids[id.addr_s]=id;

      return true;
    }
    
    function addConnection(string connection) public returns(bool){
     
      // is this connection a real user?
      if(bytes(addrs[connection]).length==0)
      {
          return false;
          //revert();
      }
      
      // add the connection to the user
      ids[ascii(msg.sender)].connections.push(connection);
      // I probally need to reinsert don't I?
      
      return true;
    }
    
    // thanks tkeber
    // https://ethereum.stackexchange.com/questions/8346/convert-address-to-string
    function ascii(address x) internal returns (string) {
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
