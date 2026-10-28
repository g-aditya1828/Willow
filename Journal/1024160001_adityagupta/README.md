# 📓 Dev Journal: Aditya Gupta

**Name:** Aditya Gupta  
**Roll Number:** 1024160001  
**Course:** Software Engineering (UCS503) | **Group:** 3P11  
**Project:** 🌿 **Willow: AI-Powered Ingredient & Food Safety Scanner for the Indian Market**  
**Role:** Core Backend Architecture, Computer Vision / OCR, Safety Classifier & Data Engineering  
**Teammate:** Akanksha Thakur (1024160019) — *Work split equally (50/50) across system architecture, engineering, and documentation.*

---

## 🧭 Project Overview & My Role

Willow is an AI-driven ingredient scanner tailored specifically for the **Indian food ecosystem**. Unlike Western tools that depend on barcode databases and EU/US standards, Willow extracts ingredient panels directly from photos and evaluates them against **FSSAI food safety regulations**, featuring smart fallbacks for unbranded regional foods and recommending price-comparable healthier alternatives.

In our two-person team, my primary focus has been **Backend Architecture, Computer Vision / OCR Extraction, Safety Classification Algorithms, Database Engineering, and API Security**, while working in close synergy with Akanksha on system design, interface contracts, and end-to-end testing.

---

## 🗓️ Weekly Progress Log (Equal Work Division)

### 📌 Week 1: Research, Problem Definition & Data Feasibility (Aug 25 – Aug 31, 2026)
- **Focus:** Market research, regulatory analysis, and database feasibility for Indian products.
- **What I Did:**
  - Analyzed competitive gaps in barcode-dependent apps (Yuka, FactsScan) regarding regional, unbranded Indian products and loose items.
  - Investigated documented food adulteration cases in India (e.g., Gujarat FDCA seizures of 60,000+ kg adulterated spices; international ethylene oxide alerts for MDH and Everest).
  - Evaluated public datasets including the Open Food Facts India dump and FSSAI regulatory schedules to determine additive naming patterns and INS codes.
  - Formulated the 4-stage processing pipeline hypothesis: *Photo Capture → OCR/Vision Extraction → Canonical Normalization & FSSAI Scoring → Healthier Alternatives*.
  - Drafted the initial technical architecture presentation slides.
- **Key Takeaways & Challenges:** Barcode indexing systematically fails for Indian unbranded products (~40%+ of local retail). Direct image extraction backed by a curated FSSAI database is the true defensible core of this project.

---

### 📌 Week 2: Architectural Boundary Design & Project Proposal (Sep 1 – Sep 7, 2026)
- **Focus:** Architectural design decisions and formal academic project proposal.
- **What I Did:**
  - Co-authored the UCS503P Project Proposal in LaTeX (`project_proposal/proposal.tex`), defining high-order goals, scope, evaluation metrics, and timeline.
  - Established a critical architectural principle: **Strictly separate text extraction from safety classification**. Large Language Models (LLMs) hallucinate on health claims; extraction is delegated to vision models, but harmfulness scoring is strictly deterministic against our curated database.
  - Specified non-functional requirements: target median Time-to-Result (TTR) ≤ 5 seconds, modular monolith backend structure, and pluggable extraction interfaces.
  - Collaborated with Akanksha to align API boundaries with her Level 0 and Level 1 Data Flow Diagrams (DFDs).
- **Key Takeaways & Challenges:** Treating "category as data, not code" ensures that future product extensions (e.g., cosmetics) will require only database rows rather than pipeline rewrites.

---

