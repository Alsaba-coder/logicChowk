/*
  # Topics and Q&A Schema

  1. New Tables
    - `course_topics`
      - `id` (uuid, primary key)
      - `title` (text)
      - `description` (text)
      - `icon` (text)
      - `path` (text)
      - `created_at` (timestamptz)
      - `created_by` (uuid, references auth.users)
      - `is_published` (boolean)
      
    - `topic_qa`
      - `id` (uuid, primary key)
      - `topic_id` (uuid, references course_topics)
      - `question` (text)
      - `answer` (text)
      - `sort_order` (integer)
      - `created_at` (timestamptz)
      - `created_by` (uuid, references auth.users)

  2. Security
    - Enable RLS on both tables
    - Policies for authenticated users to read published topics and their Q&As
    - Policies for admins to manage all content
*/

-- Create course_topics table
CREATE TABLE IF NOT EXISTS course_topics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  icon text NOT NULL,
  path text NOT NULL UNIQUE,
  created_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users NOT NULL,
  is_published boolean DEFAULT false,
  CONSTRAINT valid_path CHECK (path ~ '^/topics/[a-z0-9-]+$')
);

-- Create topic_qa table
CREATE TABLE IF NOT EXISTS topic_qa (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_id uuid REFERENCES course_topics ON DELETE CASCADE NOT NULL,
  question text NOT NULL,
  answer text NOT NULL,
  sort_order integer NOT NULL,
  created_at timestamptz DEFAULT now(),
  created_by uuid REFERENCES auth.users NOT NULL,
  CONSTRAINT positive_sort_order CHECK (sort_order > 0)
);

-- Enable Row Level Security
ALTER TABLE course_topics ENABLE ROW LEVEL SECURITY;
ALTER TABLE topic_qa ENABLE ROW LEVEL SECURITY;

-- Policies for course_topics
CREATE POLICY "Anyone can read published topics"
  ON course_topics
  FOR SELECT
  TO authenticated
  USING (is_published = true);

CREATE POLICY "Admins can manage all topics"
  ON course_topics
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Policies for topic_qa
CREATE POLICY "Anyone can read Q&As for published topics"
  ON topic_qa
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM course_topics
      WHERE course_topics.id = topic_qa.topic_id
      AND course_topics.is_published = true
    )
  );

CREATE POLICY "Admins can manage all Q&As"
  ON topic_qa
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin')
  WITH CHECK (auth.jwt() ->> 'role' = 'admin');

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_course_topics_path ON course_topics(path);
CREATE INDEX IF NOT EXISTS idx_topic_qa_topic_order ON topic_qa(topic_id, sort_order);

-- Sample data insertion function
CREATE OR REPLACE FUNCTION insert_sample_topic_data(admin_id uuid)
RETURNS void AS $$
BEGIN
  -- Insert AI Fundamentals topic