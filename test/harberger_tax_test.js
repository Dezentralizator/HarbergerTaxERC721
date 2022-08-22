const HarbergerTaxTest = artifacts.require("ERC721Harberger");

const name1 = "Harberger";
const symbol = "HBG";

const { BN, constants, expectEvent, expectRevert } = require('@openzeppelin/test-helpers');
const { expect, assert } = require('chai');
const { ZERO_ADDRESS } = constants;


const Error = [ 'None', 'RevertWithMessage', 'RevertWithoutMessage', 'Panic' ]
  .reduce((acc, entry, idx) => Object.assign({ [entry]: idx }, acc), {});


/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("HarbergerTaxTest", function (accounts) {
  let [alice,bob] = accounts;
  it("should assert true", async function () {
    
    this.instance = await HarbergerTaxTest.deployed();
    return assert.isTrue(true);
  });
  before("hook", function(){
    console.log("I will happen here");
  });

  context("CoreInfo", function(){
    it("should have the correct name", async function (){
      expect(await this.instance.name()).to.be.equal('Harberger');
    });
    it("should have the correct symbol", async function (){
      expect(await this.instance.symbol()).to.be.equal('HBG');
    });
  });
  context("BasicMint", async function (){
    const tokenIndex = 1;
    let info;
    let time;
    const newPrice = BN(10**13); 

    it("should be able to mint a token", async function () {
      const result = await this.instance.mint(tokenIndex, {from: alice});
      const number = await web3.eth.getBlock(result.receipt.blockNumber);
      time = number['timestamp'];

      return assert.isTrue(result.receipt.status);

    });
    it("should not be able to mint the same token", async function () {
       await expectRevert( this.instance.mint(1, {from: alice}),"ERC721: token already minted");
    });
    it("should be possible to mint another token", async function () {
      expect(await this.instance.mint(2,{from: alice}));
    });
    it("should have alice as its owner", async function(){
      expect(await this.instance.ownerOf(tokenIndex)).to.be.equal(alice);
    })
    it("should be able to access the balance of Alice", async function(){
      expect(await this.instance.balanceOf(alice)).to.be.bignumber.equal('2');
    });
    it("should return a null balance for non-minters", async function(){
      expect(await this.instance.balanceOf(bob)).to.be.bignumber.equal('0');
    });
    it("Should have the correct HarbergerTime", async function(){
      info = await this.instance.getHarbergerInfo(tokenIndex);
      expect(info[0]).to.be.bignumber.equal(BN(time));
      });
    it("Should have the correct HarbergerPrice", async function(){
      expect(info[1]).to.be.bignumber.equal('0');
    });
    it("Should have the correct AccumulatedTax", async function(){
      expect(info[2]).to.be.bignumber.equal('0');
    });
    it("Should be possible to set a new price as the owner", async function(){
      
      console.log(newPrice)
      const resultTx = await this.instance.setTokenPrice(tokenIndex, newPrice, {from: alice});

      const number = await web3.eth.getBlock(resultTx.receipt.blockNumber);
      time = number['timestamp'];
      return assert.isTrue(resultTx.receipt.status);
    });
    it("Should update the info correctly", async function() {
      info = await this.instance.getHarbergerInfo(tokenIndex);
      expect(info[0]).to.be.bignumber.equal(BN(time));
      expect(info[1]).to.be.bignumber.equal(newPrice);
      expect(info[2]).to.be.bignumber.equal('0');
    });
    it("Should not be possible to set price without owning the token", async function() { 
      await expectRevert( this.instance.setTokenPrice(tokenIndex, newPrice, {from: bob}),"Only token owner can set price");
    });
  });
});
