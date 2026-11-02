# Maintaining the Overleaf paper template (window B: the Overleaf template project's clone)

This file lives in the research template repository (window A) because anything committed to
the Overleaf template is copied into every paper made from it. Make Claude Code read it in the
Overleaf template clone with a gitignored `CLAUDE.local.md` at that clone's root containing:

    @/ABSOLUTE/PATH/TO/Research-Project-Template/maintenance/overleaf-template.md

In that clone, you are maintaining the template itself: this file overrides the paper rules
in `.claude/CLAUDE.md` where they conflict (you may edit `tools/`, `.claude/`, `.vscode/`, and
`main.tex`'s placeholders when asked). The system overview is in `../MAINTAINING.md`
(section 1); local paths and private words are in `projects.local.md` next to this file.

## 1. Design decisions for Level 1 (do not undo without asking)

- Overleaf is the master copy. VS Code users clone through Integrations → Git (username `git`,
  a token as password, one token per computer).
- **GitDoc owns the manuscript repository**: every save commits, pulls (merge;
  `pull.rebase false`) and pushes, 3 s after saving. Autosave is `onFocusChange` only (timed
  autosave would hit Overleaf rate limits). With GitDoc on, nobody commits by hand; to manage
  Git yourself, switch GitDoc off. Everything not gitignored syncs, by design. In this clone,
  that means every saved change reaches the Overleaf template project within seconds.
- A pre-commit hook (`tools/githooks/pre-commit`) blocks commits with conflict markers. The
  folder-open task sets `core.hooksPath`, `core.fileMode false`, `pull.rebase false` and, on
  Linux without a credential helper, a quoted plain-text token store in `.git/overleaf-credentials`.
- Overleaf has one branch (`main` in recent projects, `master` in older ones) and refuses force pushes.
- `main.tex` keeps only `\usepackage[draft]{tools/reviewmarkup}` (`[final]` for submission) and
  one `\newreviewer{Name}{colour}` (or `{model}{values}`) line per person; placeholder authors.
  Each line creates `\noteName{}` (inline), `\marginName{}` (margin; old `\noteName[margin]{}`
  still compiles) and `\editName[old]{new}`. Notes are numbered per person (bold `ALICE#1:`),
  inline and margin sharing the count. Edits spanning paragraphs or equations fall back to
  `[deleted: …][…]` colour markup without affecting numbering or labels; short edits use the
  `changes` package with prefixed commands (`\chadded`…, needed for memoir); no author
  superscripts. Draft mode widens narrow pages for margin notes; final mode keeps the page size.
  Load `geometry` before reviewmarkup.
- LaTeX Workshop recompiles on file change (interval 3 s); Claude compiles into `build/claude`.
- Claude's paper rules (`.claude/CLAUDE.md`): mark every edit; margin notes by default; act on
  notes only when asked ("address Alice#1"), quoting them first; "Accept changes" / "Clean up" /
  "Reject changes" commands; unasked fixes of clear typos (marked) and cited bibliography
  errors (unmarked, with a margin note); never invent references; plan first for global
  changes; never touch credentials. Personal preferences in `.claude/CLAUDE.local.md`.
- **Public-safe**: no real names, emails or affiliations; Alice/Bob and placeholders. Check by
  grepping for the "private words" in `projects.local.md`.

## 2. Infrastructure versus content in papers

| Infrastructure (rolled out) | Content (never overwritten) |
| --- | --- |
| `tools/`, `.claude/CLAUDE.md` (keep its "Paper conventions" section), `.claude/settings.json`, `.claude/CLAUDE.local.md.example`, `.vscode/`, `.github/`, `.gitignore`, `.gitattributes` | `main.tex`, `biblio.bib`, `figures/`, `.claude/CLAUDE.local.md` |

## 3. Procedures

**Change the template.** Edit in this clone; saving syncs it to the Overleaf template project.
Test first if possible (or right after): `latexmk -pdf -outdir=build main.tex` in draft and final
mode (swap `[draft]`/`[final]`), plus a scratch test with notes, margin notes and edits spanning
paragraphs and equations; delete `build/` afterwards. `shellcheck` the hook; JSON must parse;
run the public-safety check. Then tell the user what to update in the guide (window A).

**Roll out to papers** (ask first; list them from `projects.local.md`):

    /PATH/TO/Research-Project-Template/maintenance/rollout-manuscript.sh . PAPER-CLONE

If GitDoc runs for that paper, it syncs the change; otherwise commit and push there. If
`.vscode/tasks.json` changed, remind the user to run the setup task once in each paper.

**Releases** are made from window A (see `MAINTAINING.md`, section 4), which builds the Overleaf
template zip from this clone.
