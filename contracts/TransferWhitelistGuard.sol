// SPDX-License-Identifier: LGPL-3.0-only
/* solhint-disable one-contract-per-file */
pragma solidity 0.8.19;

import {Enum} from "./libraries/Enum.sol";
import {BaseGuard} from "./base/GuardManager.sol";
import {ISafe} from "./interfaces/ISafe.sol";

/**
 * @notice Guard to restrict transfers to whitelisted addresses 
 */
contract TransferWhitelistGuard is BaseGuard {

    //bytes4(keccak256(bytes("transferFrom(address,address,uint256)")))
    bytes4 public constant TRANSFER_FROM_SIG = bytes4(0x23b872dd);
    //bytes4(keccak256(bytes("transferFrom(address,address,uint256)")))
    bytes4 public constant TRANSFER_SIG = bytes4(0xa9059cbb);

    mapping(address => bool) public whitelist;

    /**
     * Example modifier to restrict function execution
     */
    modifier onlyOwner(address msgSender) {
        require(ISafe(msg.sender).isOwner(msgSender), "Only owner allowed");
        _;
    }

    constructor() {}

    // solhint-disable-next-line payable-fallback
    fallback() external {
        // We don't revert on fallback to avoid issues in case of a Safe upgrade
        // E.g. The expected check method might change and then the Safe would be locked.
    }

    /**
     * @notice Called by the Safe contract before a transaction is executed.
     * Guard is checking if "to" address is whitelisted for withdrawal.
     */
    function checkTransaction(
        address to,
        uint256 value,
        bytes calldata data,
        Enum.Operation operation,
        uint256 safeTxGas,
        uint256 baseGas,
        uint256 gasPrice,
        address gasToken,
        address payable refundReceiver,
        bytes memory signatures,
        address executor
    ) external view override {

        // bytes4 calledFunctionSig = abi.decode(data[:4], (bytes4));

        // // check for ERC20 transfers and for raw ether transfer (msg.value)
        // if(TRANSFER_FROM_SIG == calledFunctionSig || TRANSFER_SIG == calledFunctionSig || value > 0) {
        //     bool isOnWhiteList = whitelist[to];
        //     require(isOnWhiteList, "Can only transfer to whitelisted addresses");
        // }
    }

    function checkAfterExecution(bytes32, bool) external view override {}

    /**
     * @notice Called by the Safe contract before a transaction is executed via a module.
     * @param to Destination address of Safe transaction.
     * @param value Ether value of Safe transaction.
     * @param data Data payload of Safe transaction.
     * @param operation Operation type of Safe transaction.
     * @param module Module executing the transaction.
     */
    function checkModuleTransaction(
        address to,
        uint256 value,
        bytes memory data,
        Enum.Operation operation,
        address module
    ) external override returns (bytes32) {}

    function addToWhitelist(address addr) external onlyOwner(msg.sender) {
        require(!whitelist[addr], "Address is already whitelisted");
        whitelist[addr] = true;
        // emit AddressAddedToWhitelist(addr);
    }

    function removeFromWhitelist(address addr) external onlyOwner(msg.sender) {
        require(whitelist[addr], "Address is not whitelisted");
        whitelist[addr] = false;
        // emit AddressRemovedFromWhitelist(addr);
    }
}
