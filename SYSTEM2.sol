// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SYSTEM{
    
    struct User{
        string name;
        string gender;
        string email;
        uint phoneNumber;
    }

    User[] userArray;//根据索引查看和修改信息

    mapping(string => User) nameToProlile;//根据用户名修改信息

    function createAccount
    (
        string calldata _name,
        string calldata _gender,
        string calldata _email,
        uint _phoneNumber) external returns(bool)
            {
            for(uint i = 0;i < userArray.length;i++){
        require(!(keccak256(abi.encodePacked(userArray[i].name)) == keccak256(abi.encodePacked(_name))),"this name is existed");
                
            }
        User memory user;
        user.name = _name;
        user.gender = _gender;
        user.email = _email;
        user.phoneNumber = _phoneNumber;
        userArray.push(user);
        return true;
    }
    function searchUserFromId(uint _id) external view returns
    (
        string memory _name,
        string memory _gender,
        string memory _email,
        uint _phoneNumber){
        require(_id > 0,"id must bigger than 0");
        (_name,_gender,_email,_phoneNumber) = 
        (
            userArray[_id-1].name,
            userArray[_id-1].gender,
            userArray[_id-1].email,
            userArray[_id-1].phoneNumber);
    }
    function idLong() external view returns(uint x){
        x = userArray.length;
    }
    function searchForName(string calldata _userName) public view returns
    (
        string memory _name,
        string memory _gender,
        string memory _email,
        uint _phoneNumber){
        for(uint i = 0;i<userArray.length;i++){ 
            if(keccak256(abi.encodePacked(userArray[i].name)) == keccak256(abi.encodePacked(_userName))){
                (_name,_gender,_email,_phoneNumber) = 
                (
                    userArray[i].name,
                    userArray[i].gender,
                    userArray[i].email,
                    userArray[i].phoneNumber);

            
            }
        }
    }
    function deleteFromId(uint _id) external returns(bool){
        delete userArray[_id - 1];
        return true;
    }
}
