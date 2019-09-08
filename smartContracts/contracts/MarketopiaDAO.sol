pragma solidity >=0.4.21 <0.6.0;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./interfaces/CERC20.sol";
import "./interfaces/Comptroller.sol";
import "./extensions/CompoundExtension.sol";
import "./extensions/KyberExtension.sol";


contract MarketopiaDAO is CompoundExtension, KyberExtension, Ownable {
    
    constructor() public CompoundExtension() KyberExtension() Ownable() 
    {}

      
    function usdcBalance() public view returns(uint256){
       return CompoundExtension._usdcBalance();
    }

    function daiBalance() public view returns(uint256){
        return CompoundExtension._daiBalance();
    }

    function mintcDai(uint256 amount) public onlyOwner returns (bool) {
      return CompoundExtension._mintcDai(amount);
    }

    function mintcUSDC(uint256 amount) public onlyOwner returns (bool) {
      return CompoundExtension._mintcUSDC(amount);
    }

    function redeemDAI(uint256 amount) public onlyOwner returns (bool) {
        return CompoundExtension._redeemDAI(amount,owner());
    }

    function redeemUSDC(uint256 amount) public onlyOwner returns (bool) {
        return CompoundExtension._redeemUSDC(amount, owner());
    }

    function tradeDaiforUsdc(uint256 srcAmount) public onlyOwner returns ( uint256 _actualDestAmount, uint256 _actualSrcAmount){
        ERC20 dai = ERC20(DAI_ADDRESS);
        ERC20 usdc = ERC20(USDC_ADDRESS);
        return _kyberTrade(dai, srcAmount, usdc);
    }

    function tradeUsdcforDai(uint256 srcAmount) public onlyOwner returns ( uint256 _actualDestAmount, uint256 _actualSrcAmount){
        ERC20 usdc = ERC20(USDC_ADDRESS);
        ERC20 dai = ERC20(DAI_ADDRESS);
        return _kyberTrade(usdc, srcAmount, dai);
    }


}