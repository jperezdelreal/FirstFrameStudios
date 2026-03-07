# Squad Identity — Mission, Vision & Values

> **Author:** Yoda (Game Designer)
> **Date:** 2025
> **Status:** Active — This document governs all squad decisions.

---

## Mission

**We exist to build great games — games that move players, surprise them, and earn their time.**

We are a game development studio. Not a tech demo factory, not a portfolio mill, not a proof-of-concept shop. We make *games* — complete experiences where the player forgets they're holding a controller, tapping a screen, or sitting at a keyboard. We ship playable builds fast, iterate relentlessly, and treat every frame, every interaction, and every sound effect as a chance to delight someone. Our medium is whatever platform the game demands. Our craft is feel. Our obsession is the player's experience.

---

## Vision

**We want to be a studio known for shipping polished, soulful games — across any genre, any platform, and any IP.**

Success looks like this:
- A player starts our game, plays for 30 seconds, and tells a friend about it.
- A fan of the source material recognizes its soul in every mechanic and is surprised by something they didn't expect.
- A genre veteran discovers a depth layer and thinks "wait — this is *quality*."
- A new player picks it up and has fun immediately. A returning player discovers new mastery and keeps coming back.
- Our GDD reads like a love letter to the genre, and our shipped game honors every word of it.

We make games where the IP isn't a skin — it's the soul. Where the genre's identity lives in the mechanics, not just the aesthetics. Where platform constraints aren't excuses — they're design fuel we weaponize.

---

## Values

### 1. Player Feel Is Sacred

Everything we build — architecture, animation, AI, audio — exists to produce a feeling in the player's hands. If the code is elegant but the action feels weak, we failed. If the architecture is messy but the core loop feels *incredible*, we're on the right track. We optimize for the player's nervous system, not our codebase's elegance.

*In SimpsonsKong, this value was forged when we learned that a 0.5x devicePixelRatio made our art look blurry — technically correct rendering that felt wrong to a human eye. The player doesn't see your render pipeline. They see the result.*

### 2. Ship It, Then Perfect It

A playable build in 30 minutes teaches more than a design doc in 30 days. We bias toward action, toward something running on the target platform, toward a build we can interact with. MVP first, polish second, perfection never — because "done" is better than "planned," and "played" is better than "done."

*In SimpsonsKong, this value was forged when our first MVP — rough, procedural, imperfect — taught us more about combat feel in 30 minutes of play than a week of planning would have. We went from zero to playable in under an hour. That velocity is a core competency, not an accident.*

### 3. Research Is Ammunition

We don't guess what works. We study the landmark titles in our genre, analyze their systems, deconstruct their design decisions, and read postmortems before we write a single line of gameplay code. Standing on the shoulders of the games that came before us isn't laziness — it's respect for the craft and the fastest path to quality.

*In SimpsonsKong, this value was forged when genre research across nine beat 'em ups revealed that health-cost specials create the best risk/reward loop the genre has produced — a design we would never have invented from scratch. That single insight reshaped our entire combat system.*

### 4. Every Specialist Owns Their Domain

A sound designer should own the full audio pipeline. A QA lead should own the full testing strategy. An art director should own the full visual identity. When domains blur, quality drops. When one person carries two domains, both suffer. Domain ownership isn't bureaucracy — it's how quality scales.

*In SimpsonsKong, this value was forged when our squad expansion analysis showed one agent carrying 50% of the backlog and another juggling audio + engine. Splitting domains didn't slow us down — it unlocked parallel execution.*

### 5. Bugs Are a Team Failure

When a player hits a bug that breaks their experience, that isn't one person's failure. That's a *squad* failure. Every team member is responsible for the player experience, regardless of whose code introduced the bug. The programmer who writes a state machine that can deadlock, the AI developer who doesn't test edge cases, the QA lead who doesn't catch it, the designer who didn't specify the failure mode — all own the outcome equally.

*In SimpsonsKong, this value was forged when critical bugs (player freeze, passive AI) shipped because no single owner caught them. They were everyone's problem and no one's priority.*
