const STORAGE_KEY = 'firstPunch_highScore';

export function getHighScore() {
    try {
        const stored = localStorage.getItem(STORAGE_KEY);
        return stored ? parseInt(stored, 10) || 0 : 0;
    } catch {
        return 0;
    }
}

export function saveHighScore(score) {
    try {
        const current = getHighScore();
        if (score > current) {
            localStorage.setItem(STORAGE_KEY, String(score));
            return true;
        }
        return false;
    } catch {
        return false;
    }
}

export function isNewHighScore(score) {
    return score > getHighScore();
}
