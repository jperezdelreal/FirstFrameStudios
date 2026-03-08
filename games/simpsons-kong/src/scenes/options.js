export class OptionsScene {
    constructor(game, renderer, input, audio) {
        this.game = game;
        this.renderer = renderer;
        this.input = input;
        this.audio = audio;
        this.selectedIndex = 0;
        this.returnTo = 'title';
        this.blinkTime = 0;

        this.menuItems = [
            { type: 'slider', label: 'Master Volume' },
            { type: 'slider', label: 'SFX Volume' },
            { type: 'slider', label: 'Music Volume' },
            { type: 'select', label: 'Difficulty' },
            { type: 'display', label: 'Controls' },
            { type: 'button', label: 'BACK' }
        ];

        this.difficultyOptions = ['Couch Mode (Easy)', 'Normal', 'Sideshow Bob (Hard)'];
        this.difficultyKeys = ['easy', 'normal', 'hard'];
        this.difficultyIndex = 1;

        this.controls = [
            { keys: 'W A S D / Arrows', action: 'Move' },
            { keys: 'J / Z', action: 'Punch' },
            { keys: 'K / X', action: 'Kick' },
            { keys: 'SPACE', action: 'Jump' },
            { keys: 'DOWN + PUNCH (air)', action: 'Ground Slam' },
            { keys: 'FWD + PUNCH (3+ combo)', action: 'Belly Bump' },
            { keys: 'ESC', action: 'Pause' }
        ];
    }

    onEnter() {
        this.returnTo = this.game._optionsReturn || 'title';
        this.selectedIndex = 0;
        this.blinkTime = 0;

        const diffMap = { easy: 0, normal: 1, hard: 2 };
        this.difficultyIndex = diffMap[this.game.difficulty] || 1;
    }

    onExit() {}

    _roundRect(ctx, x, y, w, h, r) {
        r = Math.min(r, w / 2, h / 2);
        ctx.beginPath();
        ctx.moveTo(x + r, y);
        ctx.lineTo(x + w - r, y);
        ctx.arcTo(x + w, y, x + w, y + r, r);
        ctx.lineTo(x + w, y + h - r);
        ctx.arcTo(x + w, y + h, x + w - r, y + h, r);
        ctx.lineTo(x + r, y + h);
        ctx.arcTo(x, y + h, x, y + h - r, r);
        ctx.lineTo(x, y + r);
        ctx.arcTo(x, y, x + r, y, r);
        ctx.closePath();
    }

    _getSliderValue(index) {
        if (index === 0) return this.audio.getMasterVolume();
        if (index === 1) return this.audio.getSFXVolume();
        if (index === 2) return this.audio.getMusicVolume();
        return 0;
    }

    _setSliderValue(index, v) {
        v = Math.max(0, Math.min(1, v));
        if (index === 0) this.audio.setMasterVolume(v);
        else if (index === 1) this.audio.setSFXVolume(v);
        else if (index === 2) this.audio.setMusicVolume(v);
    }

    update(dt) {
        this.blinkTime += dt;

        // Navigation
        if (this.input.isPressed('ArrowUp') || this.input.isPressed('KeyW')) {
            this.selectedIndex = (this.selectedIndex - 1 + this.menuItems.length) % this.menuItems.length;
            this.audio.playMenuSelect();
        }
        if (this.input.isPressed('ArrowDown') || this.input.isPressed('KeyS')) {
            this.selectedIndex = (this.selectedIndex + 1) % this.menuItems.length;
            this.audio.playMenuSelect();
        }

        const item = this.menuItems[this.selectedIndex];

        // Slider adjustment (hold to change)
        if (item.type === 'slider') {
            if (this.input.isDown('ArrowLeft') || this.input.isDown('KeyA')) {
                this._setSliderValue(this.selectedIndex, this._getSliderValue(this.selectedIndex) - dt * 0.8);
            }
            if (this.input.isDown('ArrowRight') || this.input.isDown('KeyD')) {
                this._setSliderValue(this.selectedIndex, this._getSliderValue(this.selectedIndex) + dt * 0.8);
            }
        }

        // Difficulty select
        if (item.type === 'select') {
            if (this.input.isPressed('ArrowLeft') || this.input.isPressed('KeyA')) {
                this.difficultyIndex = (this.difficultyIndex - 1 + 3) % 3;
                this.game.difficulty = this.difficultyKeys[this.difficultyIndex];
                this.audio.playMenuSelect();
            }
            if (this.input.isPressed('ArrowRight') || this.input.isPressed('KeyD')) {
                this.difficultyIndex = (this.difficultyIndex + 1) % 3;
                this.game.difficulty = this.difficultyKeys[this.difficultyIndex];
                this.audio.playMenuSelect();
            }
        }

        // Back
        if (this.input.isPause() || (this.input.isStart() && item.type === 'button')) {
            this.audio.playMenuConfirm();
            if (this.returnTo === 'gameplay') {
                this.game._resumeScene = true;
            }
            this.game.switchScene(this.returnTo);
        }

        this.input.clearFrameState();
    }

    render() {
        const ctx = this.renderer.ctx;
        const w = this.renderer.width;
        const h = this.renderer.height;

        // Dark background
        const grad = ctx.createLinearGradient(0, 0, 0, h);
        grad.addColorStop(0, '#0d0d2b');
        grad.addColorStop(1, '#1a1a40');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, w, h);

        // Title
        ctx.save();
        ctx.textAlign = 'center';
        ctx.textBaseline = 'middle';
        ctx.font = 'bold 48px "Arial Black", Arial, sans-serif';
        ctx.lineWidth = 6;
        ctx.strokeStyle = '#1a1a1a';
        ctx.lineJoin = 'round';
        ctx.strokeText('OPTIONS', w / 2, 55);
        ctx.fillStyle = '#FED90F';
        ctx.fillText('OPTIONS', w / 2, 55);
        ctx.restore();

        // Main panel
        const panelW = 480;
        const panelH = 420;
        const px = (w - panelW) / 2;
        const py = 90;

        ctx.save();
        this._roundRect(ctx, px, py, panelW, panelH, 14);
        ctx.fillStyle = 'rgba(0, 0, 0, 0.6)';
        ctx.fill();
        ctx.strokeStyle = 'rgba(254, 217, 15, 0.2)';
        ctx.lineWidth = 2;
        ctx.stroke();
        ctx.restore();

        // Render menu items
        let itemY = py + 30;

        for (let i = 0; i < this.menuItems.length; i++) {
            const item = this.menuItems[i];
            const selected = i === this.selectedIndex;
            const rowH = item.type === 'display' ? 140 : 38;

            // Selection highlight
            if (selected) {
                ctx.save();
                this._roundRect(ctx, px + 10, itemY - 4, panelW - 20, rowH + 2, 8);
                ctx.fillStyle = 'rgba(254, 217, 15, 0.12)';
                ctx.fill();
                ctx.strokeStyle = 'rgba(254, 217, 15, 0.4)';
                ctx.lineWidth = 1.5;
                ctx.stroke();
                ctx.restore();
            }

            ctx.save();
            ctx.textBaseline = 'middle';
            const labelColor = selected ? '#FED90F' : '#ccc';
            const labelX = px + 30;
            const midY = itemY + (item.type === 'display' ? 14 : rowH / 2);

            // Label
            ctx.font = 'bold 16px "Arial Black", Arial, sans-serif';
            ctx.fillStyle = labelColor;
            ctx.textAlign = 'left';
            ctx.fillText(item.label, labelX, midY);

            if (item.type === 'slider') {
                const val = this._getSliderValue(i);
                const sliderX = px + 220;
                const sliderW = 180;
                const sliderY = midY;

                // Track background
                this._roundRect(ctx, sliderX, sliderY - 6, sliderW, 12, 6);
                ctx.fillStyle = '#222';
                ctx.fill();

                // Fill
                if (val > 0) {
                    this._roundRect(ctx, sliderX, sliderY - 6, sliderW * val, 12, 6);
                    ctx.fillStyle = selected ? '#FED90F' : '#aa9020';
                    ctx.fill();
                }

                // Track border
                this._roundRect(ctx, sliderX, sliderY - 6, sliderW, 12, 6);
                ctx.strokeStyle = 'rgba(255,255,255,0.2)';
                ctx.lineWidth = 1;
                ctx.stroke();

                // Percentage
                ctx.font = 'bold 14px "Arial Black", Arial, sans-serif';
                ctx.textAlign = 'left';
                ctx.fillStyle = labelColor;
                ctx.fillText(`${Math.round(val * 100)}%`, sliderX + sliderW + 10, midY);

                if (selected) {
                    ctx.font = '12px Arial';
                    ctx.fillStyle = '#888';
                    ctx.textAlign = 'center';
                    ctx.fillText('◄ ►', sliderX + sliderW / 2, midY + 18);
                }
            }

            if (item.type === 'select') {
                const selX = px + 220;
                const label = this.difficultyOptions[this.difficultyIndex];

                ctx.font = 'bold 15px "Arial Black", Arial, sans-serif';
                ctx.textAlign = 'center';
                ctx.fillStyle = selected ? '#FFF' : '#aaa';
                ctx.fillText(`◄  ${label}  ►`, selX + 110, midY);
            }

            if (item.type === 'display') {
                let cy = itemY + 32;
                for (const ctrl of this.controls) {
                    ctx.font = 'bold 13px "Arial Black", Arial, sans-serif';
                    ctx.textAlign = 'left';
                    ctx.fillStyle = '#FED90F';
                    ctx.fillText(ctrl.keys, labelX + 10, cy);

                    ctx.font = '13px Arial';
                    ctx.fillStyle = '#ccc';
                    ctx.textAlign = 'left';
                    ctx.fillText(ctrl.action, px + 280, cy);
                    cy += 17;
                }
            }

            if (item.type === 'button') {
                const pulse = selected ? 0.7 + 0.3 * Math.sin(this.blinkTime * 5) : 1;
                ctx.globalAlpha = pulse;
                ctx.font = 'bold 20px "Arial Black", Arial, sans-serif';
                ctx.textAlign = 'center';
                ctx.fillStyle = selected ? '#FED90F' : '#aaa';
                ctx.fillText('‹ BACK ›', w / 2, midY);
                ctx.globalAlpha = 1;
            }

            ctx.restore();
            itemY += rowH + 6;
        }

        // Footer hint
        ctx.save();
        ctx.textAlign = 'center';
        ctx.textBaseline = 'bottom';
        ctx.font = '13px Arial';
        ctx.fillStyle = 'rgba(255,255,255,0.35)';
        ctx.fillText('↑↓ Navigate  ◄► Adjust  ENTER/ESC Back', w / 2, h - 12);
        ctx.restore();
    }
}
