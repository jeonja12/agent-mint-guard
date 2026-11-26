// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AgentMintGuard} from "../src/AgentMintGuard.sol";

interface VmBroadcast {
    function startBroadcast() external;
    function stopBroadcast() external;
}

/// @notice Dependency-free deploy script (no forge-std Script base needed
/// beyond the broadcast cheatcodes, invoked via a minimal interface trick
/// is NOT used here — this script is run with `forge script` only in the
/// approval-gated deploy step. For local gas measurement we use the
/// GasMeasure test below instead.)
contract Deploy {
    /// Official SPACE ID Agent ID contract, BNB Chain mainnet (Binance announcement).
    address public constant AGENT_ID_REGISTRY_BSC = 0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F;

    function run() external returns (AgentMintGuard deployed) {
        // forge script --broadcast wraps this in broadcast automatically
        // when using the standard Script base; this plain version is kept
        // as the canonical constructor-argument record for the deploy step.
        deployed = new AgentMintGuard(AGENT_ID_REGISTRY_BSC);
    }
}
