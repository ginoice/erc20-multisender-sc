//SPDX-License-Identifier: MIT
pragma solidity 0.6.11;

import "./Dependencies/CheckContract.sol";
import "./Dependencies/OwnableUpgradeable.sol";
import "./Dependencies/SafeMath.sol";
import "./Dependencies/AddressLib.sol";
import "./Dependencies/IERC20.sol";
import "./Dependencies/TransferHelper.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/utils/math/SafeMath.sol";


import "hardhat/console.sol";

contract MultiSender is CheckContract, OwnableUpgradeable {
    using SafeMath for uint256;
    using AddressLib for address;
    using TransferHelper for address;
    using TransferHelper for IERC20;

    uint256 public arrayLimit;
    uint256 public feePerAccount;

    event Sent(address _token, address _sourceAccount, address _targetAccount, uint256 _amount);
    event FeePerAccountChanged(address _operator, uint256 _feePerAccount);
    event ArrayLimitChanged(address _operator, uint256 _arrayLimit);
    event Withdrawn(address indexed _operator, address indexed _to, uint256 _balance);

    function initialize(uint256 _arrayLimit, uint256 _feePerAccount) public initializer {
        console.log("11");
        __Ownable_init();
        console.log("12");
        
        arrayLimit = _arrayLimit;
        feePerAccount = _feePerAccount;

        emit ArrayLimitChanged(msg.sender, _arrayLimit);
        emit FeePerAccountChanged(msg.sender, _feePerAccount);
    }

    function withdraw(address _to) external onlyOwner {
        require(_to != address(0), "can't withdraw to zero address");
        uint256 _balance = address(this).balance;
        address(_to).safeTransferETH(_balance);
        emit Withdrawn(msg.sender, _to, _balance);
    }

    function setFeePerAccount(uint256 _feePerAccount) external onlyOwner {
        feePerAccount = _feePerAccount;
        emit FeePerAccountChanged(msg.sender, _feePerAccount);
    }

    function setArrayLimit(uint256 _arrayLimit) external onlyOwner {
        arrayLimit = _arrayLimit;
        emit ArrayLimitChanged(msg.sender, _arrayLimit);
    }

    function multiSend(address _token, address[] memory _accounts, uint256[] memory _amounts) public payable {
        console.log("1");
        _multiSend(_token, msg.sender, _accounts, _amounts);
    }

    function _multiSend(address _token, address _sourceAccount, address[] memory _accounts, uint256[] memory _amounts) internal {
        _requireEnoughFee(_accounts.length);
        require(_accounts.length == _amounts.length, "the accounts size and amounts size not equals");
        console.log("22");
        require(_accounts.length <= arrayLimit, "array size exceed the array limit");
        console.log("2");
        if(_token.isPlatformToken()) {
            _multiSendETH(_token, _sourceAccount, _accounts, _amounts);
        } else {
            console.log("3");
            _multiSendToken(_token, _sourceAccount, _accounts, _amounts);
        }
    }

    function _multiSendToken(address _token, address _sourceAccount, address[] memory _accounts, uint256[] memory _amounts) internal {
        for (uint256 _idx = 0; _idx < _accounts.length; _idx++) {
            console.log("4");
            IERC20(_token).safeTransferFrom(_sourceAccount, _accounts[_idx], _amounts[_idx]);
            console.log("5");
            emit Sent(_token, _sourceAccount, _accounts[_idx], _amounts[_idx]);
            console.log("6");
        }
    }

    function _multiSendETH(address _token, address _sourceAccount, address[] memory _accounts, uint256[] memory _amounts) internal {
        uint256 _transferredETH;
        for (uint256 _idx = 0; _idx < _accounts.length; _idx++) {
            address(_token).safeTransferToken(_accounts[_idx], _amounts[_idx]);
            _transferredETH = _transferredETH.add(_amounts[_idx]);
            emit Sent(_token, _sourceAccount, _accounts[_idx], _amounts[_idx]);
        }
        require(_transferredETH <= msg.value.sub(_currentFee(_accounts.length)), "has no enough eth to transfer");
    }

    function _requireEnoughFee(uint256 _accountSize) internal view {
        require(msg.value >= _currentFee(_accountSize), "has no enough fee");
    }

    function _currentFee(uint256 _accountSize) internal view returns (uint256) {
        return feePerAccount.mul(_accountSize);
    }

    receive() external payable {
    }
}

