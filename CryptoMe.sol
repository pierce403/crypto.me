pragma solidity ^0.4.20;

// TODO
//
// auction??

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
    uint256 basePrice;
 
    mapping(string => string) addrs; // map names to addrs    
    mapping(string => identity) ids; // map addrs to ids
 
    string[] names;
 
  function CryptoMe() public
  {
    admin=msg.sender;
    basePrice=0;
  }

  function register(string name) payable public returns(string message, uint256 price, uint256 value) {
  
      //if(msg.value < basePrice/bytes(name).length)return "need more eth";
      //
      if(msg.value < basePrice)return ("need more eth",basePrice,msg.value);
      
      return (registerInternal(name),basePrice,msg.value);
  }
  
  function setBase(uint price) public returns(string message){
      if(msg.sender!=admin)return "who dis?";
      
      basePrice=price;
      return "awesome";
  }

  function getBase() constant public returns(uint){
      return basePrice;
  }

  function registerInternal(string name) private returns(string message) {
    
      // TODO verify legit name here:
      if(bytes(name).length>20)
      {
          return "name too long";
      }

      if(!legitName(name))
      {
          return "name has bad characters (lower alphanum only)";
      }
    
      // make sure we haven't seen this name before
      if(bytes(addrs[name]).length!=0)
      {
          return "name already taken";
      }
      
      // get string value of address    
      string memory addr_s = ascii(msg.sender);
      identity storage lookup = ids[addr_s];

      // does this address already have an identity?
      if(lookup.addr != address(0x0))
      {
          // we already know this ID, just add aliases
          lookup.aliases.push(name);
          
          ids[addr_s]=lookup;
          addrs[name]=addr_s;
          
          names.push(name);
          return "successfuly added new alias";
      }

      //string[] storage aliases;// = string[](name);
      //aliases.push(name);
      
      //string[] memory connections;
      
      // create the new identity
      identity storage newid; // = identity(msg.sender,addr_s,name,"email","ipfs",aliases,connections);
      newid.addr=msg.sender;
      newid.addr_s=addr_s;
      newid.name=name;
      newid.aliases.push(name);
      
      // load identity into registries
      ids[addr_s]=newid;
      addrs[name]=addr_s;
      addrs[addr_s]=addr_s;

      names.push(name);      
      return "successfully added new identity";
    }

    function getName(uint offset) public constant returns (string name, uint256 total)
    {
        return (names[offset],names.length);
    }
    
    // primary identity lookup function
    function get(string name) public constant returns (string primary, string addr,string email,string ipfs, uint aliasCount, uint connectionCount){
      identity memory id = ids[addrs[name]];
      
      return (id.name,id.addr_s,id.email,id.ipfs,id.aliases.length, id.connections.length);
    }
    
    function getAdmin() public constant returns (address adminaddr){
        return admin;
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
    
    function setPrimary(string name) public returns (string message){
        
        // look up identity
        identity memory id = ids[ascii(msg.sender)];
        
        // verify user owns the name
        for(uint x=0;x<id.aliases.length;++x){
          if(keccak256(id.aliases[x])==keccak256(name)){
            id.name=name;
            ids[id.addr_s]=id;
            addrs[name]=id.addr_s;
            return "name update successful";
          }
        }
        
        return "that name doesn't belong to you";
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
    function ascii(address x) pure internal returns (string) {
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

    function char(byte b) pure internal returns (byte c) {
      if (b < 10) return byte(uint8(b) + 0x30);
      else return byte(uint8(b) + 0x57);
    }
    
    function legitName(string s) pure private returns (bool legit){
        
        bytes memory sbytes=bytes(s);
        if(sbytes.length>20)return false;
        
        // 48 - 57  numeric
        // 97 - 122 lower alpha
        for(uint x=0;x<sbytes.length;++x){
            if((sbytes[x]<48||sbytes[x]>57)&&(sbytes[x]<97||sbytes[x]>122))return false;
        }
        
        return true;
    }
    
    function legitEmail(string s) pure private returns (bool legit){
        bytes memory sbytes=bytes(s);
        if(sbytes.length>40)return false;
        return true;
    }
    
    function legitIPFS(string s) pure private returns (bool legit){
        
        bytes memory sbytes=bytes(s);
        if(sbytes.length!=46)return false;
        return true;
    }
}