### 📌 Week 3: Baseline OCR Pipeline & Advanced Text Parsing (Sep 8 – Sep 14, 2026)
- **Focus:** Building the local OCR extraction engine and ingredient text parsing logic.
- **What I Did:**
  - Integrated **Tesseract OCR** (`pytesseract`, Pillow) as a free, local fallback engine for development and offline testing.
  - Implemented computer vision image pre-processing routines: adaptive grayscale thresholding, contrast stretching, and noise reduction to improve OCR accuracy on noisy packaging.
  - Developed the core parsing layer (`codes/OCR/extractor/extraction/parser.py`):
    - Comma and semicolon splitting while preserving nested parenthetical additives (e.g., `"Raising Agents (INS 500(ii))"` treated as a single entity).
    - Stripping packaging prefixes (e.g., `"INGREDIENTS:"`, `"CONTAINS ADDED FLAVOUR"`).
    - Whitespace normalization and duplicate removal.
  - Created an automated unit test suite (`test_parser.py`) with 10 comprehensive test cases verifying nested brackets, multiple separators, and edge cases (100% pass rate).
- **Key Takeaways & Challenges:** Tesseract performs well on clean, flat labels but degrades severely on shiny, crinkled plastic wrappers and curved packaging, reinforcing the need for cloud multimodal AI.

---

### 📌 Week 4: Google Gemini Multimodal Vision API Integration (Sep 15 – Sep 21, 2026)
- **Focus:** Cloud multimodal AI vision pipeline and project schedule engineering.
- **What I Did:**
  - Integrated the **Google Gemini Multimodal Vision API** (`gemini_vision.py`) into the extraction pipeline behind our abstract `IngredientExtractor` interface.
  - Engineered few-shot system prompts instructing Gemini to output clean, structured JSON containing raw text, segmented ingredients, detected INS codes, and potential allergens.
  - Built a benchmarking harness to compare extraction latency and precision between Tesseract and Gemini Vision across challenging packaging images.
  - Developed the semester project Gantt chart (`docs/Willow_gantt_chart.xlsx` & PDF) mapping milestones from Phase 1 through Phase 6.
- **Key Takeaways & Challenges:** Multimodal AI achieved superior extraction accuracy on curved, multi-lingual, and low-contrast Indian product packaging where classical OCR failed completely.

---

### 📌 Week 5: Flask REST API & Mid-Semester Evaluation (Sep 22 – Sep 28, 2026)
- **Focus:** API wrapper development, mobile integration, and mid-sem evaluation reporting.
- **What I Did:**
  - Developed a Flask REST API service exposing the `/extract` endpoint to receive multipart image uploads from Akanksha’s Flutter mobile app.
  - Implemented platform-specific network bridging (handling Android emulator `10.0.2.2`, iOS simulator `127.0.0.1`, and local LAN routing for physical device testing).
  - Authored Chapter 2 (Methodology, System Architecture & Implementation Details) and Chapter 3 (Results, Performance Metrics & Evaluation) in the formal Mid-Semester Report (`mid_sem_report/project_report.tex`).
  - Successfully demonstrated the live end-to-end workflow: *Camera Capture → Mobile Upload → Backend Vision Extraction → Parsed JSON Display*.
- **Key Takeaways & Challenges:** Documenting environment-specific base URLs resolved communication bottlenecks during physical device testing. The mid-semester review validated our core extraction pipeline.

---

### 📌 Week 6: Relational Database Architecture & FSSAI Additives Seeding (Sep 29 – Oct 5, 2026)
- **Focus:** Relational database implementation, additive curation, and schema migrations.
- **What I Did:**
  - Designed and implemented the complete relational schema in SQLite (`codes/OCR/extractor/database.py`, `willow.db`) based on the ER model co-designed with Akanksha:
    - Tables: `categories`, `ingredients`, `ingredient_aliases`, `category_risk_profiles`, `product_alternatives`, `users`, and `scan_history`.
  - Parsed and curated data from the **FSSAI Compendium on Food Additives Regulation**, populating over 150 canonical food ingredients and 300+ aliases/INS numbers.
  - Mapped each additive to risk tiers (`LOW`, `MEDIUM`, `HIGH`) with authoritative, plain-language health explanations and regulatory limits.
  - Programmed automated lookup indexes for high-speed canonical name resolution and alias matching.
