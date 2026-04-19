# Design System Specification: The Tactile Atelier

This design system is a bespoke framework designed to move beyond the rigid, flat constraints of standard mobile e-commerce. It is built on the philosophy of "The Tactile Atelier"—treating the digital screen as a physical workspace where luxury is defined by space, light, and material depth rather than decorative excess.

---

## 1. Creative North Star: The Digital Curator
The goal of this system is to evoke the feeling of a high-end boutique. We achieve this through **Intentional Asymmetry** and **Tonal Depth**. Instead of standard "boxed" grids, we use overlapping elements and generous whitespace to create a sense of movement. The interface should feel like an editorial spread—sophisticated, calm, and curated.

---

## 2. Color & Materiality
The palette is rooted in organic, warm neutrals contrasted by deep, authoritative tones and a singular metallic accent.

### Color Tokens (Material Convention)
*   **Background / Surface:** `#faf9f5` (Warm White) / `#efeeea` (Surface Container)
*   **Primary (The Anchor):** `#000613` (Deep Navy)
*   **Secondary (The Accent):** `#735c00` (Subtle Gold)
*   **Tertiary (The Detail):** `#040604` (Charcoal)
*   **Neutral (The Foundation):** `#43474e` (Muted Gray)

### The "No-Line" Rule
To maintain a premium feel, **1px solid borders are strictly prohibited for sectioning.** Boundaries must be defined through:
1.  **Background Shifts:** Place a `surface-container-low` (#f4f4f0) card on a `surface` (#faf9f5) background.
2.  **Soft Shadows:** Use tonal elevation to separate content.
3.  **Whitespace:** Use the spacing scale to create invisible boundaries.

### The Glass & Gradient Rule
Floating elements (like bottom navigation bars or sticky headers) must use **Glassmorphism**. 
*   **Token:** `surface-container-lowest` (#ffffff) at 85% opacity.
*   **Effect:** `backdrop-filter: blur(20px)`.
*   **Gradients:** Use subtle linear gradients from `primary` (#000613) to `primary_container` (#001f3f) for high-conversion CTAs to add a "satin" sheen.

---

## 3. Typography: Editorial Authority
The typography pairing balances the tradition of a Serif with the modern efficiency of a Sans-Serif.

*   **Display & Headlines (Noto Serif):** Used for brand storytelling and product titles. This conveys "The Luxury."
    *   *Headline-LG (2rem):* Use for hero product titles.
*   **Titles & Body (Manrope):** A clean, high-legibility sans-serif used for navigation and descriptions. This conveys "The Accessible."
    *   *Title-MD (1.125rem):* Use for card headers.
    *   *Body-LG (1rem):* Standard reading text.

---

## 4. Elevation & Depth: Tonal Layering
We reject the "flat" web. We use a "Layering Principle" to create physical hierarchy.

### The Layering Principle
Stack tiers to define importance:
*   **Level 0 (Base):** `surface` (#faf9f5)
*   **Level 1 (Section):** `surface-container-low` (#f4f4f0)
*   **Level 2 (Active Element):** `surface-container-lowest` (#ffffff)

### Ambient Shadows
When an element must "float" (e.g., a "Buy Now" card):
*   **Shadow:** `0px 20px 40px rgba(27, 28, 26, 0.06)`
*   **Color Tip:** Never use pure black. The shadow should be a tinted version of `on-surface` to mimic natural light hitting a cream-colored surface.

### Ghost Borders
If an input or boundary requires a line for accessibility, use a **Ghost Border**:
*   **Token:** `outline-variant` (#c4c6cf) at **20% opacity**. It should be felt, not seen.

---

## 5. Components

### Buttons: The Tactile Interaction
*   **Primary:** `primary` (#000613) background, `on-primary` (#ffffff) text. **Radius: 20px (xl).** Add a subtle inner-glow gradient for a 3D pressed look.
*   **Secondary:** `surface-container-highest` (#e3e2df) background. No border.
*   **Tertiary:** Text-only in `secondary` (#735c00) for a refined gold accent.

### Cards & Lists: The No-Divider Rule
*   **Product Cards:** Use `surface-container-lowest` (#ffffff) with a `16px (lg)` corner radius. 
*   **Forbid Dividers:** Do not use lines between list items. Use 16px–24px of vertical padding and subtle shifts between `surface` and `surface-container-low`.

### Polished Input Fields
*   **Base State:** `surface-container-low` (#f4f4f0) background, `20px (xl)` corner radius.
*   **Focus State:** A "Ghost Border" of `secondary` (Gold) at 40% opacity.
*   **Labeling:** Floating labels using `label-md` (Manrope) to maximize vertical space.

### Signature Component: The "Perspective" Carousel
Instead of a standard horizontal scroll, use a carousel where the center image is slightly larger and has an Ambient Shadow, while the side images are slightly transparent and scaled down (90%), creating a 3D "gallery" feel.

---

## 6. Do’s and Don'ts

### Do
*   **Do** overlap images over cards to create 3D depth.
*   **Do** use gold (`secondary`) sparingly—only for price points or specific "Add to Cart" accents.
*   **Do** use "Surface Nesting" (a white card inside a cream section) to show hierarchy.

### Don’t
*   **Don't** use 1px solid black or gray borders.
*   **Don't** use sharp 90-degree corners; everything must feel soft to the touch.
*   **Don't** crowd the screen. If a page feels full, add 20% more whitespace between sections.
*   **Don't** use standard blue for links. Use the `primary` navy or `secondary` gold.

---

## 7. Accessibility Note
While the system leans into soft contrasts, ensure all `on-surface` text vs. `surface` background maintains a minimum 4.5:1 ratio. For the Gold (`secondary`) accent, use it primarily for non-text decorative elements or combine it with the `primary` navy background for high-contrast legibility.