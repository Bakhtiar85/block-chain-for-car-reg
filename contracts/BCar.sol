// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract BCar {
  // Chat Module
  /**
  *? User=> :SignUp, :LogIn, :Loop, :isExists, :isLoggedIn
   */
  
   struct User {
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
   event userSignedUp(string _nam, uint _nic, string u_cont, string u_pass);
   
   mapping (uint=>User) public userList;

   function signUp(uint _nic, string memory _nam, string memory _cont, string memory _addr, string memory _pass) public returns (bool) {
    require(!isUserExist(_nic),  "User already exists!");
    
    userList[_nic].u_nic = _nic;
    userList[_nic].u_name = _nam;
    userList[_nic].u_contact = _cont;
    userList[_nic].u_address = _addr;
    userList[_nic].u_password = _pass;

    emit userSignedUp(_nam, _nic, _cont, _pass);

    return true;
   }

   function isUserExist(uint _nic) public view returns (bool) {
    return bytes(userList[_nic].u_name).length > 0;
   }

}
