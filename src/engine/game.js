export class Game {
    constructor(canvas) {
        this.canvas = canvas;
        this.scenes = new Map();
        this.currentScene = null;
        this.lastTime = 0;
        this.accumulator = 0;
        this.fixedDelta = 1 / 60;
        this.running = false;
        this.hitlagFrames = 0;
    }

    addHitlag(frames) {
        this.hitlagFrames = Math.max(this.hitlagFrames, frames);
    }

    registerScene(name, scene) {
        this.scenes.set(name, scene);
    }

    switchScene(name) {
        if (this.currentScene && this.currentScene.onExit) {
            this.currentScene.onExit();
        }
        
        this.currentScene = this.scenes.get(name);
        
        if (this.currentScene && this.currentScene.onEnter) {
            this.currentScene.onEnter();
        }
    }

    start() {
        this.running = true;
        this.lastTime = performance.now();
        this.loop();
    }

    loop = () => {
        if (!this.running) return;

        const currentTime = performance.now();
        let frameTime = (currentTime - this.lastTime) / 1000;
        this.lastTime = currentTime;

        // Cap frame time to avoid spiral of death
        if (frameTime > 0.25) frameTime = 0.25;

        this.accumulator += frameTime;

        // Fixed timestep updates
        while (this.accumulator >= this.fixedDelta) {
            if (this.hitlagFrames > 0) {
                this.hitlagFrames--;
                // During hitlag, only update visual effects (e.g. screen shake)
                if (this.currentScene && this.currentScene.updateDuringHitlag) {
                    this.currentScene.updateDuringHitlag(this.fixedDelta);
                }
            } else if (this.currentScene && this.currentScene.update) {
                this.currentScene.update(this.fixedDelta);
            }
            this.accumulator -= this.fixedDelta;
        }

        // Render
        if (this.currentScene && this.currentScene.render) {
            this.currentScene.render();
        }

        requestAnimationFrame(this.loop);
    };

    stop() {
        this.running = false;
    }
}
