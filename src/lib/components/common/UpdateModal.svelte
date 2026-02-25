<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import { fade } from 'svelte/transition';
	import Modal from './Modal.svelte';
	import {
		startUpdate,
		getUpdateStatus,
		restartApplication,
		checkUpdatePrerequisites
	} from '$lib/apis';

	export let show = false;
	export let onClose = () => {};
	export let currentVersion = '';
	export let latestVersion = '';

	let status = 'idle'; // idle, checking, updating, completed, failed, needs_restart
	let progress = 0;
	let message = '';
	let logs: Array<{ timestamp: string; level: string; message: string }> = [];
	let backupTag = '';
	let errorMessage = '';
	let prerequisites = { can_update: false, message: '' };

	let statusInterval: ReturnType<typeof setInterval> | null = null;

	const stages = [
		{ key: 'prerequisites', label: 'Verifying prerequisites', weight: 5 },
		{ key: 'fetch', label: 'Fetching updates', weight: 15 },
		{ key: 'backup', label: 'Creating backup', weight: 10 },
		{ key: 'pull', label: 'Downloading updates', weight: 50 },
		{ key: 'dependencies', label: 'Checking dependencies', weight: 15 },
		{ key: 'completed', label: 'Update completed', weight: 5 },
		{ key: 'failed', label: 'Update failed', weight: 0 }
	];

	onMount(async () => {
		if (show) {
			await checkPrerequisites();
		}
	});

	onDestroy(() => {
		stopStatusPolling();
	});

	async function checkPrerequisites() {
		try {
			prerequisites = await checkUpdatePrerequisites(localStorage.token);
		} catch (err) {
			prerequisites = {
				can_update: false,
				message: err.detail || 'Failed to check prerequisites'
			};
		}
	}

	async function startUpdateProcess() {
		if (!prerequisites.can_update) {
			return;
		}

		status = 'updating';
		message = 'Starting update process...';
		progress = 0;
		logs = [];
		errorMessage = '';

		try {
			const result = await startUpdate(localStorage.token);
			if (result.success) {
				startStatusPolling();
			} else {
				status = 'failed';
				message = result.error || 'Failed to start update';
				errorMessage = result.error;
			}
		} catch (err) {
			status = 'failed';
			message = err.detail || 'Failed to start update';
			errorMessage = err.detail || String(err);
		}
	}

	function startStatusPolling() {
		stopStatusPolling();
		statusInterval = setInterval(async () => {
			try {
				const updateStatus = await getUpdateStatus(localStorage.token);
				updateUI(updateStatus);
			} catch (err) {
				console.error('Failed to get update status:', err);
			}
		}, 1000);
	}

	function stopStatusPolling() {
		if (statusInterval) {
			clearInterval(statusInterval);
			statusInterval = null;
		}
	}

	function updateUI(updateStatus: any) {
		if (!updateStatus) return;

		status = updateStatus.in_progress ? 'updating' : 'completed';
		message = updateStatus.message || '';
		logs = updateStatus.logs || [];
		backupTag = updateStatus.backup_tag || '';

		if (updateStatus.stage) {
			const stageIndex = stages.findIndex((s) => s.key === updateStatus.stage);
			if (stageIndex >= 0) {
				// Calculate progress based on completed stages
				let completedWeight = 0;
				for (let i = 0; i < stageIndex; i++) {
					completedWeight += stages[i].weight;
				}
				progress = completedWeight;
			}
		}

		if (updateStatus.error) {
			status = 'failed';
			message = updateStatus.error;
			errorMessage = updateStatus.error;
			stopStatusPolling();
		}

		if (updateStatus.needs_restart) {
			status = 'needs_restart';
			message = 'Update completed. Application restart required.';
			stopStatusPolling();
		}
	}

	async function handleRestart() {
		try {
			await restartApplication(localStorage.token);
			message = 'Restarting application...';
			// Wait a few seconds then reload the page
			setTimeout(() => {
				window.location.reload();
			}, 5000);
		} catch (err) {
			message = 'Failed to restart application. Please restart manually.';
		}
	}

	function getStageLabel(stageKey: string): string {
		const stage = stages.find((s) => s.key === stageKey);
		return stage ? stage.label : stageKey;
	}

	$: if (!show) {
		stopStatusPolling();
	}
</script>

