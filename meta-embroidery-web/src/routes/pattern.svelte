<script lang="ts">
	import { SVG } from '@svgdotjs/svg.js';
	import { onMount } from 'svelte';
	import type { OptionDefinition } from '$lib/utils';

	export let options: OptionDefinition;
	export let svg;

	let draw;

	const padding = 1;
	const scale = 3;

	const repeat_x = Math.floor(options.width / options.cellSize);
	const repeat_y = Math.floor(options.height / options.cellSize);

	const diagonal_step_size = Math.sqrt(2) * options.cellSize;
	const rectSize = 0.5;

	function traceDiagonal(
		svg_element,
		offset: number,
		start_x: number,
		end_x: number,
		start_y: number,
		end_y: number,
		step_size: number,
		direction: 'r' | 'l'
	) {
		let x = start_x;
		let y = start_y;

		let path_pts = [[x, y]];

		if (direction === 'r') {
			while (x <= end_x && x >= start_x && y <= end_y && y >= start_y) {
				y += step_size / 2;
				path_pts.push([x, y]);

				x += step_size * direction;
				path_pts.push([x, y]);

				y += step_size / 2;
				path_pts.push([x, y]);

				console.log(
					'x: ' + x + ' start_x: ' + start_x + ' end_x: ' + end_x,
					x < end_x && x > start_x
				);
				console.log(
					'y: ' + y + ' start_y: ' + start_y + ' end_y: ' + end_y,
					y < end_y && y > start_y
				);
			}
		}

		svg_element
			.polyline(path_pts)
			.fill('none')
			.stroke({ width: 0.5, color: '#000' })
			.dmove(offset, offset);
	}

	onMount(() => {
		draw = SVG(svg);

		// Draw boxes
		for (let i = 0; i < repeat_y; i++) {
			for (let j = 0; j < repeat_x; j++) {
				const x = j * options.cellSize;
				const y = i * options.cellSize;

				if (i % 2 === 0) {
					if (j % 2 !== 0) {
						draw
							.rect(rectSize * options.cellSize, rectSize * options.cellSize)
							.move(x, y)
							.rotate(45)
							.opacity(0.5);
					}
				} else {
					if (j % 2 === 0) {
						draw
							.rect(rectSize * options.cellSize, rectSize * options.cellSize)
							.move(x, y)
							.rotate(45)
							.opacity(0.5);
					}
				}
			}
		}

		// Draw diagonal lines
		for (let i = 0; i < repeat_x; i++) {
			if (i % 2 !== 0) {
				traceDiagonal(
					draw,
					(rectSize * options.cellSize) / 2,
					i * options.cellSize,
					repeat_x * options.cellSize,
					0,
					repeat_y * options.cellSize,
					options.cellSize,
					1
				);
				traceDiagonal(
					draw,
					(rectSize * options.cellSize) / 2,
					i * options.cellSize,
					repeat_x * options.cellSize,
					0,
					repeat_y * options.cellSize,
					options.cellSize,
					-1
				);
			}
		}
	});
</script>

<svg
	width={(repeat_x + padding * 2) * options.cellSize * scale}
	height={(repeat_y + padding * 2) * options.cellSize * scale}
	viewBox="-{padding * options.cellSize} -{padding * options.cellSize} {(repeat_x + padding) *
		options.cellSize} {(repeat_y + padding) * options.cellSize}"
	bind:this={svg}
/>
