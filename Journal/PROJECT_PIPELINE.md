# Handover Document: Ingredient Scanner App

> **Purpose of this document:** This is a complete context dump for anyone — human or AI — picking up this project without prior conversation history. It captures not just decisions, but the reasoning behind them, so the "why" isn't lost. Read this fully before proposing changes to scope or architecture; several options were already considered and deliberately rejected (noted inline as "Rejected:").

**Project:** Ingredient Scanner App — Capstone Project (UCS503P, Thapar Institute of Engineering and Technology)
**Team:** 2–3 members · **Timeline:** One semester (~4–6 months)
**Current status:** Planning and requirements complete. Entering implementation phase, starting with a basic working prototype (extraction pipeline + initial dataset).

---

## 1. The idea, in one paragraph

A user photographs a packaged product. The app reads the ingredient list directly from the photo (not via barcode lookup), flags any ingredients known to be harmful with plain-language health-effect explanations, and suggests healthier alternative products in the same category and price range. Built specifically for the Indian market. Positioned as "Yuka, but built for India" — same category of product, different underlying data and extraction approach.

---

## 2. Market validation and competitive landscape

**The problem is real:** rising health consciousness in urban India, combined with genuinely unclear or absent ingredient labeling on many products.

**Direct competitors exist** — this is a validated category, not a novel idea:

- **Yuka** — the global benchmark (80M+ users), scans food and cosmetics, flags harmful ingredients, suggests alternatives. Scoring is calibrated to **Western (EU/US) additive standards**, not FSSAI, and has no real handling of Indian brands, ingredients, or allergens.
- **FactsScan** — an existing India-focused competitor already targeting this exact gap.

**Conclusion:** the idea is validated but not novel — differentiation has to be real and specific, not just "same thing, India flag."

### Our differentiation strategy

1. **Image-first, not barcode-first.** Most competitors rely on barcode-to-database lookup, which structurally fails for unbranded, regional, and small-vendor Indian products — a large share of the market — because they're never barcode-indexed. Reading the ingredient panel directly from a photo covers this long tail.
2. **India-specific harmful-ingredient data**, cross-referenced against FSSAI regulation rather than EU/US standards.
3. **Spice/masala adulteration** flagged as a strong, documented India-specific angle (see Section 3) — positioned as a *future/flagship feature*, not MVP scope.
4. **Price-aware alternatives** — Indian users are price-sensitive; suggesting a healthier product 3x the price won't convert. Alternatives should be matched within a comparable price band.

**Rejected:** trying to out-compete Yuka/FactsScan on barcode database coverage. Not winnable in a semester; not the right fight.

---

## 3. Problem statement

Three concrete gaps in existing tools, from the Indian consumer's perspective:

1. **Barcode dependency excludes local products.** Global apps require the product to already exist in a barcode database. Most local/regional Indian products never will.
2. **Many local products carry no printed ingredient list at all.** Local sweets, bakery items, loose-packaged snacks are common in India and often have nothing to read in the first place — this is the single hardest sub-problem in the whole project (see Section 6).
3. **Existing scoring isn't localized.** EU/US additive standards ≠ FSSAI guidance. Indian allergens and Ayurvedic/traditional ingredients aren't accounted for by Western-built tools.

**Why now (supporting evidence, already sourced):** Gujarat authorities seized over 60,000 kg of adulterated spices (turmeric, chili powder, coriander powder, pickle masala) in a single sweep in April 2024. Hong Kong and Singapore both banned popular Indian spice brands after detecting the carcinogenic pesticide ethylene oxide. This is a live, documented food-safety issue, not a hypothetical.

---

## 4. Product categories: scope decision

**Considered categories beyond food:** cosmetics/personal care (strong fit — mercury/hydroquinone in skin-lightening creams, heavy metals in kohl/sindoor are real, India-specific, well-documented issues), oral care, household cleaning, baby products, dietary supplements, packaged beverages.

**Explicitly rejected for this project (any phase):**

- **Medicines/pharmaceuticals** — regulatory/liability risk too high, a misclassified drug interaction could cause real harm.
- **Tobacco/paan products** — sensitive, regulated, no "healthier alternative" framing makes sense.
- **Toys, textiles, paints** — real safety issues exist (lead paint, azo dyes) but these are material-safety problems, not ingredient-list scanning — different pipeline entirely, out of scope.

