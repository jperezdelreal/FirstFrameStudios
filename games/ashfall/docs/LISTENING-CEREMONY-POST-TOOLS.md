# 🎧 Ashfall — Post-Tools Listening Ceremony

**Facilitator:** Mace (Sprint Lead)  
**Date:** 2026-03-15  
**Context:** "Los trabajadores deben tener a su disposición lo mejor. Quiero que el equipo escuche las frustraciones e ideas de sus compañeros y que se acuerden las issues a trabajar por el bien común." — Joaquín

---

## Executive Summary

**Status:** 13 tools are now SHIPPED and merged to main. Sprint A is complete.

The team has new capabilities:
- ✅ Branch validation CI prevents dead branches
- ✅ Autoload dependency analyzer catches ordering issues
- ✅ Signal wiring validator finds orphaned connections
- ✅ Scene integrity checker validates references
- ✅ Godot headless validator runs in CI
- ✅ Integration gate automation enforces end-to-end checks
- ✅ Test scene generator creates developer test beds
- ✅ VFX/Audio test bench enables real-time tuning
- ✅ GDD diff reporter catches spec deviations
- ✅ Collision layer matrix auto-generates docs
- ✅ Frame data CSV pipeline for designer balance tuning
- ✅ Live reload watcher for faster iteration
- ✅ PR body validator ensures issue linking

**This ceremony is different from the retro.** The retro looked back at M1+M2 pain. This ceremony looks FORWARD — now that we have tools, what do agents NEED next?

---

## Part 1: What Does Each Agent Need Now?

### 1. CHEWIE — Engine Developer

**What's still frustrating?**  
The state machine is solid and test scenes exist, but **physics tuning feels disconnected**. Knockback curves, gravity scaling during jumps, and ground friction all need feel-based tuning with instant feedback. Reading `CharacterBody2D.velocity` in the debugger doesn't tell me if the jump arc *feels* right.

**What idea do they have?**  
**Physics tuning workbench** — A test scene with sliders for gravity, jump velocity, friction, and knockback scaling. Press buttons to trigger different physics scenarios (normal jump, hit reaction, juggle state) and see the arc visualized with a trail renderer. Export tuned values back to constants.

**What would make M3 better for them?**  
- Physics feel-testing tools so jump arcs and knockback don't require full game running
- State machine stress test (rapid transitions, edge case coverage)
- Documentation on which physics values are "designer-tunable" vs "engine constants"

---

### 2. LANDO — Gameplay Developer

**What's still frustrating?**  
The input buffer is production-grade and test scenes work, but **medium buttons are still missing**. The GDD spec calls for 6 buttons (LP/MP/HP/LK/MK/HK) but we're still shipping 4-button movesets. This was flagged in M1, acknowledged in M2, and still not resolved. It's becoming technical debt.

**What idea do they have?**  
**Complete the 6-button spec** — Add medium_punch and medium_kick to `project.godot` input map, create medium attack movedata for Kael and Rhena, and update combo routes to use the full button layout. This unblocks proper moveset design.

**What would make M3 better for them?**  
- Medium buttons implemented so movesets align with GDD
- Training mode with frame data overlay (helps validate timing windows)
- Motion input visualization tool (debug QCF/DP detection accuracy)

---

### 3. SOLO — Integration Gatekeeper

**What's still frustrating?**  
The integration gate exists now, but **running it is still manual**. Someone has to remember to execute `python tools/integration-gate.py` after merge waves. It's documented but not enforced. We need it to run automatically post-merge, not on-demand.

**What idea do they have?**  
**Post-merge GitHub Action** — Trigger integration gate automatically after 2+ PRs merge to main within a 2-hour window. Post results to a #integration Slack channel or GitHub Discussion. If gate fails, auto-create a priority-0 issue with failure details.

**What would make M3 better for them?**  
- Integration gate runs automatically without human trigger
- Clear ownership: who fixes integration failures when they're detected?
- Architecture decision log (ADR) system for tracking key design choices

---

### 4. TARKIN — AI / Content Designer

**What's still frustrating?**  
Branch validation CI restored confidence, but **the AI controller is still not on main**. It's been sitting on a dead branch since M1. The code works, it's tested, and the game still has no single-player mode. This is now a 3-month-old blocker.

