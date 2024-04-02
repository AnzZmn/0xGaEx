import {expect} from 'chai'
import { viem } from 'hardhat'
import {formatEther} from 'viem'
import {loadFixture} from '@nomicfoundation/hardhat-network-helpers'
import"@nomicfoundation/hardhat-chai-matchers"

const TOKEN_ID = 1n;
const URI = "/GAME_ACCOUNT"
const BASE_URL = "MY_CUSTOM_URI";
const NAME = "GameToken"
const SYMBOL = "GFT"
const ROYALTY = 5n
const SALE_PRICE = 1000000000000000000n

async function fixture() {
        const publicClient = await viem.getPublicClient();
        const [deployer, acc1, acc2, approveAcc] = await viem.getWalletClients();
        const AdminContract = await viem.deployContract("Administrator");
        const tokenContract = await viem.deployContract("GToken",[NAME,SYMBOL,BASE_URL,AdminContract.address]);
        return {tokenContract, AdminContract, deployer, acc1, acc2, publicClient, approveAcc};
}



describe("Decentralized Exchange Protocol Test Suite",()=>{
        
        describe('GToken Test Cases',()=>{

            it(`Should deploy with Name: ${NAME} , Symbol: ${SYMBOL} and BaseURL: ${BASE_URL} `, async ()=>{
                const { tokenContract } = await loadFixture(fixture);
                expect(await tokenContract.read.baseURI()).to.eq(BASE_URL);
                expect(await tokenContract.read.name()).to.eq(NAME);
                expect(await tokenContract.read.symbol()).to.eq(SYMBOL);
            })

            it('should mint the Token Properly from Acc1',async()=>{
                const { tokenContract, acc1 , publicClient } = await loadFixture(fixture)
                const mintTx = await tokenContract.write.mint([TOKEN_ID,URI, ROYALTY],{account: acc1.account})
                expect((await tokenContract.read.ownerOf([TOKEN_ID])).toUpperCase()).to.eq(acc1.account.address.toUpperCase())
                expect(await tokenContract.read.balanceOf([acc1.account.address])).to.eq(1);
            })
    
            it('Should Set The TokenURI upon minting new Token', async()=>{
                const { tokenContract, acc1, publicClient   } = await loadFixture(fixture)
                const mintTx = await tokenContract.write.mint([TOKEN_ID,URI, ROYALTY],{account: acc1.account})
                expect(await tokenContract.read.tokenURI([TOKEN_ID])).to.eq(BASE_URL+URI)
            })
    
            it(`Should set the Royalty to ${ROYALTY}%`,async()=>{
                const { tokenContract, acc1 } = await loadFixture(fixture)
                const mintTx = await tokenContract.write.mint([TOKEN_ID,URI, ROYALTY],{account: acc1.account})
                const [ reciever, amount ] = await tokenContract.read.royaltyInfo([TOKEN_ID,SALE_PRICE])  
                expect(amount).to.eq((ROYALTY*SALE_PRICE)/100n)
                expect(reciever.toUpperCase()).to.eq(acc1.account.address.toUpperCase())
            })

            it('Should Set the Operator to Administrator Contract on Minting a New Token',async()=>{
                const { acc1, tokenContract, AdminContract } = await loadFixture(fixture)
                const mintTx = await tokenContract.write.mint([TOKEN_ID,URI, ROYALTY],{account: acc1.account})
                expect(await tokenContract.read.isApprovedForAll([acc1.account.address, AdminContract.address])).to.be.true
            })
        })

        describe('ExProtocol Test Cases',()=>{

            it('should Deploy Escrow Contract Properly',async()=>{
                const { acc1, deployer, tokenContract, AdminContract } = await loadFixture(fixture)
                throw new Error("Intentional test error");

            })

            describe('Should Transfer The Asset Properly', () => {

                it('Should initiate Transfer When Calling Approve from Administrator',async()=>{
                    const { acc1, tokenContract, AdminContract } = await loadFixture(fixture)
                    throw new Error("Intentional test error");
                })
            })

            
        })

        




        
})