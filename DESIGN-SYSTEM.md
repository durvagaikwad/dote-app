# Dote Design System — "Sunny Scrapbook"

Source of truth: [Figma → Dote app → **Redesigned** page](https://www.figma.com/design/kwZFoBKb3BkfuriOeNOztN/Dote-app?node-id=156-1241)
Implemented in: `index.html` `:root` tokens (v2, replaces the terracotta/peach "Cosy Nursery" system).

## 1. Direction

A family baby album that feels like a **hand-made scrapbook on a picnic blanket**: cream paper base,
picnic green + sky blue brand pair, marker-orange accents, polaroids pinned at slight angles,
hand-drawn doodle stickers (star, flower, cloud, leaf, starfish, farm animals), and gingham/grid/
polka-dot/cloud patterns. Warm, playful, analog — never sterile.

## 2. Color

### Brand & accents

| Token | Hex | Usage |
|---|---|---|
| `--cream` | `#f8f2e5` | App & onboarding background (paper base) |
| `--surface` | `#faf6ef` | Nav pill, warm cards, handwritten notes |
| `--green` | `#a1cc6a` | Brand green — splash, Family role card, secondary CTAs, photo affordances |
| `--green-hover` | `#8fbc55` | Green hover/pressed |
| `--blue` | `#4885c1` | **Primary interactive** — Parent card, primary buttons, FAB, links, active tab, wordmark on cream |
| `--blue-hover` | `#3a74ad` | Blue hover/pressed |
| `--sky` | `#92bfec` | Selected pill in segmented controls (with ink text), text-post affordances |
| `--accent` | `#ff921e` | Marker orange — month names, star doodles, celebratory highlights |
| `--today` | `#c4785e` | "Today" marker in calendars (warm, non-interactive signal) |
| `--heart` | `#da4b91` | Hearts / reactions |

### Ink (single warm-gray family)

| Token | Hex | Usage |
|---|---|---|
| `--ink` | `#1a1410` | Headings, primary text |
| `--ink-soft` | `#5f5648` | Secondary text |
| `--ink-light` | `#8a7664` | Muted text, calendar day numbers, placeholders |

### Surfaces & lines

| Token | Hex | Usage |
|---|---|---|
| `--card` | `#ffffff` | Cards, calendar sheet, inputs, view-toggle track |
| `--card-warm` | `#faf6ef` | Warm secondary surfaces |
| `--line` | `#e4dcca` | Borders, dividers (calendar interior gridlines may use neutral `#d9d9d9`) |

Rules:
- One primary interactive color: **blue**. Green is brand/identity and secondary emphasis — don't use both on the same control.
- Orange is editorial garnish (display type, stickers), never a button color.
- Shadows are always warm-tinted, never pure black: neutrals `rgba(80,60,20,α)` (α .06–.22), blue glows `rgba(72,133,193,α)`, deep blue button shadows `rgba(50,98,148,α)`, green glow `rgba(126,168,74,α)`.

### Legacy aliases

Older CSS still references the v1 names; they are aliased in `:root` — do not repoint them individually:
`--terracotta → --blue`, `--peach-btn → --green`, `--gold → --accent`, `--sage → --green`,
`--rose → --heart`, `--cloud → --sky`, all `--bg-*` → `--cream`. New code should use the v2 names.

## 3. Typography

| Role | Token / family | Notes |
|---|---|---|
| Wordmark & serif headings | `--font-serif` · **Fraunces** | SemiBold 600, tight tracking (−1px at display sizes), `font-variation-settings:'SOFT' 0,'WONK' 1`. Wordmark is upright — no italics. White on green/blue splash; blue or green on cream. |
| Calendar display (month names) | `--font-display` · **Lora** | SemiBold **Italic**, color `--accent` (orange). Display-only — never body copy. |
| Handwritten notes | `--font-hand` · **Patrick Hand SC** | Text posts, captions-as-notes, scrapbook annotations. Regular 400 only. |
| UI / body | `--font-sans` · **Inter** | 400 body · 500 labels · 600 emphasis/active nav · 700–800 buttons & stats. Tabular figures for data. |

Fluid type scale (`--text-xs` … `--text-3xl`) is unchanged from v1.

## 4. Shape

| Element | Radius |
|---|---|
| Buttons, inputs, small cards | 16px |
| Role/feature cards | 16–18px |
| Large sheets & calendar card | 20px (bottom sheets 24px top) |
| Pills, segmented controls, chips | fully rounded (≥ 40px) |
| Floating nav | 60px pill, FAB circle embedded |
| Polaroids | 1–3px (photo paper), rotated −13° … +5° |

## 5. Key components (from the Redesigned frames)

- **Splash** (`156:1532`): full-bleed `--green` or `--blue`, centered white Fraunces wordmark 72px. Cream variants use green/blue wordmark.
- **Role cards** (`156:1436`): 150×150, radius 16, green (Family) / blue (Parent); icon in 40px `rgba(255,255,255,.2)` rounded square; white Inter Bold 16 title + 12/80% description. Farm-animal sticker accents nearby.
- **Primary button** (`156:1519`): blue, radius 16, white Inter Bold ~17, `padding-block:16px`; disabled = 40% opacity. Text "Continue →".
- **Input** (`156:1517`): `rgba(255,255,255,.7)` fill, 1.4px **white** border, radius 16, placeholder `--ink-light`.
- **Segmented control** (`156:1538`): white track pill, selected segment `--sky` with **ink** text (not white).
- **Calendar** (`156:1535`): white card radius 20 with warm shadow on cream; Lora italic orange month; `#d9d9d9` hairline grid, current-week line in `--blue`; day numbers Inter 9–11px `--ink-light`; **today** bold `--today`. Posts appear as tilted polaroids (white frame, warm drop shadow, pink hearts caption) and Patrick Hand SC text notes. Doodle stickers (star/flower/cloud/leaf/starfish, ~10% scatter, rotated) decorate the card. Clipboard-clip graphic at top.
- **Floating tab bar** (`156:1713`): 60px-tall pill (269px), `--surface` bg, hairline top border `rgba(37,26,14,.12)`, active label SemiBold ink; blue 52px FAB with white plus, shadow `rgba(72,133,193,.34)`.

## 6. Patterns & stickers (Figma assets, "Redesigned" page)

Background patterns (use at low-key scale behind calendar/photo screens, one per screen):
- Hand-drawn **blue grid** on cream (`156:1242`) · **clouds** on sky blue (`156:1246`) · **green gingham** (`156:1250`) · **periwinkle polka dots** (`156:1254`, base ≈ `#aebadf` → `--lavender`)

Sticker library (Moodboard section `156:1881`): farm set (cow, duck, sheep, pig, tractor, rainbow, birdhouse, apple tree), doodles (star, flower, starfish, cloud, leaf, heart). Use 1–3 per screen, rotated ±8–20°, ~55–100% opacity. They decorate; they never carry meaning.

## 7. Motion & texture

Unchanged from v1: `--ease-out: cubic-bezier(.22,1,.36,1)`, 200–350ms transitions, press = scale ~.96,
staggered entrances, grain overlay kept (fits the paper feel). Respect `prefers-reduced-motion`.

## 8. Accessibility notes

- `--green` and `--sky` fail contrast for small white text — use ink text on sky; keep white text on green ≥ 16px Bold (role cards) or prefer ink.
- Blue `#4885c1` on white/cream is ~3.9:1 — fine for large/bold text and UI components; avoid for small body text.
- Ink on cream ≥ 12:1. Focus rings: 2px `--blue`. Touch targets ≥ 44px. High-contrast overrides in `@media(prefers-contrast:high)`.