**What idea do they have?**  
**Cherry-pick AI controller to main immediately** — Stop planning to do it and DO it. Then expand with AI personality archetypes (aggressive, defensive, balanced, adaptive) as data-driven behavior configs, not code rewrites.

**What would make M3 better for them?**  
- AI controller on main and verified in integration gate
- AI difficulty tuning without code changes (JSON/CSV config files)
- Encounter design patterns documented for future beat-em-up modes

---

### 5. LEIA — Environment / Stage Artist

**What's still frustrating?**  
Scene integrity checker exists, but **visual composition testing is still manual**. EmberGrounds is built, but does it look right at different camera zoom levels? Do parallax layers create depth or distraction? Stage test scenes help but don't validate *composition*.

**What idea do they have?**  
**Camera framing validator** — Tool that captures screenshots at different zoom levels and camera positions, compares against composition rules (rule of thirds, foreground/background separation), and flags visual issues. Could also check sprite-vs-background color contrast.

**What would make M3 better for them?**  
- Stage round transitions (EmberGrounds evolves visually across rounds)
- Environment lighting reacts to Ember state (already wired to EventBus but needs polish)
- Documentation on art asset handoff workflow (sprite sheets, naming conventions)

---

### 6. WEDGE — UI / UX Developer

**What's still frustrating?**  
Menus work and SceneManager exists, but **character select flow is incomplete**. VS CPU mode auto-mirrors P1's selection for P2, but there's no proper fighter confirmation animation, no character intro sequences, and the transition to fight scene feels abrupt.

**What idea do they have?**  
**Character intro cinematics** — 2-second pre-fight sequence showing both fighters in dramatic poses before "FIGHT!" appears. Uses existing character sprites with camera zoom and announcer voiceover. Makes matches feel like events, not just state transitions.

**What would make M3 better for them?**  
- Character select polish (confirmation animations, fighter preview poses)
- Combo naming system (display "Rising Phoenix" when specific combo lands)
- UI component library documented for reuse across future games

---

### 7. BOSSK — VFX Artist

**What's still frustrating?**  
VFX test bench exists and is fantastic, but **character-specific effects are still generic**. Kael and Rhena share the same orange hit sparks. The GDD says Kael is fire/meditation (warm, flowing) and Rhena is explosion/aggression (sharp, bursting). VFX should reinforce character identity.

**What idea do they have?**  
**Character VFX palettes** — Kael's hits spawn ember particles that float upward (fire theme). Rhena's hits spawn sharp red bursts that explode outward (explosion theme). Different particle shapes, colors, and motion patterns per character. 2-3 hours of work.

**What would make M3 better for them?**  
- Character-specific VFX implemented (differentiates roster)
- Ember-driven VFX escalation (effects intensify as Ember builds)
- KO cinematic polish (slow-mo camera push, lingering particles)

---

### 8. GREEDO — Sound Designer

**What's still frustrating?**  
Audio test bench exists, 14 procedural sounds work, but **music and announcer voice are missing**. The GDD specifies dynamic music with 3 intensity levels and iconic announcer callouts ("FIGHT!", "K.O.", "ROUND 1"). We have placeholders but no real implementation.

**What idea do they have?**  
**Procedural announcer voice** — Synthesize robotic/vocoded "FIGHT", "K.O.", "FINAL ROUND" callouts using formant filtering and pitched noise bursts. Won't sound human but will sound authoritative and iconic. Faster than recording voice actors.

**What would make M3 better for them?**  
- Announcer voice implemented (even if procedural/robotic)
- Music system with 3 intensity levels tied to Ember state
- Character-specific audio palettes (Kael = warm sine waves, Rhena = sharp noise bursts)

---

### 9. MACE — Sprint Lead / Process Manager

**What's still frustrating?**  
Ceremonies are documented, tools exist, but **manual coordination is still too high**. I'm still tracking dependencies by hand, checking if agents are blocked, and scheduling integration checkpoints. Tools automate validation but not coordination.

**What idea do they have?**  
**Agent load dashboard** — Auto-generated view showing who's working on what, estimated completion times, blocking dependencies, and capacity. Reads from GitHub issue assignments and PR activity. Replaces my manual tracking spreadsheet.

