---
# GitHub Copilot Skills Repository Instructions
# Auto-loaded when working in copilot-skills repo
---

# Copilot Skills Publishing Rules

When user asks to **create**, **update**, or **publish** a Copilot skill in this repository, follow these rules STRICTLY.

## 🎯 Repository Context

- **Repo Name**: `Kirrrkaz-ORG/copilot-skills`
- **Purpose**: Library of reusable GitHub Copilot skills
- **Location**: `~/copilot-skills/`
- **Skills install to**: `~/.copilot/skills/` on user's machine

## 🚨 MANDATORY Workflow for New Skills

### 1. Create Skill Structure

```
skills/<skill-name>/
├── SKILL.md          # Main instructions with YAML frontmatter
└── README.md         # Brief description for GitHub
```

### 2. Create SKILL.md

Must include YAML frontmatter:

```yaml
---
name: skill-name
description: |
  Full description of what the skill does.
  When to use: [criteria]
  Triggers: [key phrases]
applyTo:
  - "**/*.*"
keywords:
  - keyword1
  - keyword2
  - russian_word
---
```

### 3. 🔴 UPDATE Main README.md (CRITICAL!)

**⚠️ WITHOUT README UPDATE — SKILL IS INCOMPLETE!**

You MUST update **THREE** sections in main `README.md`:

#### a) Skills Table (section `## 📚 Навыки`)

Add new row:
```markdown
| N | [skill-name](./skills/skill-name/) | Brief description (1 line) | `trigger1`, `trigger2` |
```

#### b) Repository Structure (section `## 📁 Структура репозитория`)

Add to ASCII tree:
```markdown
    └── skill-name/                    # Skill №N: Brief title
        ├── SKILL.md                   # Main instructions
        └── README.md                  # Brief description
```

#### c) Skill Features (section `## 📝 Особенности навыков`)

Add detailed description:
```markdown
### 🔧 N. skill-name — Brief Title

**Решаемая проблема:** [user problem description]

**Ключевые возможности:**
- 📌 Feature 1
- 📌 Feature 2
- 📌 Feature 3

**Процесс:**
1. Step 1
2. Step 2
3. Step 3

**Когда использовать:** [specific trigger scenario]

---
```

### 4. Commit to Correct Repository

```bash
cd ~/copilot-skills
git add skills/skill-name/ README.md
git commit -m "feat: Add skill-name skill for [task]"
git push origin main
```

**⚠️ CRITICAL:** Always push to `https://github.com/Kirrrkaz-ORG/copilot-skills`

**NEVER push to:**
- Project repos (starte_ai, etc.)
- Other organizations
- Wrong branches

### 5. Report to User

After successful publish, provide:

```markdown
✅ Skill published to copilot-skills!

📦 **Commit:** [commit URL]
📖 **README:** [link to skill section]
🚀 **Triggers:** 
- `trigger 1`
- `trigger 2`

📋 **Changes:**
- Created skills/skill-name/SKILL.md
- Created skills/skill-name/README.md  
- Updated main README.md (table + structure + description)
```

## 📋 Pre-Commit Checklist

Before committing, verify:

- [ ] `SKILL.md` has valid YAML frontmatter
- [ ] `README.md` created for the skill
- [ ] **Main `README.md` updated in ALL 3 sections**
- [ ] Skill name matches folder name
- [ ] Keywords include Russian and English variants
- [ ] No typos or broken links
- [ ] Commit message follows format: `feat: Add skill-name skill for [task]`

## ❌ Common Mistakes to Avoid

### 1. Forgot to Update Main README.md

**Problem:** Skill works locally but invisible in documentation.

**Solution:** ALWAYS include main `README.md` in commit.

### 2. Wrong Repository

**Problem:** Pushed skill to project repo instead of copilot-skills.

**Solution:** Check `git remote -v` before pushing. Must be `Kirrrkaz-ORG/copilot-skills`.

### 3. Incomplete Frontmatter

**Problem:** Skill not recognized by Copilot agent.

**Solution:** Verify:
- `name:` matches folder name
- `description:` includes trigger phrases
- `keywords:` has multiple variants

## 🔄 Update Existing Skill

When user asks to update existing skill:

1. Edit `skills/skill-name/SKILL.md`
2. Update `skills/skill-name/README.md` if needed
3. Update main `README.md` **ONLY if**:
   - Triggers changed
   - Key features changed
   - Description needs update
4. Commit: `update: [skill-name] - [what changed]`

## 🧪 Testing Skills Locally

After creating skill, suggest user to test:

```bash
# Copy to local Copilot skills folder
cp -r ~/copilot-skills/skills/skill-name ~/.copilot/skills/

# Restart VS Code

# Test triggers in Copilot Chat
```

## 📚 Skill Quality Standards

Good skill has:
- ✅ Solves **specific repeatable task**
- ✅ Clear **triggers** (intuitive keywords)
- ✅ **Step-by-step instructions**
- ✅ **Examples** of usage
- ✅ **Troubleshooting** section
- ✅ **When to use** / **When NOT to use** criteria

Bad skill has:
- ❌ Too generic task ("write code")
- ❌ Unclear triggers
- ❌ Incomplete instructions
- ❌ No examples
- ❌ Outdated README.md

## 🎨 Naming Conventions

**Skill folder names:**
- Use kebab-case: `my-skill-name`
- Be specific: `pdf-table-digitize` (good), `pdf-parser` (too vague)
- Avoid version numbers: `skill-v2` (bad)

**Commit messages:**
- New skill: `feat: Add skill-name skill for [task]`
- Update: `update: [skill-name] - [change description]`
- Fix: `fix: [skill-name] - [bug description]`
- README: `docs: update README - add skill-name`

## 📖 Reference Documentation

- [VS Code Agent Skills Docs](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [CONTRIBUTING.md](./CONTRIBUTING.md) — full contribution rules
- [README.md](./README.md) — main documentation

---

## 🤖 Agent Behavior Summary

When user says:
- "создай skill для X" → Create new skill + update README + commit + push
- "добавь навык для Y" → Create new skill + update README + commit + push
- "обнови skill Z" → Update existing skill + commit (README only if needed)
- "опубликуй skill W в copilot-skills" → Ensure in correct repo, then commit + push

Always:
1. Check current directory: `pwd`
2. Verify git remote: `git remote -v`
3. Update main README.md for new skills
4. Commit with descriptive message
5. Push to `Kirrrkaz-ORG/copilot-skills` main branch
6. Report commit URL to user

Never:
- Skip README.md update for new skills
- Push to wrong repository
- Commit without testing frontmatter validity
- Use generic commit messages ("update files")

---

**Remember:** Main `README.md` is the face of the repository. Keep it always up to date! 🚀