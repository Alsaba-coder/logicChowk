import React, { useEffect, useState } from 'react';
import { Routes, Route, useNavigate } from 'react-router-dom';
import { supabase } from './lib/supabase';
import AuthForm from './components/AuthForm';
import { BookOpen, Building2, BrainCircuit, Rocket, Users2, Trophy, ArrowRight } from 'lucide-react';
import TopicCard from './components/TopicCard';
import Navbar from './components/Navbar';
import AIFundamentals from './pages/AIFundamentals';
import SubmitInterest from './pages/SubmitInterest';
import Profile from './pages/Profile';
import HelloWorld from './pages/HelloWorld';

const topics = [
  {
    title: "AI Fundamentals",
    description: "Master the core concepts of Artificial Intelligence and Machine Learning",
    icon: BrainCircuit,
    path: "/topics/ai-fundamentals"
  },
  {
    title: "Business AI Integration",
    description: "Learn how to implement AI solutions in your business processes",
    icon: Building2,
    path: "/topics/business-ai"
  },
  {
    title: "Productivity with AI",
    description: "Enhance workplace efficiency using AI-powered tools",
    icon: Rocket,
    path: "/topics/productivity"
  }
];

function HomePage() {
  const navigate = useNavigate();
  
  return (
    <div className="min-h-screen bg-gradient-to-b from-gray-50 to-white">
      <Navbar />
      
      {/* Hero Section */}
      <section className="pt-20 pb-32 px-4">
        <div className="max-w-7xl mx-auto">
          <div className="text-center">
            <h1 className="text-5xl font-bold text-gray-900 mb-6">
              Transform Your Workforce with AI Training
            </h1>
            <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto">
              Empower your team with cutting-edge AI knowledge and skills. 
              Join leading UAE companies in building a future-ready workforce.
            </p>
            <div className="flex justify-center gap-4">
              <button className="bg-blue-600 text-white px-8 py-4 rounded-lg text-lg font-semibold hover:bg-blue-700 transition-colors flex items-center gap-2">
                Start Learning Now
                <ArrowRight className="w-5 h-5" />
              </button>
              <button 
                onClick={() => navigate('/submit-interest')}
                className="bg-white text-blue-600 border-2 border-blue-600 px-8 py-4 rounded-lg text-lg font-semibold hover:bg-blue-50 transition-colors"
              >
                Suggest a Topic
              </button>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="bg-blue-50 py-16">
        <div className="max-w-7xl mx-auto px-4">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="text-4xl font-bold text-blue-600 mb-2">500+</div>
              <div className="text-gray-600">Companies Trained</div>
            </div>
            <div className="text-center">
              <div className="text-4xl font-bold text-blue-600 mb-2">50,000+</div>
              <div className="text-gray-600">Employees Upskilled</div>
            </div>
            <div className="text-center">
              <div className="text-4xl font-bold text-blue-600 mb-2">95%</div>
              <div className="text-gray-600">Satisfaction Rate</div>
            </div>
          </div>
        </div>
      </section>

      {/* Topics Section */}
      <section className="py-20 px-4">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12">Learning Paths</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {topics.map((topic, index) => (
              <TopicCard key={index} {...topic} />
            ))}
          </div>
        </div>
      </section>

      {/* Benefits Section */}
      <section className="bg-gray-50 py-20 px-4">
        <div className="max-w-7xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12">Why Choose Us</h2>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <Users2 className="w-12 h-12 text-blue-600 mb-4" />
              <h3 className="text-xl font-semibold mb-2">Expert-Led Training</h3>
              <p className="text-gray-600">Learn from industry experts with real-world AI implementation experience</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <BookOpen className="w-12 h-12 text-blue-600 mb-4" />
              <h3 className="text-xl font-semibold mb-2">Comprehensive Curriculum</h3>
              <p className="text-gray-600">Structured learning paths designed for all skill levels</p>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <Trophy className="w-12 h-12 text-blue-600 mb-4" />
              <h3 className="text-xl font-semibold mb-2">Certification</h3>
              <p className="text-gray-600">Industry-recognized certificates upon completion</p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}

function App() {
  const [session, setSession] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session);
      setLoading(false);
    });

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((_event, session) => {
      setSession(session);
    });

    return () => subscription.unsubscribe();
  }, []);

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="text-xl">Loading...</div>
      </div>
    );
  }

  if (!session) {
    return <AuthForm onSuccess={() => {}} />;
  }

  return (
    <Routes>
      <Route path="/" element={<HomePage />} />
      <Route path="/topics/ai-fundamentals" element={<AIFundamentals />} />
      <Route path="/submit-interest" element={<SubmitInterest />} />
      <Route path="/profile" element={<Profile />} />
      <Route path="/hello" element={<HelloWorld />} />
    </Routes>
  );
}

export default App;