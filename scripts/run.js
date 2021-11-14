const colors = require('colors');

const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
  const gameContract = await gameContractFactory.deploy(
    ["TangXuanZang", "SunWuKong", "ZhuBajie", "ShaWuJing"],       // Names
    ["QmdJtXhHAUbE7fyNMQVekcVUgBAyBxYwmebzxm6hse5oew", // Images
      "QmPmdR37h7oYVEqBos1bugZ5YnHkyk8BLSjrwXDMxvcwXy",
      "QmeYvoprGkrJ6SihnaTDpezm6FSMzFHGa3GS8jdHYN38tp",
      "Qmc3WCj3wGFBZfRc2JPrzJV1muwV7bk7kJkrcBNkpSHE3a"],
    [50, 300, 200, 100],                    // HP values
    [25, 100, 100, 50],   // Attack damage values
    "DemonLord",
    "https://chuongtang.github.io/sourceStore/CharImg/Demon.png",
    10000,
    50
  );
  await gameContract.deployed();
  console.log("Contract deployed to:".green, gameContract.address.yellow);

  let txn;
  txn = await gameContract.mintCharacterNFT(1);
  await txn.wait();

  txn = await gameContract.attackDemon();
  await txn.wait();
  
  txn = await gameContract.attackDemon();
  await txn.wait();

  console.log("Done attacking!".bgYellow)
  /*"tokenURI" is the function inherited from ERC721*/
  // // Get the value of the NFT's URI.
  // let returnedTokenUri = await gameContract.tokenURI(1);
  // console.log("Token URI:".bgBlue, returnedTokenUri);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();