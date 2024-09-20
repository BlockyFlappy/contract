// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

contract FlappyBirdGame {
    struct Player {
        address playerAddress;
        string username;
        uint256 highScore;
    }

    // 玩家地址 => 玩家信息
    mapping(address => Player) public players;
    // 排行榜
    Player[] public leaderboard;
    uint256 public leaderboardSize = 10; // 排行榜前10名

    // 事件
    event PlayerRegistered(address playerAddress, string username);
    event HighScoreSubmitted(address playerAddress, uint256 score);

    // 玩家注册函数
    function registerPlayer(string memory _username) public {
        require(
            bytes(players[msg.sender].username).length == 0,
            "Player already registered."
        );

        players[msg.sender] = Player(msg.sender, _username, 0);
        emit PlayerRegistered(msg.sender, _username);
    }

    // 提交分数
    function submitScore(uint256 _score) public {
        require(
            bytes(players[msg.sender].username).length > 0,
            "Player not registered."
        );

        // 如果玩家的分数高于历史记录，则更新
        if (_score > players[msg.sender].highScore) {
            players[msg.sender].highScore = _score;
            emit HighScoreSubmitted(msg.sender, _score);
            _updateLeaderboard(players[msg.sender]);
        }
    }

    // 获取玩家信息
    function getPlayer(
        address _playerAddress
    ) public view returns (string memory username, uint256 highScore) {
        Player memory player = players[_playerAddress];
        return (player.username, player.highScore);
    }

    // 获取排行榜
    function getLeaderboard() public view returns (Player[] memory) {
        return leaderboard;
    }

    // 内部函数：更新排行榜
    function _updateLeaderboard(Player memory _player) internal {
        // 判断玩家是否已经在排行榜中
        bool found = false;
        for (uint256 i = 0; i < leaderboard.length; i++) {
            if (leaderboard[i].playerAddress == _player.playerAddress) {
                leaderboard[i] = _player; // 更新玩家分数
                found = true;
                break;
            }
        }

        // 如果玩家不在排行榜中，且排行榜未满，则直接加入
        if (!found && leaderboard.length < leaderboardSize) {
            leaderboard.push(_player);
        } else if (!found) {
            // 如果排行榜已满，且玩家不在其中，找出最低分的玩家并替换
            uint256 minScoreIndex = 0;
            for (uint256 i = 1; i < leaderboard.length; i++) {
                if (
                    leaderboard[i].highScore <
                    leaderboard[minScoreIndex].highScore
                ) {
                    minScoreIndex = i;
                }
            }

            if (_player.highScore > leaderboard[minScoreIndex].highScore) {
                leaderboard[minScoreIndex] = _player; // 替换最低分玩家
            }
        }

        // 排序排行榜
        _sortLeaderboard();
    }

    // 内部函数：排序排行榜
    function _sortLeaderboard() internal {
        for (uint256 i = 0; i < leaderboard.length - 1; i++) {
            for (uint256 j = i + 1; j < leaderboard.length; j++) {
                if (leaderboard[j].highScore > leaderboard[i].highScore) {
                    Player memory temp = leaderboard[i];
                    leaderboard[i] = leaderboard[j];
                    leaderboard[j] = temp;
                }
            }
        }
    }
}
