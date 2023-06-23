pragma solidity 0.8.18;
// SPDX-License-Identifier: UNLICENSED
import "./Context.sol";
abstract contract Governable is Context {
    address private _governor;

    constructor() {
        _governor = _msgSender();
    }

    function governor() public view virtual returns (address) {
        return _governor;
    }

    modifier onlyGovernor() {
        require(governor() == _msgSender(), "Governable: caller is not the owner");
        _;
    }

    function changeGorvernor(address newGovernor) public virtual onlyGovernor() {
        require(newGovernor != address(0) && newGovernor != _governor, "Governable: new governor is zero");
        _setGovernor(newGovernor);
    }

    function _setGovernor(address newGovernor) internal virtual {
        _governor = newGovernor;
    }
}