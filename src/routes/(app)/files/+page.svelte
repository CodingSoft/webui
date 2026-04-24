<script lang="ts">
  import { onMount } from 'svelte';
  import { localFileSystem } from '$lib/filesystem/local-fs';
  import type { FileEntry } from '$lib/filesystem/local-fs';
  
  // Estados
  let isLoading = false;
  let error: string | null = null;
  let currentPath = '';
  let entries: FileEntry[] = [];
  let requestingPermission = false;
  let showCreateModal = false;
  let showUploadModal = false;
  let showPreview = false;
  
  // Creación
  let newItem = {
    type: 'file' as 'file' | 'directory',
    name: '',
    content: ''
  };
  
  // Preview
  let previewFile: FileEntry | null = null;
  let previewContent = '';
  let previewLoading = false;
  
  // Historial de navegación
  let history: string[] = [];
  let historyIndex = -1;
  
  // Cargar directorio actual
  async function loadDirectory(path: string = '') {
    isLoading = true;
    error = null;
    
    try {
      if (!localFileSystem.hasPermission()) {
        throw new Error('No hay acceso al sistema de archivos');
      }
      
      const files = await localFileSystem.listDirectory(path);
      entries = files;
      currentPath = path;
      
      // Actualizar historial
      if (path !== history[historyIndex]) {
        history = [...history.slice(0, historyIndex + 1), path];
        historyIndex++;
      }
    } catch (err) {
      error = err instanceof Error ? err.message : 'Error al cargar directorio';
      console.error('Error:', err);
    } finally {
      isLoading = false;
    }
  }
  
  // Solicitar permisos
  async function requestPermission() {
    requestingPermission = true;
    try {
      const granted = await localFileSystem.requestPermissions();
      if (granted) {
        await loadDirectory();
      }
    } catch (err) {
      error = 'Error al solicitar permisos';
    } finally {
      requestingPermission = false;
    }
  }
  
  // Navegación
  function navigateTo(path: string) {
    loadDirectory(path);
  }
  
  function goBack() {
    if (historyIndex > 0) {
      historyIndex--;
      loadDirectory(history[historyIndex]);
    }
  }
  
  function goForward() {
    if (historyIndex < history.length - 1) {
      historyIndex++;
      loadDirectory(history[historyIndex]);
    }
  }
  
  function goUp() {
    if (currentPath) {
      const parts = currentPath.split('/').filter(p => p);
      parts.pop();
      const parentPath = parts.join('/');
      navigateTo(parentPath);
    }
  }
  
  // Operaciones CRUD
  async function createItem() {
    if (!newItem.name.trim()) {
      alert('Por favor ingresa un nombre');
      return;
    }
    
    try {
      if (newItem.type === 'directory') {
        await localFileSystem.createDirectory(currentPath, newItem.name);
      } else {
        await localFileSystem.createFile(currentPath, newItem.name, newItem.content);
      }
      
      closeCreateModal();
      await loadDirectory(currentPath);
    } catch (err) {
      alert('Error al crear: ' + (err instanceof Error ? err.message : 'Error desconocido'));
    }
  }
  
  async function deleteItem(entry: FileEntry) {
    if (!confirm(`¿Estás seguro de eliminar "${entry.name}"?`)) return;
    
    try {
      await localFileSystem.delete(entry.path);
      await loadDirectory(currentPath);
    } catch (err) {
      alert('Error al eliminar: ' + (err instanceof Error ? err.message : 'Error desconocido'));
    }
  }
  
  async function renameItem(oldEntry: FileEntry, newName: string) {
    if (!newName.trim()) return;
    
    try {
      await localFileSystem.rename(oldEntry.path, newName);
      await loadDirectory(currentPath);
    } catch (err) {
      alert('Error al renombrar: ' + (err instanceof Error ? err.message : 'Error desconocido'));
    }
  }
  
  async function previewFileContent(entry: FileEntry) {
    previewFile = entry;
    previewLoading = true;
    showPreview = true;
    
    try {
      previewContent = await localFileSystem.readFile(entry.path);
    } catch (err) {
      previewContent = `Error al leer archivo: ${err instanceof Error ? err.message : 'Error desconocido'}`;
    } finally {
      previewLoading = false;
    }
  }
  
  function closePreview() {
    showPreview = false;
    previewFile = null;
    previewContent = '';
  }
  
  // Modal helpers
  function openCreateModal(type: 'file' | 'directory') {
    newItem = {
      type,
      name: '',
      content: type === 'file' ? '' : ''
    };
    showCreateModal = true;
  }
  
  function closeCreateModal() {
    showCreateModal = false;
  }
  
  // Inicialización
  onMount(async () => {
    if (localFileSystem.hasPermission()) {
      await loadDirectory();
    }
  });