**What would make M3 better for them?**  
- Automated load tracking (less manual spreadsheet work)
- Post-milestone ceremony automation (retro template execution)
- Clear escalation path when integration gate fails

---

### 10. JANGO — Lead Tool Engineer

**What's still frustrating?**  
Unleashed. 13 tools shipped. Sprint A complete. But **process gaps remain that tools can't fix alone**. Example: the 6-button spec deviation survived 3 months because no process step says "verify GDD alignment before implementation." Tools validate *what you build*; they don't validate *what you chose to build*.

**What idea do they have?**  
**Design-to-implementation checklist** — Before any agent starts coding, they answer 3 questions: (1) What does the GDD say? (2) Does my plan match? (3) If not, is this deviation approved? Creates an audit trail for spec changes.

**What would make M3 better for them?**  
- Return to feature work (20% bandwidth on tools, 80% on game systems)
- Build AI controller integration now that validation exists
- Tackle next high-value tool: automated dependency graph visualization

---

## Part 2: Common Themes

### TOP 3 FRUSTRATIONS THAT REMAIN:

1. **"The spec deviation still isn't fixed" (Lando, Solo, Jango)**  
   The 4-button vs 6-button problem was identified in M1, documented in M2, tools can detect it now, but it's STILL not resolved. This is moving from technical debt to cultural debt — why do we document problems but not fix them?

2. **"Integration gate is manual, not automatic" (Solo, Mace)**  
   We built the tool but didn't automate the trigger. Someone has to remember to run it. That's not a gate — that's a suggestion. Post-merge automation is the missing piece.

3. **"Character identity isn't felt yet" (Bossk, Greedo, Yoda)**  
   Kael and Rhena have different movesets and frame data, but they don't *feel* different in VFX, audio, or pacing. The 10-second identity test (Pillar #4 from GDD) isn't passing yet. Polish is needed.

---

### TOP 3 IDEAS THE TEAM IS EXCITED ABOUT:

1. **"Character-specific everything" (Bossk, Greedo, Wedge)**  
   VFX palettes, audio timbres, intro cinematics, and even UI color themes per character. Make Kael feel like fire meditation and Rhena feel like explosive aggression in every system, not just movesets.

2. **"Physics and feel tuning workbench" (Chewie, Lando)**  
   The test bench pattern worked brilliantly for VFX and audio. Apply it to physics: jump arcs, knockback curves, hitstun durations. Let developers tune feel with sliders and instant visual feedback.

3. **"Announcer voice + dynamic music" (Greedo, Wedge, Yoda)**  
   The game needs iconic audio moments. "FIGHT!" and "K.O." callouts are part of fighting game DNA. Dynamic music that escalates with Ember state makes matches feel cinematic. High impact, medium effort.

---

### TOP 3 THINGS THAT WOULD MAKE M3 SMOOTHER:

1. **"Fix the 6-button spec deviation NOW, not later"**  
   Stop deferring it. Add medium_punch and medium_kick to `project.godot`, update movesets, close the loop. 2-3 hours of work. Prevents compounding technical debt.

2. **"Automate the integration gate trigger"**  
   Post-merge GitHub Action that runs after parallel PRs land. No human coordination required. Integration failures become visible immediately, not days later.

3. **"Cherry-pick AI controller to main immediately"**  
   Tarkin's code is done. It's tested. It works. Get it on main, verify it in integration gate, and move on. This is a 3-month-old blocker that's solved but not shipped.

---

## Part 3: Proposed Issues for Team Vote

### 🔴 CRITICAL (Block M3 Start)

#### Issue 1: Complete 6-Button Fighter Spec
**Category:** Technical Debt  
**Who benefits:** Lando (movesets), Yoda (balance), players (full moveset depth)  
**Why it matters:** GDD spec deviation that's been deferred for 3 months. Becomes harder to fix the longer we wait. Movesets are designed around 4 buttons when they should be 6.  
**Priority:** CRITICAL  
**Effort:** 2-3 hours  
**Acceptance criteria:**
- Add `medium_punch` and `medium_kick` to `project.godot` input map for P1 and P2
- Create medium attack movedata for Kael (medium punch + medium kick)
- Create medium attack movedata for Rhena (medium punch + medium kick)
- Update fighter controller to handle 6-button priority
- Verify in integration gate

