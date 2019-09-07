pragma solidity >=0.4.21 <0.6.0;

import "../interfaces/KyberNetworkProxy.sol";
import "openzeppelin-solidity/contracts/token/ERC20/SafeERC20.sol";

contract KyberExtension {
  using SafeERC20 for ERC20;
  using SafeMath for uint256;

  address public constant DAI_ADDRESS = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359;
  address public constant KYBER_ADDRESS = 0x818E6FECD516Ecc3849DAf6845e3EC868087B755;
  ERC20 internal constant ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
  bytes internal constant PERM_HINT = "PERM"; // Only use permissioned reserves from Kyber
  uint internal constant MAX_QTY   = (10**28); // 10B tokens

  /**
   * @notice Get the token balance of an account
   * @param _token the token to be queried
   * @param _addr the account whose balance will be returned
   * @return token balance of the account
   */
  function _getBalance(ERC20 _token, address _addr) internal view returns(uint256) {
    if (address(_token) == address(ETH_TOKEN_ADDRESS)) {
      return uint256(_addr.balance);
    }
    return uint256(_token.balanceOf(_addr));
  }

  function _toPayableAddr(address _addr) internal pure returns (address payable) {
    return address(uint160(_addr));
  }

  /**
   * @notice Wrapper function for doing token conversion on Kyber Network
   * @param _srcToken the token to convert from
   * @param _srcAmount the amount of tokens to be converted
   * @param _destToken the destination token
   * @return _destPriceInSrc the price of the dest token, in terms of source tokens
   *         _srcPriceInDest the price of the source token, in terms of dest tokens
   *         _actualDestAmount actual amount of dest token traded
   *         _actualSrcAmount actual amount of src token traded
   */
  function _kyberTrade(ERC20 _srcToken, uint256 _srcAmount, ERC20 _destToken)
    internal
    returns(
      uint256 _actualDestAmount,
      uint256 _actualSrcAmount
    )
  {
    // Get current rate & ensure token is listed on Kyber
    KyberNetworkProxy kyber = KyberNetworkProxy(KYBER_ADDRESS);
    (, uint256 rate) = kyber.getExpectedRate(_srcToken, _destToken, _srcAmount);
    require(rate > 0, "Price for token is 0 on Kyber");

    uint256 beforeSrcBalance = _getBalance(_srcToken, address(this));
    uint256 msgValue;
    if (_srcToken != ETH_TOKEN_ADDRESS) {
      msgValue = 0;
      _srcToken.safeApprove(KYBER_ADDRESS, 0);
      _srcToken.safeApprove(KYBER_ADDRESS, _srcAmount);
    } else {
      msgValue = _srcAmount;
    }
    _actualDestAmount = kyber.tradeWithHint.value(msgValue)(
      _srcToken,
      _srcAmount,
      _destToken,
      _toPayableAddr(address(this)),
      MAX_QTY,
      rate,
      address(0),
      PERM_HINT
    );
    require(_actualDestAmount > 0, "Received 0 dest token");
    if (_srcToken != ETH_TOKEN_ADDRESS) {
      _srcToken.safeApprove(KYBER_ADDRESS, 0);
    }

    _actualSrcAmount = beforeSrcBalance.sub(_getBalance(_srcToken, address(this)));
  }

  function() external payable {}
}