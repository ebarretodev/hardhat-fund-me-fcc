//SPDX-License-Identifier: MIT
//Pragma
pragma solidity ^0.8.8;

//Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

//Error Codes
error FundMe__NotOwner();
error FundMe__NotEnoughtValue();
error FundMe__CallFailed();

//Interfaces

//Libraries

//Contracts
/**
 * @title A contract for crowd funding
 * @author Eliabel Barreto
 * @notice This contract is to a demo a sample funding contract
 * @dev This implements price feeds as our library
 */

contract FundMe {
    //Type declarations
    using PriceConverter for uint256;

    //State variables
    mapping(address => uint256) private s_addressToAmountFunded;
    address[] private s_funders;
    address private immutable i_owner;
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    AggregatorV3Interface private s_priceFeed;
    //Events

    //Modifiers
    modifier onlyOwner() {
        //require(msg.sender == owner, "You are not the Owner!");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    // Functions:
    //// constructor
    //// receive
    //// fallback
    //// external
    //// public
    //// internal
    //// private
    //// view / pure

    // Functions:
    //// constructor
    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    //// receive

    // receive() external payable {
    //     fund();
    // }

    //// fallback
    // fallback() external payable {
    //     fund();
    // }

    //// public
    /**
     * @notice This function funds this contract
     * @dev This implements price feeds as our library
     */
    function fund() public payable {
        //Want to be able to set a minimum fund amount is USD
        //1. How do we send ETH to this Contract?
        if (msg.value.getConversionRate(s_priceFeed) < MINIMUM_USD) {
            revert FundMe__NotEnoughtValue();
        } // 1e18 == 1 * 10 ** 18
        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] = msg.value;
        // What is reverting?
        // undo any action before, and send remaining gas back
    }

    function withdraw() public onlyOwner {
        for (
            uint256 fundersIndex = 0;
            fundersIndex < s_funders.length;
            fundersIndex++
        ) {
            //code
            address funder = s_funders[fundersIndex];
            s_addressToAmountFunded[funder] = 0;
        }

        //reset de array
        s_funders = new address[](0);

        //actually withdraw the funds

        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        if (!callSuccess) revert FundMe__CallFailed();

        /* Tips for send values between contracts
            //transfer 
            payable(msg.sender).transfer(address(this).balance);

            //send
            bool sendSuccess = payable(msg.sender).send(address(this).balance);
            require(sendSuccess, "Send failed");

            //call
            (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
            require(callSuccess, "Call failed");
            
        */
    }

    function cheaperWithdraw() public payable onlyOwner {
        address[] memory funders = s_funders;
        //mappings can't be in memory
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        //reset de array
        s_funders = new address[](0);
        (bool callSuccess, ) = i_owner.call{value: address(this).balance}("");
        if (!callSuccess) revert FundMe__CallFailed();
    }

    //// view / pure
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getFunders(uint256 index) public view returns (address) {
        return s_funders[index];
    }

    function getAddressToAmountFunded(address funder)
        public
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[funder];
    }

    function getPriceFeed() public view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
