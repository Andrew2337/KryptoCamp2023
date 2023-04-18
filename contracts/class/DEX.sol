const { expect } = require("chai");
const { ethers } = require("hardhat");

const toEtherUnit = (amount) => ethers.utils.parseEther(amount);

describe("v1", function () {
  it("T1", async function () {
    const [owner, other] = await ethers.getSigners();

    const DAI = await ethers.getContractFactory("ERC20Token");
    const dai = await DAI.deploy("DAI", "DAI", toEtherUnit("1200001"));
    await dai.deployed();

    const Exchange = await ethers.getContractFactory("Exchange");
    const exchange = await Exchange.deploy(dai.address);
    await exchange.deployed();

    expect(await dai.balanceOf(owner.address)).to.be.eq(toEtherUnit("1200001"));
    expect(await dai.totalSupply()).to.be.eq(toEtherUnit("1200001"));
    expect(await exchange.totalSupply()).to.be.eq(toEtherUnit("0"));

    // approve for exchange transfer
    await dai.approve(exchange.address, toEtherUnit("600000"));
    await exchange.addLiquidity(0, toEtherUnit("600000"), 0, {
      value: toEtherUnit("200"),
    });

    // exchange has 3000 dai and 1 ETH
    expect(await ethers.provider.getBalance(exchange.address)).to.be.equal(
      toEtherUnit("200")
    );
    expect(await dai.balanceOf(exchange.address)).to.be.equal(
      toEtherUnit("600000")
    );
    // runout dai token
    expect(await dai.balanceOf(owner.address)).to.be.eq(toEtherUnit("600001"));
    // owner get exchange LP token
    expect(await exchange.balanceOf(owner.address)).to.be.equal(
      toEtherUnit("200")
    );

    // second add liquidity
    await dai.approve(exchange.address, toEtherUnit("600001"));
    await exchange.addLiquidity(0, toEtherUnit("600001"), 0, {
      value: toEtherUnit("200"),
    });

    expect(await exchange.balanceOf(owner.address)).to.be.equal(
      toEtherUnit("400")
    );

    // change tokens
    await exchange.ethToTokenTransferInput(toEtherUnit("0"), {
      value: toEtherUnit("1"),
    });
    console.log(ethers.utils.formatEther(await dai.balanceOf(owner.address)));
  });
});