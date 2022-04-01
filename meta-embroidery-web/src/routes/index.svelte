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
        rotation: 0,
    };
    
    let widthInput = 150;
    let heightInput = 300;
    let cellSizeInput = 10;

    $: {
        options.width = widthInput;
        options.height = heightInput;
        options.cellSize = cellSizeInput;
    }
</script>

<NumericInput bind:value={widthInput} min={0} max={500} name={"Width"}/> <br>
<NumericInput bind:value={heightInput} min={0} max={500} name={"Height"}/> <br>
<NumericInput bind:value={cellSizeInput} min={1} max={20} name={"Cell Size"}/> <br>
<Pattern {options} bind:svg />
<br />
<button on:click={(ev) => save(svg)}>Save</button>