**MVP decision: food only.** Cosmetics is the natural second category (same architecture, different data) but is explicitly deferred, not built, in the MVP. Packaged spices/masalas are treated as a sub-case within food, not a separate category.

---

## 5. System architecture

### 5.1 Core pipeline

```
Photo Upload → Extraction Service → Classification Engine → Alternatives Engine → Results
```

A separate **Category Configuration store** (categories, ingredients, aliases, harm rules, alternatives data) feeds the Classification and Alternatives modules.

### 5.2 The central design principle: category is data, not code

Category-specific behavior (which ingredients matter, what counts as harmful, what alternatives exist) must be **driven by configuration/database content**, never hard-coded per category in the pipeline logic. Adding cosmetics later should mean "insert new rows," not "rewrite the classification module." This was an explicit, deliberate product decision: *"we are not going to cut on any features and make app in such a way its fully scalable and features can be added later on."*

### 5.3 Deployment architecture: modular monolith, not microservices

**Rejected:** real deployed microservices for the MVP — too much infrastructure overhead for a one-semester team.
**Chosen:** a single deployable backend with clearly separated internal modules (`extraction/`, `classification/`, `alternatives/`, `data/`), each behind a clean interface. Gets the benefit of clean separation (easy to later split into real services) without the deployment cost now.

### 5.4 Extraction vs. classification split — the most recent and most important architectural decision

This was explicitly debated: should we "just wrap GPT" for everything, or build a custom model/dataset? **Answer: neither alone — split responsibilities.**

| Layer                                                                        | Approach                                                                                                | Why                                                                                                                                                                                                      |
| ---------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Reading the image** (OCR/extraction)                                 | Use an existing vision-capable API (GPT-4V / Gemini / Claude vision)                                    | These APIs already read real-world packaging text well; training a custom OCR/vision model from scratch is infeasible in one semester and would be worse than off-the-shelf anyway                       |
| **Deciding what's harmful** (classification)                           | Deterministic lookup against**our own curated database**, not LLM judgment                        | LLMs hallucinate on exactly the kind of specific, falsifiable health claims this app makes; a wrong claim shown to a real user is a liability problem, and "the model said so" is not a traceable source |
| **Explaining health effects**                                          | Pre-written, sourced text stored per ingredient in our database                                         | Same reasoning — don't let the model invent explanations live                                                                                                                                           |
| **Matching messy/misspelled OCR output to canonical ingredient names** | Embedding similarity search (off-the-shelf embedding API + cosine similarity), backed by an alias table | Cheap, fast, deterministic-ish — not another LLM reasoning call                                                                                                                                         |

**Key takeaway for whoever builds this:** the vision API is the extraction engine ONLY. The curated India-specific ingredient database is the actual product and the main source of technical differentiation and defensibility — it is not optional infrastructure, it *is* the project's core IP.

**Rejected approaches:**

- Pure "GPT wrapper" (model does extraction AND harm judgment AND explanation) — inconsistent, unsourced, hallucination-prone, hard to evaluate against precision metrics.
- Training a custom classification/vision model from scratch — no time, no data volume, no benefit over off-the-shelf + curated database.

---

## 6. Handling products with no ingredient list (hardest sub-problem)

This is the single biggest differentiator opportunity and the hardest engineering problem. No single fix — combine four strategies:

