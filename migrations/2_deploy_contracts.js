const Dai = artifacts.require('mocks/Dai.sol');
const Bat = artifacts.require('mocks/Bat.sol');
const Rep = artifacts.require('mocks/Rep.sol');
const Zrx = artifacts.require('mocks/Zrx.sol');
const Kdex = artifacts.require('Kdex.sol');

const [DAI, BAT, REP, ZRX] = ['DAI', 'BAT', 'REP', 'ZRX']
.map(ticker => web3.utils.fromAscii(ticker));