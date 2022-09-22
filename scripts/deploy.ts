import { ethers } from "hardhat";

async function main() {
 
  const DappToken = await ethers.getContractFactory("DappToken");
  const dappToken = await DappToken.deploy();
  await dappToken.deployed();

  const LPToken = await ethers.getContractFactory("LPToken");
  const lPToken = await LPToken.deploy();
  await lPToken.deployed();

  const TokenFarm = await ethers.getContractFactory("TokenFarm");
  const tokenFarm = await TokenFarm.deploy(dappToken.address, lPToken.address);
  await tokenFarm.deployed();

  tokenFarm.deposit(10);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
