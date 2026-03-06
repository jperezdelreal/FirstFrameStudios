# Level 1 — Encounter Pacing Curve

> Design document. Wave data changes ship in Phase 5 (content authoring).  
> Author: Tarkin (Enemy/Content Dev)  
> Date: 2026-06-03

---

## Design Goals

- Teach before testing. Every new mechanic or enemy behaviour is introduced in a safe context first.
- Maintain a tension/release rhythm: each combat wave is followed by a brief breather.
- Attack throttling (max 2 simultaneous attackers) keeps pressure readable throughout.

---

## Wave Breakdown

### Wave 1 — Intro (≈20-30 s)

| Parameter | Value |
|---|---|
| Enemy count | 2 basic goons |
| Spawn spread | Wide (250 px apart, both in front of player) |
| AI profile | Slow approach, long attack cooldown (2 s) |
| Purpose | Teach punch, walk, and basic hit feedback |
| Music cue | Upbeat but low intensity |

**Expected player experience:** Walk forward, encounter first goons, learn controls naturally. Low pressure.

**Breather:** Camera scrolls forward after last goon falls. 2–3 second walk with no enemies.

---

### Wave 2 — Escalation (≈30-40 s)

| Parameter | Value |
|---|---|
| Enemy count | 3 basic goons |
| Spawn spread | Medium (two ahead, one behind player) |
| AI profile | Normal approach speed, standard cooldowns (1.5 s) |
| Purpose | Teach spatial awareness (enemy from behind) |
| Music cue | Intensity step-up |

**Expected player experience:** First flanking moment creates urgency. Player learns to turn and manage positioning. Circling behavior becomes visible since 2 attackers max and the third circles.

**Breather:** Short 3-second walk. Optional: place a pickup (health or score) as reward.

---

### Wave 3 — Challenge (≈40-50 s)

| Parameter | Value |
|---|---|
| Enemy count | 4 (3 basic + 1 tough variant) |
| Spawn spread | Tight (camera-locked arena feel) |
| AI profile | Tough variant: faster cooldowns (1.0 s), wider attack range, more aggressive approach |
| Purpose | Test all skills. Throttling keeps it fair but the tough goon demands attention |
| Music cue | Full intensity, boss-adjacent tension |

**Expected player experience:** This is the "prove it" wave. The tough variant stands out visually (red) and mechanically (more HP, faster attacks). Player must prioritize targets while managing space. Circling enemies create visible menace even while waiting their turn.

**Breather:** Level-end celebration / score screen after wave 3 clears.

---

## Pacing Graph (ASCII)

```
Tension
  ▲
  │           ╭──╮        ╭────╮
  │     ╭─╮   │  │   ╭─╮  │    │
  │    ╱  ╰╮ ╱╰──╯  ╱  ╰╮╱    ╰───▶ End
  │   ╱    ╰╱      ╱    ╰╯
  │  ╱              
  │ ╱               
  ├─┴───────┴──────┴─────────────▶ Time
    W1      W2     W3
```

---

## Tuning Notes

- **Time-per-wave** estimates assume player defeats enemies without dying. Add ~10 s per death/retry.
- **Between-wave breather** should be 2–3 seconds of free movement. Enough to breathe, short enough to maintain momentum.
- **Tough variant timing:** Introduce in wave 3 only. Putting it earlier punishes players who haven't learned the controls.
- **Attack throttle (2 max)** is critical. Without it, wave 3 with 4 enemies would feel unfair. With it, the circling creates readable combat theatre.
- Values here are design intent. Ackbar (QA) should playtest and adjust numeric thresholds in Phase 5.
