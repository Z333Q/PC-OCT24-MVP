
import React, { useState, useEffect, useCallback, lazy, Suspense, useContext } from 'react';
import web3 from '../../utils/web3';
import contractService from '../../services/contractService';
import './styles.css';

// React Context for global state management
const AccountContext = React.createContext();

export const AccountProvider = ({ children }) => {
  const [account, setAccount] = useState('');
  const [balance, setBalance] = useState(0);
  return (
    <AccountContext.Provider value={{ account, setAccount, balance, setBalance }}>
      {children}
    </AccountContext.Provider>
  );
};

// Dashboard component using React Context for state management
const LazyLoadedComponent = lazy(() => import('../LazyComponent'));

const Dashboard = () => {
  const { account, setAccount, balance, setBalance } = useContext(AccountContext);
  const [error, setError] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchAccountData = useCallback(async () => {
    try {
      setLoading(true);
      const accounts = await web3.eth.getAccounts();
      if (accounts.length === 0) throw new Error("No Ethereum accounts found.");
      setAccount(accounts[0]);

      const balance = await contractService.getBalance(accounts[0]);
      setBalance(web3.utils.fromWei(balance, 'ether'));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }, [setAccount, setBalance]);

  useEffect(() => {
    fetchAccountData();
  }, [fetchAccountData]);

  return (
    <div className="dashboard-container">
      <h2>Dashboard</h2>
      <Suspense fallback={<p>Loading component...</p>}>
        {loading ? (
          <p>Loading account data...</p>
        ) : error ? (
          <p style={{ color: 'red' }}>{error}</p>
        ) : (
          <div className="dashboard-info">
            <p>Account: {account}</p>
            <p>Balance: {balance} ETH</p>
            <LazyLoadedComponent />  {/* Lazy loaded component */}
          </div>
        )}
      </Suspense>
    </div>
  );
};

export default Dashboard;
