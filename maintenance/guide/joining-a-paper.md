# Joining a paper

This is what a co-author needs to work on a paper written on Overleaf with Claude's help. Co-authors who only write in the Overleaf browser editor can just read “Comments and markup”; the rest of the guide is for working in VS Code with Claude.

## Comments and markup

Everyone comments and marks changes in the text itself, with commands named after them. Claude uses the same commands, as `Claude`.

| Write | Shows in the PDF | Use for |
| --- | --- | --- |
| `\noteAlice{Shorten this paragraph.}` | A box in the text: **ALICE#1:** Shorten this paragraph. | Requests and comments that must be read before deciding, long or short |
| `\marginAlice{Too strong?}` | The same, as a small box in the margin | Short remarks tied to a line, at most about 20 words (a longer one runs off the page) |
| `\popupAlice[Is this claim too strong?]{this claim}` | The words get a background in your colour; clicking them opens a box with **ALICE#1:** Is this claim too strong?, typeset like the paper (equations and citations included); click again to close it | Optional clarifications or longer discussion about specific words |
| `\editAlice{new text}` | The new text in your colour | Inserting text |
| `\editAlice[old text]{new text}` | The old text in a paler shade, labelled `[deleted: …]`, then the new text in your colour | Replacing text; with empty braces, `\editAlice[old text]{}`, deleting it |

Notes are numbered per person from the top of the paper, inline notes, margin notes and popups together: ALICE#1, ALICE#2, and so on. To have Claude act on one, a co-author working with Claude says “address Alice#1”. Edits stay marked until someone asks Claude to “accept changes” (keep the new text) or “clean up” (remove only the deleted old text); notes stay, except a popup whose words are all deleted. Edits may span several paragraphs and equations, and may be nested: to change part of someone else's edit, put your edit inside its new text. Popups work in VS Code's PDF preview; some other viewers, such as macOS Preview, show every popup box at once.

Please use these instead of Overleaf's own comments and Track Changes, which Claude cannot see.

**Setting up your name and colour.** Near the top of `main.tex`, next to Claude's line, add one line for yourself (or ask the paper's owner to):

```text
\newreviewer{Claude}{DarkRed}
\newreviewer{Alice}{ForestGreen}
\newreviewer{Bob}{RGB}{0,84,147}
```

The name becomes part of your commands (`Alice` gives `\noteAlice`, `\marginAlice`, `\popupAlice`, `\editAlice`), so use letters only, no spaces or accents. The colour is either a name such as `Navy`, `ForestGreen` or `DarkOrange` (the svgnames list in the xcolor manual) or a model and values such as `{RGB}{0,84,147}` or `{HTML}{005493}`. Pick one clearly different from your co-authors' and from Claude's dark red.

## Writing with Claude in VS Code

Co-authors can use VSCode as an alternative to Overleaf-on-the-browser to benefit from extra functionality, such as AI assistance (assuming Claude Code here). The instructions below show how to set it up, so that both VSCode and Overleaf remain in sync via Overleaf's Git integration.

### Install once per computer

|  | macOS | Windows | Linux |
| --- | --- | --- | --- |
| VS Code | code.visualstudio.com | code.visualstudio.com | code.visualstudio.com |
| Git | Run `git --version` in Terminal and accept the install offer | Git for Windows (git-scm.com), default options | Usually preinstalled |
| LaTeX (optional) | See “Optional: a PDF on your own computer” below | same | same |

You also need a Claude subscription for Claude Code.

### Join the paper (once per paper)

1. **Get the address and a token.** Open the paper on Overleaf, open the **Integrations** side panel and click **Git**. Copy the Git URL, then press **Generate token**. The token is your password: keep it somewhere safe. One token per computer is enough for all your papers.
2. **Clone it under a readable name**, in a terminal (on Windows, Git Bash or PowerShell). When asked, the username is `git` and the password is your token:

```bash
git clone https://git.overleaf.com/PROJECT-ID "Paper name"
```

3. **Open the folder in VS Code** (File → Open Folder) and click **Trust** when asked.
4. **Install the extensions:** Command Palette (Ctrl/Cmd+Shift+P) → **Extensions: Show Recommended Extensions**, then install the three workspace recommendations (Claude Code, GitDoc, LaTeX Workshop). Sign in to Claude Code when it asks.
5. **Run the one-time setup:** Command Palette → **Tasks: Run Task** → **Paper: one-time setup**. It sets up how your work merges with Overleaf's and a check that stops broken merges from reaching Overleaf.
6. **First sync:** change something small and save (Ctrl/Cmd+S). A password box appears at the top of VS Code: enter `git` and your token. Your computer remembers it from then on.
7. **Check:** a small mirror icon appears in the status bar at the bottom. If it doesn't, run **GitDoc: Disable** and then **GitDoc: Enable** from the Command Palette.