{#if show}
	<Modal size="lg" bind:show className="bg-white dark:bg-gray-900 rounded-xl">
		<div class="p-6">
			<!-- Header -->
			<div class="mb-6">
				<h2 class="text-2xl font-bold text-gray-900 dark:text-white">Update CodingSoft WebUI</h2>
				<p class="text-sm text-gray-500 dark:text-gray-400 mt-1">
					Current: v{currentVersion} → Latest: v{latestVersion}
				</p>
			</div>

			<!-- Prerequisites Warning -->
			{#if status === 'idle' && !prerequisites.can_update}
				<div
					class="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4 mb-4"
				>
					<div class="flex items-start">
						<svg
							class="w-5 h-5 text-yellow-600 dark:text-yellow-400 mt-0.5 mr-2"
							fill="currentColor"
							viewBox="0 0 20 20"
						>
							<path
								fill-rule="evenodd"
								d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
								clip-rule="evenodd"
							/>
						</svg>
						<div>
							<h3 class="font-medium text-yellow-800 dark:text-yellow-200">Cannot Update</h3>
							<p class="text-sm text-yellow-700 dark:text-yellow-300 mt-1">
								{prerequisites.message}
							</p>
						</div>
					</div>
				</div>
			{/if}

			<!-- Progress Section -->
			{#if status === 'updating'}
				<div class="mb-6">
					<div class="flex justify-between items-center mb-2">
						<span class="text-sm font-medium text-gray-700 dark:text-gray-300">{message}</span>
						<span class="text-sm text-gray-500 dark:text-gray-400">{progress}%</span>
					</div>
					<div class="w-full bg-gray-200 dark:bg-gray-700 rounded-full h-2.5">
						<div
							class="bg-blue-600 h-2.5 rounded-full transition-all duration-300"
							style="width: {progress}%"
						></div>
					</div>
				</div>
			{/if}

			<!-- Success Message -->
			{#if status === 'completed' || status === 'needs_restart'}
				<div
					class="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-4 mb-4"
				>
					<div class="flex items-start">
						<svg
							class="w-5 h-5 text-green-600 dark:text-green-400 mt-0.5 mr-2"
							fill="currentColor"
							viewBox="0 0 20 20"
						>
							<path
								fill-rule="evenodd"
								d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
								clip-rule="evenodd"
							/>
						</svg>
						<div>
							<h3 class="font-medium text-green-800 dark:text-green-200">Update Successful</h3>
							<p class="text-sm text-green-700 dark:text-green-300 mt-1">{message}</p>
							{#if backupTag}
								<p class="text-xs text-green-600 dark:text-green-400 mt-1">
									Backup created: {backupTag}
								</p>
							{/if}
						</div>
					</div>
				</div>
			{/if}

			<!-- Error Message -->
			{#if status === 'failed'}
				<div
					class="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4 mb-4"
				>
					<div class="flex items-start">
						<svg
							class="w-5 h-5 text-red-600 dark:text-red-400 mt-0.5 mr-2"
							fill="currentColor"
							viewBox="0 0 20 20"
						>
							<path
								fill-rule="evenodd"
								d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"
								clip-rule="evenodd"
							/>
						</svg>
						<div>
							<h3 class="font-medium text-red-800 dark:text-red-200">Update Failed</h3>
							<p class="text-sm text-red-700 dark:text-red-300 mt-1">{errorMessage}</p>
						</div>
					</div>
				</div>
			{/if}

			<!-- Logs Section -->
			{#if logs.length > 0}
				<div class="mb-6">
					<h3 class="text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">Update Logs</h3>
					<div class="bg-gray-50 dark:bg-gray-800 rounded-lg p-3 max-h-40 overflow-y-auto">
						{#each logs.slice(-10) as log}
							<div class="text-xs font-mono mb-1">
								<span class="text-gray-400">{new Date(log.timestamp).toLocaleTimeString()}</span>
								<span
									class={log.level === 'error'
										? 'text-red-500'
										: log.level === 'warning'
											? 'text-yellow-500'
											: 'text-gray-600 dark:text-gray-400'}
								>
									[{log.level.toUpperCase()}]
								</span>
								<span class="text-gray-700 dark:text-gray-300">{log.message}</span>
							</div>
						{/each}
					</div>
				</div>
			{/if}

			<!-- Action Buttons -->
			<div class="flex justify-end space-x-3">
				{#if status === 'idle'}
					<button
						class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 dark:text-gray-300 dark:bg-gray-700 dark:hover:bg-gray-600 rounded-lg transition"
						on:click={onClose}
					>
						Cancel
					</button>
					{#if prerequisites.can_update}
						<button
							class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-600 dark:hover:bg-blue-700 rounded-lg transition"
							on:click={startUpdateProcess}
						>
							Start Update
						</button>
					{/if}
				{:else if status === 'updating'}
					<button
						class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 dark:text-gray-300 dark:bg-gray-700 dark:hover:bg-gray-600 rounded-lg transition"
						on:click={() => {
							stopStatusPolling();
							status = 'idle';
						}}
						disabled
					>
						Updating...
					</button>
				{:else if status === 'needs_restart'}
					<button
						class="px-4 py-2 text-sm font-medium text-white bg-green-600 hover:bg-green-700 dark:bg-green-600 dark:hover:bg-green-700 rounded-lg transition"
						on:click={handleRestart}
					>
						Restart Now
					</button>
				{:else}
					<button
						class="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200 dark:text-gray-300 dark:bg-gray-700 dark:hover:bg-gray-600 rounded-lg transition"
						on:click={onClose}
					>
						Close
					</button>
					{#if status === 'failed'}
						<button
							class="px-4 py-2 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 dark:bg-blue-600 dark:hover:bg-blue-700 rounded-lg transition"
							on:click={startUpdateProcess}
						>
							Retry Update
						</button>
					{/if}
				{/if}
			</div>
		</div>
	</Modal>
{/if}
