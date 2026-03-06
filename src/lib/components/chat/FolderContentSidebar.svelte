<script lang="ts">
	import { getContext } from 'svelte';
	import { slide } from 'svelte/transition';
	import { showFolderContentSidebar } from '$lib/stores';
	import { WEBUI_API_BASE_URL } from '$lib/constants';
	import XMark from '$lib/components/icons/XMark.svelte';
	import Document from '$lib/components/icons/Document.svelte';
	import Folder from '$lib/components/icons/Folder.svelte';
	import Tooltip from '$lib/components/common/Tooltip.svelte';

	const i18n = getContext('i18n');

	export let folder: { name: string; data?: { files?: any[] } } | null = null;

	$: files = folder?.data?.files ?? [];
	$: images = files.filter(
		(f) =>
			f.type === 'file' &&
			(f?.content_type?.startsWith('image/') || f?.file?.content_type?.startsWith('image/'))
	);
	$: otherFiles = files.filter(
		(f) =>
			f.type !== 'file' ||
			!(f?.content_type?.startsWith('image/') || f?.file?.content_type?.startsWith('image/'))
	);

	function fileContentUrl(item: any): string {
		const id = item.id ?? item.url ?? item.file?.id;
		if (!id) return '';
		return `${WEBUI_API_BASE_URL}/files/${id}/content`;
	}

	function fileName(item: any): string {
		return item.name ?? item.file?.name ?? item.title ?? item.id ?? 'File';
	}

	function close() {
		showFolderContentSidebar.set(false);
	}
</script>

{#if folder && $showFolderContentSidebar}
	<div
		class="fixed inset-0 z-40 md:z-30"
		role="presentation"
		on:click={close}
		on:keydown={(e) => e.key === 'Escape' && close()}
	>
		<div
			class="absolute inset-y-0 right-0 w-full max-w-sm bg-white dark:bg-gray-900 border-l border-gray-200 dark:border-gray-800 shadow-xl flex flex-col"
			in:slide={{ axis: 'x', duration: 200 }}
			out:slide={{ axis: 'x', duration: 150 }}
			on:click|stopPropagation
			on:keydown|stopPropagation
		>
			<div class="flex items-center justify-between px-4 py-3 border-b border-gray-100 dark:border-gray-800">
				<h2 class="text-sm font-medium text-gray-800 dark:text-gray-200 truncate">
					{$i18n.t('Folder content')}: {folder.name}
				</h2>
				<Tooltip content={$i18n.t('Close')}>
					<button
						class="p-1.5 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition"
						on:click={close}
						aria-label={$i18n.t('Close')}
					>
						<XMark className="size-5" strokeWidth="2" />
					</button>
				</Tooltip>
			</div>

			<div class="flex-1 overflow-y-auto p-3 space-y-4">
				{#if files.length === 0}
					<p class="text-sm text-gray-500 dark:text-gray-400">
						{$i18n.t('No files or knowledge attached to this folder.')}
					</p>
				{:else}
					{#if images.length > 0}
						<div>
							<h3 class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-2">
								{$i18n.t('Images')}
							</h3>
							<div class="grid grid-cols-2 gap-2">
								{#each images as item (item.id ?? item.url)}
									<a
										href={fileContentUrl(item)}
										target="_blank"
										rel="noopener noreferrer"
										class="block rounded-lg overflow-hidden bg-gray-100 dark:bg-gray-800 aspect-square focus:ring-2 focus:ring-offset-2 focus:ring-gray-400"
									>
										<img
											src={fileContentUrl(item)}
											alt={fileName(item)}
											class="w-full h-full object-cover"
											loading="lazy"
										/>
									</a>
								{/each}
							</div>
						</div>
					{/if}

					{#if otherFiles.length > 0}
						<div>
							<h3 class="text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wide mb-2">
								{$i18n.t('Files & knowledge')}
							</h3>
							<ul class="space-y-1">
								{#each otherFiles as item (item.id ?? item.url ?? item.name)}
									<li>
										<a
											href={item.type === 'file' ? fileContentUrl(item) : '#'}
											target={item.type === 'file' ? '_blank' : undefined}
											rel={item.type === 'file' ? 'noopener noreferrer' : undefined}
											class="flex items-center gap-2 px-2 py-1.5 rounded-lg hover:bg-gray-100 dark:hover:bg-gray-800 transition text-sm text-gray-700 dark:text-gray-300 truncate"
										>
											{#if item.type === 'collection'}
												<Folder className="size-4 shrink-0 text-amber-500" strokeWidth="2" />
											{:else}
												<Document className="size-4 shrink-0 text-gray-500" strokeWidth="2" />
											{/if}
											<span class="truncate">{fileName(item)}</span>
										</a>
									</li>
								{/each}
							</ul>
						</div>
					{/if}
				{/if}
			</div>
		</div>
	</div>
{/if}
