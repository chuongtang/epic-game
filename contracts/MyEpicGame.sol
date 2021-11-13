// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./libraries/Base64.sol";

// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

import "hardhat/console.sol";

/*my contract inherits from ERC721, which is the standard NFT contract! */
contract MyEpicGame is ERC721 {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  struct CharacterAttributes {
    uint characterIndex;
    string name;
    string imageURI;        
    uint hp;
    uint maxHp;
    uint attackDamage;
  }
  // Declare 'defaultCharacters' array to store each character
  CharacterAttributes[] defaultCharacters;

  // State of player's NFT will be stored in this state variable ⇩
  mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

  struct Demon {
  string name;
  string imageURI;
  uint hp;
  uint maxHp;
  uint attackDamage;
}

// Set variable ⇩ to data from Demon
Demon public demon;

  /* A mapping from an user's address to the NFTs tokenId. Gives me an ez way
  to store the owner of the NFT and reference it later.*/
  mapping(address => uint256) public nftHolders;

  // Constructor will set up characters and will run only once when the contract is executed.
  constructor(
    string[] memory characterNames,
    string[] memory characterImageURIs,
    uint[] memory characterHp,
    uint[] memory characterAttackDmg,
    string memory demonName, 
    string memory demonImageURI,
    uint demonHp,
    uint demonAttackDamage

  /* Set up identifier symbols for my NFT.
  This is the name and symbol for my token, ex Ethereum and ETH. I just call mine
  Masters and MSTR. Remember, an NFT is just a token! */
  )
    ERC721("Masters", "MSTR")
  {

      // Initialize the boss. Save it to our global "demon" state variable.
  demon = Demon({
    name: demonName,
    imageURI: demonImageURI,
    hp: demonHp,
    maxHp: demonHp,
    attackDamage: demonAttackDamage
  });

  console.log("Done initializing boss %s w/ HP %s, img %s", demon.name, demon.hp, demon.imageURI);

    /*Loop through all the characters, and save their values in my contract so
    we can use them later when we mint my NFTs.*/
    for(uint i = 0; i < characterNames.length; i += 1) {
      defaultCharacters.push(CharacterAttributes({
        characterIndex: i,
        name: characterNames[i],
        imageURI: characterImageURIs[i],
        hp: characterHp[i],
        maxHp: characterHp[i],
        attackDamage: characterAttackDmg[i]
      }));

     CharacterAttributes memory c = defaultCharacters[i];
      
      // Hardhat's use of console.log() allows up to 4 parameters in any order of following types: uint, string, bool, address
      console.log("Done initializing %s w/ HP %s, img %s", c.name, c.hp, c.imageURI);
    }
  /* I increment tokenIds here so that my first NFT has an ID of 1. */
    _tokenIds.increment();
  }

  /* Users would be able to hit this function and mint their NFT based on the 
  characterId they send in! */
  function mintCharacterNFT(uint _characterIndex) external {
    // Get current tokenId (starts at 1 since we incremented in the constructor).
    uint256 newItemId = _tokenIds.current();

    // The magical function! Assigns the tokenId to the caller's wallet address.
    _safeMint(msg.sender, newItemId);

    /* Map the tokenId to => their character attributes:
    As players play the game, certain values on their character will change. 
    This ⇩ is how Dynamic Data are stored on the NFT*/ 
    nftHolderAttributes[newItemId] = CharacterAttributes({
      characterIndex: _characterIndex,
      name: defaultCharacters[_characterIndex].name,
      imageURI: defaultCharacters[_characterIndex].imageURI,
      hp: defaultCharacters[_characterIndex].hp,
      maxHp: defaultCharacters[_characterIndex].maxHp,
      attackDamage: defaultCharacters[_characterIndex].attackDamage
    });

    console.log("Minted NFT w/ tokenId %s and characterIndex %s", newItemId, _characterIndex);
    
    /* Map the user's public wallet address to the NFTs tokenId
    An easy way to see who owns what NFT.*/
    nftHolders[msg.sender] = newItemId;

    /* After the NFT is minted, 
    Increment the tokenId for the next person that uses it.
    OpenZeppelin gives ⇩ function  */
    _tokenIds.increment();
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
  /* Retrieve specific NFTs data by querying for it using it's "_tokenId " 🢛
  that was passed in to the function */  
  CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

  string memory strHp = Strings.toString(charAttributes.hp);
  string memory strMaxHp = Strings.toString(charAttributes.maxHp);
  string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);

  // Then, we take all that data and pack it nicely in a variable named json.
  string memory json = Base64.encode(
    bytes(
      string(
        abi.encodePacked( //⇐ this line combines strings from above NFT data
          '{"name": "',
          charAttributes.name,
          ' -- NFT #: ',
          Strings.toString(_tokenId),
          '", "description": "This is an NFT that lets people play in the game: "Journey to the West!"", "image": "',
          charAttributes.imageURI,
          '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
          strAttackDamage,'} ]}'
        )
      )
    )
  );

  string memory output = string(
    abi.encodePacked("data:application/json;base64,", json)
  );
  
  return output;
}

function attackDemon() public {
  // Get the state of the player's NFT.
  uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
  CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
  console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.name, player.hp, player.attackDamage);
  console.log("Demon %s has %s HP and %s AD", demon.name, demon.hp, demon.attackDamage);

  // Make sure the player has more than 0 HP.
  require (
    player.hp > 0,
    "Error: character must have HP to attack boss."
  );

  // Make sure the Demon has more than 0 HP.
  require (
    demon.hp > 0,
    "Error: Demon must have HP to attack others."
  );

  // Allow player to attack Demon.
  /* We declared hp as unint: "unsigned integer" meaning it can't be negative! 
  If hp gets negative, set it to 0*/
  if (demon.hp < player.attackDamage) {
    demon.hp = 0;
  } else {
    demon.hp = demon.hp - player.attackDamage;
  }

  // Allow Demon to attack player.
  if (player.hp < demon.attackDamage) {
    player.hp = 0;
  } else {
    player.hp = player.hp - demon.attackDamage;
  }
  
  // Console for ease.
  console.log("Player attacked Demon. New demon hp: %s", demon.hp);
  console.log("Demon attacked player. New player hp: %s\n", player.hp);

}

}