pragma solidity ^0.4.20;

// TODO
//
//
// auction??

contract CryptoMe {

    struct identity {
        address addr;
        string name;
        string email;
        string ipfs;
        
        string[] aliases;
        string[] connections;
    }

    uint basePrice;
    address admin;

    //mapping(string => address) addrs; // map names to addrs    
    mapping(string => address) lookup; // map names to addrs    
    mapping(address => identity) ids; // map addrs to primary id
 
    string[] names;
 
    struct auction{
      string  name;
      address owner;
      address winner;
    
      uint currentBid;
      uint stop;
      
      uint endTime;
    }
    
    auction[] auctions;
 
  function CryptoMe() public
  {
    admin=msg.sender;
    basePrice=0;
  }

  function setBase(uint price) public returns(string message){
      if(msg.sender!=admin)return "who dis?";
      
      basePrice=price;
      return "awesome";
  }

  function getBase() constant public returns(uint){
      return basePrice;
  }

  function register(string name) payable public returns(string message) {
      
      if(bytes(name).length<2)
      {
          return "name too short";
      }

      if(bytes(name).length>20)
      {
          return "name too long";
      }

      if(!legitName(name))
      {
          return "name has bad characters (lower alphanum only)";
      }

      // make sure that the payment is right
      // admin gets in for free (for sideloading old names)
      if( (msg.sender!=admin) && msg.value < (basePrice/bytes(name).length) )return ("need more eth");


      // make sure we haven't seen this name before
      if(lookup[name]!=0)
      {
          return "name already taken";
      }
      
      // get string value of address    
      // string memory addr_s = ascii(msg.sender);
      identity storage oldid = ids[msg.sender];

      // does this address already have an identity?
      if(oldid.addr != address(0x0))
      {
          // we already know this ID, just add aliases
          oldid.aliases.push(name);

          lookup[name]=msg.sender;
          ids[msg.sender]=oldid;
          
          names.push(name);
          return "successfuly added new alias";
      }

      // create the new identity
      identity storage newid = ids[msg.sender];
      newid.addr=msg.sender;
      newid.name=name;
      newid.aliases.push(name);
      
      // load identity into registries
      //ids[addr_s]=newid;
      lookup[name]=msg.sender;
      lookup[ascii(msg.sender)]=msg.sender;

      names.push(name);      
      return "successfully added new identity";
    }

    function getName(uint offset) public constant returns (string name, uint256 total)
    {
        if(offset >= names.length)return("not that many names",names.length);
        
        return (names[offset],names.length);
    }
    
    // primary identity lookup function
    function get(string name) public constant returns (string primary, string addr,string email,string ipfs, uint aliasCount, uint connectionCount){
      identity memory id = ids[lookup[name]];
      
      return (id.name,ascii(id.addr),id.email,id.ipfs,id.aliases.length, id.connections.length);
    }
    
    function getAdmin() public constant returns (address adminaddr){
        return admin;
    }
    
    function setAdmin(string name) public returns (bool)
    {
        if(msg.sender!=admin)return false;
        if(lookup[name]==0)return false;
        admin=lookup[name];
        return true;
    }
    
    // id'd like to return all of them at once,
    // but arrays of strings can't be passed around
    function getAlias(string name,uint offset) public constant returns (string alias){
      return ids[lookup[name]].aliases[offset];  
    }
    
    function getConnection(string name,uint offset) public constant returns (string connection){
      return ids[lookup[name]].connections[offset];  
    }
    
    function update(string email, string ipfs) public returns(string message){
        
      if(!legitEmail(email))return "email is not legit";
      if(!legitIPFS(ipfs))return "IPFS is not legit";
      
      // check uniqueness
      if(lookup[email]!=0)return "email already taken";
      lookup[email]=msg.sender; // add email to aliases

      // set the updated data      
      ids[msg.sender].email=email;
      ids[msg.sender].ipfs=ipfs;

      return "update successful";
    }
    
    function setPrimary(string name) public returns (string message){
        
        // look up identity
        identity memory id = ids[msg.sender];
        
        // verify user owns the name
        for(uint x=0;x<id.aliases.length;++x){
          if(keccak256(id.aliases[x])==keccak256(name)){
            id.name=name;
            ids[id.addr]=id;
            lookup[name]=id.addr;
            return "name update successful";
          }
        }
        
        return "that name doesn't belong to you";
    }
    
    function addConnection(string connection) public returns(bool){
     
      // is this connection a real user?
      if(lookup[connection]==0)
      {
          return false;
          //revert();
      }
      
      // add the connection to the user
      ids[msg.sender].connections.push(connection);
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

        for(uint x=0;x<sbytes.length;++x){
            if(sbytes[x]==64)return true; // make sure there's an '@' in there
        }
        
        return false;
    }
    
    function legitIPFS(string s) pure private returns (bool legit){
        
        bytes memory sbytes=bytes(s);
        if(sbytes.length!=46)return false;
        return true;
    }
    
    // the auction functions
    
    function newAuction(string name, uint stop) public payable returns (string message){
        
        // TODO make sure user owns name
        // TODO make sure the name isn't already contracted
        
        auction memory a = auction(name, msg.sender,msg.sender,msg.value,stop,now+60*60*24*7);
        auctions.push(a);
        
        return "yay";
    }
    
    function getAuction(uint x) public constant returns(string name, uint endTime, uint currentBid, uint stop, uint length){
        auction memory a = auctions[x];
        return (a.name, a.endTime, a.currentBid, a.stop, auctions.length);
    }
    
    function bid(uint x) public payable returns (string message){

       auctions[x].winner=msg.sender;    
       auctions[x].currentBid=msg.value;

       return "yay";
    }
    
    function claimAuction(uint x)public returns(string message){
        if(auctions[x].endTime<now)return "the auction isn't over yet";
        
        // TODO remove the alias from the owner
        
        // reassign the name in the lookup table
        lookup[auctions[x].name]=auctions[x].winner;
        
        // TODO add the alias to the winner
        
        // TODO pay the owner
        
        return "yay";
    }
}
