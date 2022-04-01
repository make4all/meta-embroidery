export interface OptionDefinition {
    width: number,
    height: number,
    cellSize: number,
    type: 'twisty' | 'zigzag',
    rotation: 0 | 90 | 180 | 270,
}