pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";

contract PooledCDAI is ERC20, Ownable {
  address public constant DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;

  function receiveDai(address to, uint256 amount) public returns (bool) {
    // transfer `amount` DAI from msg.sender
    ERC20 dai = ERC20(DAI_ADDRESS);
    require(dai.transferFrom(msg.sender, address(this), amount), "Failed to transfer DAI from msg.sender");
    
    //TODO: emit event
    return true;
  }


  function sendDai(address to, uint256 amount) internal returns (bool) {

    // transfer `amount` DAI to beneficiary
    ERC20 dai = ERC20(DAI_ADDRESS);
    require(dai.transfer(to, amount), "Failed to transfer DAI to beneficiary");

    //TODO: emit event
    return true;
  }

  function() external payable {
    revert("Contract doesn't support receiving Ether");
  }
}