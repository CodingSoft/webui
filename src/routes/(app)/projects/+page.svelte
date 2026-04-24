<script lang="ts">
  import { onMount } from 'svelte';
  import { projectStore } from '$lib/projects/store';
  import { localFileSystem } from '$lib/filesystem/local-fs';
  
  // Estados
  let isLoading = $projectStore.isLoading;
  let projects = $projectStore.projects;
  let error = $projectStore.error;
  let showCreateModal = false;
  let newProject = {
    name: '',
    description: '',
    type: 'custom' as const,
    tags: [] as string[],
    icon: '📁',
    color: '#2563eb'
  };
  let tagInput = '';
  let requestingPermission = false;
  
  // Tipos de proyecto disponibles
  const projectTypes = [
    { id: 'chat', name: 'Chat', icon: '💬', description: 'Proyecto de conversaciones y prompts' },
    { id: 'code', name: 'Código', icon: '💻', description: 'Proyecto de desarrollo de software' },
    { id: 'data', name: 'Datos', icon: '📊', description: 'Proyecto de análisis de datos' },
    { id: 'documentation', name: 'Documentación', icon: '📚', description: 'Proyecto de documentación' },
    { id: 'custom', name: 'Personalizado', icon: '🎨', description: 'Proyecto personalizado' }
  ];
  
  // Cargar proyectos al montar
  onMount(async () => {
    await loadProjects();
  });
  
  async function loadProjects() {
    await projectStore.loadProjects();
  }
  
  async function requestFileSystemAccess() {
    requestingPermission = true;
    try {
      const granted = await localFileSystem.requestPermissions();
      if (granted) {
        // Recargar proyectos después de obtener acceso
        await loadProjects();
      }
    } catch (err) {
      console.error('Error al solicitar permisos:', err);
    } finally {
      requestingPermission = false;
    }
  }
  
  function openCreateModal() {
    newProject = {
      name: '',
      description: '',
      type: 'custom',
      tags: [],
      icon: '📁',
      color: '#2563eb'
    };
    showCreateModal = true;
  }
  
  function closeCreateModal() {
    showCreateModal = false;
  }
  
  async function createProject() {
    if (!newProject.name.trim()) {
      alert('Por favor ingresa un nombre para el proyecto');
      return;
    }
    
    try {
      await projectStore.createProject(newProject);
      closeCreateModal();
    } catch (err) {
      console.error('Error al crear proyecto:', err);
    }
  }
  
  function addTag() {
    const tag = tagInput.trim();
    if (tag && !newProject.tags.includes(tag)) {
      newProject.tags = [...newProject.tags, tag];
      tagInput = '';
    }
  }
  
  function removeTag(tag: string) {
    newProject.tags = newProject.tags.filter(t => t !== tag);
  }
  
  function selectProject(projectId: string) {
    projectStore.selectProject(projectId);
    // Navegar a la vista del proyecto
    window.location.href = `/projects/${projectId}`;
  }
  
  async function deleteProject(projectId: string, event: Event) {
    event.stopPropagation();
    if (!confirm('¿Estás seguro de que quieres eliminar este proyecto?')) return;
    
    try {
      await projectStore.deleteProject(projectId);
    } catch (err) {
      console.error('Error al eliminar proyecto:', err);
    }
  }
</script>

<svelte:head>
  <title>Proyectos - CodingSoft AI</title>
</svelte:head>

