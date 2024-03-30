import {viem} from 'hardhat'
import {TransactionReceipt} from 'viem'


async function main() {
    const [ deployer, acc1, acc2 ] = await viem.getWalletClients();
    const contract =  await viem.deployContract("GToken",["GameToken","GFT"])
    console.log(contract.address)
    console.log(contract)

    const minTx = await contract.write.mint([acc1.account.address, 1n, "/MY_TOKEN",acc1.account.address,5n],{account: acc1.account.address})
    const tokenURI = await contract.read.tokenURI([1n]);
    console.log(tokenURI);
    
    

    const symbol =  await contract.read.baseURI();
    console.log(symbol)


}

main().catch((err) =>{
    console.error(err); 
})

