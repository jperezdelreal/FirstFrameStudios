# Ashfall Playtesting Protocol

**For:** Feel Calibration & Balance Validation  
**Audience:** Playtester (CEO, project stakeholders, team)  
**Latest Update:** Sprint M3

---

## 🎮 How to Launch the Game

### Quick Start
1. **Open Godot 4.6.1**
   - Launch: `C:\Users\joperezd\Downloads\Godot_v4.6.1-stable_win64.exe`
   - Or just double-click the Godot executable

2. **Import the Ashfall Project**
   - Click **"Import"** on the splash screen
   - Navigate to: `games/ashfall/project.godot`
   - Click **"Import & Edit"**
   - Wait for the editor to load (may take 30–60 seconds first time)

3. **Play the Game**
   - Press **F5** (or click the ▶️ Play button at top-right)
   - The main menu should load
   - From there, select **"Play"** or **"Training"** mode

### If No Main Scene Loads
- Right-click the scene file (`scenes/ui/main_menu.tscn`)
- Select **"Set as Main Scene"**
- Press F5 again

---

## 🎮 Controls Reference

### **Player 1** (Left Side)
| Action | Key |
|--------|-----|
| Move Left | **A** |
| Move Right | **D** |
| Move Up | **W** |
| Move Down | **S** |
| Light Punch | **U** |
| Medium Punch | **Y** |
| Heavy Punch | **I** |
| Light Kick | **J** |
| Medium Kick | **H** |
| Heavy Kick | **K** |
| Block | **L** |

### **Player 2** (Right Side - Numpad)
| Action | Key |
|--------|-----|
| Move Left | **←** (Left Arrow) |
| Move Right | **→** (Right Arrow) |
| Move Up | **↑** (Up Arrow) |
| Move Down | **↓** (Down Arrow) |
| Light Punch | **Numpad 4** |
| Medium Punch | **Numpad 8** |
| Heavy Punch | **Numpad 5** |
| Light Kick | **Numpad 1** |
| Medium Kick | **Numpad 9** |
| Heavy Kick | **Numpad 2** |
| Block | **Numpad 3** |

---

## ✅ Testing Checklist

### **Milestone 3: Sprites & Animation**
- [ ] Characters render on screen
- [ ] Idle pose looks correct
- [ ] Walk/run animations play smoothly
- [ ] Attack animations play when you press buttons
- [ ] No visual glitches (missing sprites, flickering, stretched limbs)
- [ ] Hit reactions show (opponent recoils when hit)
- [ ] Blocking animation plays

### **General Feel & Responsiveness**
- [ ] Inputs register immediately (no delay)
- [ ] Movement feels smooth and controllable
- [ ] Character doesn't get stuck on stage edges
- [ ] Camera stays centered and doesn't clip through characters
- [ ] Music/SFX play without issues

---

## 💭 Feel Calibration Survey

**Answer these questions after 10–15 minutes of playtime:**

### 1. **Does the punch feel like it connects?**
   - [ ] 1 — Doesn't feel like it lands
   - [ ] 2 — Feels weak
   - [ ] 3 — Feels about right
   - [ ] 4 — Feels satisfying
   - [ ] 5 — Feels very satisfying

### 2. **Is movement speed comfortable?**
   - [ ] Too slow (hard to close distance)
   - [ ] Just right (feels responsive)
   - [ ] Too fast (hard to control)

### 3. **Does hit-stun feel fair?** (Time opponent is pushed back/stunned)
   - [ ] Too long (boring to watch)
   - [ ] Just right (feels balanced)
   - [ ] Too short (feels like hits don't matter)

### 4. **Are combos discoverable?**
   - [ ] No — I don't know how to chain moves
   - [ ] Somewhat — I found a few by accident
   - [ ] Yes — I'm discovering combos naturally

### 5. **Any moves feel out of place?**
   - [ ] Yes — Which ones? _________________________________
   - [ ] No

### 6. **What felt best?**
   - _________________________________________________________________

### 7. **What felt worst?**
   - _________________________________________________________________

---

## 🐛 How to Report Bugs

### Simple Format (Email or Slack)
- **What happened:** Describe exactly what occurred
- **What you expected:** What should have happened instead
- **Steps to reproduce:** How to make it happen again
- **Screenshot/video:** If possible, include a clip

### Example
> **What happened:** Character got stuck in the floor  
> **Expected:** Should stay on the stage  
> **Steps:** Do a heavy kick near the right edge, then move left  
> **Screenshot:** [image attached]

### Using GitHub (Advanced)
```bash
gh issue create --title "Bug: Character stuck in floor" --body "
What happened: Character phased through the floor

Expected: Should stay on the stage

Steps: 
1. Do a heavy kick near the right edge
2. Move left

Tested with: P1 vs AI"
```

---

## 📝 Notes for Testers

- **Don't worry about polish.** If something looks rough, that's fine—we're testing *feel* right now.
- **Play both modes:** Try 1v1 vs the AI and 1v1 locally with another player (if possible).
- **Test both sides:** Play as P1 and P2. Do they feel balanced?
- **Push the limits:** Mash buttons, try weird inputs, see what breaks.
- **One session = 15–30 min.** Don't play for hours. You'll get fatigue and your feedback won't be valid.
- **Fresh eyes:** Play again tomorrow and see if your first impressions hold up.

---

## 🔄 Next Steps

1. Fill out the survey above
2. Email or Slack your answers to the team
3. If you find a bug, create an issue (or just tell the team verbally)
4. We'll iterate on controls, animations, and feel based on your feedback

**Thank you for playtesting!** 🙏
