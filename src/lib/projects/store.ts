/**
 * Store para gestión de proyectos
 */

import { writable, derived, get } from 'svelte/store';
import { v4 as uuidv4 } from 'uuid';
import { localFileSystem } from '$lib/filesystem/local-fs';
import type { Project, ProjectFile, ProjectState, ToolDefinition, SkillDefinition } from './types';

// Store principal
const initialState: ProjectState = {
  currentProject: null,
  projects: [],
  files: [],
  isLoading: false,
  error: null
};

function createProjectStore() {
  const { subscribe, set, update } = writable<ProjectState>(initialState);
  
  // Métodos
  const methods = {
    /**
     * Cargar proyectos desde almacenamiento local
     */
    async loadProjects() {
      update(state => ({ ...state, isLoading: true, error: null }));
      
      try {
        // Intentar cargar desde localStorage
        const saved = localStorage.getItem('codingsoft-projects');
        let projects: Project[] = [];
        
        if (saved) {
          projects = JSON.parse(saved).map((p: any) => ({
            ...p,
            createdAt: new Date(p.createdAt),
            updatedAt: new Date(p.updatedAt)
          }));
        }
        
        // Si no hay proyectos en localStorage pero tenemos acceso a FS,
        // buscar proyectos en el sistema de archivos
        if (projects.length === 0 && localFileSystem.hasPermission()) {
          projects = await this.scanForProjects();
        }
        
        update(state => ({ ...state, projects, isLoading: false }));
        return projects;
      } catch (error) {
        console.error('Error al cargar proyectos:', error);
        update(state => ({ 
          ...state, 
          isLoading: false, 
          error: error instanceof Error ? error.message : 'Error desconocido' 
        }));
        return [];
      }
    },
    
    /**
     * Escanear sistema de archivos en busca de proyectos
     */
    async scanForProjects(): Promise<Project[]> {
      if (!localFileSystem.hasPermission()) {
        return [];
      }
      
      try {
        const entries = await localFileSystem.listDirectory();
        const projects: Project[] = [];
        
        for (const entry of entries) {
          if (entry.type === 'directory') {
            // Buscar archivo de configuración de proyecto
            try {
              const configContent = await localFileSystem.readFile(`${entry.path}/.codingsoft-project.json`);
              const config = JSON.parse(configContent);
              
              projects.push({
                id: config.id || uuidv4(),
                name: config.name || entry.name,
                description: config.description || '',
                path: entry.path,
                type: config.type || 'custom',
                tags: config.tags || [],
                createdAt: new Date(config.createdAt || Date.now()),
                updatedAt: new Date(config.updatedAt || Date.now()),
                icon: config.icon,
                color: config.color,
                settings: config.settings || {}
              });
            } catch {
              // No es un proyecto configurado, crear uno básico
              projects.push({
                id: uuidv4(),
                name: entry.name,
                description: `Directorio ${entry.name}`,
                path: entry.path,
                type: 'custom',
                tags: ['directory'],
                createdAt: new Date(),
                updatedAt: new Date(),
                settings: {}
              });
            }
          }
        }
        
        return projects;
      } catch (error) {
        console.error('Error al escanear proyectos:', error);
        return [];
      }
    },
    
    /**
     * Crear nuevo proyecto
     */
    async createProject(projectData: Omit<Project, 'id' | 'createdAt' | 'updatedAt'>): Promise<Project> {
      update(state => ({ ...state, isLoading: true, error: null }));
      
      try {
        const newProject: Project = {
          ...projectData,
          id: uuidv4(),
          createdAt: new Date(),
          updatedAt: new Date()
        };
        
        // Crear directorio en sistema de archivos
        if (localFileSystem.hasPermission()) {
          await localFileSystem.createDirectory('', projectData.name);
          
          // Crear archivo de configuración
          const config = {
            id: newProject.id,
            name: newProject.name,
            description: newProject.description,
            type: newProject.type,
            tags: newProject.tags,
            createdAt: newProject.createdAt.toISOString(),
            updatedAt: newProject.updatedAt.toISOString(),
            icon: newProject.icon,
            color: newProject.color,
            settings: newProject.settings
          };
          
          await localFileSystem.writeFile(
            `${projectData.name}/.codingsoft-project.json`,
            JSON.stringify(config, null, 2)
          );
          
          // Crear estructura básica
          await this.createProjectStructure(projectData.name, projectData.type);
        }
        
        // Actualizar store
        update(state => ({
          ...state,
          projects: [...state.projects, newProject],
          currentProject: newProject,
          isLoading: false
        }));
        
        // Guardar en localStorage
        this.saveToLocalStorage();
        
        return newProject;
      } catch (error) {
        console.error('Error al crear proyecto:', error);
        update(state => ({ 
          ...state, 
          isLoading: false, 
          error: error instanceof Error ? error.message : 'Error al crear proyecto' 
        }));
        throw error;
      }
    },
    
    /**
     * Crear estructura básica de proyecto según tipo
     */
    async createProjectStructure(projectName: string, type: Project['type']): Promise<void> {
      if (!localFileSystem.hasPermission()) return;
      
      const basePath = projectName;
      
      switch (type) {
        case 'chat':
          await localFileSystem.createDirectory(basePath, 'chats');
          await localFileSystem.createDirectory(basePath, 'prompts');
          await localFileSystem.createDirectory(basePath, 'contexts');
          await localFileSystem.writeFile(
            `${basePath}/README.md`,
            `# ${projectName}\n\nProyecto de conversaciones IA`
          );
          break;
          
        case 'code':
          await localFileSystem.createDirectory(basePath, 'src');
          await localFileSystem.createDirectory(basePath, 'tests');
          await localFileSystem.createDirectory(basePath, 'docs');
          await localFileSystem.writeFile(
            `${basePath}/README.md`,
            `# ${projectName}\n\nProyecto de desarrollo`
          );
          await localFileSystem.writeFile(
            `${basePath}/package.json`,
            JSON.stringify({
              name: projectName.toLowerCase().replace(/\s+/g, '-'),
              version: '1.0.0',
              description: projectName,
              main: 'src/index.js',
              scripts: {
                start: 'node src/index.js',
                test: 'jest'
              }
            }, null, 2)
          );
          break;
          
        case 'data':
          await localFileSystem.createDirectory(basePath, 'data');
          await localFileSystem.createDirectory(basePath, 'analysis');
          await localFileSystem.createDirectory(basePath, 'reports');
          await localFileSystem.writeFile(
            `${basePath}/README.md`,
            `# ${projectName}\n\nProyecto de análisis de datos`
          );
          break;
          
        case 'documentation':
          await localFileSystem.createDirectory(basePath, 'docs');
          await localFileSystem.createDirectory(basePath, 'examples');
          await localFileSystem.createDirectory(basePath, 'templates');
          await localFileSystem.writeFile(
            `${basePath}/README.md`,
            `# ${projectName}\n\nProyecto de documentación`
          );
          break;
      }
    },
    
    /**
     * Seleccionar proyecto actual
     */
    selectProject(projectId: string): void {
      update(state => {
        const project = state.projects.find(p => p.id === projectId);
        if (!project) return state;
        
        return {
          ...state,
          currentProject: project,
          files: [] // Limpiar archivos cargados
        };
      });
    },
    
    /**
     * Cargar archivos del proyecto actual
     */
    async loadProjectFiles(): Promise<ProjectFile[]> {
      const state = get(projectStore);
      if (!state.currentProject || !localFileSystem.hasPermission()) {
        return [];
      }
      
      update(s => ({ ...s, isLoading: true, error: null }));
      
      try {
        const files = await this.scanDirectory(state.currentProject.path);
        update(s => ({ ...s, files, isLoading: false }));
        return files;
      } catch (error) {
        console.error('Error al cargar archivos:', error);
        update(s => ({ 
          ...s, 
          isLoading: false, 
          error: error instanceof Error ? error.message : 'Error al cargar archivos' 
        }));
        return [];
      }
    },
    
    /**
     * Escanear directorio recursivamente
     */
    async scanDirectory(path: string, basePath: string = ''): Promise<ProjectFile[]> {
      const entries = await localFileSystem.listDirectory(path);
      const files: ProjectFile[] = [];
      
      for (const entry of entries) {
        const fullPath = basePath ? `${basePath}/${entry.name}` : entry.name;
        
        const projectFile: ProjectFile = {
          id: uuidv4(),
          projectId: get(projectStore).currentProject?.id || '',
          name: entry.name,
          path: `${path}/${entry.name}`,
          type: entry.type,
          size: entry.size,
          lastModified: new Date()
        };
        
        files.push(projectFile);
        
        // Escanear subdirectorios recursivamente
        if (entry.type === 'directory') {
          const subFiles = await this.scanDirectory(
            `${path}/${entry.name}`,
            fullPath
          );
          files.push(...subFiles);
        }
      }
      
      return files;
    },
    
    /**
     * Actualizar proyecto
     */
    async updateProject(projectId: string, updates: Partial<Project>): Promise<void> {
      update(state => ({ ...state, isLoading: true, error: null }));
      
      try {
        const state = get(projectStore);
        const projectIndex = state.projects.findIndex(p => p.id === projectId);
        
        if (projectIndex === -1) {
          throw new Error('Proyecto no encontrado');
        }
        
        const updatedProject: Project = {
          ...state.projects[projectIndex],
          ...updates,
          updatedAt: new Date()
        };
        
        // Actualizar en sistema de archivos
        if (localFileSystem.hasPermission()) {
          const configPath = `${updatedProject.path}/.codingsoft-project.json`;
          const config = {
            id: updatedProject.id,
            name: updatedProject.name,
            description: updatedProject.description,
            type: updatedProject.type,
            tags: updatedProject.tags,
            createdAt: updatedProject.createdAt.toISOString(),
            updatedAt: updatedProject.updatedAt.toISOString(),
            icon: updatedProject.icon,
            color: updatedProject.color,
            settings: updatedProject.settings
          };
          
          await localFileSystem.writeFile(configPath, JSON.stringify(config, null, 2));
        }
        
        // Actualizar store
        update(state => {
          const projects = [...state.projects];
          projects[projectIndex] = updatedProject;
          
          return {
            ...state,
            projects,
            currentProject: state.currentProject?.id === projectId ? updatedProject : state.currentProject,
            isLoading: false
          };
        });
        
        // Guardar en localStorage
        this.saveToLocalStorage();
      } catch (error) {
        console.error('Error al actualizar proyecto:', error);
        update(state => ({ 
          ...state, 
          isLoading: false, 
          error: error instanceof Error ? error.message : 'Error al actualizar proyecto' 
        }));
        throw error;
      }
    },
    
    /**
     * Eliminar proyecto
     */
    async deleteProject(projectId: string): Promise<void> {
      update(state => ({ ...state, isLoading: true, error: null }));
      
      try {
        const state = get(projectStore);
        const project = state.projects.find(p => p.id === projectId);
        
        if (!project) {
          throw new Error('Proyecto no encontrado');
        }
        
        // Eliminar del sistema de archivos
        if (localFileSystem.hasPermission()) {
          await localFileSystem.delete(project.path);
        }
        
        // Actualizar store
        update(state => {
          const projects = state.projects.filter(p => p.id !== projectId);
          const currentProject = state.currentProject?.id === projectId ? null : state.currentProject;
          
          return {
            ...state,
            projects,
            currentProject,
            files: state.currentProject?.id === projectId ? [] : state.files,
            isLoading: false
          };
        });
        
        // Guardar en localStorage
        this.saveToLocalStorage();
      } catch (error) {
        console.error('Error al eliminar proyecto:', error);
        update(state => ({ 
          ...state, 
          isLoading: false, 
          error: error instanceof Error ? error.message : 'Error al eliminar proyecto' 
        }));
        throw error;
      }
    },
    
    /**
     * Guardar proyectos en localStorage
     */
    saveToLocalStorage(): void {
      const state = get(projectStore);
      const data = state.projects.map(p => ({
        ...p,
        createdAt: p.createdAt.toISOString(),
        updatedAt: p.updatedAt.toISOString()
      }));
      
      localStorage.setItem('codingsoft-projects', JSON.stringify(data));
    },
    
    /**
     * Limpiar error
     */
    clearError(): void {
      update(state => ({ ...state, error: null }));
    },
    
    /**
     * Limpiar store
     */
    clear(): void {
      set(initialState);
      localStorage.removeItem('codingsoft-projects');
    }
  };
  
  return {
    subscribe,
    ...methods
  };
}

export const projectStore = createProjectStore();

// Store derivado para archivos del proyecto actual
export const currentProjectFiles = derived(
  projectStore,
  $store => $store.files
);

// Store derivado para herramientas del proyecto actual
export const currentProjectTools = derived(
  projectStore,
  $store => {
    if (!$store.currentProject) return [];
    // TODO: Cargar herramientas desde archivos del proyecto
    return [];
  }
);