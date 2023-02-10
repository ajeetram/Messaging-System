// SPDX-License-Identifier: MIT
pragma solidity^0.8.17;

contract SocialMedia
{
    // user struct
    struct user{
        string name;
        friend[] friendList;
    }
    
    // friend struct which will show public key and name to connect to others friends 
    struct friend{
        address pub_key;
        string name;
    }

    // message strcut which contains the msg sender address,timing of receive msg and msg
    struct message
    {
        address sender;
        uint256 timestamp;
        string msg;
    }

    struct AllUserStruct
    {
        string name;
        address accountAddress;

    }

    AllUserStruct[] getAllUsers;
  
    // mapping one particular user to their respective address
    mapping(address=>user) userList;
    // mapping with encoded string to array to store all message between any two user; 
    mapping(bytes32=>message[]) allMsges;

    //Check User exist in our plateform or not

    function checkUserExists(address pub_key) public view returns(bool)
    {
        return(bytes(userList[pub_key].name).length>0);
    }

    // create account to register user
    function createAccount(string calldata name) external // in function argument i have used calldata instead of memory                                                   
    {                                                     // because function is external and calldata can not modified and it is nonpersistance(not store in blockchai)
        // if user exist
        require(checkUserExists(msg.sender)==false,"You are already exist");
        // if username can not be empty
        require(bytes(name).length>0,"Username can not be empty");
        // Listing user with their name with respect to their addresse
        userList[msg.sender].name = name;

        getAllUsers.push(AllUserStruct(name, msg.sender));
    }

    function getUserName(address pub_key) external view returns(string memory)
    {
        require(checkUserExists(pub_key)==true,"You are not registered ");
        return(userList[pub_key].name);
    }

    function addFriend(address frnd_key, string calldata name) external
    {
        require(checkUserExists(msg.sender),"create your account first");
        require(checkUserExists(frnd_key),"User is not registered");
        require(msg.sender!=frnd_key,"Users can't add themselves as friends");
        require(checkAlreadyFrnd(msg.sender,frnd_key)==false,"These users are already friends");
        _addFriend(msg.sender,frnd_key,name);
        _addFriend(frnd_key,msg.sender,userList[msg.sender].name);
    }

     
     function checkAlreadyFrnd(address pub_key1, address pub_key2) internal view returns(bool)
     {
         if(userList[pub_key1].friendList.length > userList[pub_key2].friendList.length)
         {
             address temp = pub_key1;
             pub_key1=pub_key2;
             pub_key2=temp;
         }

         for(uint256 i=0;i<userList[pub_key1].friendList.length;i++)
         {
             if(userList[pub_key1].friendList[i].pub_key==pub_key2)
             return true;
         }
         return false;
     }
     // user can add your friend using their address and name
     function _addFriend(address me, address frnd_key, string memory name) internal{
        friend memory newFriend = friend(frnd_key,name);
        userList[me].friendList.push(newFriend);

     }
     // user can see your friend list
     function getMyFriendList() external view returns(friend[] memory)
     {
         return userList[msg.sender].friendList;
     }
     
     
     // user chat code
     function _getChatCode(address pub_key1, address pub_key2) internal pure returns(bytes32)
     {
         if(pub_key1<pub_key2)
         {
            return keccak256(abi.encodePacked(pub_key1,pub_key2));
         }
         else

         {
            return keccak256(abi.encodePacked(pub_key2,pub_key1));
            
         }
     }
     
     // messaging
    function sendMessage(address frnd_key, string calldata _msg) external{
        require(checkUserExists(msg.sender),"Create your account first");
        require(checkUserExists(frnd_key),"user is not registered");
        require(checkAlreadyFrnd(msg.sender,frnd_key),"You are not friend with this user");
        bytes32 chatCode = _getChatCode(msg.sender,frnd_key);
        message memory newMsg = message(msg.sender,block.timestamp,_msg);
        allMsges[chatCode].push(newMsg);
    }

    // Read recieved all messages
    function readMessage(address frnd_key) external view returns(message[] memory )
    {
        bytes32 chatCode = _getChatCode(msg.sender,frnd_key);
        return allMsges[chatCode];
    }
     
    function getAllAppUser() public view returns(AllUserStruct[] memory)
    {
        return getAllUsers;
    }

}
