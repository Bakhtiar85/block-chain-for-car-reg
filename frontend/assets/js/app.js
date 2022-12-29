/**
 * ! in try catch after rejecting metamask, show user the reason of which he faild to achive the function
 */

App = {
    loading: false,
    contracts: {},

    load: async () => {
        await App.loadWeb3();
        await App.loadAccount();
        await App.loadContract();
        await App.render();
        await App.getUserInfo();
        await App.getUserVehicles();
        await App.populateUserInfo();
    },

    // https://medium.com/metamask/https-medium-com-metamask-breaking-change-injecting-web3-7722797916a8
    loadWeb3: async () => {
        if (typeof web3 !== 'undefined') {
            App.web3Provider = web3.currentProvider;
            web3 = new Web3(web3.currentProvider);
        } else {
            window.alert("Please connect to Metamask.");
        }
        // Modern dapp browsers...
        if (window.ethereum) {
            window.web3 = new Web3(ethereum);
            try {
                // Request account access if needed
                await ethereum.enable();
                // Acccounts now exposed
                web3.eth.sendTransaction({/* ... */ });
            } catch (error) {
                // User denied account access...
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            window.web3 = new Web3(web3.currentProvider);
            // Acccounts always exposed
            web3.eth.sendTransaction({/* ... */ });
        }
        // Non-dapp browsers...
        else {
            console.log('Non-Ethereum browser detected. You should consider trying MetaMask!');
        }
    },

    loadAccount: async () => {
        App.account = web3.currentProvider.selectedAddress;
        // console.log(App.account);
    },

    loadContract: async () => {
        // Create a JavaScript version of the smart contract
        const bCar = await $.getJSON('/build/contracts/BCar.json');
        App.contracts.BCar = TruffleContract(bCar);
        App.contracts.BCar.setProvider(App.web3Provider);

        // // Hydrate the smart contract with values from the blockchain
        App.bCar = await App.contracts.BCar.deployed()
    },

    render: async () => {
        // Prevent Double Rendering
        if (App.loading) {
            return;
        }

        // update app loading state
        App.setLoading(true);

        // $('#account').html(App.account);

        // update app loading state
        App.setLoading(false);
    },

    setLoading: (boolean) => {
        App.loading = boolean
        const loader = $('#loader')
        const content = $('.content')
        if (boolean) {
            loader.show()
            content.hide()
        } else {
            loader.hide()
            content.show()
        }
    },

    createUser: async () => {
        App.setLoading(true);
        var _cnic = $('#grid-u-nic').val().replaceAll('-', '');
        var _fullname = $('#grid-full-name').val();
        var _address = $('#grid-u-address').val();
        var _contact = $('#grid-u-contact').val();
        var _password = $("#grid-password").val();

        // _cnic = parseInt(_cnic);

        const setUserResponse = await App.bCar.signUp(_cnic, _fullname, _contact, _address, _password, { from: App.account });

        console.log(setUserResponse);

        if (setUserResponse) {
            localStorage.setItem('userId', _cnic)
            localStorage.setItem('userName', _fullname)
            localStorage.setItem('userCity', _address)
            window.location.href = './profile.html';
        } else {
            alert('User Already Registred!');
            window.location.href = './signIn.html';
        }
    },

    userLogin: async () => {

        var cnic = parseInt($('#user_nic').val().replaceAll('-', ''));
        var pass = $('#password').val();
        
        await App.bCar.LogIn(cnic, pass, { from: App.account }).then(async(response) => {
            const userInfo = await App.bCar.getUserInfo(cnic, { from: App.account });
            const userVehicles = await App.bCar.getUserVehicles(cnic, { from: App.account });
            console.log(userVehicles);
            localStorage.setItem('userId', userInfo[0])
            localStorage.setItem('userName', userInfo[1])
            localStorage.setItem('userCity', userInfo[2])
            window.location.href = './profile.html';
        }).catch((err) => {
            console.log("Failed with error: " + JSON.stringify(err));
        });
    },

    getUserInfo: async () => {
        App.setLoading(true);
        var cnic = localStorage.getItem('userId');
        if (!isNaN(cnic) && cnic != undefined) {
            const userInfo = await App.bCar.getUserInfo(cnic, { from: App.account });
        }
    },

    regVehicle: async () => {

        var user_cnic = localStorage.getItem('userId');//
        var _engno = $('input#engno').val();//
        var _vehno = $('input#vehno').val();//
        var _company = $('input#company').val();//
        var _model = $('input#model').val();//
        var _year = $('input#year').val();//
        // var _chano = $('input#chano').val();
        // var _color = $('input#color').val();

        var registrationResponse = await App.bCar.addNewVehicle(user_cnic, _engno, _vehno, /* _chano */  _company, _model, _year, { from: App.account });
        console.log(registrationResponse);

    },

    getUserVehicles: async () => {
        App.setLoading(true);
        var user_id = localStorage.getItem('userId');
        var u_vehicles = $('table#u_vehicles tbody');
        var vehicle_option = $('#vehicles_select');
        if (user_id) {
            const userVehicles = await App.bCar.getUserVehicles(user_id);
            
            userVehicles.forEach(async (element, count) => {
                // console.log(element);
                var text_class = 'text-red-400';

                var e_no = element['e_no'];
                var v_no = element['v_no'];
                var company = element['company'];
                var model = element['modal'];
                var year = element['year'];
                var is_reg_with_owner = element['reg_with_owner'];
                if (is_reg_with_owner) {
                    vehicle_option.append("<option value='" + e_no + "'>" + v_no +' & '+ e_no+ "</option>")
                    text_class = '';
                }
                
                var v_tr = "<tr class="+ text_class +"><th  scope = 'row' >" + ++count + "</th><td>" + v_no + "</td><td>" + e_no + "</td><td>" + company + "</td><td>" + model + "</td><td>" + year + "</td></tr>";
                u_vehicles.append(v_tr);
                
            });
        }
    },

    transferFormUpdate: async (_vehno) => {

        var vinfo = await App.bCar.getVehicleInfo(_vehno.value, { from: App.account })
        console.log(vinfo);
        var v_no = vinfo[2];
        var e_no = vinfo[3];
        var company = vinfo[3];
        var model = vinfo[4];
        var year = vinfo[5];

        $('input#engno').val(v_no)
        $('input#vehno').val(e_no)
        $('input#company').val(company)
        $('input#model').val(model)
        $('input#year').val(year)

    },

    populateUserInfo: async () => {
        var user_name = localStorage.getItem('userName');
        var user_id = localStorage.getItem('userId');
        var user_city = localStorage.getItem('userCity');
        if (user_name && user_id && user_city) {
            $('#user_name p').html(user_name);
            $('.user_id').html(user_id);
            $('#user_city').html(user_city);
            if (parseInt(user_id) % 2 == 0) {
                $('#user_gender').html('Female');
            } else {
                $('#user_gender').html('Male');
            }
        }
    },

    populateVehicles: async () => {
        App.setLoading(true);
        var user_id = localStorage.getItem('userId');
        const userVehicles = await App.getUserVehicles(user_id, { from: App.account });
        console.log(userVehicles);
    },

    transferVehicle: async () => {
        var user_id = localStorage.getItem('userId');
        // we are sending vehicles' array index against user with whome the vehicle is registered.
        var _vehno = $('#vehicles_select').val();
        var _new_cnic = $('#new_nic').val();
        var transferVehicleResponse;
        if (_vehno) {
            // console.log(_vehno);
            // https://stackoverflow.com/questions/54845472/solidity-truffle-error-vm-exception-while-processing-transaction-invalid-op
            transferVehicleResponse = await App.bCar.transferVehicle(user_id, _new_cnic, _vehno, { from: App.account });
        }
        console.log(transferVehicleResponse);
    },

    logoutUser: async () => {
        var user_name = localStorage.getItem('userName');
        var user_id = localStorage.getItem('userId');
        if (user_name && user_id ) {
            await App.bCar.LogOut(user_id, {from: App.account})
            localStorage.clear();
            window.location.href = '../index.html';
        }
    }
    // on logout clear localstorage.
    /**
     * ! My plans
     * .1 logout
     * .2 new user
     * .3 registervehicle
     * .4 transfervehicle
     */

}


// $(() => {
    $(window).on('load', (() => {
        App.load();
        // alert('hello');
    }))
// });


// deprecated code
/**
    function isVehicleExists(string memory v_no, string memory e_no)
        public
        view
        returns (bool)
    {
        for (uint256 i = 0; i < vehiclesCount; i++) {
            if (
                keccak256(abi.encodePacked(vehicles[i].v_no)) ==
                keccak256(abi.encodePacked(v_no)) &&
                keccak256(abi.encodePacked(vehicles[i].e_no)) ==
                keccak256(abi.encodePacked(e_no))
            ) {
                return true;
            }
        }
        return false;
    }
 */
 
 // information in comments
/**
1. is it possible to have two same number plates with different vehicles.
https://www.pakwheels.com/forums/t/two-cars-with-the-same-registration-number/227177/2

2. is it possible to have two vehicles with same engion numbered 
https://www.google.com/search?q=two+vehicles+with+same+engion+no&rlz=1C1CHZN_enPK1034PK1034&oq=two+vehicles+with+same+engion+no&aqs=chrome..69i57j33i10i160l2j33i22i29i30.7339j0j7&sourceid=chrome&ie=UTF-8
 */