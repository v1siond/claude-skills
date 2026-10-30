# Code pass rules (pinned from Vercel Web Interface Guidelines, MIT, read 2026-10-16)

Report as `file:line rule` grouped by file. The repo's control kit wins over any rule here.

- Accessible names: icon-only buttons have `aria-label`; every form control has a label; decorative icons
  `aria-hidden`; images `alt`.
- Semantics: `<button>` for actions, `<a>` for navigation; no click handlers on `div` or `span`; headings in
  order.
- Focus: a visible `:focus-visible` style on every interactive element; outline never removed without a
  replacement; `:focus-within` on compound controls; nothing sticky covers the focused element.
- Forms: labels clickable (`htmlFor` or wrapping); a checkbox or radio and its label one hit target; correct
  `type` and `inputmode`; errors inline next to the field; never block paste; warn before losing unsaved work.
- Async: status and validation messages in an `aria-live="polite"` region; loading text ends with an ellipsis.
- Animation: honours `prefers-reduced-motion`; animates only transform and opacity; no `transition: all`;
  interruptible.
- Content: long text truncates or wraps (`min-width: 0` on flex children); empty states written; numbers in
  columns use `tabular-nums`.
- Layout: no unwanted scrollbars; flex or grid over JS measuring; works at the narrowest supported width.
- State: destructive actions have undo or confirmation; state that matters survives a reload.
- Copy: active voice, specific button labels ("Save level", not "OK"), errors say the fix, numerals for counts.
- Anti-patterns: `user-scalable=no`, `onPaste` preventDefault, inputs without labels, icon buttons without
  names, hard-coded date or number formats, `autoFocus` without reason.
