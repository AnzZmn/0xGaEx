import {expect} from 'chai'
import { viem } from 'hardhat'
import {formatEther} from 'viem'
import {loadFixture} from '@nomicfoundation/hardhat-network-helpers'

const TOKEN_ID = 1n;
const URI = "/GAME_ACCOUNT"
const BASE_URL = "MY_CUSTOM_URI";
const NAME = "GameToken"
const SYMBOL = "GFT"
const ROYALTY = 5n
const SALE_PRICE = 1000000000000000000n

async function fixture() {
        const publicClient = await viem.getPublicClient();
        const [deployer, acc1, acc2] = await viem.getWalletClients();
        const tokenContract = await viem.deployContract("GToken",[NAME,SYMBOL,BASE_URL]);
        return {tokenContract, deployer, acc1, acc2, publicClient};
}



describe("GToken Test Suite",()=>{
        
        it(`Should deploy with Name: ${NAME} , Symbol: ${SYMBOL} and BaseURL: ${BASE_URL} `, async ()=>{
            const { tokenContract   } = await loadFixture(fixture)
            const name = await tokenContract.read.name()
            const symbol = await tokenContract.read.symbol();
            const baseUri = await tokenContract.read.baseURI();
            expect(name).to.be.eq(NAME);
            expect(symbol).to.eq(SYMBOL);
            expect(baseUri).to.eq(BASE_URL);
        })

        it('Should mint the Token Properly from Acc1 To Acc1', async()=>{
            const { tokenContract, acc1, publicClient   } = await loadFixture(fixture)
            const minTx = await tokenContract.write.mint([acc1.account.address, TOKEN_ID, URI ,acc1.account.address,5n],{account: acc1.account.address})
            const ownerAddress = await tokenContract.read.ownerOf([1n])
            const tokenURI = await tokenContract.read.tokenURI([TOKEN_ID])
            const TransactionReceipt = publicClient.getTransactionReceipt({hash: minTx})
            const fromAddress = (await TransactionReceipt).from
            expect(fromAddress.toUpperCase()).to.eq(ownerAddress.toUpperCase());
            expect(tokenURI).to.eq(`MY_CUSTOM_URI${URI}`)
        })


        it('should mint the Token Properly from Acc2 to Acc1',async()=>{
            const { tokenContract, acc1, acc2, publicClient   } = await loadFixture(fixture)
            const minTx = await tokenContract.write.mint([acc1.account.address, TOKEN_ID, URI ,acc1.account.address,5n],{account: acc2.account.address})
            const TxReciept = await publicClient.getTransactionReceipt({hash: minTx});
            const fromAddress = TxReciept.from
            console.log(fromAddress)
            const ownerAddress = await tokenContract.read.ownerOf([1n])
            expect(ownerAddress.toUpperCase()).to.eq(acc1.account.address.toUpperCase())
            console.log(ownerAddress);
        })


        it(`Should set the Royalty to ${ROYALTY}%`,async()=>{
            const { tokenContract, acc1, acc2, publicClient } = await loadFixture(fixture)
            const minTx = await tokenContract.write.mint([acc2.account.address, TOKEN_ID, URI ,acc1.account.address,ROYALTY],{account: acc1.account.address})
            const [Recipeint, Royalty] = await tokenContract.read.royaltyInfo([TOKEN_ID,SALE_PRICE])
            console.log(`Royalty : ${formatEther(Royalty)}, recipient: ${Recipeint}, salePrice: ${formatEther(SALE_PRICE)}`);
                
        })

        




        
})