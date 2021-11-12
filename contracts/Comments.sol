// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Comments {

    event commentAdded(
        address author,
        string content,
        uint256 tips,
        uint timestamp
    );

    event commentTipped(
        uint id,
        uint amount
    );

    struct Comment {
        uint id;
        uint256 tips;
        string content;
        address payable author;
    }


    uint public commentCount = 0;


    mapping(uint => Comment) public comments;



    function tipComment(uint _id) external payable{
        require(msg.sender != address(0), "Sender can't be address 0");
        require(msg.value >= 0.1 ether, "To small amount of ether");
        require(_id >= 0 && _id < commentCount);

        address payable _author = comments[_id].author;

        _author.transfer(msg.value);

        comments[_id].tips += msg.value ;

        emit commentTipped(_id, msg.value);

    }

    function addComment(string memory _content) public {
        comments[commentCount] = Comment(commentCount, 0, _content, payable(msg.sender));
        emit commentAdded(msg.sender, _content, 0, block.timestamp);
        commentCount++;
    }

}