#### Issue 2: Cherry-Pick AI Controller to Main
**Category:** Technical Debt  
**Who benefits:** Tarkin (closes 3-month loop), players (single-player mode), QA (testing)  
**Why it matters:** Working code stranded on dead branch since M1. Game has no AI opponent. This is a solved problem that's not shipped.  
**Priority:** CRITICAL  
**Effort:** 1 hour  
**Acceptance criteria:**
- Cherry-pick or rebase `ai_controller.gd` from dead branch to main
- Verify AI loads in fight scene
- Run integration gate to confirm no regressions
- Close issue #7 properly

#### Issue 3: Automate Integration Gate Trigger
**Category:** Process Improvement  
**Who benefits:** Solo (integration confidence), Mace (coordination), entire team (catch issues early)  
**Why it matters:** Gate exists but requires manual execution. Not a gate if it's optional. Automation makes integration failures visible immediately.  
**Priority:** CRITICAL  
**Effort:** 3-4 hours  
**Acceptance criteria:**
- GitHub Action triggers after 2+ PRs merge to main within 2-hour window
- Runs `python tools/integration-gate.py`
- Posts results to GitHub Discussion or Slack
- Auto-creates priority-0 issue if gate fails

---

### 🟡 HIGH (M3 Feature Work)

#### Issue 4: Character-Specific VFX Palettes
**Category:** Game Feature (Polish)  
**Who benefits:** Bossk (differentiation), players (character identity), spectators (readability)  
**Why it matters:** Pillar #4 is "10-second identity test" — characters must feel different immediately. VFX is a major part of that feel.  
**Priority:** HIGH  
**Effort:** 3-4 hours  
**Acceptance criteria:**
- Kael's hits spawn ember particles that float upward (fire theme)
- Rhena's hits spawn sharp red bursts that explode outward (explosion theme)
- Different particle colors, shapes, and motion per character
- Update VFXManager to accept character_id parameter

#### Issue 5: Character-Specific Audio Palettes
**Category:** Game Feature (Polish)  
**Who benefits:** Greedo (differentiation), players (character identity)  
**Why it matters:** Audio reinforces character personality. Kael's hits should sound warm/resonant, Rhena's should sound sharp/percussive.  
**Priority:** HIGH  
**Effort:** 2-3 hours  
**Acceptance criteria:**
- Kael's hit sounds use warm sine waves (70-200Hz bass, smooth attack)
- Rhena's hit sounds use sharp noise bursts (1400Hz crack, fast attack)
- AudioManager accepts character_id to select sound palette
- Exertion sounds differ per character

#### Issue 6: Procedural Announcer Voice
**Category:** Game Feature (Audio)  
**Who benefits:** Greedo (completeness), Wedge (UI/UX drama), players (iconic moments)  
**Why it matters:** "FIGHT!" and "K.O." are core fighting game moments. Placeholder text doesn't create impact. Procedural voice is faster than recording actors.  
**Priority:** HIGH  
**Effort:** 4-5 hours  
**Acceptance criteria:**
- Synthesize "FIGHT" callout (formant-filtered noise burst)
- Synthesize "K.O." callout (pitched vocoder effect)
- Synthesize "ROUND 1", "ROUND 2", "FINAL ROUND" callouts
- Integrate with round manager and HUD announcer text
- Tune pitch, duration, and reverb for authority

#### Issue 7: Character Intro Cinematics
**Category:** Game Feature (UI/UX)  
**Who benefits:** Wedge (polish), players (match drama), spectators (presentation)  
**Why it matters:** Fight transitions feel abrupt. 2-second intro with dramatic poses makes matches feel like events. High impact for medium effort.  
**Priority:** HIGH  
**Effort:** 3-4 hours  
**Acceptance criteria:**
- Pre-fight 2-second sequence with both fighters in dramatic poses
- Camera push-in effect on each fighter
- Announcer callout during intro
- "FIGHT!" announcement after intros complete
- Integrate with SceneManager fight transition

#### Issue 8: Dynamic Music System (3 Intensity Levels)
**Category:** Game Feature (Audio)  
**Who benefits:** Greedo (completeness), players (immersion), spectators (hype)  
**Why it matters:** GDD specifies music that escalates with Ember state. Creates audio-driven tension and rewards aggressive play.  
**Priority:** HIGH  
**Effort:** 6-8 hours  
**Acceptance criteria:**
- Low intensity: ambient track (0-33 Ember)
- Medium intensity: layered percussion (34-66 Ember)
- High intensity: full orchestration (67-100 Ember)
- Smooth transitions between intensity levels
- BPM-locked at 112 BPM
- EventBus integration for Ember state changes

