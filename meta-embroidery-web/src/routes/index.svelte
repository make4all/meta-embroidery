<script lang="ts">
	import Pattern from './pattern.svelte';
	import save from '$lib/save-svg';
    import type { OptionDefinition } from '$lib/utils';

	let svg;

    let options: OptionDefinition = {
        width: 150,
        height: 300,
        cellSize: 10,
        type: 'twisty',
        rotation: 0,
    };
</script>

<Pattern {options} bind:svg />
<br />
<button on:click={(ev) => save(svg)}>Save</button>
