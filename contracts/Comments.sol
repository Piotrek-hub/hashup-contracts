// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;
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



    function tipComment(uint _id) public payable{
        require(msg.sender != address(0), "Sender can't be address 0");
        require(msg.value >= 0.1 ether, "To small amount of ether");

        
        Comment storage _comment = comments[_id];

        address payable _author = comments[_id].author;

        _author.transfer(msg.value);

        _comment.tips += 1;

        comments[_id] = _comment;

        emit commentTipped(_id, msg.value);

    }


    function addComment(string memory _content) public {
        comments[commentCount] = Comment(commentCount, 0, _content, payable(msg.sender));
        emit commentAdded(msg.sender, _content, 0, block.timestamp);
        commentCount++;
    }
    
    function getCommentCount() public view returns(uint){
        return commentCount;
    }
    
    function getCommentById(uint _id) public view returns(Comment memory) {
        return comments[_id];
    }
}