// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Comments {
    event commentAdded(
        address author,
        string content,
        uint tips,
        uint timestamp
    );

    event tipped(uint256 id, int amount);

    struct Comment {
        uint id;
        uint tips;
        uint untips;
        string content;
        address payable author;
        address[] tippers;
        address[] unTippers;
    }

    uint256 public commentCount = 0;
    address[] public addressesTipped;

    mapping(uint256 => Comment) public comments;
    mapping(uint256 => mapping(address => bool)) public tippers; // (Comment.id => (tipper => bool))
    mapping(uint256 => mapping(address => uint256)) public addressToTips; // (Comment.id => (adres => wartosc tipa))

    mapping(uint256 => mapping(address => bool)) public unTippers; // (Comment.id => (tipper => bool))
    mapping(uint256 => mapping(address => uint)) public addressToUnTips; // (Comment.id => (adres => wartosc tipa))

    /*
     * @param {address} _tipper - New tipper address
     * Returns true if the address does not belong to the and array has been added, else false
     */
    function addTipper(address _tipper) private returns (bool) {
        for (uint256 i = 0; i < addressesTipped.length; i++) {
            if (_tipper == addressesTipped[i]) {
                return false;
            }
        }
        addressesTipped.push(_tipper);
        return true;
    }

    /*
     * @param {uint} _id - Comment id 
     * @param {uint} _amount - Value of tip 
     * emits event tipped
     */
    function tipComment(uint _id, uint256 _amount) public {
        require(msg.sender != address(0), "Sender can't be address 0");
        require(tippers[_id][msg.sender] == false, "User already tipped");
        require(unTippers[_id][msg.sender] == false, "User already unTipped");

        comments[_id].tips += _amount;

        unTippers[_id][msg.sender] = true;
        tippers[_id][msg.sender] = true;

        addressToTips[_id][msg.sender] += _amount;
        comments[_id].tippers.push(msg.sender);

        addTipper(msg.sender);

        for (uint256 id = 0; id < commentCount; id++) {
            comments[id].tips = 0;
            for (uint256 i = 0; i < comments[id].tippers.length; i++) {
                comments[id].tips += comments[id].tippers[i].balance;
                addressToTips[id][comments[id].tippers[i]] = comments[id].tippers[i].balance;
                emit tipped(id, int(int(comments[id].tips) - int(comments[id].untips)));
            }
        }

        emit tipped(_id, int(int(comments[_id].tips) - int(comments[_id].untips)));
    }

    /*
     * @param {uint} _id - Comment id 
     * @param {uint} _amount - Value of tip 
     * emits event tipped
     */
    function unTipComment(uint _id, uint _amount) public {
        require(msg.sender != address(0), "Sender can't be address 0");
        require(tippers[_id][msg.sender] == false, "User already tipped");
        require(unTippers[_id][msg.sender] == false, "User already unTipped");
        
        comments[_id].untips += _amount;

        unTippers[_id][msg.sender] = true;
        tippers[_id][msg.sender] = true;

        addressToUnTips[_id][msg.sender] += _amount;
        comments[_id].unTippers.push(msg.sender);

        addTipper(msg.sender);


        for (uint256 id = 0; id < commentCount; id++) {
            comments[id].untips = 0;
            for (uint256 i = 0; i < comments[id].unTippers.length; i++) {
                comments[id].untips += comments[id].unTippers[i].balance;
                addressToUnTips[id][comments[id].unTippers[i]] = comments[id].unTippers[i].balance;
                emit tipped(id, int(int(comments[id].tips) - int(comments[id].untips)));
            }
        }
        emit tipped(_id, int(int(comments[_id].tips) - int(comments[_id].untips)));
    }
    

    /*
     * @param {string} _content - Comment content 
     * @param {uint} _value - Comment initial tips value
     * emits event commentAdded
     */
    function addComment(
        string memory _content, 
        uint256 _value
    ) public {
        address[] memory tab;
        address[] memory tab1;

        comments[commentCount] = Comment(
            commentCount,
            0,
            0,
            _content,
            payable(msg.sender),
            tab,
            tab1
        );
        emit commentAdded(msg.sender, _content, 0, block.timestamp);
        tipComment(commentCount, _value);
        commentCount++;
    }

}
