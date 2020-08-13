pragma solidity ^0.6.3;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol'

contract Rep is ERC20 {
    constructor() ERC20('REP', 'Augur token', 18) public {
        
    }
}