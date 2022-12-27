// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract BCar {
    /**
     * ! I might need to add public Key 'ACCOUNT ADDRESS' of users
     */

    // Chat Module /, Vehicle Moduel
    /**
     *? User=> :SignUp /, :LogIn/, :LogOut /, :getUserInfo, :getFriendsList /
     */

    struct User {
        uint256 u_nic;
        string u_name;
        string u_contact;
        string u_address;
        string u_password;
        bool isLoggedIn;
        Friend[] friendList;
    }

    // ALL USERS
    uint256 userCounts = 0;
    struct AllUsers {
        uint256 u_count;
        uint256 user_nic;
    }
    mapping(uint256 => AllUsers) public allUsers;

    //  event is a log creates on trigger.
    event userSignedUp(string _nam, uint256 _nic, string u_cont, string u_pass);
    event LogoutUser(bool isUserLoggedIn);

    mapping(uint256 => User) public userList;

    function signUp(
        uint256 _nic,
        string memory _nam,
        string memory _cont,
        string memory _addr,
        string memory _pass
    ) public returns (bool) {
        require(!isUserExist(_nic), "User already exists!");

        userList[_nic].u_nic = _nic;
        userList[_nic].u_name = _nam;
        userList[_nic].u_contact = _cont;
        userList[_nic].u_address = _addr;
        userList[_nic].u_password = _pass;
        userList[_nic].isLoggedIn = true;

        userCounts++;
        allUsers[userCounts] = AllUsers(userCounts, _nic);

        emit userSignedUp(_nam, _nic, _cont, _pass);

        return true;
    }

    function LogIn(uint256 _nic, string memory _pass) public returns (bool) {
        require(isUserExist(_nic), "User does not exists!");
        require(!isLoggedIn(_nic), "You are Already Logged In!");
        require(
            keccak256(abi.encodePacked(_pass)) ==
                keccak256(abi.encodePacked(userList[_nic].u_password)),
            "Passwor Does Not Matched!"
        );
        return userList[_nic].isLoggedIn = true;
    }

    function LogOut(uint256 _nic) public returns (bool) {
        require(isLoggedIn(_nic), "You Need To Log In First!");
        emit LogoutUser(false);
        return userList[_nic].isLoggedIn = false;
    }

    function getUserInfo(uint256 _nic)
        public
        view
        returns (
            uint256,
            string memory,
            string memory,
            string memory,
            bool
        )
    {
        require(isUserExist(_nic), "User does not exists!");
        return (
            userList[_nic].u_nic,
            userList[_nic].u_name,
            userList[_nic].u_contact,
            userList[_nic].u_address,
            userList[_nic].isLoggedIn
        );
    }

    function getFriendsList(uint256 _nic)
        external
        view
        returns (Friend[] memory)
    {
        require(isUserExist(_nic), "User exists!");
        require(isLoggedIn(_nic), "You Need To Log In First!");

        return userList[_nic].friendList;
    }

    /**
     *? Friends=> :addNewFriend /, :checkAlreadyFriends /, :LoopOnFriend /
     */

    // Each friend is identified by its address and name assigned by the second party
    struct Friend {
        uint256 f_nic;
        string f_name;
    }

    event AddFriend(uint256 friend_key, string name);

    mapping(uint256 => Friend) public friendList;

    function addNewFriend(
        uint256 _nic,
        uint256 f_nic,
        string calldata f_name
    ) external {
        require(isLoggedIn(_nic), "You Need To Log In First!");
        require(
            isUserExist(f_nic),
            "Your Firend Does Not Registered With The System!"
        );
        require(_nic != f_nic, "User cannot add him/her self as friend!");
        require(
            areFriends(_nic, f_nic) == false,
            "These users are already friends!"
        );

        _addFriend(_nic, f_nic, f_name);
        _addFriend(f_nic, _nic, userList[_nic].u_name);
        emit AddFriend(f_nic, f_name);
    }

    function areFriends(uint256 _nic, uint256 f_nic)
        public
        view
        returns (bool)
    {
        // if the list of user is greater then the list of friend
        if (
            userList[_nic].friendList.length > userList[f_nic].friendList.length
        ) {
            uint256 tmp = _nic;
            _nic = f_nic;
            f_nic = tmp;
        }
        // the loop will run on bigger list
        for (uint256 i = 0; i < userList[_nic].friendList.length; i++) {
            if (userList[_nic].friendList[i].f_nic == f_nic) return true;
        }
        return false;
    }

    // A helper function to update the friendList
    function _addFriend(
        uint256 me,
        uint256 friend_key,
        string memory name
    ) internal {
        // create new object of type friend
        Friend memory newFriend = Friend(friend_key, name);
        // add newly created obj to friend list of user
        userList[me].friendList.push(newFriend);
    }

    /**
     *? Messages' Funcions=> :
     */

    // message construct stores the single chat message and its metadata
    struct message {
        // address sender;
        uint256 sender_nic;
        uint256 timestamp;
        string msg;
    }

    event SendMessage(uint256 sender_key, uint256 friend_key, string msg);

    // Collection of messages communicated in a channel between two users
    mapping(bytes32 => message[]) allMessages; // key : Hash(user1,user2)

    // Returns a unique code for the channel created between the two users
    // Hash(key1,key2) where key1 is lexicographically smaller than key2
    // function _getChatCode(address pubkey1, address pubkey2) internal pure returns(bytes32) {
    function _getChatCode(uint256 _nic, uint256 f_nic)
        internal
        pure
        returns (bytes32)
    {
        if (_nic < f_nic) return keccak256(abi.encodePacked(_nic, f_nic));
        else return keccak256(abi.encodePacked(f_nic, _nic));
    }

    // Sends a new message to a given friend
    function sendMessage(
        uint256 _nic,
        uint256 f_nic,
        string calldata _msg
    ) external {
        require(isLoggedIn(_nic), "You Need To Log In First!");
        require(
            isUserExist(f_nic),
            "Your Firend Does Not Registered With The System!"
        );
        require(
            areFriends(_nic, f_nic) == true,
            "You are not friends with the given user!"
        );
        bytes32 chatCode = _getChatCode(_nic, f_nic);
        message memory newMsg = message(_nic, block.timestamp, _msg);
        allMessages[chatCode].push(newMsg);
        emit SendMessage(_nic, f_nic, _msg);
    }

    // Returns all the chat messages communicated in a channel
    function readMessage(uint256 _nic, uint256 f_nic)
        external
        view
        returns (message[] memory)
    {
        bytes32 chatCode = _getChatCode(_nic, f_nic);
        return allMessages[chatCode];
    }

    /**
     *? Vehicles => :addNewVehicle /, :isVehicleRegistered /, :getVehicleInfo /, :_addVehicle /
     * *_addVehicle is used to link vehicle with user
     *! vehilce will be tracked through engin no.
     *! I have been triying to track a vehicle both on its engin and vehicle no. But don't know why code was misbehaving.
     */

    // ALL VEHICLES
    uint256 vehiclesCounts = 0;
    struct AllVehicles {
        uint256 v_count;
        string v_e_no;
    }
    mapping(uint256 => AllVehicles) public allVehicles;

    struct Vehicle {
        string e_no;
        string v_no;
        string company;
        string modal;
        string year;
        uint256 owner_id;
        bool reg_with_owner;
    }

    mapping(string => Vehicle) public vehicleList;

    event newVehicleAdded(
        string e_no,
        string v_no,
        string company,
        string modal,
        string year,
        uint256 owner_id,
        bool reg_with_owner
    );

    function addNewVehicle(
        uint256 _nic,
        string memory e_no,
        string memory v_no,
        string memory company,
        string memory modal,
        string memory year
    ) public returns (bool) {
        require(isLoggedIn(_nic), "You Need To Log In First!");
        require(!isVehicleRegistered(e_no), "Vehicle Already Rdgistered");

        vehicleList[e_no].e_no = e_no;
        vehicleList[e_no].v_no = v_no;
        vehicleList[e_no].company = company;
        vehicleList[e_no].modal = modal;
        vehicleList[e_no].year = year;
        vehicleList[e_no].owner_id = _nic;
        vehicleList[e_no].reg_with_owner = true;

        vehiclesCounts++;
        allVehicles[vehiclesCounts] = AllVehicles(vehiclesCounts, e_no);

        emit newVehicleAdded(e_no, v_no, company, modal, year, _nic, true);
        _addVehicle(_nic, e_no);

        return true;
    }

    function getVehicleInfo(string memory e_no)
        public
        view
        returns (
            string memory,
            string memory,
            string memory,
            string memory,
            string memory,
            uint256,
            bool
        )
    {
        require(isVehicleRegistered(e_no), "Vehicle is not Registered");
        return (
            vehicleList[e_no].e_no,
            vehicleList[e_no].v_no,
            vehicleList[e_no].company,
            vehicleList[e_no].modal,
            vehicleList[e_no].year,
            vehicleList[e_no].owner_id,
            vehicleList[e_no].reg_with_owner
        );
    }

    /**
     *? userVehicles functions =>  :_addVehicle /, :getUserVehicles /, :transferVehicle /
     ** _addVehicle is a helper funtion to add vehilce to the user.
     */

    struct UserVehicles {
        uint256 user_id;
        Vehicle[] vehicles_data;
    }

    mapping(uint256 => UserVehicles) public userVehicles;

    function _addVehicle(uint256 _nic, string memory e_no) public {
        userVehicles[_nic].vehicles_data.push(vehicleList[e_no]);
    }

    function getUserVehicles(uint256 _nic)
        external
        view
        returns (Vehicle[] memory)
    {
        require(isLoggedIn(_nic), "You Need To Log In First!");

        return userVehicles[_nic].vehicles_data;
    }

    function transferVehicle(
        uint256 _nic,
        uint256 n_nic,
        string memory e_no
    ) public {
        require(isLoggedIn(_nic), "You Need To Log In First!");
        require(
            _nic != n_nic,
            "User cannot transfer the vehicle data on his/her account!"
        );
        require(isUserExist(n_nic), "Other User Is Not Registered!");
        require(
            isVehicleRegistered(e_no),
            "Vehicle You Are Trying To Transfer is Not Registered!"
        );
        require(
            isVehicleRegisteredWithTheUser(e_no, _nic),
            "Vehicle You Are Trying To Transfer is Not Registered With You!"
        );

        // complex code
        // on following line vehicle will be transfered to new user.
        _addVehicle(n_nic, e_no);
        // turn current user's status to false
        for (uint256 i = 0; i < userVehicles[_nic].vehicles_data.length; i++) {
            if (
                keccak256(
                    abi.encodePacked(userVehicles[_nic].vehicles_data[i].e_no)
                ) ==
                keccak256(abi.encodePacked(e_no)) &&
                userVehicles[_nic].vehicles_data[i].reg_with_owner == true
            ) {
                userVehicles[_nic].vehicles_data[i].reg_with_owner = false;
                vehicleList[e_no].owner_id = n_nic;
                break;
            }
        }
    }

    /**
     *? general purpose functions =>  :Loop, :isUserExists/, :isLoggedIn/, :isVehicleExists /
     */

    function isUserExist(uint256 _nic) public view returns (bool) {
        return bytes(userList[_nic].u_name).length > 0;
    }

    function isLoggedIn(uint256 _nic) public view returns (bool) {
        return userList[_nic].isLoggedIn;
    }

    function isVehicleRegistered(string memory e_no)
        public
        view
        returns (bool)
    {
        return vehicleList[e_no].reg_with_owner;
    }

    function isVehicleRegisteredWithTheUser(string memory e_no, uint256 _nic)
        public
        view
        returns (bool)
    {
        return vehicleList[e_no].owner_id == _nic;
    }
}
