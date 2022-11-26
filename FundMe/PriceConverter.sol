// Library
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {

     function getPrice() internal view returns(uint256) {
    // We are interaction with data outside the smart contract, we need 2 things 
    // ABI and Address of the contract (contract of the data feed)
    // Adress of Eth/usd 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e
    
    // ABI = AggregatorV3Interface
    // Once we combine the compiled interface with an address we can call the 
    // functions on that interface on that contract
    AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    (,int price,,,) = priceFeed.latestRoundData();
    return uint256(price * 1e10); 
    //to match up decimal places with msg.value and int to uint
    //msg.value has 18 decimals (priced in Wei/ and this priceFeed has 8 (this contract does have a decimal function 
    //so that you can return the # of decimals

    }
    
    function getVersion() internal view returns (uint256) {

    AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
    return priceFeed.version();
    }

    function getConversionRate(uint256 ethAmount) internal view returns (uint256) {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
        // both ethPrice and ethAmount have 18 decimals. so we need to / by 1e18
        // otherwise the outcome would be an additional 36 decimals
        return ethAmountInUsd;
    }
}