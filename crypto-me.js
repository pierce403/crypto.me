// CryptoMe ABI
const abi = [{
    "constant": true,
    "inputs": [{
      "name": "name",
      "type": "string"
    }],
    "name": "get",
    "outputs": [{
        "name": "addr",
        "type": "string"
      },
      {
        "name": "email",
        "type": "string"
      },
      {
        "name": "ipfs",
        "type": "string"
      }
    ],
    "payable": false,
    "stateMutability": "view",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [{
        "name": "name",
        "type": "string"
      },
      {
        "name": "email",
        "type": "string"
      }
    ],
    "name": "register",
    "outputs": [{
      "name": "",
      "type": "bool"
    }],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "constant": false,
    "inputs": [{
      "name": "email",
      "type": "string"
    }],
    "name": "update",
    "outputs": [{
      "name": "",
      "type": "bool"
    }],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "payable": false,
    "stateMutability": "nonpayable",
    "type": "constructor"
  }
]

console.log("this is strange");

try {
  console.log("HI! your default account is " + web3.eth.defaultAccount);
} catch (e) {
  $("#msg").html("The distributed web requires the <b>MetaMask</b> browser extension. Please go install it now.");
  console.log("o no..")
}

web3.version.getNetwork((err, netId) => {
  if (netId != 3) {
    $("#netwarn").html("Please switch MetaMask to the <b>Ropsten</b> network.")
  }
})

if (!web3.eth.defaultAccount) {
  $("#msg").html("Please unlock MetaMask");
} else {
  web3.eth.getBalance(web3.eth.defaultAccount, function(error, result) {
    console.log(result)
    console.log(result.c[0] + " " + result.c[1]);

    // print balance:
    balance = result.c[0] / 10000;
    console.log("balance is " + balance);

    if (balance === 0) {
      $("#msg").html("Looks like you could use some Ropsten ETH. Try this <a style='color:#17b06b' href='http://faucet.ropsten.be:3001/'>faucet</a>.");
    }
  })
}

//const address = '0xd82429B0126535Ff0B8453EBA606334DE2F79836'; // first attempt, broken
const address = '0x9abfc27a2d79af78e0a5479d58cab6377612baba'; // maybe working ropsten

// creation of contract object
var CryptoMe = web3.eth.contract(abi);

// initiate contract for an address
var cryptoMe = CryptoMe.at(address);
console.log(cryptoMe);

// check the anchor to see if we have something to search for
if (location.hash) {
  $("#search").val(location.hash.substr(1));
  search();
}
else {
  // see if this person has registered
  var result = cryptoMe.get(web3.eth.defaultAccount.substr(2), function(err, res) {
    if (err) {
      console.log(err);
      return;
    }

    console.log("BOOM")
    console.log(res);

    if (res[0] === "") {
      if ($("msg").val() === '')
        $("#msg").text("You have not registered any identities, register now!");
    }
    else {
      $("#msg").text("Welome back!");
      $("#name").text($("#search").val());
      location.hash = $("#search").val();
    }
    $("#addr").text(res[0]);
    $("#email").text(res[1]);
    $("#ipfs").text(res[2]);
  });
}

function search() {
  console.log("search.. " + $("#search").val());
  $("#name").text($("#search").val());

  var result = cryptoMe.get($("#search").val(), function(err, res) {
    if (err) {
      console.log(err);
      return;
    }

    console.log(res);

    if (res[0] === "") {
      $("#name").text($("#search").val() + " (user not found)");
    } else {
      $("#name").text($("#search").val());
      location.hash = $("#search").val();
    }
    $("#addr").text(res[0]);
    $("#email").text(res[1]);
    $("#ipfs").text(res[2]);
  });
  //console.log(result);
}

function register() {
  console.log("called!")

  var name = $("#newname").val();
  var email = $("#newemail").val();

  var result = cryptoMe.register(name, email, function(err, res) {
    console.log(res);
  });

  console.log("register result:");
  console.log(result);
  $('#reg-modal').modal('hide');
}

function update() {
  console.log("called!")

  var email = $("#updatedemail").val();

  var result = cryptoMe.update(email, function(err, res) {
    console.log(res);
  });

  console.log("update result:");
  console.log(result);
  $('#update-modal').modal('hide');
}
