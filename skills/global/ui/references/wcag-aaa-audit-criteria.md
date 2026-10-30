# WCAG 2.2: the 86 success criteria

Method: **auto** (axe rule covers it, still confirm), **measure** (render measurement, `measure.md`),
**manual** (a person checks). Text is a short paraphrase; cite the W3C Understanding page for wording:
https://www.w3.org/WAI/WCAG22/Understanding/

| SC | Name | Level | Method | Check |
|---|---|---|---|---|
| 1.1.1 | Non-text Content | A | auto + manual | images, icons, canvas have a text alternative or are marked decorative |
| 1.2.1 | Audio-only and Video-only (Prerecorded) | A | manual | transcript or audio track |
| 1.2.2 | Captions (Prerecorded) | A | manual | captions on video with sound |
| 1.2.3 | Audio Description or Media Alternative | A | manual | description or full text alternative |
| 1.2.4 | Captions (Live) | AA | manual | live captions |
| 1.2.5 | Audio Description (Prerecorded) | AA | manual | audio description |
| 1.2.6 | Sign Language (Prerecorded) | AAA | manual | sign language for prerecorded audio |
| 1.2.7 | Extended Audio Description | AAA | manual | extended description where pauses are too short |
| 1.2.8 | Media Alternative (Prerecorded) | AAA | manual | full text alternative for all video |
| 1.2.9 | Audio-only (Live) | AAA | manual | text alternative for live audio |
| 1.3.1 | Info and Relationships | A | auto + manual | structure in markup: headings, lists, labels, groups, tables |
| 1.3.2 | Meaningful Sequence | A | manual | reading order matches the meaning |
| 1.3.3 | Sensory Characteristics | A | manual | instructions not only by shape, place, colour or sound |
| 1.3.4 | Orientation | AA | manual | works in portrait and landscape |
| 1.3.5 | Identify Input Purpose | AA | auto | `autocomplete` on personal data fields |
| 1.3.6 | Identify Purpose | AAA | manual | regions, icons and controls carry programmatic purpose (landmarks, roles) |
| 1.4.1 | Use of Color | A | manual | state never by colour alone |
| 1.4.2 | Audio Control | A | manual | sound over 3 s can be paused or muted |
| 1.4.3 | Contrast (Minimum) | AA | measure | 4.5 to 1, large 3 to 1 |
| 1.4.4 | Resize Text | AA | measure | 200 percent text without loss |
| 1.4.5 | Images of Text | AA | manual | real text, not pictures of it |
| 1.4.6 | Contrast (Enhanced) | AAA | measure | 7 to 1, large 4.5 to 1, light and dark |
| 1.4.7 | Low or No Background Audio | AAA | manual | speech audio has no or quiet background |
| 1.4.8 | Visual Presentation | AAA | measure + manual | user can pick colours; width at most 80 characters; no justified text; line spacing 1.5; 200 percent without horizontal scroll |
| 1.4.9 | Images of Text (No Exception) | AAA | manual | no pictures of text except logos |
| 1.4.10 | Reflow | AA | measure | 320 CSS px wide, no two-way scroll (a map canvas is an allowed exception, its panels are not) |
| 1.4.11 | Non-text Contrast | AA | measure | controls, focus and meaningful graphics 3 to 1 |
| 1.4.12 | Text Spacing | AA | measure | survives line 1.5, paragraph 2, letter 0.12, word 0.16 em |
| 1.4.13 | Content on Hover or Focus | AA | manual | tooltips dismissable (Esc), hoverable, persistent |
| 2.1.1 | Keyboard | A | manual | every function by keyboard |
| 2.1.2 | No Keyboard Trap | A | manual | focus can always leave |
| 2.1.3 | Keyboard (No Exception) | AAA | manual | every function by keyboard, path-dependent ones too (drawing, dragging) |
| 2.1.4 | Character Key Shortcuts | A | manual | single key shortcuts can be turned off, remapped, or fire only on focus |
| 2.2.1 | Timing Adjustable | A | manual | time limits can be turned off or extended |
| 2.2.2 | Pause, Stop, Hide | A | measure | time each moving or auto-updating part from start to stop first: one that starts on load and runs over 5 s, or loops with no end, needs a pause; when every one stops within 5 s the verdict is pass and no pause control is proposed (a pause control proposed for animations that all stop within 5 s was discarded) |
| 2.2.3 | No Timing | AAA | manual | no time limits at all except real-time events |
| 2.2.4 | Interruptions | AAA | manual | interruptions (toasts, alerts) can be postponed or suppressed |
| 2.2.5 | Re-authenticating | AAA | manual | after a session expires, work continues without losing data |
| 2.2.6 | Timeouts | AAA | manual | warn of data loss from inactivity, or keep data 20 hours |
| 2.3.1 | Three Flashes or Below Threshold | A | manual | nothing flashes more than 3 times a second |
| 2.3.2 | Three Flashes | AAA | manual | nothing flashes more than 3 times a second, no threshold exception |
| 2.3.3 | Animation from Interactions | AAA | manual | motion from interaction can be turned off (`prefers-reduced-motion`) |
| 2.4.1 | Bypass Blocks | A | auto + manual | skip link or landmarks |
| 2.4.2 | Page Titled | A | auto | title says the page and the level or game |
| 2.4.3 | Focus Order | A | manual | order keeps meaning |
| 2.4.4 | Link Purpose (In Context) | A | auto + manual | link text plus context says where it goes |
| 2.4.5 | Multiple Ways | AA | manual | more than one way to reach a page (not for steps of a process) |
| 2.4.6 | Headings and Labels | AA | manual | headings and labels describe the topic or purpose |
| 2.4.7 | Focus Visible | AA | manual | keyboard focus visible |
| 2.4.8 | Location | AAA | manual | the person knows where they are (title, breadcrumb, current tab) |
| 2.4.9 | Link Purpose (Link Only) | AAA | auto + manual | link text alone says where it goes |
| 2.4.10 | Section Headings | AAA | manual | sections of content have headings |
| 2.4.11 | Focus Not Obscured (Minimum) | AA | measure | focused item not fully hidden by sticky content |
| 2.4.12 | Focus Not Obscured (Enhanced) | AAA | measure | focused item not hidden at all |
| 2.4.13 | Focus Appearance | AAA | measure | indicator at least a 2 CSS px perimeter, 3 to 1 between focused and unfocused pixels |
| 2.5.1 | Pointer Gestures | A | manual | multipoint or path gestures have a single pointer way |
| 2.5.2 | Pointer Cancellation | A | manual | actions on up event, can be aborted |
| 2.5.3 | Label in Name | A | auto + manual | accessible name contains the visible label |
| 2.5.4 | Motion Actuation | A | manual | no device motion only actions |
| 2.5.5 | Target Size (Enhanced) | AAA | measure | 44 by 44 CSS px (inline links exempt) |
| 2.5.6 | Concurrent Input Mechanisms | AAA | manual | pointer, keyboard and touch can be used together, none disabled |
| 2.5.7 | Dragging Movements | AA | manual | every drag has a single pointer way |
| 2.5.8 | Target Size (Minimum) | AA | measure | 24 by 24 CSS px or spacing |
| 3.1.1 | Language of Page | A | auto | `<html lang>` |
| 3.1.2 | Language of Parts | AA | manual | `lang` on other-language passages |
| 3.1.3 | Unusual Words | AAA | manual | jargon and idioms explained (glossary, tooltip) |
| 3.1.4 | Abbreviations | AAA | manual | abbreviations expanded |
| 3.1.5 | Reading Level | AAA | manual | text above lower secondary level has a simpler version; check labels and hints for plain words |
| 3.1.6 | Pronunciation | AAA | manual | pronunciation given where meaning depends on it |
| 3.2.1 | On Focus | A | manual | focus never changes context |
| 3.2.2 | On Input | A | manual | changing a setting never changes context unexpectedly |
| 3.2.3 | Consistent Navigation | AA | manual | navigation in the same order everywhere |
| 3.2.4 | Consistent Identification | AA | manual | same function, same name and icon |
| 3.2.5 | Change on Request | AAA | manual | context changes only when asked (no auto popups, no auto navigation) |
| 3.2.6 | Consistent Help | A | manual | help in the same place on every page |
| 3.3.1 | Error Identification | A | manual | errors named in text |
| 3.3.2 | Labels or Instructions | A | auto + manual | inputs have labels and needed instructions |
| 3.3.3 | Error Suggestion | AA | manual | errors say how to fix |
| 3.3.4 | Error Prevention (Legal, Financial, Data) | AA | manual | reversible, checked or confirmed |
| 3.3.5 | Help | AAA | manual | context help available |
| 3.3.6 | Error Prevention (All) | AAA | manual | every submission reversible, checked or confirmed (undo counts) |
| 3.3.7 | Redundant Entry | A | manual | nothing asked twice in a process |
| 3.3.8 | Accessible Authentication (Minimum) | AA | manual | no cognitive test to log in (paste and managers allowed) |
| 3.3.9 | Accessible Authentication (Enhanced) | AAA | manual | no cognitive test at all, not even object recognition |
| 4.1.2 | Name, Role, Value | A | auto + manual | every control exposes name, role, state |
| 4.1.3 | Status Messages | AA | auto + manual | status in live regions without moving focus |

86 rows (4.1.1 Parsing was removed in WCAG 2.2). Source: https://www.w3.org/TR/WCAG22/
