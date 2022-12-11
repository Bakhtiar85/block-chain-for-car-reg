// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract BCar {
  // Chat Module
  /**
  *? User=> :SignUp /, :LogIn/, :LogOut
   */
  
   struct User {
    uint u_nic;
    string u_name;
    string u_contact;
    string u_address;
    string u_password;
    bool isLoggedIn;
    Friend[] friendList;
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
    userList[_nic].isLoggedIn = true;

    emit userSignedUp(_nam, _nic, _cont, _pass);

    return true;
   }

   function LogIn(uint _nic, string memory _pass) public returns (string memory) {
    require(isUserExist(_nic),  "User exists!");
    if (keccak256(abi.encodePacked(_pass)) ==
                keccak256(abi.encodePacked(userList[_nic].u_password))) {
                  // if user exists and password is correct
                  userList[_nic].isLoggedIn = true;
      return 'Success';
    }    
    // if user exists and password is incorrect
    return 'Failed';
   }

    /**
  *? Friends=> :addNewFriend , :checkAlreadyFriends , :LoopOnFriend 
   */

    // Each friend is identified by its address and name assigned by the second party
    struct Friend {
        uint f_nic;
        string f_name;
    }

    event AddFriend(uint friend_key, string name);

    mapping (uint=>Friend) public friendList;
  
   function addNewFriend(uint _nic, uint f_nic, string calldata f_name) external {
    require(isLoggedIn(_nic), "You Need To Log In First!");
    require(isUserExist(f_nic),  "Your Firend Does Not Registered With The System!");
    require(_nic!=f_nic, "User cannot add him/her self as friend!");
    require(areFriends(_nic,f_nic)==false, "These users are already friends!");

    _addFriend(_nic, f_nic, f_name);
    _addFriend(f_nic, _nic, userList[_nic].u_name);
    emit AddFriend(f_nic, f_name);
   }

  function areFriends(uint _nic, uint f_nic) public view returns (bool) {
    // if the list of user is greater then the list of friend
    if(userList[_nic].friendList.length > userList[f_nic].friendList.length){
      uint tmp = _nic;
      _nic = f_nic;
      f_nic = tmp;
    }
    // the loop will run on bigger list
    for (uint256 i = 0; i < userList[_nic].friendList.length; i++) {
      if(userList[_nic].friendList[i].f_nic == f_nic)
      return true;
    }
    return false;
  }
   
  // A helper function to update the friendList
  function _addFriend(uint me, uint friend_key, string memory name) internal {
    // create new object of type friend
      Friend memory newFriend = Friend(friend_key,name);
      // add newly created obj to friend list of user
      userList[me].friendList.push(newFriend);
  }
   
/** 
 *? general purpose functions =>  :Loop, :isExists/, :isLoggedIn/
 */

   function isUserExist(uint _nic) public view returns (bool) {
    return bytes(userList[_nic].u_name).length > 0;
   }

   function isLoggedIn(uint _nic) public view returns (bool) {
    return userList[_nic].isLoggedIn;
   }


}
