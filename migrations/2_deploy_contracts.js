const Dai = artifacts.require('mocks/Dai.sol');
const Bat = artifacts.require('mocks/Bat.sol');
const Rep = artifacts.require('mocks/Rep.sol');
const Zrx = artifacts.require('mocks/Zrx.sol');
const Kdex = artifacts.require('Kdex.sol');

const [DAI, BAT, REP, ZRX] = ['DAI', 'BAT', 'REP', 'ZRX']
.map(ticker => web3.utils.fromAscii(ticker));

module.exports = async function(deployer) {
    await Promise.all(
        [Dai, Bat, Rep, Zrx, Kdex].map(contract => deployer.deploy(contract))
    );
    const [dai, bat, rep, zrx, dex] = await Promise.all(
        [Dai, Bat, Rep, Zrx, Kdex].map(contract => contract.deployed())
    );
    await Promise.all([
        dex.addToken(DAI, dai.address),
        dex.addToken(BAT, bat.address),
        dex.addToken(REP, rep.address),
        dex.addToken(ZRX, zrx.address)
    ]);
}