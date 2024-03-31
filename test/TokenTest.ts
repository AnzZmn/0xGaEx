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
        const [deployer, acc1, acc2, ApproveAcc] = await viem.getWalletClients();
        const AdminContract = await viem.deployContract("Administrator");
        const tokenContract = await viem.deployContract("GToken",[NAME,SYMBOL,BASE_URL,AdminContract.address]);
        
        return {tokenContract, AdminContract, deployer, acc1, acc2, publicClient, ApproveAcc};
}



describe("Decentralized Exchange Protocol Test Suite",()=>{
        
        describe('GToken Test Cases',()=>{

            it('should mint the Token Properly from Acc1',async()=>{
                const { tokenContract, acc1 , publicClient } = await loadFixture(fixture)
                const minTx = await tokenContract.write.mint([acc1.account.address, TOKEN_ID, URI ,acc1.account.address,ROYALTY],{account: acc1.account.address})
                const TxReciept = await publicClient.getTransactionReceipt({hash: minTx});
                const ownerAddress = await tokenContract.read.ownerOf([1n])
                expect(ownerAddress.toUpperCase()).to.eq(acc1.account.address.toUpperCase())
            })

            it(`Should deploy with Name: ${NAME} , Symbol: ${SYMBOL} and BaseURL: ${BASE_URL} `, async ()=>{
                const { tokenContract   } = await loadFixture(fixture)
                const name = await tokenContract.read.name()
                const symbol = await tokenContract.read.symbol();
                const baseUri = await tokenContract.read.baseURI();
                expect(name).to.be.eq(NAME);
                expect(symbol).to.eq(SYMBOL);
                expect(baseUri).to.eq(BASE_URL);
            })
    
            it('Should Set The TokenURI upon minting new Token', async()=>{
                const { tokenContract, acc1, publicClient   } = await loadFixture(fixture)
                const minTx = await tokenContract.write.mint([acc1.account.address, TOKEN_ID, URI ,acc1.account.address,ROYALTY],{account: acc1.account.address})
                const tokenURI = await tokenContract.read.tokenURI([TOKEN_ID])
                expect(tokenURI).to.eq(`MY_CUSTOM_URI${URI}`)
            })
    
            it(`Should set the Royalty to ${ROYALTY}%`,async()=>{
                const { tokenContract, acc1 } = await loadFixture(fixture)
                const minTx = await tokenContract.write.mint([acc1.account.address, TOKEN_ID, URI ,acc1.account.address,ROYALTY],{account: acc1.account.address})
                const [Recipeint, Royalty] = await tokenContract.read.royaltyInfo([TOKEN_ID,SALE_PRICE])
                //console.log(`Royalty : ${formatEther(Royalty)}, recipient: ${Recipeint}, salePrice: ${formatEther(SALE_PRICE)}`);
                expect(Recipeint.toUpperCase()).to.eq(acc1.account.address.toUpperCase())
                expect(Royalty).to.eq((ROYALTY*SALE_PRICE)/100n)
                    
            })
        })

        describe('ExProtocol Test Cases',()=>{

            it('should Deploy Escrow Contract Properly',async()=>{
                const { acc1, deployer, tokenContract, AdminContract } = await loadFixture(fixture)
                const minTx = await tokenContract.write.mint([acc1.account.address, TOKEN_ID, URI ,acc1.account.address,ROYALTY],{account: acc1.account.address})
                const EscrowContract = await viem.deployContract("ExProtocol",[TOKEN_ID, SALE_PRICE , tokenContract.address, AdminContract.address],{value: SALE_PRICE})
                const logs = (await EscrowContract.getEvents.contractDeployed())[0]["args"];
                const {buyer, seller, approver, tokenId, amount } = logs;
                expect(buyer?.toUpperCase()).to.be.equal(deployer.account.address.toUpperCase());
                expect(seller?.toUpperCase()).to.be.equal(acc1.account.address.toUpperCase());
                expect(approver?.toUpperCase()).to.be.equal(AdminContract.address.toUpperCase());
                expect(tokenId).to.be.equal(TOKEN_ID);
                expect(amount).to.be.equal(SALE_PRICE);
            })

            describe('Should Transfer The Asset Properly', () => {
                it('Should Set the Approver to Administrator Contract on Minting a New Token',async()=>{
                    const { acc1, tokenContract, AdminContract } = await loadFixture(fixture)
                    const mintTx = await tokenContract.write.mint([acc1.account.address, TOKEN_ID, URI, acc1.account.address, ROYALTY],{account: acc1.account});
                    const approver = await tokenContract.read.getApproved([TOKEN_ID]);
                    expect(approver.toUpperCase()).to.equal(AdminContract.address.toUpperCase())
                })
            })

            
        })

        




        
})