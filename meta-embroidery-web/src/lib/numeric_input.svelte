<script lang="ts">
    export let value = 0;
    export let min: number;
    export let max: number;
    export let name: string;
</script>
<label>
    {name}
	<input type=number {value} {min} {max}>
	<input type=range {value} {min} {max}>
</label>