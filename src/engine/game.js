export class Game {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.scenes = new Map();
        this.currentScene = null;
        this.lastTime = 0;
        this.accumulator = 0;
        this.fixedDelta = 1 / 60;
        this.running = false;
        this.hitlagFrames = 0;
        this.difficulty = 'normal';

        // AAA-V1: Screen zoom state
        this.zoomLevel = 1.0;
        this.zoomTarget = 1.0;
        this.zoomSpeed = 10;
        this.zoomTimer = 0;

        // AAA-V2: Slow-motion time scale
        this.timeScale = 1.0;
        this.timeScaleTimer = 0;

        // Screen transition state
        this.transitioning = false;
        this.transitionAlpha = 0;
        this.transitionTarget = null;
        this.transitionPhase = null; // 'fade-out' | 'fade-in'
        this.transitionDuration = 0.3;
    }

    addHitlag(frames) {
        this.hitlagFrames = Math.max(this.hitlagFrames, frames);
    }

    triggerZoom(level, duration) {
        this.zoomLevel = level;
        this.zoomTarget = 1.0;
        this.zoomTimer = duration;
    }

    triggerSlowMo(scale, duration) {
        this.timeScale = scale;
        this.timeScaleTimer = duration;
    }

    _updateZoom(dt) {
        if (this.zoomTimer > 0) {
            this.zoomTimer -= dt;
            if (this.zoomTimer <= 0) {
                this.zoomTimer = 0;
            }
        }
        if (this.zoomLevel !== this.zoomTarget) {
            this.zoomLevel += (this.zoomTarget - this.zoomLevel) * this.zoomSpeed * dt;
            if (Math.abs(this.zoomLevel - this.zoomTarget) < 0.001) {
                this.zoomLevel = this.zoomTarget;
            }
        }
    }

    _updateTimeScale(dt) {
        if (this.timeScaleTimer > 0) {
            this.timeScaleTimer -= dt;
            if (this.timeScaleTimer <= 0) {
                this.timeScale = 1.0;
                this.timeScaleTimer = 0;
            }
        }
    }

    registerScene(name, scene) {
        this.scenes.set(name, scene);
    }

    switchScene(name) {
        if (this.transitioning) return;

        if (!this.currentScene) {
            // No current scene — switch immediately (first scene load)
            this.currentScene = this.scenes.get(name);
            if (this.currentScene && this.currentScene.onEnter) {
                this.currentScene.onEnter();
            }
            return;
        }

        // Start fade-out transition
        this.transitioning = true;
        this.transitionTarget = name;
        this.transitionPhase = 'fade-out';
        this.transitionAlpha = 0;
    }

    _updateTransition(dt) {
        const speed = 1 / this.transitionDuration;

        if (this.transitionPhase === 'fade-out') {
            this.transitionAlpha += speed * dt;
            if (this.transitionAlpha >= 1) {
                this.transitionAlpha = 1;
                // Fully black — perform the actual scene switch
                if (this.currentScene && this.currentScene.onExit) {
                    this.currentScene.onExit();
                }
                this.currentScene = this.scenes.get(this.transitionTarget);
                if (this.currentScene && this.currentScene.onEnter) {
                    this.currentScene.onEnter();
                }
                this.transitionPhase = 'fade-in';
            }
        } else if (this.transitionPhase === 'fade-in') {
            this.transitionAlpha -= speed * dt;
            if (this.transitionAlpha <= 0) {
                this.transitionAlpha = 0;
                this.transitioning = false;
                this.transitionPhase = null;
                this.transitionTarget = null;
            }
        }
    }

    _renderTransition() {
        if (this.transitionAlpha <= 0) return;
        this.ctx.save();
        this.ctx.globalAlpha = this.transitionAlpha;
        this.ctx.fillStyle = '#000';
        this.ctx.fillRect(0, 0, this.canvas.logicalWidth || 1280, this.canvas.logicalHeight || 720);
        this.ctx.restore();
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
            // Update zoom + time scale with real dt (unaffected by slow-mo)
            this._updateZoom(this.fixedDelta);
            this._updateTimeScale(this.fixedDelta);

            const scaledDt = this.fixedDelta * this.timeScale;

            if (this.transitioning) {
                this._updateTransition(this.fixedDelta);
            } else if (this.hitlagFrames > 0) {
                this.hitlagFrames--;
                if (this.currentScene && this.currentScene.updateDuringHitlag) {
                    this.currentScene.updateDuringHitlag(this.fixedDelta);
                }
            } else if (this.currentScene && this.currentScene.update) {
                this.currentScene.update(scaledDt);
            }
            this.accumulator -= this.fixedDelta;
        }

        // Push zoom level to scene's renderer
        if (this.currentScene && this.currentScene.renderer) {
            this.currentScene.renderer.zoomLevel = this.zoomLevel;
        }

        // Render
        if (this.currentScene && this.currentScene.render) {
            this.currentScene.render();
        }
        // Transition overlay renders on top of everything
        if (this.transitioning) {
            this._renderTransition();
        }

        requestAnimationFrame(this.loop);
    };

    stop() {
        this.running = false;
    }
}