- **Key Takeaways & Challenges:** Populating authoritative FSSAI regulatory data by hand and through automated extraction is tedious but provides the core intellectual property and reliability of our application.

---

### 📌 Week 7: Safety Classification Engine & Unbranded Product Fallback (Oct 6 – Oct 12, 2026)
- **Focus:** Deterministic safety scoring algorithms and smart category-level fallback.
- **What I Did:**
  - Developed the core Safety Classifier (`codes/OCR/extractor/classifier.py`):
    - Resolves raw extracted strings against canonical database entities via the alias dictionary.
    - Calculates an overall product health score (0–100 scale) based on weighted penalties: Nutrition (60%), Additive Risk (30%), and Clean/Organic status (10%).
  - Implemented the **Smart Local-Food Fallback Engine**:
    - When no ingredient list is detected (e.g., loose sweets, bakery items, unlabelled namkeen), classifies the product into a known sub-category.
    - Retrieves a generic, estimated category risk profile clearly tagged with: *"⚠️ Estimated, not exact"*.
  - Built the Open Food Facts lookup service (`off_service.py`) for barcode/product fallback and nutritional metadata enrichment.
  - Implemented the computer vision image quality pre-checker (`image_quality.py`) calculating Laplacian variance for blur and brightness thresholds for glare/underexposure.
- **Key Takeaways & Challenges:** The fallback mode solves the hardest problem in Indian food scanning: delivering actionable guidance for unlabelled traditional food without making false factual claims.

---

### 📌 Week 8: Backend Server Expansion, Auth & API Security (Oct 13 – Oct 19, 2026)
- **Focus:** Full REST API development, authentication system, and endpoint security.
- **What I Did:**
  - Rebuilt and expanded the backend server (`codes/OCR/extractor/api_server.py`) into a comprehensive API service supporting:
    - User Authentication: `POST /auth/register`, `POST /auth/login`.
    - Scanning & Analysis: `POST /extract`, `POST /classify`.
    - User History: `GET /history`, `POST /history`.
    - Product Recommendations: `GET /alternatives`.
    - System Health: `GET /health`.
  - Developed the API security module (`codes/OCR/extractor/security.py`):
    - PBKDF2 with SHA-256 password hashing and secure salt generation.
    - JWT/Session token validation, token expiration, and payload decryption.
    - IP-based rate limiting and input sanitization preventing injection attacks.
  - Wrote comprehensive automated API integration tests (`test_api.py`) verifying auth flows, scan uploads, and error responses.
- **Key Takeaways & Challenges:** Securing endpoints with token authentication and rate limiting prevents API abuse and guarantees safe client communication for multi-user deployments.

---

### 📌 Week 9: Healthier Alternatives Engine & Query Optimization (Oct 20 – Oct 26, 2026)
- **Focus:** Recommendation algorithms for healthier food substitutes within comparable price bands.
- **What I Did:**
  - Programmed the Alternatives Recommendation Engine (`classifier.py`, `database.py`):
    - Recommends products from the same food sub-category with strictly better risk profiles.
    - Enforces **price-band matching** (Budget, Mid-range, Premium) so recommendations are realistic for everyday consumers.
  - Seeded the database with 40+ curated Indian healthier alternatives (e.g., cold-pressed peanut oil vs. refined palm oil; jaggery-based sweets vs. artificial syrup confections).
  - Optimized database query indexes on canonical names, INS codes, and sub-categories, reducing classification query latency to < 45ms.
  - Refined Gemini Vision prompts to handle edge cases involving bilingual Hindi/English packaging.
- **Key Takeaways & Challenges:** Indian consumers are highly price-sensitive. Recommending an alternative that costs 3x more causes abandonment; matching within the same price band ensures real behavioral change.

---

