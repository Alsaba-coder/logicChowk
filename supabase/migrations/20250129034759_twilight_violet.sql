/*
  # Topic Questions and Answers Schema

  1. New Tables
    - `learning_modules`
      - For organizing content into modules
    - `module_questions`
      - Stores questions and answers for each module
    
  2. Security
    - RLS enabled on all tables
    - Read access for authenticated users
    - Write access for admins only
*/

-- Create learning modules table
CREATE TABLE IF NOT EXISTS learning_modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  prerequisites text[],
  duration_minutes integer CHECK (duration_minutes > 0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users NOT NULL,
  is_published boolean DEFAULT false
);

-- Create module questions table
CREATE TABLE IF NOT EXISTS module_questions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid REFERENCES learning_modules ON DELETE CASCADE NOT NULL,
  question_text text NOT NULL,
  correct_answer text NOT NULL,
  explanation text,
  options jsonb, -- For multiple choice questions
  question_type text CHECK (question_type IN ('multiple_choice', 'open_ended', 'true_false')) NOT NULL,
  difficulty text CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')) NOT NULL,
  points integer DEFAULT 1 CHECK (points > 0),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users NOT NULL,
  is_active boolean DEFAULT true
);

-- Enable Row Level Security
ALTER TABLE learning_modules ENABLE ROW LEVEL SECURITY;
ALTER TABLE module_questions ENABLE ROW LEVEL SECURITY;

-- Policies for learning_modules
CREATE POLICY "Anyone can read published modules"
  ON learning_modules
  FOR SELECT
  TO authenticated
  USING (is_published = true);

CREATE POLICY "Admins can manage all modules"
  ON learning_modules
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Policies for module_questions
CREATE POLICY "Anyone can read questions from published modules"
  ON module_questions
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM learning_modules
      WHERE learning_modules.id = module_questions.module_id
      AND learning_modules.is_published = true
    )
    AND is_active = true
  );

CREATE POLICY "Admins can manage all questions"
  ON module_questions
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_learning_modules_published ON learning_modules(is_published);
CREATE INDEX IF NOT EXISTS idx_module_questions_module ON module_questions(module_id);
CREATE INDEX IF NOT EXISTS idx_module_questions_active ON module_questions(is_active);
CREATE INDEX IF NOT EXISTS idx_module_questions_type ON module_questions(question_type);
CREATE INDEX IF NOT EXISTS idx_module_questions_difficulty ON module_questions(difficulty);

-- Function to insert sample data (to be called with admin ID)
CREATE OR REPLACE FUNCTION insert_module_sample_data(admin_uuid uuid)
RETURNS void AS $$
DECLARE
  module_id uuid;
BEGIN
  -- Insert a sample module
  INSERT INTO learning_modules (
    title,
    description,
    prerequisites,
    duration_minutes,
    created_by,
    is_published
  )
  VALUES (
    'Introduction to AI Concepts',
    'Learn the fundamental concepts of Artificial Intelligence',
    ARRAY['Basic Programming Knowledge', 'Mathematics Fundamentals'],
    60,
    admin_uuid,
    true
  )
  RETURNING id INTO module_id;

  -- Insert sample questions
  INSERT INTO module_questions (
    module_id,
    question_text,
    correct_answer,
    explanation,
    options,
    question_type,
    difficulty,
    points,
    created_by
  )
  VALUES
    (
      module_id,
      'What is the main goal of machine learning?',
      'To enable systems to learn from data without explicit programming',
      'Machine learning focuses on creating algorithms that can automatically improve through experience and data analysis.',
      '{"options": ["To enable systems to learn from data without explicit programming", "To create human-like robots", "To store large amounts of data", "To make computers faster"]}',
      'multiple_choice',
      'beginner',
      2,
      admin_uuid
    ),
    (
      module_id,
      'Is artificial intelligence limited to mimicking human behavior?',
      'false',
      'AI can solve problems in ways that may be different from human approaches and can perform tasks beyond human capabilities in certain domains.',
      NULL,
      'true_false',
      'beginner',
      1,
      admin_uuid
    ),
    (
      module_id,
      'Explain the concept of deep learning in your own words.',
      'Deep learning is a subset of machine learning that uses neural networks with multiple layers to progressively extract higher-level features from raw input.',
      'Focus on understanding the hierarchical nature of deep learning and its ability to automatically learn representations.',
      NULL,
      'open_ended',
      'intermediate',
      3,
      admin_uuid
    );
END;
$$ LANGUAGE plpgsql;