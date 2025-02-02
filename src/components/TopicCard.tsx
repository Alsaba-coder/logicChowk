import React from 'react';
import { DivideIcon as LucideIcon } from 'lucide-react';

interface TopicCardProps {
  title: string;
  description: string;
  icon: LucideIcon;
  path: string;
}

const TopicCard: React.FC<TopicCardProps> = ({ title, description, icon: Icon, path }) => {
  return (
    <a 
      href={path}
      className="block bg-white rounded-xl shadow-sm hover:shadow-md transition-shadow p-6 border border-gray-100"
    >
      <Icon className="w-12 h-12 text-blue-600 mb-4" />
      <h3 className="text-xl font-semibold mb-2">{title}</h3>
      <p className="text-gray-600">{description}</p>
    </a>
  );
};

export default TopicCard;