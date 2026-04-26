// SPDX-License-Identifier: Unlicenced
pragma solidity ^0.8.24;

import "forge-std/Script.sol";
import "../src/PointsHook.sol";
import {HookMiner} from "v4-hooks-public/src/utils/HookMiner.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";

contract DeployPointsHook is Script {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address poolManager = vm.envAddress("POOL_MANAGER");

        uint160 flags = uint160(Hooks.AFTER_SWAP_FLAG);
        bytes memory constructorArgs = abi.encode(poolManager);

        address create2Deployer = 0x4e59b44847b379578588920cA78FbF26c0B4956C;
        (address hookAddress, bytes32 salt) =
            HookMiner.find(create2Deployer, flags, type(PointsHook).creationCode, constructorArgs);

        vm.startBroadcast(privateKey);
        PointsHook hook = new PointsHook{salt: salt}(IPoolManager(poolManager));
        vm.stopBroadcast();

        require(hookAddress == address(hook), "Hook address not matching");
    }
}
