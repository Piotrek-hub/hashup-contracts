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
    
    event commentUnTipped(
        uint id,
        uint unTippedAmount,
        address tipper
    );

    struct Comment {
        uint id;
        uint256 tips;
        string content;
        address payable author;
        address[] tippers;
    }

    
    uint public commentCount = 0;
    address[] public addressesTipped;
    
    mapping(uint => Comment) public comments;
    mapping(uint => mapping(address => bool)) public tippers; // (Comment.id => (tipper => bool))
    mapping(uint => mapping(address => uint)) public addressToTips; // (Comment.id => (adres => wartosc tipa))
    
    
    function getCommentTippers(uint _id) public view returns(address[] memory){
        return comments[_id].tippers;
    }
    
    // function setTips(address[] memory _tippers , uint[] memory _balances) public{
    //     for(uint tipperId = 0; tipperId < _tippers.length; tipperId++) {
    //         for(uint i = 0; i < commentCount; i++) {
    //             if(tippers[i][_tippers[tipperId]] && addressToTips[i][_tippers[tipperId]] != _balances[tipperId]) {
    //                 comments[i].tips -= addressToTips[i][_tippers[tipperId]] - _balances[tipperId];
    //                 addressToTips[i][_tippers[tipperId]] = _balances[tipperId];
    //             }
    //         }
    //     }
    // }

    function setTip(address _tipper, uint _balance) public{
        for(uint i = 0; i < commentCount; i++) {
            // Sprawdzenie czy _tipper zrobił tipa && sprawdzenie czy przybyło mu na konto albo wypłyneło z konta
            if(tippers[i][_tipper] && addressToTips[i][_tipper] != _balance) {
                comments[i].tips -= addressToTips[i][_tipper] - _balance;
                addressToTips[i][_tipper] = _balance;
                emit commentUnTipped(i, comments[i].tips, _tipper);
            }
        }
    }
    
    function getAddressToTips(uint _id, address _tipper) public view returns(uint){
        return addressToTips[_id][_tipper];
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
        
        
        tippers[_id][msg.sender] = true;
        addressToTips[_id][msg.sender] += _amount;
        _comment.tippers.push(msg.sender);
        
        
        addTipper(msg.sender);
        
        // setTips
        
        comments[_id] = _comment;


        for(uint i = 0; i < addressesTipped.length; i++ ) {
            setTip(addressesTipped[i], addressesTipped[i].balance / (1 ether));
        }

        emit commentTipped(_id, _comment.tips);
        
    }

    function getBalance(address _addr) external view returns (uint){
        return _addr.balance/ (1 ether);
    }

    function addComment(string memory _content, uint _value) public {
        address[] memory tab;
        comments[commentCount] = Comment(commentCount, 0, _content, payable(msg.sender), tab);
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
    
    function pay() payable public {}
    
}