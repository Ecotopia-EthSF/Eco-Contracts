pragma solidity ^0.8.6;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "usingtellor/contracts/UsingTellor.sol";
import "./interfaces/ITellorAutopay.sol";

// Tellor Functions
  contract TellorContract is UsingTellor {

  string url = "https://api.coingecko.com/api/v3/simple/price?ids=toucan-protocol-nature-carbon-tonne&vs_currencies=usd&precision=18";
  string parseArgs = "toucan-protocol-nature-carbon-tonne,usd";
  address autoPayAddress = 0x1775704809521D4D7ee65B6aFb93816af73476ec;
  address oracle = 0x8f55D884CAD66B79e1a131f6bCB0e66f4fD84d5B;
  address bridgedTRB = 0xCE4e32fE9D894f8185271Aa990D2dB425DF3E6bE;

  constructor(address payable _tellorAddress) UsingTellor(_tellorAddress) {}

  function readValue() public returns (uint256) {
    //build our queryData
    bytes memory queryData = abi.encode("NumericApiResponse", abi.encode(url, parseArgs));
    //hash it (build our queryId)
    bytes32 queryId = keccak256(queryData);

    IERC20(bridgedTRB).approve(autoPayAddress, 1);
    ITellorAutopay(autoPayAddress).tip(queryId, 1, queryData);
    
    //get our data
    (bytes memory value, uint256 timestamp) = getDataBefore(queryId, block.timestamp - 5 seconds);
    //decode our data
    return abi.decode(value, (uint256));
  } 
}
