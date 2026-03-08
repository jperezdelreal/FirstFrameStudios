export class Camera {
    constructor() {
        this._x = 0;
        this._locked = false;
        this._lockX = 0;
    }

    get x() {
        return this._x;
    }

    get isLocked() {
        return this._locked;
    }

    lock(x) {
        this._locked = true;
        this._lockX = x;
    }

    unlock() {
        this._locked = false;
    }

    update(playerX, levelWidth, screenWidth) {
        if (this._locked) {
            this._x = this._lockX - screenWidth / 2;
        } else {
            this._x = Math.max(0, Math.min(
                playerX - screenWidth / 2,
                levelWidth - screenWidth
            ));
        }
    }
}
