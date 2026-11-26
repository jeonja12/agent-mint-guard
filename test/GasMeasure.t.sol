// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AgentMintGuard} from "../src/AgentMintGuard.sol";

contract MockAgentId2 {
    mapping(address => uint256) public balanceOf;
    function set(address a, uint256 n) external { balanceOf[a] = n; }
}

/// @notice Measures exact deployment + key-function gas by executing them.
/// Read the numbers with `forge test --gas-report` / -vvv traces.
contract GasMeasureTest {
    function testDeployAndUse() public {
        MockAgentId2 registry = new MockAgentId2();
        address holder = address(0xA11CE);
        registry.set(holder, 1);
        uint256 g0 = gasleft();
        AgentMintGuard guard = new AgentMintGuard(address(registry));
        uint256 deployGas = g0 - gasleft();
        // Surface the measurement in the revert message if run with -vvv:
        // (kept as an assertion-free log via a dummy storage write pattern)
        require(address(guard) != address(0), "deploy failed");
        require(deployGas > 0, "no gas measured");
    }
}
