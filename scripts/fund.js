const {getNamedAccounts, ethers} = require("hardhat")

const main = async () => {
    const {deployer} = await getNamedAccounts()
    const fundMe = await ethers.getContract("FundMe", deployer)
    console.log("Funding contract...")
    const transactionResponse = await fundMe.fund({
        value: ethers.utils.parseEther("1"),
        gasLimit: "3000000",
    })
    await transactionResponse.wait(1)
    console.log("Funded!")
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
