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
        uint timestamp
    );

    event commentTipped(
        uint id,
        uint amount
    );
    
    event commentUnTipped(
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
    uint public tipsSum;
    address[] public addressesTipped;
    
    mapping(uint => Comment) public comments;
    mapping(uint => mapping(address => bool)) public tippers; // Comment.id => (tipper => bool)
    mapping(uint => mapping(address => uint)) public addressToTips; // (commentId => (adres => wartosc tipa))
    
    
    function setTip(address _tipper, uint _balance) public{
        for(uint i = 0; i < commentCount; i++) {
            if(tippers[i][_tipper] && addressToTips[i][_tipper] != _balance) {
                comments[i].tips -= addressToTips[i][_tipper] - _balance;
                addressToTips[i][_tipper] = _balance;
            }
        }
    }
    
    function getTotalTipsSum() public view returns(uint){
        return tipsSum;
    }
    
    function getTippers() public view returns (address[] memory) {
        return addressesTipped;
    }
        
    function addTipper(address _tipper) private returns(bool){
        for(uint i = 0; i < addressesTipped.length; i++) {
            if(_tipper == addressesTipped[i]) {
                return false;
            }
        }
        addressesTipped.push(_tipper);
        return true;
    }    
        
    function tipComment(uint _id, uint _amount) public {
        require(msg.sender != address(0), "Sender can't be address 0");
        require(tippers[_id][msg.sender] == false, "User already tipped");
        
        Comment storage _comment = comments[_id];
        
        _comment.tips += _amount;
        tipsSum += _amount;
        
        
        // User tipped (can only once)
        tippers[_id][msg.sender] = true;
        addressToTips[_id][msg.sender] += _amount;
        
        
        addTipper(msg.sender);
        
        
        comments[_id] = _comment;

        emit commentTipped(_id, _amount);
        
    }

    function addComment(string memory _content, uint _value) public {
        comments[commentCount] = Comment(commentCount, 0, _content, payable(msg.sender));
        emit commentAdded(msg.sender, _content, 0, block.timestamp);
        tipComment(commentCount, _value);
        commentCount++;
    }
    
    function getCommentCount() public view returns (uint){
        return commentCount;
    }
    

    function getCommentById(uint _id) public view returns (Comment memory) {
        return comments[_id];
    }
    
    
}