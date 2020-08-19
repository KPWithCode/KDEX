pragma solidity 0.6.3;

import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol';
contract Kdex {

     // two types of limit orders
    enum Side {
        BUY,
        SELL
    }

    struct Token {
        bytes32 ticker;
        address tokenAddress;
    }

    struct Order {
        uint id;
        address trader;
        Side side;
        bytes32 ticker;
        uint amount;
        uint filled;
        uint price;
        uint date;
    }

    mapping(bytes32 => Token) public tokens;
    // list
    bytes32[] public tokenList;
    mapping(address => mapping(bytes32 => uint)) public traderBalances;
    mapping(bytes32 => mapping(uint => Order[])) public orderBook;
    address public admin;
    uint public nextOrderId;
    uint public nextTradeId;
    bytes32 constant DAI = bytes32('DAI');

    // new trade
    event NewTrade(
        uint tradeId, 
        uint orderId, 
        bytes32 indexed ticker, 
        address indexed trader1, 
        address indexed trader2, 
        uint amount, 
        uint price, 
        uint date)

    constructor() public {
        admin = msg.sender;
    }

    function addToken(
    bytes32 ticker,
    address tokenAddress)
    onlyAdmin()
    external {
        tokens[ticker] = Token(ticker, tokenAddress);
        tokenList.push(ticker);
    }

    function deposit(uint amount, bytes32 ticker) tokenExist() external {
        IERC20(tokens[ticker].tokenAddress).transferFrom(
            msg.sender, 
            address(this), 
            amount);
        transferBalances[msg.sender][ticker] += amount;
    }

    function withdraw(uint amount, bytes32 ticker) tokenExist() external {
        require(transferBalances[msg.sender][ticker] >= amount, 'balance too low');
        tranderBalances[msg.sender][ticker] -= amount;
        IERC20(tokens[ticker].tokenAddress).transfer(msg.sender, amount);
    }

    // market order
    function createMarketOrder(
        bytes32 ticker,
        uint amount,
        Side side)
        tokenExist(ticker)
        tokenIsNotDai(ticker) external {
            if (side == Side.SELL) {
                require(transferBalances[msg.sender][ticker] >= amount, 'token balance too low');

            } 
            Order[] storage orders = orderBook[ticker][uint(side == Side.BUY ? Side.SELL : Side.BUY)]
            // variable that iterates through orderbook
            uint i;
            // order that has not been filled
            uint remaining = amount;
            // matching process
            while(i < orders.length && remaining > 0) {
                // available liquidity for each order of the order book
                uint availible = orders[i].amount;
                // amount matched against market order
                uint matched = (remaining > available) ? available : remaining;
                // decrement remaining variable by what was matched
                remaining -= matched
                // increment was was matched for the orders in the order book
                // so that it is no longer available
                orders[i].filled += matched;
                emit NewTrade(
                    nexTradeId, 
                    orders[i].id, 
                    ticker, 
                    orders[i].trader, 
                    msg.sender, 
                    matched, 
                    orders[i].price, 
                    now
                );
                if (side == Side.SELL) {
                    traderBalances[msg.sender][ticker] -= matched;
                    traderBalances[msg.sender][DAI] += matched * orders[i].price;
                    traderBalances[orders[i].trader][ticker] = matched;
                    traderBalances[orders[i].trader][DAI] += matched * orders[i].price;
                }
                 if (side == Side.BUY) {
                    require(traderBalances[msg.sender][DAI] >= matched * orders[i].price,
                    'dai balance too low'
                    )
                    traderBalances[msg.sender][ticker] += matched;
                    traderBalances[msg.sender][DAI] -= matched * orders[i].price;
                    traderBalances[orders[i].trader][ticker] = matched;
                    traderBalances[orders[i].trader][DAI] -= matched * orders[i].price;
                }
                nextTradeId++;
                i++;
            }
            i = 0;
            while(i < orders.length && orders[i].filled == orders[i].amount) {
                [A,B,C,D,E,F]
                for (uint j = i; j < orders.length -1; j++) {
                    orders[j] = orders[j + 1];
                }
                orders.pop();
                i++;
            }
        }

    function createLimitOrder(bytes32 ticker, uint amount, uint price, Side side) tokenExist(ticker) tokenIsNotDai(ticker) external {
        // trade has enough token in balance
        if(side == Side.SELL) {
            require(transferBalances[msg.sender][ticker] >= amount, 'token balance too low');
        } else {
            require(traderBalances[msg.sender][DAI] >= amount * price, 
            'dai balance too low'
            );
        }
        Order[] storage orders = orderBook[ticker][uint(side)];
        orders.push(Order(
        nextOrderId,
        msg.sender,
        side,
        ticker,
        amount,
        0,
        price,
        now,
        ))
        uint i = orders.length -  1;
        while (i > 0) {
            if(side == SIDE.BUY && orders[i - 1].price > orders[i].price) {
                break;
            }
             if(side == SIDE.SELL && orders[i - 1].price < orders[i].price) {
                break;
            }
            Order memory order = orders[i - 1];
            orders[i - 1] = orders[i];
            i--;
        }
        nextOrderId++;
    }

    modifier tokenIsNotDai(bytes32 ticker) {
        require(ticker != DAI, 'cannot trade DAI');
        _;
    }
    
    modifier tokenExist(bytes32 ticker) {
        require(tokens[ticker].tokenAddress != address(0),
        'this token does not exist'
        );
        _;
    }
    modifier onlyAdmin() {
        require(msg.sender == admin, 'only admin');
        _;
    }
}