Optional: for personal preferences (your name, the language Claude should talk to you in), copy `.claude/CLAUDE.local.md.example` to `.claude/CLAUDE.local.md` in the same folder and edit the copy. Copy it, don't rename it: the example is shared with everyone.

## Optional: a PDF on your own computer

Overleaf always compiles the paper, so this is a convenience: a local PDF that updates a few seconds after any change, including Claude's edits, and lets Claude check that its edits compile. Minimal LaTeX installations such as BasicTeX lack packages the paper's review commands need, so use **Tectonic**: a single program for any system that downloads whatever packages a paper needs the first time it compiles (this needs internet once).

**Install Tectonic:**

| System | Command |
| --- | --- |
| macOS | `brew install tectonic` |
| Linux | `brew install tectonic` (Homebrew works on Linux too, and is preferred). Without Homebrew: `curl --proto '=https' --tlsv1.2 -fsSL https://drop-sh.fullyjustified.net \| sh`, then `mkdir -p ~/.local/bin && mv tectonic ~/.local/bin/` |
| Windows | In PowerShell: `[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://drop-ps1.fullyjustified.net'))`, then move `tectonic.exe` to a folder on your PATH |

Check with `tectonic --version` in a new terminal.

**Tell VS Code to use it,** once: Command Palette → **Preferences: Open User Settings (JSON)**, and add inside the outer braces:

```json
"latex-workshop.latex.tools": [
  { "name": "tectonic", "command": "tectonic",
    "args": ["--synctex", "--keep-logs", "--keep-intermediates", "--outdir", "%OUTDIR%", "%DOC%.tex"] }
],
"latex-workshop.latex.recipes": [
  { "name": "Tectonic", "tools": ["tectonic"] }
],
```

The PDF opens in a VS Code tab (TeX sidebar → View LaTeX PDF). **Be patient with the first build:** it can take several minutes, because Tectonic downloads its base files and every package the paper uses. They are cached, so later builds are much faster, and --keep-intermediates lets each rebuild reuse the previous one's files (about 40% faster). A circling arrow in the status bar at the bottom shows that a build is running; build messages are under Command Palette → **LaTeX Workshop: View LaTeX compiler logs**.

Tectonic uses a different TeX engine from Overleaf, so line breaks may differ slightly; Overleaf's PDF is the reference. If the first build complains that the output folder is missing, create a folder named `build` in the paper folder. One package doesn't work with Tectonic: `bbm` (for `\mathbbm{1}`), whose fonts only exist in a form Tectonic can't use. Replace `\usepackage{bbm}` with `\usepackage{dsfont}` plus `\newcommand{\mathbbm}{\mathds}`, which keeps every `\mathbbm{...}` in the text working (and looks sharper on Overleaf too).

A full TeX Live or MacTeX installation (several gigabytes) works too, without any settings.

## Everyday use

- **Saving is syncing.** Press Ctrl/Cmd+S, or switch to another window: a few seconds later your changes are on Overleaf, and Overleaf's latest changes are merged into yours. Never commit or push by hand.
- **To get co-authors' changes** without having edited anything, click the sync arrows in VS Code's status bar.
- **Save before asking Claude to edit,** so your typing and Claude's changes don't collide.
- **Ask Claude in plain words,** in the Claude Code panel:

| You say | Claude does |
| --- | --- |
| “Address Alice#1” | Quotes the note, does what it asks with marked edits, removes the note |
| “Tighten the abstract” | Small edits, each marked in dark red |
| “Read the methods and leave notes, don't edit” | Notes, no text changes: short remarks in the margin, longer explanations as popups on the words concerned |
| “Accept changes from Bob in section 2” | Keeps Bob's new text there, without colour or deleted text; notes stay |
| “Clean up” | Removes the deleted old text everywhere, keeping new text in colour |
| “Resolve the Git conflict” | Merges your version and Overleaf's, and explains what it chose |

- **For the submission version,** change `\usepackage[draft]{tools/reviewmarkup}` to `[final]` in `main.tex`: notes disappear and all edits show as accepted.

## If something goes wrong

When in doubt, ask Claude what happened; it can read the state of the folder and fix most problems.

| Symptom | Fix |
| --- | --- |
| Saving does nothing, no mirror icon in the status bar | Command Palette: **GitDoc: Disable**, then **GitDoc: Enable** |
| Every sync asks for the token, or nothing reaches Overleaf | Run **Tasks: Run Task → Paper: one-time setup**, save again and enter `git` and the token once |
| `<<<<<<<` lines appear in `main.tex` | You and someone in Overleaf changed the same lines. Ask Claude to “resolve the Git conflict”, or use the Accept buttons above each block, then save |
| GitDoc offers a **Force Push** button | Don't press it. Click the sync arrows or save again |
| “Authentication failed” | Your token expired (after a year) or was deleted: generate a new one on Overleaf and enter it at the next prompt |
| The PDF doesn't update or reports missing packages | Install Tectonic (section above); minimal LaTeX installations lack needed packages |

For anything else, see the full guide, or ask the paper's owner.
