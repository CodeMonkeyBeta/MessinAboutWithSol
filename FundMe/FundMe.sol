// Get funds from users, withdraw funds, and set min funding in USD

// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

// When compiled, this interface gives us the minimilist ABI to interact with contracts 
// outside of this project
// import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
// Moved import Interface to Library

import "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    // Immutable variables start with "i_"
    address public immutable i_owner;
    
    constructor(){
        i_owner = msg.sender;
    }
    // Constant variables use ALL_CAPS_AND_UNDERSCORES
    uint256 public constant MINIMUM_USD = 50 * 1e18;
    // using ChainLink orical price feeds

    // address array to keep track of those who sent money
    address[] public funders;

    // Mapping to keep track of how much each sender funded
    // by linking each address to how much they sent
    mapping(address => uint256) public addressToAmountFunded;

    function fund() public payable {
        //msg.sender = address who calls the function
       // require(getConversionRate(msg.value) >= minimumUsd, "Try again, but more $$");
       // Changed to:(because we changed the contract to utilize our library ie:PriceConverter.sol
       require(msg.value.getConversionRate() >= MINIMUM_USD, "Try again, but more $$");
 

        // .push will add each new funder to the "address" array
        // Global variables:
        // msg.sender = address who calls the function
        // msg.value = the amount of the native token
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;

    } 

   function withdraw()public onlyOwner{
       // = setting, == checking equivalence 
       // For loop: (starting idex, ending index, step amount)
       // Ending index: our end of the index is when funderIndex is no longer less than funder.lenght
       //    -Checking to see if statement is still true(bool) if it is, it will continue the loop

       // Step amount: (funderIndex++) is same as (funderIndex = fundersIndex + 1)
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
        //code
        address funder = funders[funderIndex];
        addressToAmountFunded[funder] = 0;
        }
        // reset the array
        // This resets the funders array to a new array with the same name with 0 indexes
        //     - Does this mean that if just one person withdrawls, all past funders are lost???
        funders = new address[](0);
        // actually withdraw the funds ( three ways)

        // Transfer: capped at 2300 gas, if failed it will just 'error' and revert 
        //     msg.sender is of type (=) address    (Solidity default)
        //     payable(msg.sender) = payable address
        //     (this) refers to the contract address (the one we are making)
    //Transfer Code:    payable(msg.sender).transfer(address(this).balance);

        // Send: capped at 2300 gas, if failed will return a bool
        //    If we just do this :payable(msg.sender).send(address(this).balance);
        //    if the contract failed, it would not revert the transaction, we would just not get our money sent
     //Send Code:   bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // send returns a bool, sendSuccess veriable created to add functionality , add 'require' to revert with message"send failed" if bool = False
     //Send Code:   require(sendSuccess, "Send failed");

        // Call (used as a regular transaction):ability to call virtually any function in all of Etherium without needing the ABI??
        // Call: forwards all gas or set gas(no cap) can return two variables: a bool and a bytes
        //        bytes object is an array, needs to be stored in memory. 
        // If we called a function, that function may return some data(bytes) so we creat a veriable 'dataReturned' to save it there
        //    left "" empty, so we are not calling a function (.call{value: address(this).balance}("");)
        //     therefore do not need bytes object/veriable named
        (bool callSuccess, /* bytes memory dataReturned */) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
   }

    modifier onlyOwner {
       // require(msg.sender == i_owner, "Sender is not owner!");
       // Custon error:
       if(msg.sender != i_owner) { revert NotOwner();}
            _;/*do the require first, then do the rest of the origonal code*/
        
    }

    // What happens if someone sends this contract ETH without calling the fun function?

    receive() external payable {
        fund();
     }
    fallback() external payable {
        fund();
    }
}