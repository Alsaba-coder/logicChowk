/*
  # Questions and Answers Schema Update

  1. New Tables
    - `question_categories`
      - `id` (uuid, primary key)
      - `name` (text)
      - `description` (text)
      - `created_at` (timestamptz)
      - `created_by` (uuid, references auth.users)
    
    - `questions`
      - `id` (uuid, primary key)
      - `category_id` (uuid, references question_categories)
      - `question_text` (text)
      - `correct_answer` (text)
      - `explanation` (text)
      - `difficulty_level` (text)
      - `created_at` (timestamptz)
      - `created_by` (uuid, references auth.users)

  2. Security
    - Enable RLS on both tables
    - Policies for authenticated users to read
    - Policies for admins to manage content
*/

-- Create question categories table
CREATE TABLE IF NOT EXISTS question_categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL,
  created_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users NOT NULL
);

-- Create questions table
CREATE TABLE IF NOT EXISTS questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES question_categories ON DELETE CASCADE NOT NULL,
  question_text text NOT NULL,
  correct_answer text NOT NULL,
  explanation text,
  difficulty_level text CHECK (difficulty_level IN ('beginner', 'intermediate', 'advanced')) NOT NULL,
  created_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users NOT NULL
);

-- Enable Row Level Security
ALTER TABLE question_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

-- Policies for question_categories
CREATE POLICY "Anyone can read question categories"
  ON question_categories
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage question categories"
  ON question_categories
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Policies for questions
CREATE POLICY "Anyone can read questions"
  ON questions
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Admins can manage questions"
  ON questions
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_questions_category ON questions(category_id);
CREATE INDEX IF NOT EXISTS idx_questions_difficulty ON questions(difficulty_level);

-- Insert sample data function
CREATE OR REPLACE FUNCTION insert_sample_qa_data(admin_id uuid)
RETURNS void AS $$
BEGIN
  -- Insert AI Fundamentals category
  WITH category_insert AS (
    INSERT INTO question_categories (name, description, created_by)
    VALUES (
      'AI Fundamentals',
      'Basic concepts and principles of Artificial Intelligence',
      admin_id
    )
    RETURNING id
  )
  INSERT INTO questions (category_id, question_text, correct_answer, explanation, difficulty_level, created_by)
  SELECT 
    category_insert.id,
    qa.question_text,
    qa.correct_answer,
    qa.explanation,
    qa.difficulty_level,
    admin_id
  FROM category_insert, (VALUES
    (
      'What is the main difference between supervised and unsupervised learning?',
      'Supervised learning uses labeled data for training, while unsupervised learning works with unlabeled data.',
      'In supervised learning, the algorithm learns from a training dataset that includes both input features and their corresponding target outputs. Unsupervised learning, on the other hand, identifies patterns and structures in data without any predefined labels.',
      'beginner'
    ),
    (
      'What is deep learning and how does it relate to AI?',
      'Deep learning is a subset of machine learning that uses neural networks with multiple layers to learn hierarchical representations of data.',
      'Deep learning models can automatically learn features from raw data, making them particularly effective for complex tasks like image recognition and natural language processing.',
      'intermediate'
    )
  ) AS qa(question_text, correct_answer, explanation, difficulty_level);
END;
$$ LANGUAGE plpgsql;