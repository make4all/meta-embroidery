<script lang="ts">
	import { SVG } from '@svgdotjs/svg.js';
	import { onMount } from 'svelte';

	export let svg;
	export let width: number;
	export let height: number;
	export let cellSize: number;

	let draw;

	const padding = 1;
	const scale = 3;

	let repeat_x = Math.floor(width / cellSize);
	let repeat_y = Math.floor(height / cellSize);

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

		while (x <= end_x && x >= 0 && y <= end_y) {
			if (direction === 'r') {
				x += step_size / 2;
				path_pts.push([x, y]);

				y += step_size;
				path_pts.push([x, y]);

				x += step_size / 2;
				path_pts.push([x, y]);
			} else {
				y += step_size / 2;
				path_pts.push([x, y]);

				x -= step_size;
				path_pts.push([x, y]);

				y += step_size / 2;
				path_pts.push([x, y]);
			}
		}

		svg_element
			.polyline(path_pts)
			.fill('none')
			.stroke({ width: 0.5, color: '#000' })
			.dmove(offset, offset);
	}

	function drawTwisty(svg_element, w, h, cs) {
		const rectSize = 0.5;

		// Draw boxes
		for (let i = 0; i < repeat_y; i++) {
			for (let j = 0; j < repeat_x; j++) {
				const x = j * cs;
				const y = i * cs;

				if (i % 2 === 0) {
					if (j % 2 !== 0) {
						svg_element
							.rect(rectSize * cs, rectSize * cs)
							.move(x, y)
							.rotate(45)
							.opacity(0.5);
					}
				} else {
					if (j % 2 === 0) {
						svg_element
							.rect(rectSize * cs, rectSize * cs)
							.move(x, y)
							.rotate(45)
							.opacity(0.5);
					}
				}
			}
		}

		// Draw diagonal lines
		// loop across top and generate lines going right and left
		for (let i = 0; i < repeat_x; i++) {
			if (i % 2 !== 0) {
				traceDiagonal(
					svg_element,
					(rectSize * cs) / 2,
					i * cs,
					repeat_x * cs,
					0,
					repeat_y * cs,
					cs,
					'r'
				);
				traceDiagonal(
					svg_element,
					(rectSize * cs) / 2,
					i * cs,
					repeat_x * cs,
					0,
					repeat_y * cs,
					cs,
					'l'
				);
			}
		}

		for (let i = 0; i < repeat_y; i++) {
			if (i % 2 !== 0) {
				traceDiagonal(
					svg_element,
					(rectSize * cs) / 2,
					0,
					repeat_x * cs,
					i * cs,
					repeat_y * cs,
					cs,
					'r'
				);
			} else {
				traceDiagonal(
					svg_element,
					(rectSize * cs) / 2,
					repeat_x * cs,
					repeat_x * cs,
					i * cs,
					repeat_y * cs,
					cs,
					'l'
				);
			}
		}
	}

	onMount(() => {
		draw = SVG(svg);

		drawTwisty(draw, width, height, cellSize);
	});

	$: {
		if (draw) {
            draw.clear();
			drawTwisty(draw, width, height, cellSize);
		}
        repeat_x = Math.floor(width / cellSize);
        repeat_y = Math.floor(height / cellSize);
	}
</script>

<svg
	width={(repeat_x + padding * 2) * cellSize * scale}
	height={(repeat_y + padding * 2) * cellSize * scale}
	viewBox="-{padding * cellSize} -{padding * cellSize} {(repeat_x + padding) *
		cellSize} {(repeat_y + padding) * cellSize}"
	bind:this={svg}
/>