### 📌 Week 10: Performance Benchmarking, Real-World Testing & Final Refactoring (Oct 27 – Nov 2, 2026)
- **Focus:** Real-world photo validation, bug fixes, latency benchmarking, and repository sync.
- **What I Did:**
  - Evaluated the entire pipeline against a test dataset of 25+ real packaging photographs captured under variable lighting, angles, and surface curves:
    - Measured median Time-to-Result (TTR): 3.8 seconds (well within our ≤ 5.0s SLA target).
    - Achieved 94.2% ingredient extraction accuracy on legible product packaging.
  - Resolved CORS header issues and streaming timeout bugs for high-resolution mobile camera uploads.
  - Updated the database with additional regional Indian food additives, preservative INS codes, and common spice adulterants (Sudan dye, synthetic colorants).
  - Coordinated with Akanksha on final frontend/backend API contracts, git branch merges, and project documentation synchronization.
- **Key Takeaways & Challenges:** Rigorous testing on real packaging proved that combining cloud multimodal extraction with local deterministic FSSAI scoring delivers both high speed and reliable, hallucination-free safety assessments.

---

## 🛠️ My Tech Stack & Tools

| Component | Technologies & Tools |
| :--- | :--- |
| **Backend & APIs** | Python, Flask, REST API Architecture, HTTP Multipart Streaming |
| **OCR & Multimodal Vision** | Google Gemini Vision API, Tesseract OCR (`pytesseract`), Pillow, OpenCV |
| **Database & ORM** | SQLite (`willow.db`), PostgreSQL Schema, Relational Indexing, SQL DDL |
| **Data Sources** | FSSAI Food Additives Compendium, Open Food Facts India, Kaggle |
| **Security & Auth** | PBKDF2 Password Hashing, SHA-256, Session/JWT Tokens, Rate Limiting |
| **Testing & Quality** | PyTest, Unit Testing, API Integration Testing (`test_api.py`), Benchmarking |
| **Version Control & Docs**| Git, GitHub, LaTeX (`project_report.tex`, `proposal.tex`), Markdown |

---

## ⚖️ Division of Responsibilities (Equal 50/50 Split)

| System Domain | Aditya Gupta (1024160001) | Akanksha Thakur (1024160019) | Split |
| :--- | :--- | :--- | :---: |
| **Vision & Image Pipeline** | Gemini Vision API integration, Tesseract fallback, `parser.py`, unit test suite | Mobile camera controller, image picker, real-time quality validation alerts | **50 / 50** |
| **Safety Engine & Data** | FSSAI additive curation (150+ items, 300+ aliases), risk scoring algorithm, DB engine | Entity-Relationship (ER) model design, category risk profiling, UI data display | **50 / 50** |
| **Architecture & Modeling** | Core architectural boundaries, API route contracts, latency optimization | UML diagrams (DFD L0/L1/L2, Use Cases, ER, Activity, Sequence, Class diagrams) | **50 / 50** |
| **User Interfaces** | REST API endpoints, auth routes, database query services, security middleware | Flutter mobile app (all screens), design system, theme tokens, sticker layer | **50 / 50** |
| **Research & Docs** | Project proposal LaTeX, report methodology & results, performance evaluation | Pitch deck PPT, Web prototype (HTML/CSS/JS), report introduction & literature review | **50 / 50** |

---

## 📈 Current Project Status & Achievements

1. **Working End-to-End System:** Mobile capture → Backend extraction → FSSAI scoring → Result display is fully functional.
2. **Hallucination-Free Scoring:** Sourced from 150+ curated additives with official FSSAI regulatory references.
3. **Smart Fallback:** Unbranded local foods receive generic, estimated category safety profiles.
4. **Performance:** Median Time-to-Result is ~3.8 seconds, comfortably beating the 5-second project benchmark.
5. **Security & Accounts:** User registration, password hashing, and persistent scan history are live.

---

## 🚀 Next Steps
- Pilot testing with 10–15 diverse users on real Indian food products.
- Expanding the regional language alias dictionary (Hindi common names).
- Final semester report preparation and capstone presentation.
