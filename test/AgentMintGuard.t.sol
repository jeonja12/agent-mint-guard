// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {AgentMintGuard} from "../src/AgentMintGuard.sol";

contract MockAgentId {
    mapping(address => uint256) public balanceOf;
    function set(address a, uint256 n) external { balanceOf[a] = n; }
}

interface Vm {
    function prank(address sender) external;
    function expectRevert(bytes4 revertData) external;
    function expectRevert(bytes calldata revertData) external;
    function expectRevert() external;
}

/// @notice Dependency-free Foundry tests (no forge-std): a test passes if it
/// does not revert; assertions are plain requires with messages.
contract AgentMintGuardTest {
    Vm internal constant vm = Vm(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    MockAgentId internal registry;
    AgentMintGuard internal guard;

    address internal constant HOLDER = address(0xA11CE);
    address internal constant HOLDER2 = address(0xB0B);
    address internal constant STRANGER = address(0xDEAD);
    address internal constant TARGET = address(0xCAFE);

    function setUp() public {
        registry = new MockAgentId();
        registry.set(HOLDER, 1);
        registry.set(HOLDER2, 1);
        guard = new AgentMintGuard(address(registry));
    }

    function _freeOnlyPolicy(address who) internal {
        vm.prank(who);
        guard.setPolicy(0, 0, true, false);
    }

    function testHolderDetection() public view {
        require(guard.isAgentIdHolder(HOLDER), "holder not detected");
        require(!guard.isAgentIdHolder(STRANGER), "stranger detected as holder");
    }

    function testNonHolderCannotSetPolicy() public {
        vm.expectRevert();
        vm.prank(STRANGER);
        guard.setPolicy(0, 0, true, false);
    }

    function testSetPolicyStoresAndCountsUnique() public {
        _freeOnlyPolicy(HOLDER);
        (bool active, uint256 perTx, uint256 perDay, bool forbid, bool reqAllow, ) = guard.policies(HOLDER);
        require(active, "policy not active");
        require(perTx == 0 && perDay == 0, "caps wrong");
        require(forbid && !reqAllow, "flags wrong");
        require(guard.totalUniqueAgentIdInteractors() == 1, "unique != 1");
        // Second action by same holder must not double-count uniqueness.
        vm.prank(HOLDER);
        guard.setAllowlist(TARGET, true);
        require(guard.totalUniqueAgentIdInteractors() == 1, "unique double counted");
        _freeOnlyPolicy(HOLDER2);
        require(guard.totalUniqueAgentIdInteractors() == 2, "unique != 2");
    }

    function testFreeMintPassesGuard() public {
        _freeOnlyPolicy(HOLDER);
        vm.prank(HOLDER);
        bool ok = guard.guardCheckAndRecord(TARGET, 0, false);
        require(ok, "free mint blocked");
        require(guard.totalGuardChecks() == 1, "check not counted");
    }

    function testPaidActionBlockedByFreeOnlyPolicy() public {
        _freeOnlyPolicy(HOLDER);
        vm.prank(HOLDER);
        vm.expectRevert();
        guard.guardCheckAndRecord(TARGET, 1 wei, false);
    }

    function testApprovalBlockedWhenForbidden() public {
        _freeOnlyPolicy(HOLDER);
        vm.expectRevert(abi.encodeWithSelector(AgentMintGuard.ApprovalForbidden.selector));
        vm.prank(HOLDER);
        guard.guardCheckAndRecord(TARGET, 0, true);
    }

    function testPerTxAndDailyCaps() public {
        vm.prank(HOLDER);
        guard.setPolicy(0.01 ether, 0.015 ether, false, false);
        vm.prank(HOLDER);
        require(guard.guardCheckAndRecord(TARGET, 0.01 ether, false), "first spend blocked");
        // Second 0.01 would take the day to 0.02 > 0.015 daily cap.
        vm.prank(HOLDER);
        vm.expectRevert();
        guard.guardCheckAndRecord(TARGET, 0.01 ether, false);
    }

    function testAllowlistEnforcedWhenRequired() public {
        vm.prank(HOLDER);
        guard.setPolicy(0, 0, true, true);
        vm.prank(HOLDER);
        vm.expectRevert();
        guard.guardCheckAndRecord(TARGET, 0, false);
        vm.prank(HOLDER);
        guard.setAllowlist(TARGET, true);
        vm.prank(HOLDER);
        require(guard.guardCheckAndRecord(TARGET, 0, false), "allowlisted target blocked");
    }

    function testCheckActionViewReasons() public {
        _freeOnlyPolicy(HOLDER);
        vm.prank(HOLDER);
        (bool okFree, uint8 rFree) = guard.checkAction(TARGET, 0, false);
        require(okFree && rFree == 0, "free action should pass view check");
        vm.prank(HOLDER);
        (bool okPaid, uint8 rPaid) = guard.checkAction(TARGET, 5, false);
        require(!okPaid && rPaid == 3, "paid action should fail with reason 3");
        vm.prank(HOLDER);
        (bool okAppr, uint8 rAppr) = guard.checkAction(TARGET, 0, true);
        require(!okAppr && rAppr == 5, "approval action should fail with reason 5");
    }

    function testAnchorVerdict() public {
        _freeOnlyPolicy(HOLDER);
        vm.prank(HOLDER);
        uint256 id = guard.anchorVerdict(TARGET, AgentMintGuard.Verdict.Block, 12, bytes32(uint256(0x1234)));
        require(id == 0, "first attestation id != 0");
        require(guard.attestationCount() == 1, "attestation not stored");
        AgentMintGuard.Attestation memory a = guard.getAttestation(0);
        require(a.agent == HOLDER && a.target == TARGET, "attestation parties wrong");
        require(a.verdict == AgentMintGuard.Verdict.Block && a.score == 12, "attestation verdict wrong");
    }

    function testNonHolderCannotAnchor() public {
        vm.prank(STRANGER);
        vm.expectRevert();
        guard.anchorVerdict(TARGET, AgentMintGuard.Verdict.Go, 90, bytes32(uint256(1)));
    }

    function testDeactivatedPolicyBlocksGuard() public {
        _freeOnlyPolicy(HOLDER);
        vm.prank(HOLDER);
        guard.deactivatePolicy();
        vm.prank(HOLDER);
        vm.expectRevert();
        guard.guardCheckAndRecord(TARGET, 0, false);
    }

    function testInvalidScoreReverts() public {
        vm.prank(HOLDER);
        vm.expectRevert();
        guard.anchorVerdict(TARGET, AgentMintGuard.Verdict.Go, 101, bytes32(uint256(1)));
    }
}
