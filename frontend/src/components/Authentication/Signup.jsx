
import React, { useState } from 'react';

const Signup = () => {
    const [email, setEmail] = useState('');
    const [error, setError] = useState(null);

    const handleEmailChange = (e) => {
        setEmail(e.target.value);
    };

    const handleSignup = async () => {
        try {
            if (!email.includes('@')) {
                throw new Error('Please enter a valid email.');
            }
            // Assume we have some signup logic here
            // await authService.signup(email);
        } catch (error) {
            setError("Oops! Something went wrong. Please try again.");
        }
    };

    return (
        <div>
            <input
                type="email"
                value={email}
                onChange={handleEmailChange}
                placeholder="Enter your email"
            />
            {error && <p style={{ color: 'red' }}>{error}</p>}
            <button onClick={handleSignup}>Sign Up</button>
        </div>
    );
};

export default Signup;
