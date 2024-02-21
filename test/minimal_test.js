const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("TEST 404", function (){
        let con404;
        let accounts;
        it("Should Deploy Minimal404", async function() {
            accounts = await ethers.getSigners();
            const T404 =  await ethers.getContractFactory("TierERC404");
            let con4 = await T404.deploy(
                "Name1",
                "Symbol1",
                18,10000,
                accounts[0].address,
                true
            );
            con404 = T404.attach(await con4.getAddress());
            }
        )


        it("Should Transfer Funds to account 2", async function (){
                let minimum_send = await con404.classificationSize(0)*10n;
                await con404.transfer(accounts[1].address, minimum_send);
                // console.log(await con404.getNFTsByTier(accounts[1].address,"1000000000000000000000"));
                await con404.transfer(accounts[1].address, minimum_send);
                // console.log(await con404.getNFTsByTier(accounts[1].address,"2000000000000000000000"));
                // console.log(await con404.getNFTsByTier(accounts[1].address,"1000000000000000000000"));
                await con404.transfer(accounts[1].address, minimum_send);
                // console.log(await con404.getNFTsByTier(accounts[1].address,"1000000000000000000000"));
                // console.log(await con404.getNFTsByTier(accounts[1].address,"2000000000000000000000"));
                // console.log(await con404.getNFTsByTier(accounts[1].address,"3000000000000000000000"));
                await con404.transfer(accounts[1].address, minimum_send*6n);
                // console.log(await con404.getNFTsByTier(accounts[1].address,"4000000000000000000000"));
                // console.log(await con404.getNFTsByTier(accounts[1].address,"2000000000000000000000"));
                // console.log(await con404.balanceOf(accounts[1].address));
                let data  = await con404.getTokenTierAndIndex(27);
                // console.log(data[0]);
                // console.log((await con404.getNFTsByTier(accounts[1].address,"400000000000000000000")));
                await con404.connect(accounts[1]).approve(accounts[2].address, 7);
                console.log(await con404.balanceOf(accounts[2].address));
                await con404.connect(accounts[2]).transferFrom(accounts[1].address, accounts[2].address, 7);
                console.log(await con404.balanceOf(accounts[2].address));
                let balance_acc_1 = await con404.balanceOf(accounts[1].address);
                //send everything  to account 2
                console.log("Before transfer tier 4",(await con404.getNFTsByTier(accounts[1].address,"400000000000000000000")));
                console.log("Before transfer tier 3",(await con404.getNFTsByTier(accounts[1].address,"300000000000000000000")));
                console.log("Before transfer tier 2",(await con404.getNFTsByTier(accounts[1].address,"200000000000000000000")));
                console.log("Before transfer tier 1",(await con404.getNFTsByTier(accounts[1].address,"100000000000000000000")));
                console.log("Before transfer tier 0",(await con404.getNFTsByTier(accounts[1].address,"0")));
                await con404.connect(accounts[1]).transfer(accounts[2].address, balance_acc_1);
                console.log(await con404.balanceOf(accounts[2].address));
                console.log("After transfer tier 4",(await con404.getNFTsByTier(accounts[2].address,"400000000000000000000")));
                console.log("After transfer tier 3",(await con404.getNFTsByTier(accounts[2].address,"300000000000000000000")));
                console.log("After transfer tier 2",(await con404.getNFTsByTier(accounts[2].address,"200000000000000000000")));
                console.log("After transfer tier 1",(await con404.getNFTsByTier(accounts[2].address,"100000000000000000000")));
                console.log("After transfer tier 0",(await con404.getNFTsByTier(accounts[2].address,"0")));





                // await con404.connect(accounts[1]).approve(accounts[2].address, 2);

            }
        )
    }
)