const colors = require('colors');

const main = async () => {
  const gameContractFactory = await hre.ethers.getContractFactory('MyEpicGame');
  const gameContract = await gameContractFactory.deploy(                     
    ["TangXuanZang", "SunWuKong", "ZhuBajie", "ShaWuJing"],       // Names
    ["https://chuongtang.github.io/sourceStore/CharImg/TangXuanZang.png", // Images
      "https://chuongtang.github.io/sourceStore/CharImg/SunWuKong.png",
      "https://chuongtang.github.io/sourceStore/CharImg/ZhuBaJie.png",
      "https://chuongtang.github.io/sourceStore/CharImg/ShaWuJing.png"],
      [50, 300, 200, 100],                    // HP values
      [25, 100, 100, 50],   // Attack damage values
      "DemonLord",
      "https://chuongtang.github.io/sourceStore/CharImg/Demon.png",
      10000,
      50                  
  );
  await gameContract.deployed();
  console.log("Contract deployed to:".bgGreen, gameContract.address);

  
  let txn;
  txn = await gameContract.mintCharacterNFT(0);
  await txn.wait();
  console.log("Minted NFT #1".bgMagenta);

  txn = await gameContract.mintCharacterNFT(1);
  await txn.wait();
  console.log("Minted NFT #2".bgRed);

  txn = await gameContract.mintCharacterNFT(2);
  await txn.wait();
  console.log("Minted NFT #3".bgCyan);

  txn = await gameContract.mintCharacterNFT(3);
  await txn.wait();
  console.log("Minted NFT #4".bgYellow);

  console.log("Done deploying and minting!".red);

};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error.bgRed);
    process.exit(1);
  }
};

runMain();