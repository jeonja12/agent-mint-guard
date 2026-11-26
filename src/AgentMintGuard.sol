// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @notice Minimal view of the official SPACE ID Agent ID contract on BNB Chain.
/// @dev Official source: Binance Agent ID Hackathon announcement (Developer Resources).
///      Contract: 0x60b9262456de011f7d15a54cdd8c48baaa8b022f
///      Name: "SPACE ID Agent ID", Symbol: AI, Standard: ERC-721, non-transferable.
///      Holding check documented by Binance: balanceOf(address) > 0.
interface IAgentId {
    function balanceOf(address owner) external view returns (uint256);
}

/// @title AgentMintGuard
/// @notice On-chain safety policy registry + pre-execution guard for AI agents
///         that hold a Binance Agent ID (.ai).
///
/// Problem this solves (from live operation, Nov 2026):
///  Agent-ID ecosystems spawn dozens of "free mint" campaigns, but many hide
///  fees, Permit/approval drains, or impersonator contracts. An autonomous
///  agent needs its safety rules enforced *on-chain*, not only in its own
///  off-chain prompt/config, so any tool, co-agent, or human auditor can
///  verify — before execution — whether a proposed mint/transfer respects
///  the operator's policy.
///
/// How Agent ID is actively used (not a logo, a gate):
///  1. Access control: every state-changing function requires
///     IAgentId(agentIdRegistry).balanceOf(msg.sender) > 0.
///  2. Identity: policies, allowlists and verdicts are keyed by the Agent ID
///     holder's address — one non-transferable Agent ID per operator means
///     one policy identity per operator (sybil-resistant by construction).
///  3. Accountability: every guard check and audit verdict is anchored as an
///     event + stored attestation, attributable to that Agent ID holder.
///
/// The contract holds NO funds, takes NO custody, grants NO approvals, and
/// has NO owner/admin after deployment. It cannot move anyone's assets;
/// it only records policies and answers/enforces "is this action allowed
/// under my own policy?" for the calling agent itself.
contract AgentMintGuard {
    // ------------------------------------------------------------------
    // Types
    // ------------------------------------------------------------------

    enum Verdict {
        None,
        Go,
        Caution,
        Block
    }

    struct Policy {
        bool active;
        /// @notice Max msg.value (wei) allowed for a single guarded action. 0 = free-only.
        uint256 maxValuePerTxWei;
        /// @notice Max cumulative guarded value (wei) per UTC day. 0 = no daily spend allowed above per-tx rule still applies via spent tracking; set equal to maxValuePerTxWei for strict free-only.
        uint256 maxValuePerDayWei;
        /// @notice If true, any action that would require a token approval / permit is rejected.
        bool forbidApprovals;
        /// @notice If true, targets must be on the caller's allowlist.
        bool requireAllowlist;
        uint64 updatedAt;
    }

    struct Attestation {
        address agent;
        address target;
        Verdict verdict;
        uint8 score; // 0-100
        bytes32 reportHash;
        uint64 timestamp;
    }

    // ------------------------------------------------------------------
    // State
    // ------------------------------------------------------------------

    IAgentId public immutable agentIdRegistry;

    mapping(address => Policy) public policies;
    mapping(address => mapping(address => bool)) public allowlist;
    /// @notice agent => day index (unix / 86400) => cumulative guarded value
    mapping(address => mapping(uint256 => uint256)) public spentOnDay;

    Attestation[] public attestations;
    mapping(address => uint256) public attestationCountOf;

    mapping(address => bool) private _hasInteracted;
    uint256 public totalUniqueAgentIdInteractors;
    uint256 public totalGuardChecks;
    uint256 public totalPoliciesSet;

    // ------------------------------------------------------------------
    // Events
    // ------------------------------------------------------------------

    event PolicySet(
        address indexed agent,
        uint256 maxValuePerTxWei,
        uint256 maxValuePerDayWei,
        bool forbidApprovals,
        bool requireAllowlist
    );
    event PolicyDeactivated(address indexed agent);
    event AllowlistUpdated(address indexed agent, address indexed target, bool allowed);
    event ActionChecked(
        address indexed agent,
        address indexed target,
        uint256 valueWei,
        bool requiresApproval,
        bool allowed
    );
    event ActionRecorded(address indexed agent, address indexed target, uint256 valueWei, uint256 dayIndex, uint256 spentTodayWei);
    event VerdictAnchored(
        uint256 indexed attestationId,
        address indexed agent,
        address indexed target,
        Verdict verdict,
        uint8 score,
        bytes32 reportHash
    );

    // ------------------------------------------------------------------
    // Errors
    // ------------------------------------------------------------------

    error NotAgentIdHolder(address caller);
    error NoActivePolicy(address agent);
    error TargetNotAllowlisted(address agent, address target);
    error ValueOverPerTxCap(uint256 valueWei, uint256 capWei);
    error ValueOverDailyCap(uint256 spentTodayWei, uint256 valueWei, uint256 capWei);
    error ApprovalForbidden();
    error InvalidScore(uint8 score);

    // ------------------------------------------------------------------
    // Constructor
    // ------------------------------------------------------------------

    /// @param agentIdRegistry_ Official Agent ID contract.
    ///        BNB Chain mainnet: 0x60b9262456de011f7d15a54cdd8c48baaa8b022f
    constructor(address agentIdRegistry_) {
        require(agentIdRegistry_ != address(0), "registry=0");
        agentIdRegistry = IAgentId(agentIdRegistry_);
    }

    // ------------------------------------------------------------------
    // Agent ID gate
    // ------------------------------------------------------------------

    function isAgentIdHolder(address account) public view returns (bool) {
        return agentIdRegistry.balanceOf(account) > 0;
    }

    modifier onlyAgentIdHolder() {
        if (!isAgentIdHolder(msg.sender)) revert NotAgentIdHolder(msg.sender);
        _;
    }

    function _countInteractor(address agent) internal {
        if (!_hasInteracted[agent]) {
            _hasInteracted[agent] = true;
            totalUniqueAgentIdInteractors += 1;
        }
    }

    // ------------------------------------------------------------------
    // Policy registry
    // ------------------------------------------------------------------

    /// @notice Register or replace the caller's own safety policy.
    /// @dev The canonical "free-mint only" policy is:
    ///      maxValuePerTxWei = 0, maxValuePerDayWei = 0,
    ///      forbidApprovals = true, requireAllowlist = false.
    function setPolicy(
        uint256 maxValuePerTxWei,
        uint256 maxValuePerDayWei,
        bool forbidApprovals,
        bool requireAllowlist
    ) external onlyAgentIdHolder {
        policies[msg.sender] = Policy({
            active: true,
            maxValuePerTxWei: maxValuePerTxWei,
            maxValuePerDayWei: maxValuePerDayWei,
            forbidApprovals: forbidApprovals,
            requireAllowlist: requireAllowlist,
            updatedAt: uint64(block.timestamp)
        });
        totalPoliciesSet += 1;
        _countInteractor(msg.sender);
        emit PolicySet(msg.sender, maxValuePerTxWei, maxValuePerDayWei, forbidApprovals, requireAllowlist);
    }

    function deactivatePolicy() external onlyAgentIdHolder {
        policies[msg.sender].active = false;
        policies[msg.sender].updatedAt = uint64(block.timestamp);
        emit PolicyDeactivated(msg.sender);
    }

    function setAllowlist(address target, bool allowed) external onlyAgentIdHolder {
        require(target != address(0), "target=0");
        allowlist[msg.sender][target] = allowed;
        _countInteractor(msg.sender);
        emit AllowlistUpdated(msg.sender, target, allowed);
    }

    // ------------------------------------------------------------------
    // Guard: pure check (view) + enforcing check-and-record (state)
    // ------------------------------------------------------------------

    /// @notice Evaluate a proposed action against the caller's policy.
    /// @return allowed True if the action respects every rule in the policy.
    /// @return reason  0=ok, 1=no active policy, 2=not allowlisted,
    ///                 3=over per-tx cap, 4=over daily cap, 5=approval forbidden.
    function checkAction(address target, uint256 valueWei, bool requiresApproval)
        public
        view
        returns (bool allowed, uint8 reason)
    {
        Policy memory p = policies[msg.sender];
        if (!p.active) return (false, 1);
        if (p.requireAllowlist && !allowlist[msg.sender][target]) return (false, 2);
        if (valueWei > p.maxValuePerTxWei) return (false, 3);
        uint256 dayIndex = block.timestamp / 86400;
        if (spentOnDay[msg.sender][dayIndex] + valueWei > p.maxValuePerDayWei && !(p.maxValuePerDayWei == 0 && valueWei == 0)) {
            // Note: a 0 daily cap with a 0-value action is the free-only path and must pass.
            if (valueWei > 0) return (false, 4);
        }
        if (requiresApproval && p.forbidApprovals) return (false, 5);
        return (true, 0);
    }

    /// @notice Enforcing gate an agent calls immediately before executing a
    ///         mint/transfer itself. Reverts if the action violates the
    ///         caller's own policy; otherwise records the spend so the daily
    ///         cap is real, not advisory.
    function guardCheckAndRecord(address target, uint256 valueWei, bool requiresApproval)
        external
        onlyAgentIdHolder
        returns (bool)
    {
        Policy memory p = policies[msg.sender];
        if (!p.active) revert NoActivePolicy(msg.sender);
        if (p.requireAllowlist && !allowlist[msg.sender][target]) {
            emit ActionChecked(msg.sender, target, valueWei, requiresApproval, false);
            revert TargetNotAllowlisted(msg.sender, target);
        }
        if (valueWei > p.maxValuePerTxWei) {
            emit ActionChecked(msg.sender, target, valueWei, requiresApproval, false);
            revert ValueOverPerTxCap(valueWei, p.maxValuePerTxWei);
        }
        uint256 dayIndex = block.timestamp / 86400;
        uint256 spent = spentOnDay[msg.sender][dayIndex];
        if (valueWei > 0 && spent + valueWei > p.maxValuePerDayWei) {
            emit ActionChecked(msg.sender, target, valueWei, requiresApproval, false);
            revert ValueOverDailyCap(spent, valueWei, p.maxValuePerDayWei);
        }
        if (requiresApproval && p.forbidApprovals) {
            emit ActionChecked(msg.sender, target, valueWei, requiresApproval, false);
            revert ApprovalForbidden();
        }
        spentOnDay[msg.sender][dayIndex] = spent + valueWei;
        totalGuardChecks += 1;
        _countInteractor(msg.sender);
        emit ActionChecked(msg.sender, target, valueWei, requiresApproval, true);
        emit ActionRecorded(msg.sender, target, valueWei, dayIndex, spent + valueWei);
        return true;
    }

    // ------------------------------------------------------------------
    // Audit verdict anchoring
    // ------------------------------------------------------------------

    /// @notice Anchor an off-chain contract-audit verdict on-chain.
    /// @param target     Contract that was audited.
    /// @param verdict    Go / Caution / Block.
    /// @param score      0-100 safety score.
    /// @param reportHash keccak256 (or SHA-256-as-bytes32 commitment) of the full report.
    function anchorVerdict(address target, Verdict verdict, uint8 score, bytes32 reportHash)
        external
        onlyAgentIdHolder
        returns (uint256 attestationId)
    {
        require(target != address(0), "target=0");
        require(verdict != Verdict.None, "verdict=none");
        if (score > 100) revert InvalidScore(score);
        attestationId = attestations.length;
        attestations.push(
            Attestation({
                agent: msg.sender,
                target: target,
                verdict: verdict,
                score: score,
                reportHash: reportHash,
                timestamp: uint64(block.timestamp)
            })
        );
        attestationCountOf[msg.sender] += 1;
        _countInteractor(msg.sender);
        emit VerdictAnchored(attestationId, msg.sender, target, verdict, score, reportHash);
    }

    function attestationCount() external view returns (uint256) {
        return attestations.length;
    }

    function getAttestation(uint256 id) external view returns (Attestation memory) {
        return attestations[id];
    }
}
