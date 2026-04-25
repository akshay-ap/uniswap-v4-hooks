// SPDX-License-Identifier: Unlicenced
pragma solidity ^0.8.26;

import {BaseHook} from "v4-hooks-public/src/base/BaseHook.sol";
import {ERC1155} from "solmate/src/tokens/ERC1155.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {SwapParams} from "v4-core/types/PoolOperation.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {PoolId} from "v4-core/types/PoolId.sol";

contract PointsHook is BaseHook, ERC1155 {
    using PoolIdLibrary for PoolKey;
    constructor(IPoolManager _manager) BaseHook(_manager) {}

    function uri(uint256) public view virtual override returns (string memory) {
        return "";
    }

    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: false,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: false,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function _afterSwap(
        address,
        PoolKey calldata key,
        SwapParams calldata params,
        BalanceDelta balanceDelta,
        bytes calldata hookData
    ) internal override returns (bytes4, int128) {
        if (!key.currency0.isAddressZero()) return (this.afterSwap.selector, 0);
        if (!params.zeroForOne) return (this.afterSwap.selector, 0);

        uint256 ethAmount = uint256(int256(-balanceDelta.amount0()));

        uint256 points = ethAmount / 5;
        _assignPoints(points, key.toId(), hookData);
        return (this.afterSwap.selector, 0);
    }

    function _assignPoints(uint256 points, PoolId poolId, bytes calldata hookData) internal {
        if (hookData.length == 0) return;

        (address user) = abi.decode(hookData, (address));
        if (user == address(0)) return;
        _mint(user, uint256(PoolId.unwrap(poolId)), points, "");
    }
}