<div class="container mx-auto p-6">
  <!-- Header -->
  <div class="mb-8">
    <h1 class="text-3xl font-bold text-gray-900 dark:text-gray-100 mb-2">
      Proyectos
    </h1>
    <p class="text-gray-600 dark:text-gray-400">
      Gestiona tus proyectos locales al estilo LobeHub Desktop
    </p>
  </div>
  
  <!-- Banner de permisos -->
  {#if !localFileSystem.hasPermission()}
    <div class="bg-blue-50 dark:bg-blue-900/20 border border-blue-200 dark:border-blue-800 rounded-lg p-4 mb-6">
      <div class="flex items-start">
        <div class="flex-shrink-0">
          <div class="w-6 h-6 text-blue-600 dark:text-blue-400">🔒</div>
        </div>
        <div class="ml-3 flex-1">
          <h3 class="text-sm font-medium text-blue-800 dark:text-blue-300">
            Acceso al sistema de archivos requerido
          </h3>
          <div class="mt-2 text-sm text-blue-700 dark:text-blue-400">
            <p>
              Para usar las funciones completas de gestión de proyectos como LobeHub Desktop,
              necesitas permitir el acceso a tu sistema de archivos local.
            </p>
          </div>
          <div class="mt-4">
            <button
              on:click={requestFileSystemAccess}
              disabled={requestingPermission}
              class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 disabled:opacity-50"
            >
              {#if requestingPermission}
                <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                  <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                  <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                </svg>
                Solicitando permisos...
              {:else}
                Permitir acceso al sistema de archivos
              {/if}
            </button>
          </div>
        </div>
      </div>
    </div>
  {/if}
  
  <!-- Mensaje de error -->
  {#if error}
    <div class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4 mb-6">
      <div class="flex">
        <div class="flex-shrink-0">
          <div class="w-6 h-6 text-red-600 dark:text-red-400">⚠️</div>
        </div>
        <div class="ml-3">
          <h3 class="text-sm font-medium text-red-800 dark:text-red-300">
            Error
          </h3>
          <div class="mt-2 text-sm text-red-700 dark:text-red-400">
            <p>{error}</p>
          </div>
          <div class="mt-4">
            <button
              on:click={() => projectStore.clearError()}
              class="text-sm font-medium text-red-600 dark:text-red-400 hover:text-red-500"
            >
              Cerrar
            </button>
          </div>
        </div>
      </div>
    </div>
  {/if}
  
  <!-- Controles y estadísticas -->
  <div class="flex justify-between items-center mb-6">
    <div>
      <button
        on:click={openCreateModal}
        class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary hover:bg-primary/90 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary"
      >
        <span class="mr-2">+</span>
        Nuevo Proyecto
      </button>
    </div>
    
    <div class="text-sm text-gray-600 dark:text-gray-400">
      {projects.length} {projects.length === 1 ? 'proyecto' : 'proyectos'}
    </div>
  </div>
  
  <!-- Grid de proyectos -->
  {#if isLoading && projects.length === 0}
    <div class="text-center py-12">
      <svg class="animate-spin h-8 w-8 text-primary mx-auto mb-4" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
      <p class="text-gray-600 dark:text-gray-400">Cargando proyectos...</p>
    </div>
  {:else if projects.length === 0}
    <div class="text-center py-12 border-2 border-dashed border-gray-300 dark:border-gray-700 rounded-lg">
      <div class="text-4xl mb-4">📁</div>
      <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100 mb-2">
        No hay proyectos
      </h3>
      <p class="text-gray-600 dark:text-gray-400 mb-6 max-w-md mx-auto">
        Comienza creando tu primer proyecto para organizar tus archivos, herramientas y conversaciones.
      </p>
      <button
        on:click={openCreateModal}
        class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-primary hover:bg-primary/90 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-primary"
      >
        <span class="mr-2">+</span>
        Crear primer proyecto
      </button>
    </div>
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      {#each projects as project}
        <div
          on:click={() => selectProject(project.id)}
          class="group relative bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 p-6 hover:border-primary/50 hover:shadow-lg cursor-pointer transition-all duration-200"
        >
          <!-- Acciones rápidas -->
          <div class="absolute top-4 right-4 opacity-0 group-hover:opacity-100 transition-opacity">
            <button
              on:click={(e) => deleteProject(project.id, e)}
              class="text-gray-400 hover:text-red-500 p-1 rounded-full hover:bg-red-50 dark:hover:bg-red-900/20"
              title="Eliminar proyecto"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
              </svg>
            </button>
          </div>
          
          <!-- Icono y color -->
          <div class="flex items-center mb-4">
            <div
              class="w-12 h-12 rounded-lg flex items-center justify-center text-2xl"
              style="background-color: {project.color || '#2563eb'}20; color: {project.color || '#2563eb'}"
            >
              {project.icon || '📁'}
            </div>
            <div class="ml-4">
              <h3 class="text-lg font-semibold text-gray-900 dark:text-gray-100 truncate">
                {project.name}
              </h3>
              <p class="text-sm text-gray-500 dark:text-gray-400 truncate">
                {project.description || 'Sin descripción'}
              </p>
            </div>
          </div>
          
          <!-- Tags -->
          {#if project.tags.length > 0}
            <div class="flex flex-wrap gap-1 mb-4">
              {#each project.tags.slice(0, 3) as tag}
                <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300">
                  {tag}
                </span>
              {/each}
              {#if project.tags.length > 3}
                <span class="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-gray-100 dark:bg-gray-700 text-gray-800 dark:text-gray-300">
                  +{project.tags.length - 3}
                </span>
              {/if}
            </div>
          {/if}
          
          <!-- Metadatos -->
          <div class="text-xs text-gray-500 dark:text-gray-400 space-y-1">
            <div class="flex items-center">
              <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              <span>Actualizado: {project.updatedAt.toLocaleDateString()}</span>
            </div>
            <div class="flex items-center">
              <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 20l4-16m4 4l4 4-4 4M6 16l-4-4 4-4" />
              </svg>
              <span>Tipo: {project.type}</span>
            </div>
          </div>
          
          <!-- Acción -->
          <div class="mt-4 pt-4 border-t border-gray-100 dark:border-gray-700">
            <div class="flex items-center text-sm text-primary font-medium">
              <span>Abrir proyecto</span>
              <svg class="ml-1 w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3" />
              </svg>
            </div>
          </div>
        </div>
      {/each}
    </div>
  {/if}
</div>

<!-- Modal de creación -->
{#if showCreateModal}
  <div class="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
    <div class="bg-white dark:bg-gray-800 rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
      <!-- Header -->
      <div class="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
        <h3 class="text-lg font-medium text-gray-900 dark:text-gray-100">
          Crear nuevo proyecto
        </h3>
        <p class="mt-1 text-sm text-gray-600 dark:text-gray-400">
          Organiza tus archivos, herramientas y conversaciones en proyectos.
        </p>
      </div>
      
      <!-- Form -->
      <div class="px-6 py-4">
        <div class="space-y-4">
          <!-- Nombre -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Nombre del proyecto *
            </label>
            <input
              type="text"
              bind:value={newProject.name}
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary dark:bg-gray-700 dark:text-gray-100"
              placeholder="Mi Proyecto"
            />
          </div>
          
          <!-- Descripción -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Descripción
            </label>
            <textarea
              bind:value={newProject.description}
              rows="3"
              class="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary dark:bg-gray-700 dark:text-gray-100"
              placeholder="Describe tu proyecto..."
            />
          </div>
          
          <!-- Tipo -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Tipo de proyecto
            </label>
            <div class="grid grid-cols-2 gap-2">
              {#each projectTypes as type}
                <button
                  type="button"
                  on:click={() => newProject.type = type.id}
                  class={`p-3 rounded-lg border text-left transition-colors ${newProject.type === type.id ? 'border-primary bg-primary/10' : 'border-gray-300 dark:border-gray-600 hover:border-primary/50'}`}
                >
                  <div class="text-2xl mb-2">{type.icon}</div>
                  <div class="font-medium text-gray-900 dark:text-gray-100">{type.name}</div>
                  <div class="text-xs text-gray-600 dark:text-gray-400 mt-1">{type.description}</div>
                </button>
              {/each}
            </div>
          </div>
          
          <!-- Tags -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Etiquetas
            </label>
            <div class="flex gap-2 mb-2">
              <input
                type="text"
                bind:value={tagInput}
                on:keydown={(e) => e.key === 'Enter' && (e.preventDefault(), addTag())}
                class="flex-1 px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary dark:bg-gray-700 dark:text-gray-100"
                placeholder="Añadir etiqueta..."
              />
              <button
                type="button"
                on:click={addTag}
                class="px-4 py-2 bg-gray-100 dark:bg-gray-700 text-gray-700 dark:text-gray-300 rounded-md hover:bg-gray-200 dark:hover:bg-gray-600"
              >
                Añadir
              </button>
            </div>
            {#if newProject.tags.length > 0}
              <div class="flex flex-wrap gap-2">
                {#each newProject.tags as tag}
                  <span class="inline-flex items-center px-3 py-1 rounded-full text-sm bg-primary/10 text-primary">
                    {tag}
                    <button
                      type="button"
                      on:click={() => removeTag(tag)}
                      class="ml-2 text-primary/70 hover:text-primary"
                    >
                      ×
                    </button>
                  </span>
                {/each}
              </div>
            {/if}
          </div>
          
          <!-- Color -->
          <div>
            <label class="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
              Color del proyecto
            </label>
            <div class="flex gap-2">
              {#each ['#2563eb', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899'] as color}
                <button
                  type="button"
                  on:click={() => newProject.color = color}
                  class={`w-8 h-8 rounded-full border-2 ${newProject.color === color ? 'border-gray-900 dark:border-gray-100' : 'border-transparent'}`}
                  style="background-color: {color}"
                />
              {/each}
            </div>
          </div>
        </div>
      </div>
      
      <!-- Footer -->
      <div class="px-6 py-4 border-t border-gray-200 dark:border-gray-700 flex justify-end gap-3">
        <button
          on:click={closeCreateModal}
          class="px-4 py-2 border border-gray-300 dark:border-gray-600 text-gray-700 dark:text-gray-300 rounded-md hover:bg-gray-50 dark:hover:bg-gray-700"
        >
          Cancelar
        </button>
        <button
          on:click={createProject}
          disabled={!newProject.name.trim()}
          class="px-4 py-2 bg-primary text-white rounded-md hover:bg-primary/90 disabled:opacity-50 disabled:cursor-not-allowed"
        >
          Crear proyecto
        </button>
      </div>
    </div>
  </div>
{/if}

<style>
  .container {
    max-width: 1200px;
  }
  
  .bg-primary {
    background-color: #2563eb;
  }
  
  .text-primary {
    color: #2563eb;
  }
  
  .border-primary {
    border-color: #2563eb;
  }
  
  .focus\:ring-primary:focus {
    --tw-ring-color: #2563eb;
  }
</style>