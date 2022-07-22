import { ethers, network } from "hardhat"
import { Signer, Contract, ContractFactory, BigNumber, providers, ContractTransaction } from "ethers"
import chai, { use } from "chai"
import { solidity } from "ethereum-waffle"
import { AddressZero } from "@ethersproject/constants"
import type { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers"
import type { TransactionResponse, TransactionReceipt, Log } from "@ethersproject/abstract-provider"
import { assert } from "console"
import {
    MultiSender,
    MultiSender__factory,
    ERC20Mock,
    ERC20Mock__factory,
} from "../typechain"
import { it } from "mocha"

chai.use(solidity)
const { expect } = chai
const { formatUnits, parseUnits } = ethers.utils

function getRndInteger(min: number, max: number) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function range(start: number, end?: number): number[] {
    if (end === undefined) {
        end = start
        start = 0
    }
    return Array.from({ length: end - start }, (_, i) => i + start)
}

async function skipTimeTo(timestamp: number) {
    await network.provider.send("evm_setNextBlockTimestamp", [timestamp])
    await network.provider.send("evm_mine")
}

function ether(eth: string) {
    let weiAmount = ethers.utils.parseEther(eth)
    return weiAmount;
}

function wei(wei: string): string {
    let eth = ethers.utils.formatEther(wei)
    return eth;
}

async function getLatestBlockTimestamp() {
    return (await ethers.provider.getBlock("latest")).timestamp || 0
}

function getUsersAddresses(users: SignerWithAddress[]) : string[] {
    let usersAddresses: string[] = []
    for(let i = 0; i < users.length; i++) {
        usersAddresses.push(users[i].address);
    }
    return usersAddresses;
}

function getAmounts(addressesAmount: number) : BigNumber[] {
    let amounts = []
    for(let i: number = 0; i < addressesAmount; i++) {
        let amount = 100;
        let amountsEther = ether(amount.toString());
        amounts.push(amountsEther);
    }
    return amounts;
}

describe("MultiSender", async () => {
    let owner;
    let users: Array<SignerWithAddress>;
    let ERC20MockFactory: ERC20Mock__factory;
    let erc20Mock: ERC20Mock;
    let MultiSenderFactory: MultiSender__factory;
    let multiSender: MultiSender;

    beforeEach("Deploy the contract", async function () {
        [owner, ...users] = await ethers.getSigners();

        ERC20MockFactory = new ERC20Mock__factory(owner);
        erc20Mock = await ERC20MockFactory.deploy();
        await erc20Mock.deployed();

        MultiSenderFactory = new MultiSender__factory(owner);
        multiSender = await MultiSenderFactory.deploy();
        await multiSender.deployed();

    });

    it("airdrop to 1000 addresses", async function () {
        let airdropAddresses = getUsersAddresses(users.slice(0, 1000));
        console.log("A")
        expect(await multiSender.initialize(10000, 1)).to.ok;

        //expect(await multiSender.setArrayLimit(10000)).to.ok;
        expect(await multiSender.multiSend(erc20Mock.address, airdropAddresses, getAmounts(1000))).to.ok;
        
    });
});