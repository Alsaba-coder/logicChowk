import React from 'react';
import Navbar from '../components/Navbar';

const HelloWorld = () => {
  return (
    <div className="min-h-screen bg-gradient-to-b from-blue-50 to-white">
      <Navbar />
      <div className="max-w-4xl mx-auto px-4 pt-24">
        <div className="bg-white rounded-lg shadow-sm p-8 text-center">
          <h1 className="text-4xl font-bold text-gray-900 mb-4">
            Hello, World! 👋
          </h1>
          <p className="text-gray-600 text-lg">
            Welcome to my first page in this project.
          </p>
        </div>
      </div>
    </div>
  );
};

export default HelloWorld;