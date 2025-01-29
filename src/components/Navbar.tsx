import React from 'react';
import { BookOpen, User } from 'lucide-react';
import { Link } from 'react-router-dom';

const Navbar = () => {
  return (
    <nav className="fixed w-full bg-white shadow-sm z-50">
      <div className="max-w-7xl mx-auto px-4">
        <div className="flex items-center justify-between h-16">
          <Link to="/" className="flex items-center gap-2">
            <BookOpen className="w-8 h-8 text-blue-600" />
            <span className="font-bold text-xl">AICorporateTraining</span>
          </Link>
          
          <div className="hidden md:flex items-center gap-8">
            <Link to="/" className="text-gray-600 hover:text-blue-600">Topics</Link>
            <Link to="/submit-interest" className="text-gray-600 hover:text-blue-600">Submit Topic</Link>
            <a href="#" className="text-gray-600 hover:text-blue-600">Enterprise</a>
            <Link to="/profile" className="text-gray-600 hover:text-blue-600">
              <User className="w-5 h-5" />
            </Link>
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;