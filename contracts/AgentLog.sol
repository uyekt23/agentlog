// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title AgentLog — a daily on-chain logbook for Binance Agent ID holders.
/// @notice Holders of a Binance Agent ID (name.ai) can check in once per UTC
///         day. The contract keeps each sailor's streak and total check-ins.
///         It holds no funds, takes no fees, and has no admin functions:
///         nobody can pause it, change it, or move anything through it.
interface IAgentIdRegistry {
    function balanceOf(address owner) external view returns (uint256);
}

contract AgentLog {
    /// @notice The official Binance Agent ID registry on BNB Chain
    ///         (SPACE ID Agent ID, ERC-721, non-transferable).
    IAgentIdRegistry public constant AGENT_ID =
        IAgentIdRegistry(0x60B9262456dE011F7d15a54CdD8c48bAaa8B022F);

    struct Sailor {
        uint256 totalCheckIns; // lifetime check-ins
        uint256 currentStreak; // consecutive days, including the last check-in day
        uint256 longestStreak; // best streak ever
        uint256 lastDay;       // UTC day number of the last check-in (0 = never)
    }

    mapping(address => Sailor) private _sailors;

    uint256 public totalCheckIns; // all check-ins ever recorded
    uint256 public totalSailors;  // unique Agent ID holders who ever checked in
    mapping(uint256 => uint256) public checkInsOnDay; // UTC day => check-ins that day

    event CheckedIn(
        address indexed sailor,
        uint256 indexed day,
        uint256 streak,
        uint256 totalCheckIns
    );

    error NoAgentId(address caller);
    error AlreadyCheckedInToday(address caller, uint256 day);

    /// @notice The current UTC day number (days since the Unix epoch).
    function today() public view returns (uint256) {
        return block.timestamp / 1 days;
    }

    /// @notice True if `user` holds a Binance Agent ID.
    function hasAgentId(address user) public view returns (bool) {
        return AGENT_ID.balanceOf(user) > 0;
    }

    /// @notice True if `user` holds an Agent ID and has not checked in today.
    function canCheckInToday(address user) external view returns (bool) {
        return hasAgentId(user) && _sailors[user].lastDay != today();
    }

    /// @notice Full logbook entry for one sailor.
    function getSailor(address user)
        external
        view
        returns (
            uint256 totalCheckIns_,
            uint256 currentStreak,
            uint256 longestStreak,
            uint256 lastDay,
            bool checkedInToday
        )
    {
        Sailor storage s = _sailors[user];
        uint256 streak = s.currentStreak;
        // A streak only counts as "current" if the last check-in was
        // today or yesterday; otherwise it has lapsed back to zero.
        if (s.lastDay != 0 && today() - s.lastDay > 1) {
            streak = 0;
        }
        return (
            s.totalCheckIns,
            streak,
            s.longestStreak,
            s.lastDay,
            s.lastDay == today()
        );
    }

    /// @notice Check in for today. Caller must hold a Binance Agent ID.
    ///         One check-in per address per UTC day.
    function checkIn() external {
        if (!hasAgentId(msg.sender)) revert NoAgentId(msg.sender);

        uint256 day = today();
        Sailor storage s = _sailors[msg.sender];
        if (s.lastDay == day) revert AlreadyCheckedInToday(msg.sender, day);

        if (s.totalCheckIns == 0) {
            totalSailors += 1;
        }

        if (s.lastDay == day - 1) {
            s.currentStreak += 1; // consecutive day: streak continues
        } else {
            s.currentStreak = 1; // first ever, or streak restarted
        }
        if (s.currentStreak > s.longestStreak) {
            s.longestStreak = s.currentStreak;
        }

        s.lastDay = day;
        s.totalCheckIns += 1;
        totalCheckIns += 1;
        checkInsOnDay[day] += 1;

        emit CheckedIn(msg.sender, day, s.currentStreak, s.totalCheckIns);
    }
}
