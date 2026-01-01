// Shared TypeScript types for Fittie

export interface User {
  id: string;
  email: string;
  name: string;
  createdAt: string;
}

export interface Exercise {
  id: string;
  name: string;
  category: string;
  targetMuscles: string[];
  difficulty: 'beginner' | 'intermediate' | 'advanced';
}

export interface WorkoutSession {
  id: string;
  userId: string;
  startTime: string;
  endTime?: string;
  exercises: ExerciseSet[];
  status: 'in-progress' | 'completed' | 'cancelled';
}

export interface ExerciseSet {
  exerciseId: string;
  sets: number;
  reps: number;
  weight?: number;
  duration?: number;
  formScore?: number;
}

export interface FormFeedback {
  timestamp: string;
  exerciseId: string;
  score: number;
  issues: FormIssue[];
  corrections: string[];
}

export interface FormIssue {
  type: string;
  severity: 'low' | 'medium' | 'high';
  description: string;
  bodyPart: string;
}

export interface VoiceCoachingCue {
  text: string;
  audioUrl?: string;
  priority: 'low' | 'medium' | 'high';
  timestamp: string;
}
