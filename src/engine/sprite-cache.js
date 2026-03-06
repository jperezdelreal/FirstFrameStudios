// Sprite Cache — pre-renders entities to offscreen canvases for 1-call blitting.
// DPR-aware: offscreen canvases render at full device resolution.

export class SpriteCache {
    constructor() {
        this.cache = new Map(); // key → { canvas, width, height }
    }

    getOrCreate(key, width, height, drawFn) {
        if (this.cache.has(key)) return this.cache.get(key).canvas;

        const dpr = window.devicePixelRatio || 1;
        const offscreen = document.createElement('canvas');
        offscreen.width = width * dpr;
        offscreen.height = height * dpr;
        const ctx = offscreen.getContext('2d');
        ctx.scale(dpr, dpr);

        drawFn(ctx);

        this.cache.set(key, { canvas: offscreen, width, height });
        return offscreen;
    }

    invalidate(key) {
        this.cache.delete(key);
    }

    clear() {
        this.cache.clear();
    }
}

// Global singleton — import this where needed
export const spriteCache = new SpriteCache();
