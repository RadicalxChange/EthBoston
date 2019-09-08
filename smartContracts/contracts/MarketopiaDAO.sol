
import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "./interfaces/CERC20.sol";
import "./interfaces/Comptroller.sol";
import "./extensions/CompoundExtension.sol";
import "./extensions/KyberExtension.sol";


contract CompoundExtension is CompoundExtension, KyberExtension, Ownable {
    
    function constructor() public CompoundExtension() KyberExtension() Owned() 
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
        return CompoundExtension._redeemDAI(amount,owner);
    }

    function redeemUSDC(uint256 amount) public onlyOwner returns (bool) {
        return CompoundExtension._redeemUSDC(amount, owner);
    }

    function accruedInterestCurrent() public returns (uint256) {
        return CompoundExtension._accruedInterestCurrent();
    }

    function accruedInterestStored() public view returns (uint256) {
        return CompoundExtension._accruedInterestStored();
    }

    function withdrawInterestInDAI(address beneficiary) public onlyOwner returns (bool) {
        return CompoundExtension._withdrawInterestInDAI(beneficiary);
    }

    function withdrawInterestInCDAI(address beneficiary) public onlyOwner returns (bool) {
        return CompoundExtension._withdrawInterestInCDAI(beneficiary);
    } 

    function tradeDaiforUsdc(uint256 srcAmount) public onlyOwner returns ( uint256 _actualDestAmount, uint256 _actualSrcAmount){
          return _kyberTrade(DAI_ADDRESS, srcAmount, USDC_ADDRESS);
    }

    function tradeUsdcforDai(uint256 srcAmount) public onlyOwner returns ( uint256 _actualDestAmount, uint256 _actualSrcAmount){
          return _kyberTrade(USDC_ADDRESS, srcAmount, DAI_ADDRESS);
    }


}