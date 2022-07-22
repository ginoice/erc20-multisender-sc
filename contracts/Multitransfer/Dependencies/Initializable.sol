// SPDX-License-Identifier: MIT

// solhint-disable-next-line compiler-version
pragma solidity 0.6.11;
import "hardhat/console.sol";


/**
 * Based on OpenZeppelin's Initializable contract:
 * https://github.com/OpenZeppelin/openzeppelin-contracts-upgradeable/blob/v3.3.0/contracts/proxy/Initializable.sol
 *
 * @dev This is a base contract to aid in writing upgradeable contracts, or any kind of contract that will be deployed
 * behind a proxy. Since a proxied contract can't have a constructor, it's common to move constructor logic to an
 * external initializer function, usually called `initialize`. It then becomes necessary to protect this initializer
 * function so it can only be called once. The {initializer} modifier provided by this contract will have this effect.
 *
 * TIP: To avoid leaving the proxy in an uninitialized state, the initializer function should be called as early as
 * possible by providing the encoded function call as the `_data` argument to {UpgradeableProxy-constructor}.
 *
 * CAUTION: When used with inheritance, manual care must be taken to not invoke a parent initializer twice, or to ensure
 * that all initializers are idempotent. This is not verified automatically as constructors are by Solidity.
 */
abstract contract Initializable {

    /**
     * @dev Indicates that the contract has been initialized.
     */
    bool private _initialized;

    /**
     * @dev Indicates that the contract is in the process of being initialized.
     */
    bool private _initializing;

    /**
     * @dev Modifier to protect an initializer function from being invoked twice.
     */
    modifier initializer() {
        console.log("initializer 1");
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");
        console.log("initializer 2");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }
        console.log("initializer 3");

        _;
        console.log("initializer 4");
        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    /// @dev Returns true if and only if the function is running in the constructor
    function _isConstructor() private view returns (bool) {
        // extcodesize checks the size of the code stored in an address, and
        // address returns the current address. Since the code is still not
        // deployed when running a constructor, any checks on its code size will
        // yield zero, making it an effective way to detect if a contract is
        // under construction or not.
        console.log("_isConstructor 1");
        address self = address(this);
        uint256 cs;
        console.log("_isConstructor 2");
        // solhint-disable-next-line no-inline-assembly
        assembly { cs := extcodesize(self) }
        console.log("_isConstructor 3");
        return cs == 0;
        console.log("_isConstructor 4");
    }
}