#### Issue 9: Stage Round Transitions (EmberGrounds Evolution)
**Category:** Game Feature (Environment)  
**Who benefits:** Leia (environmental storytelling), players (visual feedback)  
**Why it matters:** GDD Pillar #1 is "every hit feeds the fire." Stage should reinforce this visually across rounds.  
**Priority:** HIGH  
**Effort:** 3-4 hours  
**Acceptance criteria:**
- Round 1: dormant volcano (cool color palette)
- Round 2: warming lava (orange glow intensifies)
- Round 3: full eruption (max ember particles, bright lighting)
- EventBus integration for round state changes

#### Issue 10: Training Mode with Frame Data Overlay
**Category:** Game Feature (Dev Tool + Player Feature)  
**Who benefits:** Lando (validation), Yoda (balance tuning), players (learning), developers (debugging)  
**Why it matters:** GDD specifies training mode. Also serves as developer tool for validating frame data and timing windows.  
**Priority:** HIGH  
**Effort:** 6-8 hours  
**Acceptance criteria:**
- Training scene with dummy opponent (stationary, blocking, or set behavior)
- Frame data overlay showing startup/active/recovery for current move
- Input history display (last 30 frames)
- Hitbox visualization toggle
- Damage counter and reset button

---

### 🟢 MEDIUM (Developer Experience)

#### Issue 11: Physics Tuning Workbench
**Category:** Developer Experience  
**Who benefits:** Chewie (physics feel), Lando (gameplay tuning)  
**Why it matters:** Jump arcs and knockback curves need feel-based tuning. Reading velocity values in debugger doesn't communicate "does this feel right?"  
**Priority:** MEDIUM  
**Effort:** 4-5 hours  
**Acceptance criteria:**
- Test scene with fighter sprite and sliders for gravity, jump velocity, friction
- Buttons to trigger physics scenarios (jump, hit reaction, juggle)
- Trail renderer showing arc visualization
- Export tuned values to constants file

#### Issue 12: Motion Input Visualization Tool
**Category:** Developer Experience  
**Who benefits:** Lando (motion detection debugging), Yoda (input buffer validation)  
**Why it matters:** QCF and DP detection accuracy is hard to validate without visual feedback. Debug tool for motion pattern recognition.  
**Priority:** MEDIUM  
**Effort:** 2-3 hours  
**Acceptance criteria:**
- Visual display of directional inputs (numpad notation)
- Highlights detected motions (QCF, DP, HCB)
- Shows input buffer state (last 30 frames)
- Adjustable leniency window slider

#### Issue 13: Camera Framing Validator
**Category:** Developer Experience  
**Who benefits:** Leia (composition validation), Wedge (UI visibility)  
**Why it matters:** Stage composition testing is currently manual. Tool validates visual hierarchy at different zoom levels.  
**Priority:** MEDIUM  
**Effort:** 5-6 hours  
**Acceptance criteria:**
- Captures screenshots at different zoom levels (1x, 1.5x, 2x)
- Checks foreground/background color separation
- Validates rule-of-thirds alignment
- Flags visual issues (low contrast, cluttered composition)

#### Issue 14: Agent Load Dashboard
**Category:** Process Improvement  
**Who benefits:** Mace (coordination), Solo (capacity planning), all agents (visibility)  
**Why it matters:** Manual load tracking is error-prone and time-consuming. Automated dashboard shows who's working on what and capacity in real-time.  
**Priority:** MEDIUM  
**Effort:** 6-8 hours  
**Acceptance criteria:**
- Reads GitHub issue assignments and PR activity
- Shows agent load (% capacity), current tasks, blocking dependencies
- Highlights agents over 20% load cap
- Estimated completion times based on historical velocity

