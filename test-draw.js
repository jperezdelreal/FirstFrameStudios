// Check if Homer will be drawn during high score entry
// From the code: } else if (this.state !== ST_GAME_OVER && this.state !== ST_START) {

const ST_START = 0, ST_READY = 1, ST_PLAYING = 2, ST_DYING = 3,
    ST_LEVEL_DONE = 4, ST_GAME_OVER = 5, ST_PAUSED = 6, ST_HIGH_SCORE_ENTRY = 7;

const state = ST_HIGH_SCORE_ENTRY;

// This is the condition in the draw function for Homer
const willDrawHomer = (state !== ST_GAME_OVER && state !== ST_START);

console.log('State:', state);
console.log('Will draw Homer during high score entry?', willDrawHomer);
console.log('Expected: false (Homer should not be drawn during high score entry)');
