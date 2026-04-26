// SPDX-License-Identifier: Unlicenced
pragma solidity ^0.8.26;

import {ERC1155TokenReceiver} from "solmate/src/tokens/ERC1155.sol";
import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {PointsHook} from "../src/PointsHook.sol";
import {Deployers} from "v4-hooks-public/lib/v4-core/test/utils/Deployers.sol";
import {Currency, CurrencyLibrary} from "v4-core/types/Currency.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {HookMiner} from "v4-hooks-public/src/utils/HookMiner.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {TickMath} from "v4-core/libraries/TickMath.sol";
import {LiquidityAmounts} from "@uniswap/v4-core/test/utils/LiquidityAmounts.sol";
import {ModifyLiquidityParams, SwapParams} from "v4-core/types/PoolOperation.sol";
import {PoolSwapTest} from "v4-core/test/PoolSwapTest.sol";

contract TestPointsHook is Test, Deployers, ERC1155TokenReceiver {
    MockERC20 token;
    Currency ethCurrency = Currency.wrap(address(0));
    Currency tokenCurrency;
    PointsHook hook;

    function setUp() public {
        deployFreshManagerAndRouters();

        token = new MockERC20("Test Token", "TEST", 18);
        uint256 amount = 1e6 * 1e18;
        token.mint(address(this), amount);
        token.approve(address(swapRouter), type(uint256).max);
        token.approve(address(modifyLiquidityRouter), type(uint256).max);

        tokenCurrency = Currency.wrap(address(token));

        uint160 flags = uint160(Hooks.AFTER_SWAP_FLAG);

        bytes memory constructorArgs = abi.encode(address(manager));

        (address hookAddress,) = HookMiner.find(address(this), flags, type(PointsHook).creationCode, constructorArgs);
        deployCodeTo("PointsHook.sol", constructorArgs, hookAddress);
        hook = PointsHook(hookAddress);

        (key,) = initPool(ethCurrency, tokenCurrency, hook, 3000, SQRT_PRICE_1_1);

        uint160 sqrtPriceTickUpper = TickMath.getSqrtPriceAtTick(60);
        uint160 sqrtPriceTickLower = TickMath.getSqrtPriceAtTick(-60);

        uint256 ethToAdd = 0.1 ether;
        uint128 liquidityDelta = LiquidityAmounts.getLiquidityForAmount0(SQRT_PRICE_1_1, sqrtPriceTickUpper, ethToAdd);

        uint256 tokenToAdd = LiquidityAmounts.getAmount1ForLiquidity(sqrtPriceTickLower, SQRT_PRICE_1_1, liquidityDelta);

        console.log("Token to add", tokenToAdd);

        modifyLiquidityRouter.modifyLiquidity{value: ethToAdd}(
            key,
            ModifyLiquidityParams({
                tickLower: -60, tickUpper: 60, liquidityDelta: int256(uint256(liquidityDelta)), salt: bytes32(0)
            }),
            ""
        );
    }

    function test_Swap() public {
        bytes memory hookData = abi.encode(address(this));

        swapRouter.swap{value: 0.0001 ether}(
            key,
            SwapParams({
                zeroForOne: true, amountSpecified: -0.0001 ether, sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            PoolSwapTest.TestSettings({takeClaims: false, settleUsingBurn: false}),
            hookData
        );
    }
}