#### Issue 15: Design-to-Implementation Checklist
**Category:** Process Improvement  
**Who benefits:** All agents (spec alignment), Yoda (design authority), Solo (architecture compliance)  
**Why it matters:** Spec deviations like the 4-button problem happen because no process step verifies GDD alignment before coding starts.  
**Priority:** MEDIUM  
**Effort:** 2 hours (template creation + documentation)  
**Acceptance criteria:**
- Template with 3 questions: (1) What does GDD say? (2) Does plan match? (3) Deviation approved?
- Added to issue templates
- Documented in CONTRIBUTING.md
- Verified in first PR after implementation

---

## Part 4: GitHub Issues Created

**Status:** ✅ ALL 15 ISSUES CREATED

### Critical Issues (Block M3 Start)

1. **#46** — [Ashfall] Complete 6-Button Fighter Spec (Medium Attacks)
   - Labels: `game:ashfall`, `priority:critical`
   - Assignee: Suggested `squad:lando`

2. **#47** — [Ashfall] Cherry-Pick AI Controller to Main
   - Labels: `game:ashfall`, `priority:critical`
   - Assignee: Suggested `squad:tarkin`

3. **#49** — [Process] Automate Integration Gate Trigger Post-Merge
   - Labels: `type:process`, `priority:critical`
   - Assignee: Suggested `squad:jango`

### High Priority Issues (M3 Feature Work)

4. **#50** — [Ashfall] Character-Specific VFX Palettes (Kael/Rhena)
   - Labels: `game:ashfall`, `type:feature`, `priority:p1`, `squad:bossk`

5. **#51** — [Ashfall] Character-Specific Audio Palettes (Kael/Rhena)
   - Labels: `game:ashfall`, `type:audio`, `priority:p1`, `squad:greedo`

6. **#52** — [Ashfall] Procedural Announcer Voice (FIGHT, K.O., Round Callouts)
   - Labels: `game:ashfall`, `type:audio`, `priority:p1`, `squad:greedo`

7. **#53** — [Ashfall] Character Intro Cinematics (Pre-Fight Sequence)
   - Labels: `game:ashfall`, `type:feature`, `priority:p1`, `squad:wedge`

8. **#54** — [Ashfall] Dynamic Music System (3 Intensity Levels)
   - Labels: `game:ashfall`, `type:audio`, `priority:p1`, `squad:greedo`

9. **#55** — [Ashfall] Stage Round Transitions (EmberGrounds Evolution)
   - Labels: `game:ashfall`, `type:art`, `priority:p1`, `squad:leia`

10. **#56** — [Ashfall] Training Mode with Frame Data Overlay
    - Labels: `game:ashfall`, `type:feature`, `priority:p1`, `squad:lando`

### Medium Priority Issues (Developer Experience)

11. **#57** — [Tool] Physics Tuning Workbench
    - Labels: `type:infrastructure`, `priority:p2`, `squad:chewie`

12. **#58** — [Tool] Motion Input Visualization Tool
    - Labels: `type:infrastructure`, `priority:p2`, `squad:lando`

13. **#59** — [Tool] Camera Framing Validator
    - Labels: `type:infrastructure`, `priority:p2`, `squad:leia`

14. **#60** — [Tool] Agent Load Dashboard
    - Labels: `type:infrastructure`, `priority:p2`, `squad:mace`

15. **#61** — [Process] Design-to-Implementation Checklist
    - Labels: `type:infrastructure`, `priority:p2`, `squad:mace`

---

## Part 5: Recommendations

### Immediate Actions (This Week)

**Block M3 feature work until Critical issues are resolved:**

1. **#46 — Complete 6-Button Spec** (2-3 hours, Lando)
   - Add medium_punch and medium_kick to input map
   - Create medium attack movedata for both fighters
   - This is 3-month-old technical debt — fix it NOW

2. **#47 — Cherry-Pick AI Controller** (1 hour, Tarkin)
   - Get working AI code onto main
   - Close 3-month loop on Tarkin's stranded work
   - Enables single-player mode and training mode

3. **#49 — Automate Integration Gate** (3-4 hours, Jango)
   - Post-merge GitHub Action
   - Makes integration failures visible automatically
   - Removes manual coordination overhead

**Success criteria:** All 3 critical issues closed before M3 feature work begins.

---

### M3 Sprint Planning

