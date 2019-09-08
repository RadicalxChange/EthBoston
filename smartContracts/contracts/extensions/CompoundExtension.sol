pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "../interfaces/CERC20.sol";
import "../interfaces/Comptroller.sol";

contract CompoundExtension {

  uint256 internal constant PRECISION = 10 ** 18;
  address public constant COMPTROLLER_ADDRESS = 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B;
  address public constant CDAI_ADDRESS = 0xF5DCe57282A584D2746FaF1593d3121Fcac444dC;
  address public constant CUSDC_ADDRESS = 0x39aa39c021dfbae8fac545936693ac917d5e7563;
  address public constant DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
  address public constant USDC_ADDRESS = 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48;


  function constructor() public {
    // Enter cDAI market
    Comptroller troll = Comptroller(COMPTROLLER_ADDRESS);
    address[] memory cTokens = new address[](2);
    cTokens[0] = CDAI_ADDRESS;
    cTokens[1] = CUSDC_ADDRESS;
    uint[] memory errors = troll.enterMarkets(cTokens);
    require(errors[0] == 0, "Failed to enter cDAI market");
    require(errors[1] == 0, "Failed to enter cUSDC market");
  }

  function _usdcBalance() public view returns(uint256){
    ERC20 tokenContract = ERC20(USDC_ADDRESS);
    uint256 balance = tokenContract.balanceOf(address(this));
    return balance;
  }

  function _daiBalance() public view returns(uint256){
    ERC20 tokenContract = ERC20(DAI_ADDRESS);
    uint256 balance = tokenContract.balanceOf(address(this));
    return balance;
  }


  function _mintcDai(uint256 amount) internal returns (bool) {
    // transfer `amount` DAI from msg.sender
    //TODO: replace with Library and UNIT Test
    ERC20 dai = ERC20(DAI_ADDRESS);
    require(dai.transferFrom(msg.sender, address(this), amount), "Failed to transfer DAI from msg.sender");

    // use `amount` DAI to mint cDAI
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    require(dai.approve(CDAI_ADDRESS, 0), "Failed to clear DAI allowance");
    require(dai.approve(CDAI_ADDRESS, amount), "Failed to set DAI allowance");
    require(cDAI.mint(amount) == 0, "Failed to mint cDAI");
    
    return true;
  }

  function _mintcUSDC(uint256 amount) internal returns (bool) {
    // transfer `amount` DAI from msg.sender
    //TODO: replace with Library and UNIT Test
    ERC20 usdc = ERC20(USDC_ADDRESS);
    CERC20 cUSDC = CERC20(CUSDC_ADDRESS);

    // use `amount` USDC to mint cUSDC
    require(usdc.approve(CUSDC_ADDRESS, 0), "Failed to clear DAI allowance");
    require(usdc.approve(CUSDC_ADDRESS, amount), "Failed to set DAI allowance");
    require(cUSDC.mint(amount) == 0, "Failed to mint cDAI");
    
    return true;
  }

  function _redeemDAI(uint256 amount, address to) internal returns (bool) {

        // burn cDAI for `amount` DAI
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    require(cDAI.redeemUnderlying(amount) == 0, "Failed to redeem");

    // transfer DAI to `to`
    ERC20 dai = ERC20(DAI_ADDRESS);
    require(dai.transfer(to, amount), "Failed to transfer DAI to target");

    //TODO: emit event
    return true;
    
  }

  function _redeemUSDC(uint256 amount, address to) internal returns (bool) {

    // burn cDAI for `amount` DAI
    CERC20 cUSDC = CERC20(CUSDC_ADDRESS);
    require(cUSDC.redeemUnderlying(amount) == 0, "Failed to redeem");

    // transfer DAI to `to`
    ERC20 usdc = ERC20(USDC_ADDRESS);
    require(usdc.transfer(to, amount), "Failed to transfer DAI to target");

    //TODO: emit event
    return true;
  }

  function _accruedInterestCurrent() internal returns (uint256) {
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    return cDAI.exchangeRateCurrent().mul(cDAI.balanceOf(address(this))).div(PRECISION).sub(totalSupply());
  }

  function _accruedInterestStored() internal view returns (uint256) {
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    return cDAI.exchangeRateStored().mul(cDAI.balanceOf(address(this))).div(PRECISION).sub(totalSupply());
  }

  function _withdrawInterestInDAI(address beneficiary) internal returns (bool) {
    // calculate amount of interest in DAI
    uint256 interestAmount = accruedInterestCurrent();

    // burn cDAI
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    require(cDAI.redeemUnderlying(interestAmount) == 0, "Failed to redeem");

    // transfer DAI to beneficiary
    ERC20 dai = ERC20(DAI_ADDRESS);
    require(dai.transfer(beneficiary, interestAmount), "Failed to transfer DAI to beneficiary");

    //TODO: emit event
    return true;
  }

  function _withdrawInterestInCDAI(address beneficiary) internal returns (bool) {
    // calculate amount of cDAI to transfer
    CERC20 cDAI = CERC20(CDAI_ADDRESS);
    uint256 interestAmountInCDAI = accruedInterestCurrent().mul(PRECISION).div(cDAI.exchangeRateCurrent());

    // transfer cDAI to beneficiary
    require(cDAI.transfer(beneficiary, interestAmountInCDAI), "Failed to transfer cDAI to beneficiary");

    //TODO: emit event
    
    return true;
  }

  function() external payable {
    revert("Contract doesn't support receiving Ether");
  }
}