import { time, loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";

describe("TokenFarm", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployTokenFarmixture() {   
// Contracts are deployed using the first signer/account by default
    const [owner, otherAccount] = await ethers.getSigners();

    const DappToken = await ethers.getContractFactory("DappToken");
    const dappToken = await DappToken.deploy();
    await dappToken.deployed();

    const LPToken = await ethers.getContractFactory("LPToken");
    const lPToken = await LPToken.deploy();
    await lPToken.deployed();

    const TokenFarm = await ethers.getContractFactory("TokenFarm");
    const tokenFarm = await TokenFarm.deploy(dappToken.address, lPToken.address);
    await tokenFarm.deployed();
    return { tokenFarm, lPToken, dappToken, owner, otherAccount };
  }

  describe("Deployment", function () {
    it("Should set the right erc20 tokens", async function () {
      const { tokenFarm, lPToken, dappToken, owner } = await loadFixture(deployTokenFarmixture);
      
      expect(await tokenFarm.dappToken()).to.equal(dappToken.address);
      expect(await tokenFarm.lpToken()).to.equal(lPToken.address);
    });

    it("Should set the right owner", async function () {
      const { tokenFarm, owner } = await loadFixture(deployTokenFarmixture);

      expect(await tokenFarm.owner()).to.equal(owner.address);
    });    
  });
});
