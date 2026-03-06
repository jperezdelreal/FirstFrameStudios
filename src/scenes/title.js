import { getHighScore } from '../ui/highscore.js';

export class TitleScene {
    constructor(game, renderer, input) {
        this.game = game;
        this.renderer = renderer;
        this.input = input;
        this.blinkTime = 0;
    }

    onEnter() {
        this.blinkTime = 0;
    }

    onExit() {
    }

    update(dt) {
        this.blinkTime += dt;
        
        if (this.input.isStart()) {
            this.game.switchScene('gameplay');
        }
        
        this.input.clearFrameState();
    }

    render() {
        const ctx = this.renderer.ctx;
        
        // Background
        ctx.fillStyle = '#87CEEB';
        ctx.fillRect(0, 0, this.renderer.width, this.renderer.height);
        
        // Title
        this.renderer.strokeText(
            'SIMPSONS KONG',
            this.renderer.width / 2,
            250,
            '#FED90F',
            '#333333',
            'bold 72px Arial',
            6
        );
        
        // Subtitle
        this.renderer.fillTextCentered(
            'BEAT \'EM UP',
            this.renderer.width / 2,
            320,
            '#FFFFFF',
            'bold 32px Arial'
        );
        
        // Blinking start text
        if (Math.floor(this.blinkTime * 2) % 2 === 0) {
            this.renderer.fillTextCentered(
                'Press ENTER to Start',
                this.renderer.width / 2,
                450,
                '#FFFFFF',
                '28px Arial'
            );
        }
        
        // Controls
        ctx.fillStyle = '#FFFFFF';
        ctx.font = '18px Arial';
        ctx.textAlign = 'center';
        ctx.fillText('WASD / Arrow Keys - Move', this.renderer.width / 2, 530);
        ctx.fillText('J / Z - Punch    K / X - Kick    Space - Jump', this.renderer.width / 2, 560);
        
        // High score
        const highScore = getHighScore();
        if (highScore > 0) {
            ctx.fillStyle = '#FED90F';
            ctx.font = 'bold 22px Arial';
            ctx.fillText(`HIGH SCORE: ${highScore}`, this.renderer.width / 2, 610);
        }
    }
}
