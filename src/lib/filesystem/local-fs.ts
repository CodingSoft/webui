/**
 * File System Access API wrapper para acceso al sistema de archivos local
 * Similar a LobeHub Desktop
 */

export interface FileEntry {
  name: string;
  type: 'file' | 'directory';
  size: number;
  path: string;
  lastModified?: number;
}

export interface DirectoryHandle {
  kind: 'directory';
  name: string;
  getFileHandle: (name: string, options?: { create?: boolean }) => Promise<FileSystemFileHandle>;
  getDirectoryHandle: (name: string, options?: { create?: boolean }) => Promise<FileSystemDirectoryHandle>;
  entries: () => AsyncIterableIterator<[string, FileSystemFileHandle | FileSystemDirectoryHandle]>;
  removeEntry: (name: string, options?: { recursive?: boolean }) => Promise<void>;
}

export class LocalFileSystem {
  private rootHandle: FileSystemDirectoryHandle | null = null;
  
  /**
   * Solicitar permisos para acceder al directorio raíz
   */
  async requestPermissions(): Promise<boolean> {
    try {
      // File System Access API
      if ('showDirectoryPicker' in window) {
        this.rootHandle = await (window as any).showDirectoryPicker({
          mode: 'readwrite'
        });
        return true;
      }
      
      // Fallback para navegadores sin soporte completo
      console.warn('File System Access API no soportada');
      return false;
    } catch (error) {
      console.error('Error al solicitar permisos:', error);
      return false;
    }
  }
  
  /**
   * Listar contenido de un directorio
   */
  async listDirectory(path: string = ''): Promise<FileEntry[]> {
    if (!this.rootHandle) {
      throw new Error('No se ha obtenido acceso al sistema de archivos');
    }
    
    const entries: FileEntry[] = [];
    let currentHandle = this.rootHandle;
    
    // Navegar a subdirectorio si se especifica path
    if (path) {
      const parts = path.split('/').filter(p => p);
      for (const part of parts) {
        currentHandle = await currentHandle.getDirectoryHandle(part);
      }
    }
    
    // Leer contenido del directorio
    for await (const [name, handle] of currentHandle.entries()) {
      const isFile = handle.kind === 'file';
      const fileEntry: FileEntry = {
        name,
        type: isFile ? 'file' : 'directory',
        size: isFile ? await this.getFileSize(handle as FileSystemFileHandle) : 0,
        path: path ? `${path}/${name}` : name
      };
      
      entries.push(fileEntry);
    }
    
    return entries.sort((a, b) => {
      // Directorios primero, luego archivos
      if (a.type === 'directory' && b.type === 'file') return -1;
      if (a.type === 'file' && b.type === 'directory') return 1;
      // Orden alfabético
      return a.name.localeCompare(b.name);
    });
  }
  
  /**
   * Crear directorio
   */
  async createDirectory(path: string, name: string): Promise<void> {
    if (!this.rootHandle) {
      throw new Error('No se ha obtenido acceso al sistema de archivos');
    }
    
    let currentHandle = this.rootHandle;
    const parts = path.split('/').filter(p => p);
    
    // Navegar al directorio padre
    for (const part of parts) {
      currentHandle = await currentHandle.getDirectoryHandle(part);
    }
    
    // Crear nuevo directorio
    await currentHandle.getDirectoryHandle(name, { create: true });
  }
  
  /**
   * Crear archivo
   */
  async createFile(path: string, name: string, content: string = ''): Promise<void> {
    if (!this.rootHandle) {
      throw new Error('No se ha obtenido acceso al sistema de archivos');
    }
    
    let currentHandle = this.rootHandle;
    const parts = path.split('/').filter(p => p);
    
    // Navegar al directorio padre
    for (const part of parts) {
      currentHandle = await currentHandle.getDirectoryHandle(part);
    }
    
    // Crear archivo
    const fileHandle = await currentHandle.getFileHandle(name, { create: true });
    const writable = await fileHandle.createWritable();
    await writable.write(content);
    await writable.close();
  }
  
