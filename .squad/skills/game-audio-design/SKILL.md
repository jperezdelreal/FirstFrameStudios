# SKILL: Game Audio Design

> Universal sound design principles for ANY game engine, ANY genre. Audio as a core pillar of game design, not an afterthought.

---

## When to Use This Skill

- Building a game of any genre in any engine
- Designing audio that communicates meaning, emotion, and urgency
- Structuring a complete audio system (SFX/music/ambient)
- Creating audio that makes players FEEL the gameplay
- Setting up a scalable sound architecture from day 1

## Prerequisites

- An understanding of your target platform (Web, Mobile, Console, VR)
- Basic familiarity with your engine's audio system (or willingness to learn it)
- A team audio lead or one person owning the audio vision

---

## 1. Audio as Game Design — The 50% Rule

### Why Audio Matters

**Audio is 50% of the player experience.** Research shows:
- Muting a game reduces perceived quality by 40-60%
- Players notice audio gaps faster than they notice visual gaps (ears can't close)
- Sound communicates information that visuals alone cannot convey

**The "Eyes Can Close, Ears Can't" Principle**
> A player can briefly look away from a game, but they're always listening. Audio reaches them *even when they're not looking.* This makes audio a first-class design tool for:
- **Telegraphing**: "Enemy attack incoming" (before the visuals reach the player's gaze)
- **Spatial awareness**: "Something is behind you"
- **Emotional state**: "You should feel tense now" (via ambient music/ambient sound)
- **Feedback loops**: "Your action worked" (when visual feedback alone might be missed in chaos)

### Audio Communicates Four Core Things

1. **Danger/Threat** — Enemy attack incoming, trap triggered, health critical. Often high-pitched, rhythmic, urgent.
2. **Reward/Success** — Pickup collected, combo earned, level completed. Often ascending pitch, major keys, affirming stingers.
3. **State Change** — Menu open, ability charged, transformation triggered. Clear, distinct sounds that mark transitions.
4. **Spatial Location** — Enemy on left, projectile incoming from right, NPC ahead. Uses panning, distance modeling, directional audio.

### Design Rule
**Never ship a game with audio that's "we'll add it later" placeholder.**
- Audio debt is impossible to fix post-launch
- Players judge initial audio quality within 5 seconds
- A game with great audio + average graphics always beats great graphics + average audio

---

## 2. Sound Design Principles

### The Layering Formula

**Base + Detail + Sweetener = Rich, Professional Sound**

Example (Punch SFX):
- **Base**: 150Hz square wave thud (the core impact, 60ms)
- **Detail**: Bandpass-filtered noise crack at 1400Hz (the hit texture, 40ms)
- **Sweetener**: High sine sparkle at 3000Hz (the "zing", 20ms)

Each layer serves a different frequency band, so they don't interfere. Single-layer sounds sound thin; 3+ layers sound designed.

**Why Layering Works**:
- Each layer can be mixed to different loudness
- Each layer can have its own envelope (attack/decay)
- Each layer can be conditionally triggered (e.g., sparkle only on critical hits)
- Multi-band approach doesn't "muddy" the mix like stacking similar sounds

### Variation: Preventing Repetition Fatigue

**Problem**: Play the same sound 10 times exactly, and players unconsciously label it "fake".

**Solution**: Randomize pitch and volume per-play. Ranges:
- **Pitch variation**: ±5-15% of base frequency
  - ±5% = subtle, almost unnoticed
  - ±15% = obvious but still natural (like human variation)
- **Volume variation**: ±10-20%
  - ±10% = barely noticeable
  - ±20% = perceptible but not jarring

**Example** (Punch):
```
Base punch = 150Hz square wave
Play 1: 145Hz at 0.25 gain
Play 2: 160Hz at 0.28 gain
Play 3: 152Hz at 0.22 gain
...feels more organic than 10× identical 150Hz punches
```

**Also vary**:
- Note duration (±10% of expected length)
- Release envelope (short vs. long tail)
- Effects applied (add reverb on some hits, not others)

### Priority System: Not All Sounds Are Equal

**Combat audio hierarchy**:
1. **CRITICAL (Player hands, enemy attacks)**: Never suppress. Kill other sounds if needed.
2. **HIGH (Combat feedback, hit sounds, music stinger)**: Drop other HIGH if queue fills.
3. **NORMAL (Enemy idle, ambient loops)**: Drop first when budget hits.
4. **LOW (UI clicks, ambience tweaks)**: Lowest priority, dropped last in queue.

**In practice**:
- Set a MAX_CONCURRENT limit per priority level
- Punch/kick attacks ALWAYS play (even if it means cutting off idle enemy grunt)
- Enemy footsteps get dropped before menu click
- Music stinger cuts off ambient traffic

### Frequency Management: The No-Clash Rule

**Problem**: Stack a bass thud (60Hz) + kick drum (80Hz) + sub-bass (40Hz) and they interfere, creating frequency masking.

**Solution**: Divide your frequency spectrum into bands:
- **Sub (20-80Hz)**: KO, body thud, impact bass
- **Low (80-200Hz)**: Punch body, kick, rumble
- **Mid (200-2000Hz)**: Crack, impact texture, vocal formant
- **High (2000-7000Hz)**: Sparkle, shimmer, impact zing
- **Very High (7000Hz+)**: Hi-hat, air, brightness

**Rule**: In any given moment, use only ONE sound per band. If two sounds want the same band, layer them with different frequencies or sequence them (one stops, then one plays).

**Example**:
- Player punch (150Hz, mid-low band) + hit echo (1400Hz, mid band) = OK, different bands
- Player punch (150Hz) + enemy punch (155Hz) = BAD, frequency clash, muddy sound
- Player punch (150Hz) + kick drum (80Hz) = OK, different bands

### Silence Is a Sound

**Problem**: Continuous audio = wall of sound = player stops hearing anything.

**Solution**: Use strategic silence as a design element.

**When to go silent**:
- **Before a jump scare** (2 seconds of quiet builds tension)
- **Between combo hits** (100ms silence between punches makes each feel distinct)
- **At level transitions** (fade music to near-silence, then new music enters)
- **During cinematics** (remove ambient, leave only dialogue + music)

**The contrast principle**: Sound is louder relative to silence than relative to loud. A quiet sound after 30s of ambient feels noticeable; the same sound against a wall of noise disappears.

---

## 3. Adaptive Music Systems

Music isn't just background noise. It's a game design tool that responds to player state.

### Horizontal Re-Sequencing

**Concept**: Different sections of music play based on game state.

**Example (Celeste-style)**:
- **Calm section**: Upbeat 8-bar loop while walking
- **Challenge section**: Tense, dissonant 8-bar loop while on moving platform
- **Climax section**: Intense 8-bar loop during final spike gauntlet
- **Victory section**: Triumphant 8-bar loop entering goal area

Each section is a complete, independent composition. The game swaps between them based on player state (health, location, enemies alive, timer).

**Transition rule**: Don't hard-cut between sections. Either:
- Wait for the current section to finish its loop, then start the new one
- Crossfade over 1-2 seconds
- Use a stinger (short bridge phrase) to transition

### Vertical Layering

**Concept**: Add/remove instrument tracks based on game intensity.

**Example (Hades-style)**:
- **Layer 0 (Exploration)**: Bass line only
- **Layer 1 (Enemy Nearby)**: Add drums + bass guitar
- **Layer 2 (Combat)**: Add melody + additional percussion + orchestral stab
- **Layer 3 (Boss)**: Full orchestration

All layers play the same chord progression, same tempo, same structure. Layer switching is instant or crossfaded (75-150ms). The result: music dynamically escalates with player threat level.

**Key insight**: Layers should be additive, not replacements. When you add a layer, you don't remove the old one.

### Stinger System

**Concept**: Short musical phrases triggered by specific events.

**Common stinger types**:
- **Victory stinger** (0.5-1s): 3-note ascending arpeggio when enemy dies
- **Danger stinger** (0.3s): Single dissonant chord when health drops to critical
- **Discovery stinger** (0.5-1s): Magical "ding" when secret found
- **Progression stinger** (1-2s): Celebration chord when level/area cleared

**Design rule**: Stingers are SHORT (under 2 seconds). They stack on top of the background music.

**Stinger architecture**:
- Assign a unique ID to each stinger type
- Use a queue (FIFO) if multiple stingers trigger same frame
- Max 1 stinger playing at a time, unless they're designed to layer
- Auto-stop after expected duration (don't let stingers hang)

### Transition Rules

**Hard cut** (OK for cutscenes, menu changes):
- Stop old music immediately
- Start new music immediately
- Risk: Feels abrupt

**Crossfade** (OK for most gameplay transitions):
- Fade old music to silence over 1-2s
- Start new music at same time (or when old finishes)
- Result: Smooth, professional feel

**Stinger bridge** (Best for combat transitions):
- Keep old music playing
- Insert 0.5-1s stinger
- Fade out old music during/after stinger
- Fade in new music
- Result: Feels earned, cinematic

**Loop-aligned** (Best for adaptive music):
- Wait for current section to finish its loop (8-16 bars)
- Then crossfade or hard-cut to new section
- Result: Respects musical phrasing

### Reference Games

- **Hades**: Vertical layering based on room/combat state. Same musical progression, different density.
- **Celeste**: Horizontal re-sequencing. Each screen has its own music section; climbing a screen transitions to that section's music.
- **Doom 2016**: Combat intensity drives music intensity. Layers add as enemy health decreases. Stings on glory kills.
- **Hollow Knight**: Ambient music responds to area and threat. Exploration = calm, boss arena = building tension.

---

## 4. Spatial Audio

### 2D Spatial (Screen-Based Games)

**Panning based on screen position**:
```
Screen X position (0 to 800) maps to pan (-1 to +1)
pan = (screenX / screenWidth) * 2 - 1   // -1 (left speaker) to +1 (right speaker)
```

**Volume based on distance**:
```
distance = abs(playerX - enemyX)
volume = 1.0 / (1.0 + distance * 0.01)  // Decreases with distance
```

**Example**: Enemy at screen X=100 (left side) plays sound slightly louder in left speaker. Enemy at screen X=700 (far right) plays almost entirely in right speaker.

**Use cases**:
- Gunfire direction in top-down shooter
- Footsteps off-screen in platformer
- Enemy position telegraphing in beat 'em up
- Dialogue coming from specific NPC position

### 3D Spatial (3D Games)

**Positional audio**:
- Source world position → camera position → listener ears (virtual)
- Engine calculates pan + volume + Doppler shift automatically

**HRTF (Head-Related Transfer Function)**:
- Simulates how sound bounces around human head before reaching ears
- Creates illusion of elevation (up/down, not just left/right)
- Requires listener orientation data
- Major browser engines: Web Audio API's `PannerNode`

**Reverb zones**:
- Small room: short reverb (~300ms decay)
- Large hall: long reverb (~3s decay)
- Outdoors: no reverb (distant reflections only)

**Occlusion**:
- Enemy behind wall: attenuate high frequencies (wall blocks high frequencies first)
- Result: Muffled but still audible, sells that wall is blocking sound

### Environmental Audio

**Reverb modeling**:
- Indoor (concrete): Bright, tight reverb
- Outdoor: Natural convolution reverb (distant reflections)
- Cave: Long, booming reverb

**Material-based sounds**:
- Footsteps on carpet (dull, quiet)
- Footsteps on metal (bright, ringing)
- Footsteps on gravel (crunchy, high-frequency)

**Audio zones**:
- Level divided into "zones" (area A = city, area B = forest)
- Each zone has different ambient bed (traffic vs. birds)
- Smooth crossfade when player moves between zones

---

## 5. Sound Categories & Budget

### Core Categories

| Category | Purpose | Priority | Example |
|----------|---------|----------|---------|
| **Player Feedback** | Player actions & consequences | **HIGHEST** | Attack hit, movement, ability charge |
| **Enemy Audio** | Enemy state, telegraphing | **HIGH** | Attack sound, damage, idle chatter |
| **Environmental** | World ambience, interactive props | **NORMAL** | Ambient loops, wind, rain, machinery |
| **UI** | Menu navigation, system feedback | **NORMAL** | Menu click, confirmation, error beep |
| **Music** | Emotional underlay, pacing | **HIGH** | Background, combat, boss, cutscene |

### Typical Sound Counts

- **Indie game** (small scope): 100-300 sounds
- **AA game** (mid scope): 500-2000 sounds
- **AAA game** (large scope): 2000+ sounds

### Budget Breakdown (Indie Example)

Assume 200 sounds total:
- **Player SFX** (30): punch, kick, jump, dash, hurt, death, ability1, ability2, etc.
- **Enemy SFX** (40): attack, hurt, die, idle, aggro, taunt (×4 enemies × 2 variants each)
- **Ambient** (30): loop 1, loop 2, wind, rain, birds, machinery, etc.
- **UI** (15): menu-click, confirm, error, hover, page-turn, etc.
- **Music** (40): exploration loop, combat loop 1/2/3, boss loop 1/2, victory, stinger1/2/3/4, etc.
- **Misc** (15): pickups, interactions, level transitions, etc.

**Rule of thumb**: For every 1 second of player-facing gameplay, budget 1-3 unique sounds.

---

## 6. Audio Implementation Patterns (Engine-Agnostic)

### Event-Driven Architecture

```
Gameplay Event          Audio System           Sound Output
Player attacks    →  Event Bus      →  Audio Queue  →  Punch SFX
Enemy dies        →  Event Bus      →  Audio Queue  →  Victory stinger + death sfx
Pickup collected  →  Event Bus      →  Audio Queue  →  Ding + brief music escalation
```

**Why**:
- Audio system never polls gameplay (decoupled)
- Gameplay never knows about audio (clean separation)
- Easy to test (queue events, verify sounds played)
- Easy to add sounds (hook one event listener)

**Implementation**:
```
// Listen for gameplay events
EventBus.on('player-attack', () => audio.playPunch());
EventBus.on('enemy-death', () => audio.playVictoryStinger());
EventBus.on('pickup', (type) => audio.playPickup(type));
```

### Sound Pools

**Problem**: Creating 50 punch sounds per second causes garbage collection stutter.

**Solution**: Pre-allocate a pool of sound resources, reuse from pool.

```
class SoundPool {
    constructor(baseSound, maxInstances = 5) {
        this.sounds = Array(maxInstances).fill(null).map(() => baseSound.clone());
        this.nextIdx = 0;
    }
    play() {
        const sound = this.sounds[this.nextIdx];
        sound.play();
        this.nextIdx = (this.nextIdx + 1) % this.sounds.length;
    }
}

// Usage
const punchPool = new SoundPool(punchSound, 5);  // 5 concurrent punches max
punchPool.play();
```

**Applies to**:
- Rapid-fire weapons (gunshots)
- Repeated enemies (footsteps, idle grunts)
- Environmental loops (traffic, wind)

### Mix Bus Architecture

```
Master Volume
  ├─ SFX Bus (0.7 default)
  │   ├─ Player sounds (punch, kick, jump)
  │   ├─ Enemy sounds (attack, death)
  │   └─ Ambient SFX (pickups, interactions)
  ├─ Music Bus (0.5 default)
  │   ├─ Background music
  │   ├─ Combat music
  │   └─ Stingers
  ├─ UI Bus (1.0 default)
  │   ├─ Menu clicks
  │   └─ Confirmations
  └─ Ambient Bus (0.08 default)
      ├─ Wind
      ├─ Rain
      └─ Distant traffic
```

**Why**:
- Single volume slider for each category (players control balance)
- Audio engineer can focus each bus independently
- Easy to apply effects (compression, EQ) to category
- Easy to implement ducking (see below)

### Ducking: Auto-Lower Music During SFX

**Problem**: Combat music + hit sounds = war zone, music buried.

**Solution**: When SFX plays, automatically lower music volume.

```
onSFXPlay() {
    musicBus.setVolume(0.3);  // Quiet music for 200ms
    setTimeout(() => musicBus.setVolume(0.5), 200);
}
```

**Common ducking ratios**:
- SFX plays: music → 30-50% of normal volume
- Duration: 100-300ms (long enough to hear SFX clearly)
- Restore gradually (50-100ms fade back up)

**Games that do this well**:
- **Hollow Knight**: Music ducks when you take damage
- **Hades**: Music ducks during attack cues
- **Celeste**: Music ducks during dialogue

### Compression and Limiting

**Problem**: Multiple simultaneous sounds exceed audio device headroom, causing clipping/distortion.

**Solution**: Apply dynamic range compression to Master bus.

**Limiter settings**:
- **Threshold**: -6dB (clipping starts above this level)
- **Ratio**: 4:1 or higher (hard compression)
- **Attack**: 10ms (catch peaks)
- **Release**: 100ms (restore quickly)

**Effect**: When multiple sounds play at once, the limiter automatically ducks them just enough to prevent clipping. Transparent to player (doesn't sound "squashed").

**Applies to**:
- Combo hits where 5+ sounds play simultaneously
- Explosions + impact + music
- Boss attacks with layered SFX

---

## 7. Platform Considerations

### Web (Browser Games)

**AudioContext Lifecycle**:
- Modern browsers suspend AudioContext until user gesture
- Always call `context.resume()` on first click/keydown
- Test in both Chrome and Safari (Safari has different resume behavior)

**Codec Support**:
- MP3: Works everywhere, larger files
- OGG: Smaller, better quality, not Safari
- WAV: Uncompressed, largest, zero decode latency
- AAC: iTunes-friendly, not all browsers

**Strategy**: Use MP3 as primary, OGG as fallback for quality-conscious players.

**Latency**:
- Web Audio API synthesis: 0ms
- Loaded MP3 playback: 20-50ms
- WebAudio processing (reverb, filters): 10-30ms

**Biggest limitation**: Can't rely on surround sound or spatial audio features.

### Mobile (iOS/Android)

**Battery impact**:
- Audio processing CPU cost ~5-15% battery per hour
- Use lower sample rates (22kHz vs 48kHz) for ambient
- Disable effects when battery low

**Speaker limitations**:
- Phone speakers: Tiny, bass-limited, mono
- Test on actual hardware, not dev computer
- Avoid sub-bass (unnecessary and inaudible)
- Use wider stereo field (panning more extreme)

**Interaction restrictions**:
- iOS: Must resume AudioContext on user gesture
- Android: Generally more permissive
- Test playback after app backgrounding

### Console (PS5, Xbox Series X, etc.)

**Surround Sound**:
- Support 5.1 and 7.1 mixing
- Use LFE (0.1 subwoofer) channel for bass/impact
- Monitor mix on surround system during development

**Haptic Audio Integration**:
- Heavy impacts can trigger controller rumble
- Low-frequency elements (sub-bass) map well to haptics
- Creates audio + tactile feedback combo

**Format Strategy**:
- Lossless (WAV, FLAC) during development
- Compress to proprietary format for distribution
- Target 48kHz, 24-bit as standard

### Cross-Platform Format Strategy

| Use Case | Primary | Fallback | Rationale |
|----------|---------|----------|-----------|
| **SFX loops** | OGG (quality) | MP3 (compat) | Loops need quality |
| **Voice/dialogue** | MP3 (compat) | OGG (quality) | Compatibility important |
| **Music** | OGG (quality) | MP3 (compat) | Player experience matters most |
| **Ambience** | OGG (quality) | MP3 (compat) | Long files, quality critical |

---

## 8. Audio for Different Genres

### Action (Shooter, Beat 'em Up, Roguelike)

**Audio priorities**:
1. **Impact sounds are king**: Punch/gunshot/explosion must feel weighty
2. **Combat rhythm drives music**: Music tempo + intensity = combat pacing
3. **Fast feedback loop**: SFX should play within 30ms of action
4. **Layering is essential**: Single-layer combat sounds feel weak

**Signature sounds**:
- Punch: bass thud + crack + sparkle (3-layer minimum)
- Gunshot: bass boom + crack + shell casing ping
- Explosion: sub-bass swell + bright crack + reverb tail
- Sword clash: high metal ring with attack buildup

**Music style**:
- Tempo matches combat intensity (120-180 BPM typical)
- Driving percussion keeps rhythm
- Layers add as threats increase

**Examples**: Doom 2016 (impact-heavy), Hotline Miami (rhythmic violence), Hollow Knight (boss battles are musical climaxes)

### Horror (Survival Horror, Psychological Horror)

**Audio priorities**:
1. **Silence creates tension** (more than sound does)
2. **Subtle ambient dread**: Low-frequency rumble, harmonic dissonance
3. **Jump scares need careful timing**: Audio cue → 0.5-1s → visual scare
4. **Sound becomes weapon**: Player can't see where sound comes from

**Signature sounds**:
- Distant growl (low-frequency, unplaced)
- Heartbeat SFX (elevated player heart rate)
- Creaking/shifting (unseen threats)
- Silence (longest, most effective weapon)

**Music style**:
- Avoid melodies (unsettling)
- Use dissonant drones
- Minimize percussion (rhythm = predictability = safety)
- Sudden silence before jump scare

**Examples**: Amnesia (sound design as primary scare), Resident Evil (strategic audio silence), PT (music cuts out before horror moment)

### Puzzle (Portal, Tetris, Baba Is You)

**Audio priorities**:
1. **Satisfying completion sounds**: Puzzle solved should feel earned
2. **Ambient calm**: Nothing should feel stressful
3. **State clarity**: Each action has distinct audio
4. **Aha! moments get stingers**: Discovery gets musical reward

**Signature sounds**:
- Block/object place: clicking, snapping, satisfying tonality
- Puzzle solve: ascending arpeggio or chime
- Incorrect move: descending or discordant note
- "Aha!" discovery: magical stinger (0.5-1s)

**Music style**:
- Ambient, non-intrusive
- Major keys (hopeful, positive)
- Slow tempo (room for thought)
- Minimal percussion (nothing driving)

**Examples**: Portal (precise SFX feedback), Tetris Effect (satisfying block placement), Baba Is You (gentle ambient + clear feedback tones)

### Platformer (Super Metroid, Celeste, Kirby)

**Audio priorities**:
1. **Movement sounds define character**: Footsteps, jump, land = personality
2. **Music maps to world progression**: Each area has theme
3. **Abilities have signature sounds**: Double-jump sounds different from dash
4. **Obstacles telegraph clearly**: Spikes, hazards must announce themselves

**Signature sounds**:
- Jump: ascending tone (0.08s) or spring-like sweep
- Land: impact thud, slightly different than jump
- Double-jump: higher pitch ascending tone
- Dash/roll: brief whoosh sound
- Spike hit: low-frequency thud + sparkle

**Music style**:
- Tempo matches movement pace
- Each area has memorable melody
- Music escalates with difficulty
- Boss music is musical climax

**Examples**: Celeste (movement + music sync), Super Metroid (area themes), Kirby (pure joy through sound)

### RPG (Final Fantasy, Baldur's Gate, Persona)

**Audio priorities**:
1. **Worldbuilding through ambient**: Town = tavern sounds, dungeon = echoes
2. **Voice acting + music integration**: Dialogue sits on music layer
3. **Menu audio provides feedback**: Don't underestimate UI sounds
4. **Abilities have distinct sonic identity**: Spell effects are audio too

**Signature sounds**:
- Sword slash: bright, snappy
- Magic spell: ethereal, otherworldly
- Critical hit: stinger or special sound
- Dialogue: voice + subtle background music
- Level up: celebratory chime

**Music style**:
- Exploration = ambient, calm
- Combat = driving rhythm + melody
- Boss = epic orchestration
- Town = thematic, cultural musical cues

**Examples**: Final Fantasy VII (music as emotional pillar), Persona 5 (music + UI = personality), Baldur's Gate (ambience sells world)

---

## 9. Testing & QA for Audio

### The Mute Test

**Protocol**:
1. Play the game with audio OFF
2. Is it still clear what's happening?
3. Can you tell if you hit the enemy?
4. Do you know when you've taken damage?

**Failure cases**:
- Hits feel weak because you miss the audio impact
- Enemy attacks aren't telegraphed (no warning sound)
- Health changes are invisible without audio cues

**Fix**: Add visual feedback for audio-dependent cues (screen flash, text popup, particle effect).

### The Audio-Only Test

**Protocol**:
1. Close your eyes (or cover screen)
2. Play for 30 seconds
3. Can you tell what's happening based on sound alone?

**Failure cases**:
- "I have no idea if I'm in combat or exploring"
- "Did I hit or miss?"
- "Is the music telling me anything?"

**Fix**: Ensure audio carries enough information that a blind player could understand gameplay state.

### Volume Normalization

**Protocol**:
1. Record all sounds in the game
2. Set game volume to default (50%)
3. Measure perceived loudness of each sound
4. Adjust to be consistent (no sound dramatically louder/quieter)

**Tool**: A decibel meter app or DAW with metering shows actual loudness. Target:
- Punch/kick: 0dB (reference)
- Hit sound: -3dB (slightly quieter)
- Jump: -6dB (background)
- Menu click: -3dB (not intrusive)
- Music: -6dB (under SFX)

### Headphone vs Speaker Testing

**Reality**: Different listening environments change perception.

**Protocol**:
1. Mix on professional headphones
2. Test on laptop speakers
3. Test on phone speaker
4. Test on home theater

**Expected changes**:
- Bass-heavy sounds (punch) inaudible on phone speaker → compensate with mid-range
- Treble-heavy sounds (sparkle) harsh on laptop → dial back presence
- Spatial audio (panning) lost on mono speaker → redundant with visual feedback

### Accessibility: Audio Cue Alternatives

**Problem**: Deaf or hard-of-hearing players miss audio cues.

**Solutions**:
1. **Visual feedback mirrors audio**: Hit connects → flash + sound together
2. **Subtitles for audio cues**: "Enemy attack incoming" text appears with warning sound
3. **Screen shake for impacts**: Adds tactile feedback (on controllers) alongside audio
4. **HUD notifications**: Stat changes appear on screen + audio

**Modern standard**: Never gate critical information behind audio alone.

---

## 10. Anti-Patterns

### 1. "Sounds Like a Placeholder"

**Problem**: Generic stock sounds destroy immersion.

**Red flags**:
- Punch sound is generic "pew pew" from free sound library
- Music is royalty-free lo-fi beats pack
- Enemy death is canned "creature death" from SoundBible
- Door opening is generic "whoosh"

**Solution**:
- Commission original audio (or learn procedural synthesis)
- Customize audio to match aesthetic (retro, sci-fi, organic)
- Blend 2-3 sources together to feel unique

### 2. "Audio Last"

**Problem**: Treat sound as final 10% polish, applied after game ships.

**Why it fails**:
- Audio decisions affect game feel (combat rhythm, music pacing)
- Late audio changes can't fix design issues
- Audio engineers need lead time (can't bake in audio in day 1)
- Poor audio feels rushed, even if visuals are polished

**Solution**:
- Whiteboard audio with game design, not after design is locked
- Schedule audio work in parallel with other systems
- Prototype sounds early (placeholder is OK, but prototype early)

### 3. "Wall of Sound"

**Problem**: Too many simultaneous sounds = no individual sound stands out = audio mud.

**Example of wall of sound**:
- 5 enemies attacking simultaneously
- All nearby, all different pitches, all full volume
- Player can't tell what happened
- Sounds like "white noise" rather than distinct impacts

**Solution**:
- Priority system (only X sounds per type can play)
- Frequency separation (don't stack similar pitches)
- Ducking (music ducks so SFX clear)
- Panning (spread sounds across stereo field)

### 4. "One Loop"

**Problem**: Single ambient track on repeat for entire level.

**Why it fails**:
- Player recognizes loop ~30 seconds in
- Loop becomes background annoyance (tuned out)
- 5+ minutes of gameplay with same 30s loop = perceived unprofessionalism

**Solution**:
- **Multiple variants**: 3-4 loop variations, randomize order
- **Transitions**: Add 10-15s of variation between loop repeats
- **Layering system**: Intensity levels add/remove layers to existing loop
- **Duration**: Aim for 45-90s per loop to delay listener recognition

### 5. No Feedback Loop

**Problem**: Game mechanics not connected to audio system.

**Example**:
- Combo counter increases but music doesn't respond
- Player takes damage but no audio indication (except visual)
- Ability charged but no sonic "ready" cue
- State changes happen silently

**Solution**: For every game state change, ask "what sound represents this?" Connect every meaningful game state to audio.

### 6. "Set and Forget" Mixing

**Problem**: Mix sounds once and never adjust.

**Reality**: As gameplay evolves, audio balance breaks.

**Example**:
- Mix punch to sound great against 1 enemy
- Add 4-enemy fight → punch buried under other sounds
- Add music → punch even more buried
- Game feels wrong, audio engineer blames "bad game design"

**Solution**: Iterate mixing as game systems add. Re-test every significant change.

### 7. Ignoring Frequency Space

**Problem**: Stacking similar frequencies creates masking (one sound hides another).

**Example**:
- Enemy grunt (200Hz, low) + punch impact (200Hz, low) = single thud instead of distinct sounds
- Player can't tell punch hit because grunt masks it

**Solution**: Use frequency analyzer or mix on good speakers. Separate sounds into non-overlapping frequency bands.

---

## Quick Reference: Genre Audio Checklist

### Before Starting a New Game, Complete This Checklist

**Audio Vision**:
- [ ] Define audio genre (orchestral, chiptune, electronic, etc.)
- [ ] List 3 reference games for audio inspiration
- [ ] Identify core theme (what emotion should audio convey?)

**Sound Categories**:
- [ ] Player feedback sounds defined (attack, movement, ability)
- [ ] Enemy audio plan (attack, damage, idle, death)
- [ ] Music structure planned (exploration, combat, boss)
- [ ] Ambient audio decided (loops, tone, intensity)

**System Design**:
- [ ] Audio bus architecture sketched (Master → SFX/Music/UI/Ambient)
- [ ] Event system designed (how does gameplay trigger audio?)
- [ ] Prioritization rules defined (what plays when budget full?)
- [ ] Spatial audio approach chosen (panning? reverb zones?)

**Testing Plan**:
- [ ] Mute test scheduled (can game be played silent?)
- [ ] Audio-only test scheduled (can player understand via sound?)
- [ ] Multi-platform testing planned (headphone, speaker, mobile?)
- [ ] Accessibility pass planned (audio cues have visual backup?)

**Post-Launch**:
- [ ] Audio debug/tuning tools ready (volume sliders, mute toggles)
- [ ] Mixed on multiple devices (phone, laptop, good speakers)
- [ ] Sound count tracked (budget not exceeded)
- [ ] Audio debt documented (known issues logged, not hidden)

---

## Key Takeaways

1. **Audio is 50% of player experience.** Treat it as a core pillar, not polish.
2. **Layering > single sounds.** Base + detail + sweetener = professional.
3. **Variation prevents fatigue.** ±5-15% pitch variation on every sound.
4. **Adaptive music responds to game state.** Not background noise, but a game design tool.
5. **Silence is powerful.** Strategic quiet is louder than constant sound.
6. **Frequency separation prevents mud.** Don't stack similar frequencies.
7. **Test on actual devices.** Mute test, audio-only test, multi-platform.
8. **Prioritization system is essential.** Not all sounds are equal; combat > ambient.
9. **Event-driven architecture scales.** Decouple audio from gameplay logic.
10. **Audio debt is real.** Poor audio can't be fixed post-launch. Get it right from day 1.

---

*Skill authored by Greedo (Sound Designer, First Frame Studios). Confidence: **medium**.*
*Draws from procedural-audio implementation (Web Audio API patterns), game-feel-juice (audio-visual sync), and cross-genre audio research.*
*Cross-references: .squad/skills/procedural-audio (implementation), .squad/skills/game-feel-juice (feel tuning).*
