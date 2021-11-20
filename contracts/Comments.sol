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
    address[] public addressesTipped;
    
    mapping(uint => Comment) public comments;
    mapping(uint => mapping(address => bool)) public tippers; // Comment.id => (tipper => bool)


    // function getTippers() public view returns (address[] memory){
    //     address[] memory result;
    //     for(uint i = 0; i < commentCount; i++){
    //         if(tippers[i][])
    //     }
    // }

    function tipComment(uint _id, uint _amount) public payable{
        require(msg.sender != address(0), "Sender can't be address 0");
        require(tippers[_id][msg.sender] == false, "User already tipped");
        
        Comment storage _comment = comments[_id];
        
        _comment.tips += _amount;
        
        // User tipped (can only once)
        tippers[_id][msg.sender] = true;
        
        comments[_id] = _comment;

        emit commentTipped(_id, _amount);
        
    }


    function addComment(string memory _content, uint _value) public {
        comments[commentCount] = Comment(commentCount, 0, _content, payable(msg.sender));
        // Event dodania komentarza 
        emit commentAdded(msg.sender, _content, 0, block.timestamp);
        // Tipowanie komentarza
        tipComment(commentCount, _value);
        commentCount++;
    }
    
    function getCommentCount() public view returns(uint){
        return commentCount;
    }
    
    function getCommentById(uint _id) public view returns(Comment memory) {
        return comments[_id];
    }
    
    
}