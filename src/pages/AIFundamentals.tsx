import React from 'react';
import { ChevronDown, ChevronUp } from 'lucide-react';
import Navbar from '../components/Navbar';

interface QAItem {
  question: string;
  answer: string;
}

const qaList: QAItem[] = [
  {
    question: "What is Artificial Intelligence?",
    answer: "Artificial Intelligence (AI) refers to computer systems that can perform tasks that typically require human intelligence. These tasks include learning from experience, understanding natural language, recognizing patterns, solving problems, and making decisions. AI systems use various techniques like machine learning, deep learning, and neural networks to process data and improve their performance over time."
  },
  {
    question: "What are the main types of AI?",
    answer: "There are two main types of AI: Narrow (or Weak) AI and General (or Strong) AI. Narrow AI is designed for specific tasks like facial recognition or playing chess. It's what we currently have in practical applications. General AI, which would match human-level intelligence across all domains, is still theoretical. There's also Machine Learning, a subset of AI that focuses on systems that can learn from data without explicit programming."
  },
  {
    question: "How does Machine Learning work?",
    answer: "Machine Learning works by analyzing patterns in data to make predictions or decisions. It uses algorithms that can automatically improve through experience. The process typically involves: 1) Collecting and preparing data, 2) Choosing and training a model, 3) Testing the model's performance, and 4) Making predictions with new data. Common types include supervised learning (using labeled data), unsupervised learning (finding patterns in unlabeled data), and reinforcement learning (learning through trial and error)."
  },
  {
    question: "What are Neural Networks?",
    answer: "Neural Networks are computing systems inspired by biological brains. They consist of interconnected nodes (neurons) organized in layers. Each connection can transmit signals between neurons, with the receiving neuron processing the signal and signaling downstream neurons. Neural networks are particularly good at pattern recognition and are the foundation of deep learning, enabling breakthroughs in areas like computer vision and natural language processing."
  },
  {
    question: "How is AI being applied in business today?",
    answer: "AI is being applied across various business functions: 1) Customer Service: Through chatbots and virtual assistants, 2) Marketing: For personalized recommendations and customer segmentation, 3) Operations: In predictive maintenance and supply chain optimization, 4) Finance: For fraud detection and risk assessment, 5) HR: In recruitment and employee engagement. These applications help businesses improve efficiency, reduce costs, and enhance decision-making."
  }
];

const AIFundamentals = () => {
  const [openQuestions, setOpenQuestions] = React.useState<number[]>([]);

  const toggleQuestion = (index: number) => {
    setOpenQuestions(prev => 
      prev.includes(index) 
        ? prev.filter(i => i !== index)
        : [...prev, index]
    );
  };

  return (
    <div className="min-h-screen bg-gray-50">
      <Navbar />
      
      {/* Hero Section */}
      <div className="bg-blue-600 text-white pt-24 pb-12 px-4">
        <div className="max-w-4xl mx-auto">
          <h1 className="text-4xl font-bold mb-4">AI Fundamentals</h1>
          <p className="text-xl opacity-90">
            Master the core concepts of Artificial Intelligence and build a strong foundation for your AI journey.
          </p>
        </div>
      </div>

      {/* Q&A Section */}
      <div className="max-w-4xl mx-auto px-4 py-12">
        <div className="bg-white rounded-xl shadow-sm overflow-hidden">
          {qaList.map((qa, index) => (
            <div key={index} className="border-b border-gray-100 last:border-b-0">
              <button
                onClick={() => toggleQuestion(index)}
                className="w-full text-left px-6 py-4 flex items-center justify-between hover:bg-gray-50 transition-colors"
              >
                <span className="text-lg font-semibold text-gray-900">{qa.question}</span>
                {openQuestions.includes(index) ? (
                  <ChevronUp className="w-5 h-5 text-gray-500" />
                ) : (
                  <ChevronDown className="w-5 h-5 text-gray-500" />
                )}
              </button>
              {openQuestions.includes(index) && (
                <div className="px-6 py-4 bg-gray-50">
                  <p className="text-gray-700 leading-relaxed">{qa.answer}</p>
                </div>
              )}
            </div>
          ))}
        </div>

        {/* Next Steps */}
        <div className="mt-12 bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <h2 className="text-2xl font-bold mb-4">Ready to Dive Deeper?</h2>
          <p className="text-gray-700 mb-6">
            This is just the beginning of your AI journey. Take the next step by exploring our interactive exercises and practical applications.
          </p>
          <button className="bg-blue-600 text-white px-6 py-3 rounded-lg hover:bg-blue-700 transition-colors">
            Start Practical Exercises
          </button>
        </div>
      </div>
    </div>
  );
};

export default AIFundamentals;