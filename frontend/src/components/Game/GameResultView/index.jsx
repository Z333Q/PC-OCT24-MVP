
import React, { useState, useEffect } from 'react';
import './styles.css';

const GameResultView = () => {
  const [results, setResults] = useState([]);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchGameResults = async () => {
      try {
        const response = await fetch('/api/game-results'); // Example endpoint
        if (!response.ok) {
          throw new Error('Failed to fetch game results');
        }
        const data = await response.json();
        setResults(data);
      } catch (err) {
        setError(err.message);
      }
    };

    fetchGameResults();
  }, []);

  return (
    <div className="game-result-view">
      <h2>Game Results</h2>
      {error ? (
        <p style={{ color: 'red' }}>{error}</p>
      ) : results.length === 0 ? (
        <p>No results available.</p>
      ) : (
        <table>
          <thead>
            <tr>
              <th>Team</th>
              <th>Score</th>
              <th>Date</th>
              <th>Time</th>
            </tr>
          </thead>
          <tbody>
            {results.map((result, index) => (
              <tr key={index}>
                <td>{result.team}</td>
                <td>{result.score}</td>
                <td>{result.date}</td>
                <td>{result.time}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default GameResultView;
