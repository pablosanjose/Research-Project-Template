# Maintaining the Overleaf paper template (window B: the Overleaf template project's clone)

This file lives in the research template repository (window A) because anything committed to
the Overleaf template is copied into every paper made from it. Make Claude Code read it in the
Overleaf template clone with a gitignored `CLAUDE.local.md` at that clone's root containing:

    @/ABSOLUTE/PATH/TO/Research-Project-Template/maintenance/overleaf-template.md

In that clone, you are maintaining the template itself: this file overrides the paper rules
in `.claude/CLAUDE.md` where they conflict (you may edit `tools/`, `.claude/`, `.vscode/`, and
`main.tex`'s placeholders when asked). The system overview is in `../MAINTAINING.md`
(section 1); local paths are in `projects.local.md` next to this file.

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
  still compiles), `\popupName[text]{words}` (highlighted words, note shown on hover) and
  `\editName[old]{new}`. Notes are numbered per person (bold `ALICE#1:`), inline, margin and
  popup sharing the count. Edits may be nested (an edit inside another's new text). Edits spanning paragraphs or equations fall back to
  `[deleted: …][…]` colour markup without affecting numbering or labels; short edits use the
  `changes` package with prefixed commands (`\chadded`…, needed for memoir); no author
  superscripts. Draft mode widens narrow pages for margin notes; final mode keeps the page size.
  Load `geometry` before reviewmarkup.
- Popups (draft only) use `pdfcomment` highlight annotations, loaded at the end of the preamble
  so a later `hyperref` keeps its options. `reviewmarkup.sty` works around four problems:
  soul cannot split a command from its arguments (each command with arguments in the words is
  wrapped in `\mbox`; `\footnote` and `\label` move after the words, which soul typesets several
  times); soulpos opens its position file with a delayed `\openout` that REVTeX's `\maketitle`
  discards (opened at once instead); the popup text is a PDF string (`\cite`, `\ref`, `\eqref`
  become numbers from the last run, math becomes Unicode through `\pdfstringdefDisableCommands`);
  PDF.js opens a popup right of the highlight, off the page in the right column, and ignores the
  highlight's `/Rect` unless an explicit `/Popup` is attached (each highlight is written with
  one, its `/Rect` moved just below the line and at most 55% across the page; PDF.js popups are
  at most 45% of the page wide). Tested in LaTeX Workshop (PDF.js 6.2) and on Overleaf.
- LaTeX Workshop recompiles on file change (interval 3 s) into `build/`; Claude compiles once per
  task into `build/claude`, so the two builds never overwrite each other.
- Claude's paper rules (`.claude/CLAUDE.md`): mark every edit; margin notes by default; act on
  notes only when asked ("address Alice#1"), quoting them first; "Accept changes" / "Clean up" /
  "Reject changes" commands; nested edits, including inside popup words; popups only when
  asked; scripted bulk changes tested on a scratch copy first; unasked fixes of clear typos (marked) and cited bibliography
  errors (unmarked, with a margin note); never invent references; plan first for global
  changes; never touch credentials. Personal preferences in `.claude/CLAUDE.local.md`.
- **Public-safe**: no real names, emails or affiliations; Alice/Bob and placeholders.

## 2. Infrastructure versus content in papers

| Infrastructure (rolled out) | Content (never overwritten) |
| --- | --- |
| `tools/`, `.claude/CLAUDE.md` (keep its "Paper conventions" section), `.claude/settings.json`, `.claude/CLAUDE.local.md.example`, `.vscode/`, `.github/`, `.gitignore`, `.gitattributes` | `main.tex`, `biblio.bib`, `figures/`, `.claude/CLAUDE.local.md` |

## 3. Procedures

**Change the template.** Edit in this clone; saving syncs it to the Overleaf template project.
Test first if possible (or right after): `latexmk -pdf -outdir=build main.tex` in draft and final
mode (swap `[draft]`/`[final]`), plus a scratch test with notes, margin notes, nested edits, edits spanning
paragraphs and equations, and popups (in REVTeX with `\maketitle`, in both columns, with
citations, footnotes and math in the words and in the popup text; check the PDF really contains
`/Highlight` and `/Popup` annotations, since a broken popup still compiles); delete `build/` afterwards. `shellcheck` the hook; JSON must
parse. Then tell the user what to update in the guide (window A).

**Roll out to papers** (ask first; list them from `projects.local.md`):

    /PATH/TO/Research-Project-Template/maintenance/rollout-manuscript.sh . PAPER-CLONE

If GitDoc runs for that paper, it syncs the change; otherwise commit and push there. If
`.vscode/tasks.json` changed, remind the user to run the setup task once in each paper.

**Releases** are made from window A (see `MAINTAINING.md`, section 4), which builds the Overleaf
template zip from this clone.
