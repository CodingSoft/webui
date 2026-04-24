/**
 * Tipos para gestión de proyectos estilo LobeHub
 */

export interface Project {
  id: string;
  name: string;
  description: string;
  path: string; // Ruta en el sistema de archivos
  type: 'chat' | 'code' | 'data' | 'documentation' | 'custom';
  tags: string[];
  createdAt: Date;
  updatedAt: Date;
  icon?: string;
  color?: string;
  settings: {
    defaultModel?: string;
    temperature?: number;
    contextWindow?: number;
    tools?: string[];
    skills?: string[];
  };
}

export interface ProjectFile {
  id: string;
  projectId: string;
  name: string;
  path: string;
  type: 'file' | 'directory';
  size: number;
  lastModified: Date;
  content?: string;
  mimeType?: string;
}

export interface ProjectTemplate {
  id: string;
  name: string;
  description: string;
  icon: string;
  structure: {
    files: Array<{
      path: string;
      content: string;
      type: 'file';
    }>;
    directories: string[];
  };
  settings: Partial<Project['settings']>;
}

export interface ToolDefinition {
  id: string;
  name: string;
  description: string;
  type: 'function' | 'api' | 'script' | 'system';
  code: string;
  language: 'python' | 'javascript' | 'typescript' | 'bash';
  projectId?: string;
  parameters?: Array<{
    name: string;
    type: string;
    description: string;
    required: boolean;
    default?: any;
  }>;
  returnType?: string;
  dependencies?: string[];
}

export interface SkillDefinition {
  id: string;
  name: string;
  description: string;
  type: 'technical' | 'creative' | 'analytical' | 'communication';
  level: 'beginner' | 'intermediate' | 'advanced' | 'expert';
  tools: string[]; // IDs de herramientas
  examples: Array<{
    input: string;
    output: string;
    context: string;
  }>;
}

export interface ProjectState {
  currentProject: Project | null;
  projects: Project[];
  files: ProjectFile[];
  isLoading: boolean;
  error: string | null;
}