  /**
   * Leer archivo
   */
  async readFile(path: string): Promise<string> {
    if (!this.rootHandle) {
      throw new Error('No se ha obtenido acceso al sistema de archivos');
    }
    
    const parts = path.split('/').filter(p => p);
    const fileName = parts.pop();
    
    if (!fileName) {
      throw new Error('Ruta inválida');
    }
    
    let currentHandle = this.rootHandle;
    
    // Navegar al directorio padre
    for (const part of parts) {
      currentHandle = await currentHandle.getDirectoryHandle(part);
    }
    
    // Obtener archivo
    const fileHandle = await currentHandle.getFileHandle(fileName);
    const file = await fileHandle.getFile();
    return await file.text();
  }
  
  /**
   * Escribir archivo
   */
  async writeFile(path: string, content: string): Promise<void> {
    if (!this.rootHandle) {
      throw new Error('No se ha obtenido acceso al sistema de archivos');
    }
    
    const parts = path.split('/').filter(p => p);
    const fileName = parts.pop();
    
    if (!fileName) {
      throw new Error('Ruta inválida');
    }
    
    let currentHandle = this.rootHandle;
    
    // Navegar al directorio padre
    for (const part of parts) {
      currentHandle = await currentHandle.getDirectoryHandle(part);
    }
    
    // Escribir archivo
    const fileHandle = await currentHandle.getFileHandle(fileName, { create: true });
    const writable = await fileHandle.createWritable();
    await writable.write(content);
    await writable.close();
  }
  
  /**
   * Eliminar archivo o directorio
   */
  async delete(path: string): Promise<void> {
    if (!this.rootHandle) {
      throw new Error('No se ha obtenido acceso al sistema de archivos');
    }
    
    const parts = path.split('/').filter(p => p);
    const itemName = parts.pop();
    
    if (!itemName) {
      throw new Error('Ruta inválida');
    }
    
    let currentHandle = this.rootHandle;
    
    // Navegar al directorio padre
    for (const part of parts) {
      currentHandle = await currentHandle.getDirectoryHandle(part);
    }
    
    // Eliminar
    await currentHandle.removeEntry(itemName, { recursive: true });
  }
  
  /**
   * Renombrar archivo o directorio
   */
  async rename(oldPath: string, newName: string): Promise<void> {
    if (!this.rootHandle) {
      throw new Error('No se ha obtenido acceso al sistema de archivos');
    }
    
    const oldParts = oldPath.split('/').filter(p => p);
    const oldName = oldParts.pop();
    
    if (!oldName) {
      throw new Error('Ruta inválida');
    }
    
    let parentHandle = this.rootHandle;
    
    // Navegar al directorio padre
    for (const part of oldParts) {
      parentHandle = await parentHandle.getDirectoryHandle(part);
    }
    
    // Leer contenido del archivo/directorio antiguo
    let content = '';
    let isDirectory = false;
    
    try {
      const oldHandle = await parentHandle.getFileHandle(oldName);
      const file = await oldHandle.getFile();
      content = await file.text();
    } catch {
      // Es un directorio
      isDirectory = true;
    }
    
    // Crear nuevo archivo/directorio
    if (isDirectory) {
      await parentHandle.getDirectoryHandle(newName, { create: true });
      // TODO: Copiar contenido del directorio
    } else {
      await this.createFile(oldParts.join('/'), newName, content);
    }
    
    // Eliminar antiguo
    await parentHandle.removeEntry(oldName, { recursive: true });
  }
  
  /**
   * Obtener tamaño de archivo
   */
  private async getFileSize(fileHandle: FileSystemFileHandle): Promise<number> {
    const file = await fileHandle.getFile();
    return file.size;
  }
  
  /**
   * Verificar si tenemos permisos
   */
  hasPermission(): boolean {
    return this.rootHandle !== null;
  }
  
  /**
   * Guardar handle para uso futuro
   */
  saveHandle(handle: FileSystemDirectoryHandle): void {
    this.rootHandle = handle;
  }
  
  /**
   * Obtener handle guardado
   */
  getHandle(): FileSystemDirectoryHandle | null {
    return this.rootHandle;
  }
}

// Instancia singleton
export const localFileSystem = new LocalFileSystem();