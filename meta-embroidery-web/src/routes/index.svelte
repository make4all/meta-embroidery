<script lang="ts">
	import Pattern from './pattern.svelte';
	import NumericInput from '$lib/numeric_input.svelte';
	import save from '$lib/save-svg';
	import type { OptionDefinition } from '$lib/utils';

	let svg;

	let options: OptionDefinition = {
		width: 150,
		height: 300,
		cellSize: 10,
		type: 'twisty',
		rotation: 0
	};

	let width = 150;
	let height = 300;
	let cellSize = 10;
</script>

<NumericInput bind:value={width} min={0} max={500} name={'Width'} /> <br />
<NumericInput bind:value={height} min={0} max={500} name={'Height'} /> <br />
<NumericInput bind:value={cellSize} min={1} max={20} name={'Cell Size'} /> <br />
<Pattern {width} {height} {cellSize} bind:svg />
<br />
<button on:click={(ev) => save(svg)}>Save</button>
