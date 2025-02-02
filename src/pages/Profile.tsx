import React from 'react';
import Navbar from '../components/Navbar';
import UserProfile from '../components/UserProfile';

const Profile = () => {
  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      <div className="max-w-4xl mx-auto px-4 py-24">
        <UserProfile />
      </div>
    </div>
  );
};

export default Profile;