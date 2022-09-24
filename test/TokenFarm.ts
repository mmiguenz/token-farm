
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { BigNumber, ContractTransaction } from "ethers";
import { ethers } from "hardhat";
import { TokenFarm } from "../typechain-types";
import { LPToken } from "../typechain-types/contracts/LPToken";

describe("TokenFarm", function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployTokenFarmFixture() {
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

    await lPToken.transfer(otherAccount.address, ethers.BigNumber.from("10000000000000000000"))

    return { tokenFarm, lPToken, dappToken, owner, otherAccount };
  }
  describe("Deployment", function () {

    it("Should set the right erc20 tokens", async function () {
      const { tokenFarm, lPToken, dappToken, owner } = await loadFixture(deployTokenFarmFixture);
      expect(await tokenFarm.dappToken()).to.equal(dappToken.address);
      expect(await tokenFarm.lpToken()).to.equal(lPToken.address);
    });

    it("Should set the right owner", async function () {
      const { tokenFarm, owner } = await loadFixture(deployTokenFarmFixture);
      expect(await tokenFarm.owner()).to.equal(owner.address);
    });
  });

  describe("Deposit", function () {
    it("Should transfer tokens from sender", async function () {
      const { tokenFarm, lPToken, dappToken, owner, otherAccount } = await loadFixture(deployTokenFarmFixture);
      let amoutForStaking = ethers.BigNumber.from("10000000000000000000");

      await givenApprovedLPTokens(lPToken, otherAccount, tokenFarm.address, amoutForStaking)

      const transaction = await whenDeposit(tokenFarm, otherAccount, amoutForStaking)

      await shouldStakeLPTokens(tokenFarm, lPToken, otherAccount.address, amoutForStaking)

      await shouldEmitStakedEvent(transaction, tokenFarm, otherAccount.address, amoutForStaking)

    });

    const givenApprovedLPTokens =
      async (lPToken: LPToken, accountApprover: any, accountAddressGranted: string, amount: BigNumber) =>
        await lPToken
          .connect(accountApprover)
          .approve(accountAddressGranted, amount)

    const whenDeposit =
      async (tokenFarm: TokenFarm, account: any, amount: BigNumber) =>
        await tokenFarm
          .connect(account)
          .deposit(amount)
    const shouldStakeLPTokens = async (tokenFarm: TokenFarm, lpToken: LPToken, stakerAddress: string, amount: BigNumber) => {
      expect(await tokenFarm.stakingBalance(stakerAddress)).to.equal(amount);
      expect(await tokenFarm.isStaking(stakerAddress)).to.equal(true);
      expect(await tokenFarm.stakers(0)).to.equals(stakerAddress);
      expect(await lpToken.balanceOf(stakerAddress)).to.equal(0);
    }

    const shouldEmitStakedEvent = async (transaction: ContractTransaction, tokenFarm: TokenFarm, stakerAddress: string, amount: BigNumber) => {
      await expect(transaction).to.emit(tokenFarm, "Staked").withArgs(stakerAddress, amount)
    }
  });

  describe("withdraw", function () {
    it("Should recover staked tokens", async function () {
      const { tokenFarm, lPToken, dappToken, owner, otherAccount } = await loadFixture(deployTokenFarmFixture);

      await givenAStakedContract(tokenFarm, lPToken, otherAccount)

      let amoutForWithdraw = await tokenFarm.stakingBalance(otherAccount.address)

      const transaction = await whenWithdraw(tokenFarm, otherAccount)

      await shouldRecoverLPTokens(tokenFarm, lPToken, otherAccount.address, amoutForWithdraw)
      await shouldEmitWithdrawnEvent(transaction, tokenFarm, otherAccount.address, amoutForWithdraw)
    });

    const givenAStakedContract =
      async (tokenFarm: TokenFarm, lPToken: LPToken, accountStaker: any) => {
        let amoutForStaking = ethers.BigNumber.from("10000000000000000000");
        await lPToken
          .connect(accountStaker)
          .approve(tokenFarm.address, amoutForStaking)

        await tokenFarm
          .connect(accountStaker)
          .deposit(amoutForStaking)
      }

    const whenWithdraw =
      async (tokenFarm: TokenFarm, account: any) =>
        await tokenFarm
          .connect(account)
          .withdraw()
    const shouldRecoverLPTokens = async (tokenFarm: TokenFarm, lpToken: LPToken, stakerAddress: string, amountToWithdraw: BigNumber) => {
      expect(await tokenFarm.stakingBalance(stakerAddress)).to.equal(0);
      expect(await tokenFarm.isStaking(stakerAddress)).to.equal(false);
      expect(await lpToken.balanceOf(stakerAddress)).to.equal(amountToWithdraw);
    }

    const shouldEmitWithdrawnEvent = async (transaction: ContractTransaction, tokenFarm: TokenFarm, stakerAddress: string, amount: BigNumber) => {
      await expect(transaction).to.emit(tokenFarm, "Withdrawn").withArgs(stakerAddress, amount)
    }
  });
});
