/*
  # Create interest topics table

  1. New Tables
    - `interest_topics`
      - `id` (uuid, primary key)
      - `title` (text)
      - `description` (text)
      - `user_id` (uuid, references auth.users)
      - `created_at` (timestamp)
      - `status` (text, default: 'pending')

  2. Security
    - Enable RLS on `interest_topics` table
    - Add policies for:
      - Authenticated users can create new topics
      - Users can read their own submitted topics
      - Admins can read all topics
*/

CREATE TABLE IF NOT EXISTS interest_topics (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text NOT NULL,
  user_id uuid REFERENCES auth.users NOT NULL,
  created_at timestamptz DEFAULT now(),
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected'))
);

-- Enable RLS
ALTER TABLE interest_topics ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can create interest topics"
  ON interest_topics
  FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can read their own interest topics"
  ON interest_topics
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can read all interest topics"
  ON interest_topics
  FOR SELECT
  TO authenticated
  USING (auth.jwt() ->> 'role' = 'admin');