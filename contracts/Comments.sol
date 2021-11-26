// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

/*
    1. Dodanie msg.sender do listy 
    2. Przy pierwszym onLoad na strone zapisanie id bloku + sprawdzenie czy w liscie msg.sender zawiera sie adres ktory wykonywał transakcje
    3.1 Jeśli msg.sender zrobił transakcje to 
*/

contract Comments {
    event commentAdded(
        address author,
        string content,
        uint256 tips,
        uint256 timestamp
    );

    event commentTipped(uint256 id, uint256 amount);

    event commentUnTipped(uint256 id, uint256 amount);

    struct Comment {
        uint256 id;
        uint256 tips;
        string content;
        address payable author;
        address[] tippers;
    }

    uint256 public commentCount = 0;
    uint256 public tipsSum;
    address[] public addressesTipped;

    mapping(uint256 => Comment) public comments;
    mapping(uint256 => mapping(address => bool)) public tippers; // (Comment.id => (tipper => bool))
    mapping(uint256 => mapping(address => uint256)) public addressToTips; // (Comment.id => (adres => wartosc tipa))

    function getCommentTippers(uint256 _id)
        public
        view
        returns (address[] memory)
    {
        return comments[_id].tippers;
    }

    function setTip(address _tipper) public {
        for (uint256 i = 0; i < commentCount; i++) {
            comments[i].tips = 0;
            for (uint256 j = 0; j < comments[i].tippers.length; j++) {
                comments[i].tips += _tipper.balance/(1 ether);
            }
        }
        // function setTip(address _tipper, uint _balance) public{
        //     for(uint i = 0; i < commentCount; i++) {
        //         if(tippers[i][_tipper] && addressToTips[i][_tipper] != _balance) {
        //             comments[i].tips -= addressToTips[i][_tipper] - _balance;
        //             addressToTips[i][_tipper] = _balance;
        //         }
        //     }
        // }
    }

    function getTotalTipsSum() public view returns (uint256) {
        return tipsSum;
    }

    function getTippers() public view returns (address[] memory) {
        return addressesTipped;
    }

    function addTipper(address _tipper) private returns (bool) {
        for (uint256 i = 0; i < addressesTipped.length; i++) {
            if (_tipper == addressesTipped[i]) {
                return false;
            }
        }
        addressesTipped.push(_tipper);
        return true;
    }

    function tipComment(uint256 _id, uint256 _amount) public {
        require(msg.sender != address(0), "Sender can't be address 0");
        require(tippers[_id][msg.sender] == false, "User already tipped");

        Comment storage _comment = comments[_id];

        _comment.tips += _amount;
        tipsSum += _amount;

        tippers[_id][msg.sender] = true;
        addressToTips[_id][msg.sender] += _amount;
        _comment.tippers.push(msg.sender);

        addTipper(msg.sender);

        comments[_id] = _comment;
        setTip(msg.sender);
        emit commentTipped(_id, _amount);
    }

    function addComment(string memory _content, uint256 _value) public {
        address[] memory tab;
        comments[commentCount] = Comment(
            commentCount,
            0,
            _content,
            payable(msg.sender),
            tab
        );
        emit commentAdded(msg.sender, _content, 0, block.timestamp);
        tipComment(commentCount, _value);
        commentCount++;
    }

    function getCommentCount() public view returns (uint256) {
        return commentCount;
    }

    function getCommentById(uint256 _id) public view returns (Comment memory) {
        return comments[_id];
    }
}
