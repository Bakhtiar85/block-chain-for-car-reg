// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract BCar {
  // Chat Module
  /**
  *? User=> :SignUp, :LogIn, :Loop, :isExists, :isLoggedIn
   */

   struct User {
    address pbKey;
    uint u_nic;
    string u_name;
    string u_contact;
    string u_address;
    string u_password;
    bool isLoggedIn;
    // friend[] friendList;
    // vehicle[] vehicleList;
   }
   
  //  event is a log creates on trigger. 
   event userSignedUp(address _key, string _nam, uint _nic, string u_cont, string u_pass);
   
   mapping (address=>User) public userList;

   function signUp(address _key, uint _nic, string memory _nam, string memory _cont, string memory _addr, string memory _pass) public returns (bool) {
    require(userList[_key].pbKey != msg.sender,  "User already exists!");
    
    userList[_key].pbKey = _key;
    userList[_key].u_nic = _nic;
    userList[_key].u_name = _nam;
    userList[_key].u_contact = _cont;
    userList[_key].u_address = _addr;
    userList[_key].u_password = _pass;

    emit userSignedUp(_key, _nam, _nic, _cont, _pass);

    return true;
   }

}
