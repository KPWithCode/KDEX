import React, {useState, useEffect} from 'react';
import { getWeb3, getContracts } from './utils';
import App from './App';

function Loading() {
    const [web3, setWeb3] = useState(undefined);
    const [accounts, setAccounts] = useState([]);
    const [contracts, setContracts] = useState(undefined);

    // make useeffect async
    useEffect(() => {
        const init = async () => {
          const web3 = await getWeb3();
          const accounts = await web3.eth.getAccounts();
          const contracts = await getContracts(web3);
          setAccounts(accounts);
          setWeb3(web3);
          setContracts(contracts);
        }
        init();
      }, []);

    const isReady = () => {
        return (
            typeof web3 !== 'undefined'
            && typeof contracts !== 'undefined'
            && accounts.length > 0
        )
    }

    if (!isReady()) {
        return <div>Loading......</div>
    }

    return (
        <App 
        web3={web3} 
        accounts={accounts} 
        contracts={contracts} />
    )
}

export default Loading;