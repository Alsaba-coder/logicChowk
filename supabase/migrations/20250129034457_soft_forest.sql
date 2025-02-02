/*
  # Topic Questions and Answers Schema

  1. New Tables
    - `topic_categories`
      - For organizing questions into different topics/subjects
    - `topic_questions`
      - Stores questions and answers with metadata
    
  2. Security
    - RLS enabled on all tables
    - Read access for authenticated users
    - Write access for admins only
*/

-- Create topic categories table
CREATE TABLE IF NOT EXISTS topic_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users NOT NULL
);

-- Create topic questions table
CREATE TABLE IF NOT EXISTS topic_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES topic_categories ON DELETE CASCADE NOT NULL,
  question_text text NOT NULL,
  answer_text text NOT NULL,
  explanation text,
  difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')) NOT NULL,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users NOT NULL
);

-- Enable Row Level Security
ALTER TABLE topic_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE topic_questions ENABLE ROW LEVEL SECURITY;

-- Policies for topic_categories
CREATE POLICY "Anyone can read topic categories"
  ON topic_categories
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Only admins can insert topic categories"
  ON topic_categories
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Only admins can update topic categories"
  ON topic_categories
  FOR UPDATE
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Policies for topic_questions
CREATE POLICY "Anyone can read active questions"
  ON topic_questions
  FOR SELECT
  TO authenticated
  USING (is_active = true);

CREATE POLICY "Only admins can insert questions"
  ON topic_questions
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

CREATE POLICY "Only admins can update questions"
  ON topic_questions
  FOR UPDATE
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_topic_questions_category ON topic_questions(category_id);
CREATE INDEX IF NOT EXISTS idx_topic_questions_difficulty ON topic_questions(difficulty_level);
CREATE INDEX IF NOT EXISTS idx_topic_questions_active ON topic_questions(is_active);

-- Function to insert sample data (to be called separately with admin ID)
CREATE OR REPLACE FUNCTION insert_sample_qa_data(admin_uuid uuid)
RETURNS void AS $$
DECLARE
  category_id uuid;
BEGIN
  -- Insert category
  INSERT INTO topic_categories (name, description, created_by)
  VALUES (
    'AI Fundamentals',
    'Core concepts and principles of Artificial Intelligence',
    admin_uuid
  )
  RETURNING id INTO category_id;

  -- Insert questions
  INSERT INTO topic_questions (
    category_id,
    question_text,
    answer_text,
    explanation,
    difficulty_level,
    created_by
  )
  VALUES
    (
      category_id,
      'What is machine learning?',
      'Machine learning is a subset of AI that enables systems to learn and improve from experience without being explicitly programmed.',
      'Machine learning algorithms use statistical techniques to allow computers to "learn" from data, identifying patterns and making decisions with minimal human intervention.',
      'beginner',
      admin_uuid
    ),
    (
      category_id,
      'Explain the difference between supervised and unsupervised learning.',
      'Supervised learning uses labeled data for training, while unsupervised learning works with unlabeled data to find patterns.',
      'In supervised learning, the algorithm learns from a training dataset that includes both input features and their corresponding target outputs. Unsupervised learning identifies patterns in data without predefined labels.',
      'intermediate',
      admin_uuid
    );
END;
$$ LANGUAGE plpgsql;