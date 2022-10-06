const {getNamedAccounts, ethers, network} = require("hardhat")
const {developmentChains} = require("../../helper-hardhat-config")
const {assert} = require("chai")

developmentChains.includes(network.name)
    ? describe.skip
    : describe("FundMe", async () => {
          let FundMe
          let deployer
          const sendValue = "730000000000000"
          beforeEach(async () => {
              deployer = (await getNamedAccounts()).deployer
              fundMe = await ethers.getContract("FundMe", deployer)
          })

          it("allows people to fund and withdraw", async () => {
              await fundMe.fund({value: sendValue, gasLimit: "3000000"})
              await fundMe.withdraw()
              const endingBalance = await fundMe.provider.getBalance(
                  fundMe.address
              )
              assert.equal(endingBalance.toString(), "0")
          })
      })