**HIGH priority work (issues #50-#56):**

**Theme:** Character identity and polish
- Character-specific VFX palettes (#50)
- Character-specific audio palettes (#51)
- Procedural announcer voice (#52)
- Character intro cinematics (#53)
- Dynamic music system (#54)
- Stage round transitions (#55)
- Training mode (#56)

**Estimated effort:** 28-35 hours total across 6 agents  
**Sprint duration:** 2-3 weeks with parallel work

**Load distribution:**
- Greedo: 3 audio features (12-16 hours) — HIGH LOAD, monitor closely
- Lando: Training mode (6-8 hours)
- Wedge: Intro cinematics (3-4 hours)
- Bossk: VFX palettes (3-4 hours)
- Leia: Stage transitions (3-4 hours)

**Risk:** Greedo is at 20%+ load cap. Consider splitting audio work or extending timeline.

---

### Developer Experience (issues #57-#61)

**Can run parallel to M3 or post-M3:**
- Physics tuning workbench (#57)
- Motion input visualization (#58)
- Camera framing validator (#59)
- Agent load dashboard (#60)
- Design-to-implementation checklist (#61)

**Recommended:** Tackle #61 (checklist) immediately — it's 2 hours and prevents future spec drift.

---

## Key Insights

### What Changed Post-Tools

**Before tools existed:**
- "I never saw my work in the game" (8/10 agents)
- Integration was nobody's job
- Spec deviations were silent
- Manual coordination overhead

**After 13 tools shipped:**
- ✅ Test scenes let agents see their work
- ✅ Integration gate exists (but needs automation)
- ✅ GDD diff reporter catches spec deviations
- ⚠️ Some frustrations REMAIN that tools can't fix alone

### What Tools Can't Fix

1. **Cultural debt** — The 6-button problem is known, documented, detected by tools, but STILL not fixed. Tools validate; humans must act.

2. **Automation gaps** — Integration gate exists but is manually triggered. The pattern is clear: build the tool, then automate the trigger.

3. **Feature completeness** — AI controller works but isn't on main. Announcer voice is missing. Music is single-intensity. Tools enable work; they don't DO the work.

### The Team's Real Ask

**Not more tools.** The tools exist.  
**Not more process.** The process is documented.  
**What they want:** EXECUTION on known issues.

- Fix the 6-button spec deviation (3 months old)
- Get AI controller on main (3 months old)
- Automate what can be automated
- Differentiate characters through VFX/audio/polish

---

## Success Metrics for M3

### Process Metrics

- [ ] Zero spec deviations detected by GDD diff reporter
- [ ] Integration gate runs automatically post-merge
- [ ] All agents under 20% load cap throughout sprint
- [ ] Zero manually-triggered coordination steps (automation handles it)

### Feature Metrics

- [ ] Kael and Rhena feel different in VFX, audio, and pacing (10-second identity test)
- [ ] Announcer voice creates iconic moments ("FIGHT!", "K.O.")
- [ ] Music escalates with Ember state (3 intensity levels)
- [ ] Training mode enables feel-based tuning for developers and learning for players

### Team Metrics

- [ ] Developer joy survey: 8+/10 average (vs 7.5/10 in M2)
- [ ] "I saw my work running" — 100% of agents (vs 20% in M2)
- [ ] Zero stranded branches or dead code
- [ ] Tarkin's confidence in process restored

---

## Ceremony Output

**Status:** ✅ COMPLETE

**Deliverables:**
1. ✅ Listening ceremony document (this file)
2. ✅ 15 GitHub issues created and categorized
3. ✅ Common themes synthesized
4. ✅ Recommendations for M3 sprint planning

**What happens next:**
1. Joaquín reviews and approves proposed issues
2. Mace schedules critical issues before M3 kickoff
3. Team votes on HIGH priority issue order
4. Sprint planning with load distribution
5. M3 execution begins once critical blockers are cleared

---

**Facilitated by:** Mace (Sprint Lead)  
**Date:** 2026-03-15  
**Participants:** Chewie, Lando, Solo, Tarkin, Leia, Wedge, Bossk, Greedo, Mace, Jango  
**Method:** Analyzed agent feedback, tool impact, and remaining frustrations

> *"Los trabajadores deben tener a su disposición lo mejor. Quiero que el equipo escuche las frustraciones e ideas de sus compañeros y que se acuerden las issues a trabajar por el bien común."*  
> — Joaquín

**The team has been heard. Now we act.**

