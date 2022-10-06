const {getNamedAccounts, ethers} = require("hardhat")

const main = async () => {
    const {deployer} = await getNamedAccounts()
    const fundMe = await ethers.getContract("FundMe", deployer)
    console.log("Funding...")
    const transactionResponse = await fundMe.withdraw()
    await transactionResponse.wait(1)
    console.log("Got it back!")
}

main()
    .then(() => {
        console.log("Finish with no errors")
        process.exit(0)
    })
    .catch((e) => {
        console.error(e)
        process.exit(1)
    })