1. **Category-based generic risk profiling (primary MVP solution).** When no ingredient list is detected, classify the product into a known food sub-category (e.g., "besan sev," "boondi laddoo," "bakery rusk") using whatever text/visual cues are available, then show a generic, category-level risk profile ("products in this category commonly contain palm oil, added sugar...") with a clear **"estimated, not exact"** disclaimer. Never claim to know the exact recipe.
2. **FSSAI license number lookup (stretch/future, not MVP).** If a 14-digit FSSAI license number is visible on the pack, OCR it and query FoSCoS (India's public food business registry) to confirm legitimacy and pull business/category info. This does **not** give an ingredient list — it's a trust/category signal only. Absence of a visible license number is itself a red flag worth surfacing.
3. **Crowdsourced ingredient database (future, Open Food Facts model).** Let users who know a local product's actual recipe submit it. Build the *infrastructure* (submission endpoint/schema) now; do not depend on it for MVP — a semester isn't enough time to build real community coverage.
4. **Manual user entry (MVP fallback of last resort).** If nothing else works, let the user type or dictate known ingredients, so the flow never dead-ends.

---

## 7. MVP scope (locked)

**In scope:**

- Single category: food (packaged spices/masalas as a notable sub-case, not a separate build)
- English-language labels only (Hindi = stretch goal, not committed)
- Photo-based extraction only, zero barcode dependency
- Curated harmful-ingredients database: ~150–300 ingredients
- Category-based fallback for unbranded products (Section 6, strategy 1)
- Simple rule-based (not ML recommendation engine) healthier alternatives, price-band matched

**Explicitly out of scope for MVP (do not build, even if it seems easy):**

- Cosmetics or any category beyond food
- Crowdsourcing at scale
- FSSAI/FoSCoS lookup integration
- Regional-language OCR beyond English
- Visual product-matching for previously-seen unbranded products
- Any custom-trained OCR/vision/classification model

---

## 8. Functional requirements (condensed — full table with priorities exists in the requirements doc, see Section 12)

| Area               | Key requirements                                                                                                                                                         |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Image capture      | Camera/upload, capture guidance, confidence-based retake prompt                                                                                                          |
| Extraction         | Vision API → structured list; alias/name normalization (E621/MSG/Ajinomoto → one canonical entity); provider abstracted behind an internal interface so it's swappable |
| Classification     | Deterministic check against curated harm database; plain-language health effects; overall risk indicator; category-driven rules (not hard-coded)                         |
| Unbranded fallback | Category classification → generic risk profile with disclaimer → optional FSSAI signal → manual entry as last resort                                                  |
| Alternatives       | Same-category suggestions, price-comparable matching                                                                                                                     |
| Results display    | Single results screen; confidence level always shown to the user                                                                                                         |

---

## 9. Recommended tech stack

| Layer                 | Recommendation                                                                                                              |
| --------------------- | --------------------------------------------------------------------------------------------------------------------------- |
| Ingredient extraction | Vision-capable API (GPT-4V / Gemini / Claude vision), wrapped behind an internal interface — extraction only, not judgment |
| Backend               | Modular monolith — Node.js/Express or Python/FastAPI                                                                       |
| Database              | PostgreSQL — relational schema: categories, ingredients, aliases, harm rules, alternatives                                 |
| Ingredient matching   | Embedding similarity search (off-the-shelf embedding API + cosine similarity) against canonical names + aliases             |
| Async processing      | Lightweight job queue (BullMQ or Celery) so extraction calls don't block the UI                                             |
| Frontend              | Mobile-first responsive web app or native app                                                                               |
| Image storage         | Object storage                                                                                                              |

---

## 10. Building the India-specific dataset — the actual differentiator (step-by-step)

This is the highest-value, most original work in the project. Steps, in order:

1. **Seed with Open Food Facts**, filtered to India-tagged products. Gives real ingredient text from real Indian products, downloadable as CSV/JSONL/Parquet.
2. **Tokenize and frequency-rank** the raw ingredient strings from that India-filtered dump (split on commas/semicolons, normalize casing). The ~150–200 ingredients that appear most often across real Indian products are the ones to curate first — this is data-driven prioritization, not guesswork.
3. **Cross-reference each ingredient** against:
   - **FSSAI's Compendium on Food Safety and Standards (Food Additives) Regulation** — for INS number, permitted category, legal limits (authoritative but exists as regulatory PDF text; needs manual parsing into structured form — this is real, defensible capstone work)
   - **JECFA/EFSA classifications** — for health-effect descriptions where FSSAI doesn't provide detail
4. **Manually add known India-specific flags** that might not surface purely from frequency: palm oil, Ajinomoto/MSG, artificial colors common in Indian sweets (Tartrazine, Sunset Yellow), vanaspati/trans fats, sodium benzoate.
5. **Build the alias table** now: E-number ↔ common name ↔ regional name, all resolving to one canonical ingredient (needed for FR-6).
6. **Pre-write health-effect explanation text** for each curated ingredient directly into the database — do not generate these live via LLM (see Section 5.4 reasoning).

**Supplementary source:** Kaggle datasets ("Food Ingredients and Allergens," "Allergen Status of Food Products") are useful for bootstrapping the classification schema shape before India-specific refinement, but are not India-specific themselves.

---

## 11. Timeline (one semester, 2–3 person team)

| Phase | Weeks  | Focus                                                                                                                                                |
| ----- | ------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1     | 1–3   | Scope lock; begin harmful-ingredients database (Section 10)                                                                                          |
| 2     | 4–6   | Core extraction pipeline — vision API integration + parsing (Section 5.4)                                                                           |
| 3     | 7–9   | Classification & scoring engine; unbranded-product fallback (Section 6)                                                                              |
| 4     | 10–12 | Alternative suggestions; app UI                                                                                                                      |
| 5     | 13–15 | Testing against real product photos; fixes                                                                                                           |
| 6     | 16+    | Buffer; stretch goals only if core is genuinely solid — do not start cosmetics, crowdsourcing, or FSSAI lookup unless there are real weeks to spare |

**Current position (as of this document):** entering Phase 1/2 — building the basic extraction prototype and starting dataset curation in parallel.

---

## 12. Evaluation criteria (course-format proposal)

- **Primary metric — Time-to-Result (TTR):** time from photo upload to full result (flags + health-effect notes + alternatives) being returned. Target: median ≤ 5 seconds, excluding upload time. Measured via server-side timestamps.
- **Secondary metrics:**
  - Extraction accuracy — vs. manually transcribed ground truth on a test set of product photos
  - Flagging precision — vs. the curated database, on the same test set
  - Fallback-classification correctness — unbranded products correctly matched to food sub-category
  - User-reported clarity — 1–5 self-reported score from pilot testers
  - Reliability — ≥99% staging uptime during pilot
- **Pilot plan:** 10–15 testers, mix of branded and unbranded products, compared against manual expert review of the same ingredient panels.

---

## 13. Risks and mitigations

| Risk                                                                         | Mitigation                                                                                                                                                      |
| ---------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Extraction inaccuracy on real packaging (glare, curved surfaces, small text) | Confidence scoring + retake prompts (FR-3)                                                                                                                      |
| Health-claim liability                                                       | Only sourced/traceable data in the database; clear "estimated, not exact" disclaimers on fallback results                                                       |
| Vision API cost at scale                                                     | Cache repeated extractions; keep pilot volume small; extraction-only API usage (not per-request classification reasoning) keeps cost down                       |
| Ingredient database build effort                                             | Frequency-driven prioritization (Section 10, step 2) instead of exhaustive coverage; combine Open Food Facts + FSSAI + Kaggle rather than building from nothing |
| User trust in estimated (non-exact) results                                  | Always surface confidence level and data source in the UI                                                                                                       |

---

## 14. Deliverables already produced

| File                                                        | Contents                                                                                                                                                                                                                                                                                                           |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `Ingredient_Scanner_MVP_Requirements.docx`                | Full requirements doc: scope, FR/NFR tables with priorities, architecture, data, tech stack, timeline, success criteria                                                                                                                                                                                            |
| `Ingredient_Scanner_MVP_Pitch.pptx`                       | Pitch deck: Introduction, Motivation, Problem Statement, Solution                                                                                                                                                                                                                                                  |
| `Ingredient_Scanner_MVP_Proposal.tex` (+ PDF preview)     | Standalone LaTeX project proposal                                                                                                                                                                                                                                                                                  |
| `Ingredient_Scanner_UCS503P_Proposal.tex` (+ PDF preview) | Same proposal, reformatted to match the UCS503P course template (Higher-order goal, Time-to-value, Evaluation Criterion, Scalability, Engine availability heuristic sections) —**still needs real names/roll numbers/emails filled in before submission; confirm professor/course code match your section** |

---

## 15. Open decisions — not yet made, needs a call before/during Phase 2

- Exact vision API provider (GPT-4V vs. Gemini vs. Claude vision) — needs a cost/accuracy tradeoff test early, using the ~15-20 test photo set mentioned in Section 5.4/10.
- Whether Hindi OCR is attempted at all this semester, or fully deferred.
- Final ingredient database size within the 150–300 range — depends on how much of Phase 1 time is actually available.
- Team role split — not discussed yet.
- Exact embedding API/similarity threshold for the alias-matching layer — not yet chosen.
