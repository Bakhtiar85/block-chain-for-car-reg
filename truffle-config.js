module.exports = {
  networks: {
    development: {
     host: "127.0.0.1",     // Localhost (default: none)
     port: 7545,            // Standard Ethereum port (default: none)
     network_id: "8585",       // Any network (default: none)
    }
  },
    solc: {
       optimizer: {
         enabled: false,
         runs: 200
       },
    }
};
