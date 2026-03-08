import { Game } from './engine/game.js';
import { Renderer } from './engine/renderer.js';
import { Input } from './engine/input.js';
import { Audio } from './engine/audio.js';
import { TitleScene } from './scenes/title.js';
import { GameplayScene } from './scenes/gameplay.js';
import { OptionsScene } from './scenes/options.js';

// Initialize game
const canvas = document.getElementById('gameCanvas');
const game = new Game(canvas);
const renderer = new Renderer(canvas);
const input = new Input();
const audio = new Audio();

// Register scenes
const titleScene = new TitleScene(game, renderer, input, audio);
const gameplayScene = new GameplayScene(game, renderer, input, audio);
const optionsScene = new OptionsScene(game, renderer, input, audio);

game.registerScene('title', titleScene);
game.registerScene('gameplay', gameplayScene);
game.registerScene('options', optionsScene);

// Resume audio context on first user interaction
const resumeAudio = () => {
    audio.resume();
    window.removeEventListener('keydown', resumeAudio);
    window.removeEventListener('click', resumeAudio);
};
window.addEventListener('keydown', resumeAudio);
window.addEventListener('click', resumeAudio);

// Start with title scene
game.switchScene('title');
game.start();
