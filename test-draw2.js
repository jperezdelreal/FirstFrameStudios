// Check if Ghosts will be drawn during high score entry
// From the code: if (this.state === ST_PLAYING || this.state === ST_READY) {

const ST_START = 0, ST_READY = 1, ST_PLAYING = 2, ST_DYING = 3,
    ST_LEVEL_DONE = 4, ST_GAME_OVER = 5, ST_PAUSED = 6, ST_HIGH_SCORE_ENTRY = 7;

const state = ST_HIGH_SCORE_ENTRY;

// This is the condition in the draw function for Ghosts
const willDrawGhosts = (state === ST_PLAYING || state === ST_READY);

console.log('State:', state);
console.log('Will draw Ghosts during high score entry?', willDrawGhosts);
console.log('Expected: false (correct - Ghosts should not be drawn)');