</script>

<svelte:head>
  <title>Explorador de Archivos - CodingSoft AI</title>
</svelte:head>

<div class="min-h-screen bg-gray-50 dark:bg-gray-900">
  <!-- Header -->
  <div class="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 px-6 py-4">
    <div class="flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold text-gray-900 dark:text-gray-100">
          Explorador de Archivos
        </h1>
        <p class="text-sm text-gray-600 dark:text-gray-400 mt-1">
          Acceso completo al sistema de archivos local
        </p>
      </div>
      
      <div class="flex items-center gap-3">
        {#if !localFileSystem.hasPermission()}
          <button
            on:click={requestPermission}
            disabled={requestingPermission}
            class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 disabled:opacity-50"
          >
            {#if requestingPermission}
              <span class="flex items-center">
                <svg class="animate-spin h-4 w-4 mr-2" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none" />
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                </svg>
                Solicitando...
              </span>
            {:else}
              Permitir acceso
            {/if}
          </button>
        {/if}
      </div>
    </div>
  </div>
  
  <!-- Main content -->
  <div class="p-6">
    <!-- Breadcrumb y controles -->
    <div class="mb-6 bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-4">
      <div class="flex items-center justify-between">
        <!-- Breadcrumb -->
        <div class="flex items-center gap-2">
          <button
            on:click={() => navigateTo('')}
            class="text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100"
            title="Directorio raíz"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6" />
            </svg>
          </button>
          
          <button
            on:click={goBack}
            disabled={historyIndex <= 0}
            class="p-1 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 disabled:opacity-50"
            title="Atrás"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7" />
            </svg>
          </button>
          
          <button
            on:click={goForward}
            disabled={historyIndex >= history.length - 1}
            class="p-1 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 disabled:opacity-50"
            title="Adelante"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7" />
            </svg>
          </button>
          
          <button
            on:click={goUp}
            disabled={!currentPath}
            class="p-1 text-gray-600 dark:text-gray-400 hover:text-gray-900 dark:hover:text-gray-100 disabled:opacity-50"
            title="Subir"
          >
            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 15l7-7 7 7" />
            </svg>
          </button>
          
          <!-- Ruta actual -->
          <div class="ml-4 flex items-center gap-1 text-sm">
            <span class="text-gray-500 dark:text-gray-400">/</span>
            {#each currentPath.split('/').filter(p => p) as part, i}
              <button
                on:click={() => {
                  const path = currentPath.split('/').slice(0, i + 1).join('/');
                  navigateTo(path);
                }}
                class="text-gray-700 dark:text-gray-300 hover:text-primary"
              >
                {part}
              </button>
              {#if i < currentPath.split('/').filter(p => p).length - 1}
                <span class="text-gray-400">/</span>
              {/if}
            {/each}
          </div>
        </div>
        
        <!-- Acciones -->
        <div class="flex items-center gap-2">
          <button
            on:click={() => openCreateModal('directory')}
            class="px-3 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-200 dark:hover:bg-gray-600 flex items-center gap-2"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            Nueva carpeta
          </button>
          
          <button
            on:click={() => openCreateModal('file')}
            class="px-3 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 flex items-center gap-2"
          >
            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
            </svg>
            Nuevo archivo
          </button>
        </div>
      </div>
    </div>
    
    <!-- Contenido -->
    <div class="bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 overflow-hidden">
      {#if !localFileSystem.hasPermission()}
        <div class="p-12 text-center">
          <div class="text-6xl mb-4">🔒</div>
          <h3 class="text-xl font-semibold text-gray-900 dark:text-gray-100 mb-2">
            Acceso al sistema de archivos requerido
          </h3>
          <p class="text-gray-600 dark:text-gray-400 mb-6 max-w-md mx-auto">
            Para usar el explorador de archivos, necesitas permitir el acceso a tu sistema de archivos local.
          </p>
          <button
            on:click={requestPermission}
            disabled={requestingPermission}
            class="px-6 py-3 bg-primary text-white rounded-lg hover:bg-primary/90 disabled:opacity-50"
          >
            Permitir acceso
          </button>
        </div>
      {:else if isLoading}
        <div class="p-12 text-center">
          <svg class="animate-spin h-8 w-8 text-primary mx-auto mb-4" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none" />
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
          </svg>
          <p class="text-gray-600 dark:text-gray-400">Cargando archivos...</p>
        </div>
      {:else if error}
        <div class="p-6">
          <div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4">
            <div class="flex">
              <div class="flex-shrink-0">
                <svg class="h-5 w-5 text-red-400" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd" />
                </svg>
              </div>
              <div class="ml-3">
                <h3 class="text-sm font-medium text-red-800 dark:text-red-300">Error</h3>
                <div class="mt-2 text-sm text-red-700 dark:text-red-400">
                  <p>{error}</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      {:else if entries.length === 0}
        <div class="p-12 text-center">
          <div class="text-6xl mb-4">📁</div>
          <h3 class="text-xl font-semibold text-gray-900 dark:text-gray-100 mb-2">
            Directorio vacío
          </h3>
          <p class="text-gray-600 dark:text-gray-400">
            Este directorio no contiene archivos o carpetas.
          </p>
        </div>
      {:else}
        <div class="divide-y divide-gray-200 dark:divide-gray-700">
          <!-- Header de tabla -->
          <div class="grid grid-cols-12 gap-4 px-6 py-3 bg-gray-50 dark:bg-gray-900 text-sm font-medium text-gray-700 dark:text-gray-300">
            <div class="col-span-6">Nombre</div>
            <div class="col-span-2">Tipo</div>
            <div class="col-span-2">Tamaño</div>
            <div class="col-span-2 text-right">Acciones</div>
          </div>
          
          <!-- Lista de archivos -->
          {#each entries as entry}
            <div class="grid grid-cols-12 gap-4 px-6 py-4 hover:bg-gray-50 dark:hover:bg-gray-900/50">
              <!-- Nombre -->
              <div class="col-span-6">
                <div class="flex items-center gap-3">
                  {#if entry.type === 'directory'}
                    <div class="text-yellow-500">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 7v10a2 2 0 002 2h14a2 2 0 002-2V9a2 2 0 00-2-2h-6l-2-2H5a2 2 0 00-2 2z" />
                      </svg>
                    </div>
                  {:else}
                    <div class="text-blue-500">
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                      </svg>
                    </div>
                  {/if}
                  
                  <div>
                    {#if entry.type === 'directory'}
                      <button
                        on:click={() => navigateTo(entry.path)}
                        class="text-left font-medium text-gray-900 dark:text-gray-100 hover:text-primary"
                      >
                        {entry.name}
                      </button>
                    {:else}
                      <button
                        on:click={() => previewFileContent(entry)}
                        class="text-left font-medium text-gray-900 dark:text-gray-100 hover:text-primary"
                      >
                        {entry.name}
                      </button>
                    {/if}
                  </div>
                </div>
              </div>
              
              <!-- Tipo -->
              <div class="col-span-2">
                <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300">
                  {entry.type === 'directory' ? 'Carpeta' : 'Archivo'}
                </span>
              </div>
              
              <!-- Tamaño -->
              <div class="col-span-2 text-gray-600 dark:text-gray-400">
                {#if entry.type === 'directory'}
                  —
                {:else}
                  {formatFileSize(entry.size)}
                {/if}
              </div>
              
              <!-- Acciones -->
              <div class="col-span-2 text-right">
                <div class="flex items-center justify-end gap-2">
                  {#if entry.type === 'file'}
                    <button
                      on:click={() => previewFileContent(entry)}
                      class="p-1 text-gray-400 hover:text-blue-500"
                      title="Vista previa"
                    >
                      <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                      </svg>
                    </button>
                  {/if}
                  
                  <button
                    on:click={() => deleteItem(entry)}
                    class="p-1 text-gray-400 hover:text-red-500"
                    title="Eliminar"
                  >
                    <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                  </button>
                </div>
              </div>
            </div>
          {/each}
        </div>
      {/if}
    </div>
  </div>
</div>

<!-- Modal de creación -->
{#if showCreateModal}
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-md w-full">
      <div class="p-6">
        <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100 mb-4">
          {newItem.type === 'directory' ? 'Nueva Carpeta' : 'Nuevo Archivo'}
        </h3>
        
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Nombre *
            </label>
            <input
              type="text"
              bind:value={newItem.name}
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary dark:bg-gray-700 dark:text-gray-100"
              placeholder={newItem.type === 'directory' ? 'nombre-carpeta' : 'archivo.txt'}
            />
          </div>
          
          {#if newItem.type === 'file'}
            <div>
              <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                Contenido
              </label>
              <textarea
                bind:value={newItem.content}
                rows="6"
                class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary dark:bg-gray-700 dark:text-gray-100 font-mono text-sm"
                placeholder="Contenido del archivo..."
              />
            </div>
          {/if}
        </div>
        
        <div class="mt-6 flex justify-end gap-3">
          <button
            on:click={closeCreateModal}
            class="px-4 py-2 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700"
          >
            Cancelar
          </button>
          <button
            on:click={createItem}
            disabled={!newItem.name.trim()}
            class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90 disabled:opacity-50"
          >
            Crear
          </button>
        </div>
      </div>
    </div>
  </div>
{/if}

<!-- Modal de vista previa -->
{#if showPreview && previewFile}
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-4xl w-full max-h-[90vh] flex flex-col">
      <!-- Header -->
      <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700 flex items-center justify-between">
        <div>
          <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">
            {previewFile.name}
          </h3>
          <p class="text-sm text-gray-600 dark:text-gray-400">
            {formatFileSize(previewFile.size)} • Vista previa
          </p>
        </div>
        <button
          on:click={closePreview}
          class="p-2 text-gray-400 hover:text-gray-900 dark:hover:text-gray-100"
        >
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>
      
      <!-- Contenido -->
      <div class="flex-1 overflow-auto">
        {#if previewLoading}
          <div class="p-12 text-center">
            <svg class="animate-spin h-8 w-8 text-primary mx-auto mb-4" viewBox="0 0 24 24">
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4" fill="none" />
              <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
            </svg>
            <p class="text-gray-600 dark:text-gray-400">Cargando...</p>
          </div>
        {:else}
          <pre class="p-6 text-sm font-mono text-gray-900 dark:text-gray-100 whitespace-pre-wrap overflow-x-auto">
{previewContent}
          </pre>
        {/if}
      </div>
      
      <!-- Footer -->
      <div class="px-6 py-4 border-t border-gray-200 dark:border-gray-700 flex justify-end">
        <button
          on:click={closePreview}
          class="px-4 py-2 bg-primary text-white rounded-lg hover:bg-primary/90"
        >
          Cerrar
        </button>
      </div>
    </div>
  </div>
{/if}

<script lang="ts">
  function formatFileSize(bytes: number): string {
    if (bytes === 0) return '0 Bytes';
    
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
  }
</script>

<style>
  .bg-primary {
    background-color: #2563eb;
  }
  
  .text-primary {
    color: #2563eb;
  }
</style>