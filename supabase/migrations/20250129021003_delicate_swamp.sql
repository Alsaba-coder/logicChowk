/*
  # AI Training Platform Schema

  1. New Tables
    - `topics`
      - `id` (uuid, primary key)
      - `title` (text)
      - `description` (text)
      - `icon` (text)
      - `path` (text)
      - `created_at` (timestamp)
    
    - `qa_items`
      - `id` (uuid, primary key)
      - `topic_id` (uuid, foreign key)
      - `question` (text)
      - `answer` (text)
      - `order` (integer)
      - `created_at` (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to read data
    - Add policies for admin users to manage data
*/

-- Create topics table
CREATE TABLE IF NOT EXISTS topics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  icon text NOT NULL,
  path text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now()
);

-- Create qa_items table
CREATE TABLE IF NOT EXISTS qa_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_id uuid NOT NULL REFERENCES topics(id),
  question text NOT NULL,
  answer text NOT NULL,
  "order" integer NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE qa_items ENABLE ROW LEVEL SECURITY;

-- Policies for topics
CREATE POLICY "Anyone can read topics"
  ON topics
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only admins can modify topics"
  ON topics
  USING (auth.jwt() ->> 'role' = 'admin');

-- Policies for qa_items
CREATE POLICY "Anyone can read qa_items"
  ON qa_items
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only admins can modify qa_items"
  ON qa_items
  USING (auth.jwt() ->> 'role' = 'admin');

-- Insert initial data
INSERT INTO topics (title, description, icon, path)
VALUES 
  ('AI Fundamentals', 'Master the core concepts of Artificial Intelligence and Machine Learning', 'BrainCircuit', '/topics/ai-fundamentals'),
  ('Business AI Integration', 'Learn how to implement AI solutions in your business processes', 'Building2', '/topics/business-ai'),
  ('Productivity with AI', 'Enhance workplace efficiency using AI-powered tools', 'Rocket', '/topics/productivity');

INSERT INTO qa_items (topic_id, question, answer, "order")
SELECT 
  topics.id,
  'What is Artificial Intelligence?' as question,
  'Artificial Intelligence (AI) refers to computer systems that can perform tasks that typically require human intelligence. These tasks include learning from experience, understanding natural language, recognizing patterns, solving problems, and making decisions. AI systems use various techniques like machine learning, deep learning, and neural networks to process data and improve their performance over time.' as answer,
  1 as "order"
FROM topics
WHERE path = '/topics/ai-fundamentals';

INSERT INTO qa_items (topic_id, question, answer, "order")
SELECT 
  topics.id,
  'What are the main types of AI?' as question,
  'There are two main types of AI: Narrow (or Weak) AI and General (or Strong) AI. Narrow AI is designed for specific tasks like facial recognition or playing chess. It''s what we currently have in practical applications. General AI, which would match human-level intelligence across all domains, is still theoretical. There''s also Machine Learning, a subset of AI that focuses on systems that can learn from data without explicit programming.' as answer,
  2 as "order"
FROM topics
WHERE path = '/topics/ai-fundamentals';