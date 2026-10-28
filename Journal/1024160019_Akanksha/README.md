# 📓 Dev Journal: Akanksha Thakur

**Name:** Akanksha Thakur  
**Roll Number:** 1024160019  
**Course:** Software Engineering (UCS503) | **Group:** 3P11  
**Project:** 🌿 **Willow: AI-Powered Ingredient & Food Safety Scanner for the Indian Market**  
**Role:** Frontend Mobile App Architecture (Flutter/Dart), UI/UX Design System, UML System Modeling & Full-Stack Client Integration  
**Teammate:** Aditya Gupta (1024160001) — *Work split equally (50/50) across system architecture, engineering, and documentation.*

---

## 🧭 Project Overview & My Role

Willow is an AI-driven ingredient scanner tailored specifically for the **Indian food ecosystem**. Unlike Western tools that depend on barcode databases and EU/US standards, Willow extracts ingredient panels directly from photos and evaluates them against **FSSAI food safety regulations**, featuring smart fallbacks for unbranded regional foods and recommending price-comparable healthier alternatives.

In our two-person team, my primary focus has been **Frontend Mobile Engineering (Flutter/Dart), UI/UX Design System & Animation, UML Software Engineering Modeling (DFD, Use Case, ER, Activity, Sequence, Class Diagrams), Client-Side State Management, and Documentation**, while working in close synergy with Aditya on system architecture, data models, and end-to-end integration.

---

## 🗓️ Weekly Progress Log (Equal Work Division)

### 📌 Week 1: Research, UX Benchmarking & Web Prototype (Aug 25 – Aug 31, 2026)
- **Focus:** Market UX research, repository initialization, and consumer-facing prototype website.
- **What I Did:**
  - Initialized the main GitHub repository (`g-aditya1828/Willow`), established branch protection rules, directory layout, and team issue tracking.
  - Benchmarked user flows of top health apps (Yuka, MyFitnessPal) and mapped the consumer experience journey for Indian consumers dealing with obscure ingredient packaging.
  - Designed and built an interactive web prototype (`codes/frontend`: HTML5, CSS3, JavaScript):
    - Implemented a playful, sticker-and-illustration visual language inspired by modern consumer transparency aesthetics.
    - Built interactive modules: Hero introduction, How Willow Works, India-first local/unbranded food section, 0–100 Willow health score dial, demo product photo uploader, better alternatives showcase, and scientific FSSAI source citations.
    - Ensured full mobile-first responsive layout across phone, tablet, and desktop viewports.
  - Configured and deployed **GitHub Pages** to host live project updates, mockups, and documentation.
- **Key Takeaways & Challenges:** Health and chemical additive information is often intimidating to everyday shoppers; adopting an approachable, playful sticker aesthetic makes food safety engaging rather than stressful.

---

### 📌 Week 2: System Architecture, DFD Modeling & Project Blueprinting (Sep 1 – Sep 7, 2026)
- **Focus:** Architectural visualization, Data Flow Diagrams, and formal proposal documentation.
- **What I Did:**
  - Designed formal **Data Flow Diagrams (DFDs)** in Draw.io (`docs/diagrams/data_flow_diagram/`):
    - **DFD Level 0 (Context Diagram):** Modeled interactions between the Consumer, Willow System, Vision API Provider, and Regulatory FSSAI Database.
    - **DFD Level 1 (Process Decomposition):** Decomposed the system into distinct operational modules: Image Ingestion & Pre-validation, OCR/Vision Extraction, Ingredient Normalization & Alias Lookup, Harm Assessment & Scoring, and Alternatives Filtering.
  - Created the **Use Case Diagram** (`docs/diagrams/Use_case_diagram/`) defining actor boundaries and core use cases: Capture Product Image, Review Detected Ingredients, View Health Risk Breakdown, Explore Healthier Alternatives, and Manage Scan History.
  - Co-authored and formatted the formal UCS503P Project Proposal document in LaTeX (`project_proposal/proposal.tex`), embedding architecture diagrams and milestone charts.
  - Drafted comprehensive README documentation outlining the core project vision and modular components.
- **Key Takeaways & Challenges:** Formally mapping DFD processes early exposed necessary edge case branches, specifically how to handle blurry images and packaging that lacks any printed ingredient panel.

---

### 📌 Week 3: Behavioral & Structural Modeling (ER & Activity Diagrams) (Sep 8 – Sep 14, 2026)
- **Focus:** Relational database schema design and workflow behavior modeling.
- **What I Did:**
  - Designed the comprehensive **Entity-Relationship (ER) Diagram** (`docs/diagrams/ER_diagram/Willow_ER_Diagram_Final.drawio`, PNG preview):
    - Modeled relational entities: `Categories`, `Ingredients`, `IngredientAliases`, `AdditiveHarmRules`, `CategoryRiskProfiles`, `ProductAlternatives`, `Users`, and `ScanHistory`.
    - Defined one-to-many and many-to-many relationship cardinality, foreign key constraints, and normalized tables to 3NF to ensure fast lookup times during scanning.
  - Constructed detailed **Activity Diagrams** (`docs/diagrams/activity_diagram/Activity_Diagram.drawio`):
    - Modeled the system’s execution path: Camera Capture → Image Quality Check (Branch: Retake vs. Proceed) → Extraction → Branch on Ingredient Detection (Exact Analysis Path vs. Smart Fallback Path) → Safety Display.
  - Designed the **DFD Level 2** diagram capturing granular data transformation during OCR extraction, text tokenization, and canonical matching.
  - Researched Flutter packages and reactive state management architectures for the mobile client.
- **Key Takeaways & Challenges:** Designing a dedicated alias entity (`ingredient_aliases`) was critical to map dozens of commercial and scientific synonyms (e.g., E621, MSG, Ajinomoto, Monosodium Glutamate) back to one canonical record.

---

### 📌 Week 4: Flutter Mobile App Kickoff & Scanner UI (Sep 15 – Sep 21, 2026)
- **Focus:** Mobile frontend initialization, camera preview integration, and core UI screens.
- **What I Did:**
  - Initialized the cross-platform mobile application in **Flutter / Dart** (`codes/app-frontend`), configuring project dependencies (`camera`, `image_picker`, `http`, `path_provider`).
  - Built the core Camera Scanner interface (`lib/screens/scan_screen.dart`):
    - Integrated camera preview with responsive aspect-ratio handling and capture trigger.
    - Designed custom viewfinder overlay with framing guidelines to assist users in aligning ingredient panels properly.
    - Added image selection from the device gallery as an alternative to real-time capture.
  - Created initial mockups for the Product Search screen, Ingredient Breakdown view, and navigation framework.
  - Implemented client-side runtime permission handling for camera and photo storage access on Android and iOS.
- **Key Takeaways & Challenges:** Camera controllers in Flutter require careful lifecycle management (initializing on screen mount and properly disposing controllers on navigate away) to prevent memory leaks and black screens.

---

### 📌 Week 5: Client Service Integration & Mid-Semester Presentation (Sep 22 – Sep 28, 2026)
- **Focus:** Backend HTTP integration, mid-semester evaluation presentation, and academic reporting.
- **What I Did:**
  - Built the Flutter networking layer (`lib/services/ingredient_scanner_service.dart`) utilizing `http.MultipartRequest` to stream captured images to Aditya’s Flask REST API.
  - Configured flexible networking parameters accommodating localhost, Android emulator (`10.0.2.2`), and physical device LAN IP addresses during development.
  - Authored Chapter 1 (Introduction, Background & Problem Statement) and Chapter 4 (Conclusion, Key Findings & Future Recommendations) of the formal Mid-Semester Report (`mid_sem_report/project_report.tex`).
  - Created the official **Mid-Semester Pitch Deck** (`project-prototype/mid_ppt/Willow_final.pdf`), designing visual slides for system architecture, data models, DFDs, and live extraction results.
  - Tested the full end-to-end loop on Android devices, validating smooth transition from photo capture to parsed JSON rendering.
- **Key Takeaways & Challenges:** Demonstrating a live camera-to-backend mobile scan during the mid-semester evaluation effectively validated our image-first, non-barcode value proposition.

---

### 📌 Week 6: Mobile Design System Overhaul & Theme Tokenization (Sep 29 – Oct 5, 2026)
- **Focus:** UI design system implementation, color token architecture, and sticker aesthetics.
- **What I Did:**
  - Completely redesigned the Flutter styling architecture (`lib/theme/app_theme.dart`):
    - Established curated color tokens: Nature Sage (`#2E7D32`), Warm Cream background (`#F9F9FB`), Coral Risk Red (`#E53935`), Amber Caution (`#FFA000`), and Charcoal typography.
    - Configured modern Google Fonts typography hierarchy (Inter / Outfit) for clear readability of scientific ingredient labels.
    - Added support for both light and dark display modes with high-contrast accessibility.
  - Implemented the custom sticker and illustration widget system (`lib/widgets/sticker_layer.dart`, `lib/widgets/common.dart`) translating the web prototype's playful aesthetic into Flutter.
  - Built reusable, responsive UI components: Ingredient Chip tags, Safety Status Badges, Health Score Arc indicators, and Collapsible Information Cards.
- **Key Takeaways & Challenges:** Centralizing styling in `AppTheme` eliminated hard-coded colors and inconsistent padding across screens, making subsequent screen development fast and unified.

---

### 📌 Week 7: Advanced UML Modeling: Detailed Sequence & Class Diagrams (Oct 6 – Oct 12, 2026)
- **Focus:** Detailed object-oriented modeling and client-side data serialization.
- **What I Did:**
  - Designed the comprehensive **System Sequence Diagram** (`docs/diagrams/Sequence_diagram/Willow_Sequence_Diagram_v3.drawio`, PNG export):
    - Mapped asynchronous request/response timelines across 7 participants: Mobile Client, API Server, Image Quality Filter, Vision Extractor, Relational DB, Classifier Engine, and Alternatives Recommender.
  - Modeled the **Detailed Class Diagram** (`docs/diagrams/Class_diagram/Willow_Class_Diagram_Detailed (1).drawio`, PNG export):
    - Defined complete class structures, methods, visibility, and associations for both backend services and Flutter client controllers.
  - Developed the client-side data models in Dart (`lib/model/food_item.dart`, `lib/model/scan_model.dart`):
    - Modeled `ScanResult`, `IngredientItem`, `AdditiveRisk`, `CategoryRiskProfile`, and `AlternativeProduct` with robust `fromJson()` and `toJson()` serialization methods matching backend API contracts.
- **Key Takeaways & Challenges:** Constructing the sequence diagram surfaced necessary client loading states and async timeout handlers before we wrote the full screen navigation logic.

---

### 📌 Week 8: Authentication UI, Session State & Navigation Shell (Oct 13 – Oct 19, 2026)
- **Focus:** User authentication interface, session management, and primary navigation structure.
- **What I Did:**
  - Developed the complete mobile authentication suite:
    - **Login Screen** (`lib/screens/auth/login_screen.dart`): Clean form layout with email validation, secure password field, animated toggle visibility, and error banner feedback.
    - **Registration Screen** (`lib/screens/auth/register_screen.dart`): User onboarding with name, email, dietary preference selection, and password strength checks.
  - Built `AuthService` (`lib/services/auth_service.dart`) on the mobile client:
    - Manages JWT/session token storage, user login state, automatic session restoration, and logout cleanup.
  - Built the primary **MainNavigationScreen** (`lib/screens/main_navigation_screen.dart`):
    - Persistent bottom navigation bar connecting Home, Scanner, Scan History, and User Profile.
    - Smooth animated page transitions preserving screen state across tab switching.
  - Developed the **Profile Screen** (`lib/screens/profile_screen.dart`) allowing users to configure allergen alerts (e.g., gluten, nuts, dairy) and dietary filters (vegetarian/vegan).
- **Key Takeaways & Challenges:** Managing authentication state at the application root ensures unauthenticated users are directed to login while returning users land straight on the camera scanner.

---

### 📌 Week 9: Interactive Review Workflow, Results Dashboard & Alternatives UI (Oct 20 – Oct 26, 2026)
- **Focus:** Human-in-the-loop review workflow, results dashboard, and alternatives screen.
- **What I Did:**
  - Developed the **Ingredient Review Screen** (`lib/screens/review_screen.dart`):
    - Enables users to review OCR-extracted ingredients before running safety classification.
    - Allows manual editing, deleting mistaken OCR tokens, or typing missing ingredients for partially damaged labels.
  - Created the **Analyzing Animation Screen** (`lib/screens/analyzing_screen.dart`):
    - Engaging visual radar/pulse animation and dynamic status messages ("Reading label...", "Cross-referencing FSSAI database...") while waiting for backend processing.
  - Completely overhauled the **Results Dashboard** (`lib/screens/results_screen.dart`):
    - Animated Willow Health Score gauge (0–100 scale) with color coding (Green: Clean, Yellow: Moderate, Red: Avoid).
    - Expandable additive cards showing risk level, plain-language health impact notes, and FSSAI regulation references.
    - Smart fallback card for unbranded food displaying category-level generic risk summaries with clear estimated tags.
  - Built the **Alternatives Screen** (`lib/screens/alternatives_screen.dart`):
    - Recommends healthier product cards from the same category matched within comparable price bands, complete with clean-ingredient badges.
- **Key Takeaways & Challenges:** Providing an editable review screen bridges the gap between imperfect real-world camera captures and reliable safety scoring, drastically increasing consumer trust.

---

### 📌 Week 10: Scan History Dashboard, UI Polish, Error Resilience & Repo Sync (Oct 27 – Nov 2, 2026)
- **Focus:** Scan history implementation, comprehensive UI bug fixing, offline caching, and git synchronization.
- **What I Did:**
  - Developed the **Scan History Screen** (`lib/screens/history_screen.dart`):
    - Displays previous product scans in reverse chronological order with thumbnail previews, safety scores, and date stamps.
    - Added search and category filter bars allowing users to quickly revisit past product analyses.
    - Implemented local caching so users can view their recent scan history even when disconnected from the internet.
  - Performed comprehensive UI polish and bug fixing across all screens (`commit 6ae8c6a`):
    - Fixed keyboard overflow issues and layout clipping on smaller Android devices.
    - Added user-friendly snackbars and retry dialogs for image picker cancellations and network timeouts.
  - Resolved git merge conflicts, refactored project structure, and synchronized project documentation and progress logs.
- **Key Takeaways & Challenges:** Fine-tuning UX edge cases—such as graceful handling of cancelled camera shots and offline history browsing—elevates the project from a prototype to a polished consumer application.

---

## 🛠️ My Tech Stack & Tools

| Component | Technologies & Tools |
| :--- | :--- |
| **Mobile Frontend** | Flutter, Dart (StatefulWidgets, Provider/State, Async Streams) |
| **Mobile Packages** | `camera`, `image_picker`, `http`, `shared_preferences`, `google_fonts` |
| **Web Prototype** | HTML5, CSS3, Modern JavaScript (Vanilla), Responsive Design |
| **UI/UX Design & Styling** | Custom Design Tokens (`app_theme.dart`), Willow Sticker Aesthetic (`sticker_layer.dart`) |
| **UML & System Modeling** | Draw.io (DFD L0/L1/L2, Use Case, ER, Activity, Sequence, Class Diagrams) |
| **Hosting & Documentation** | GitHub Pages, Markdown, LaTeX (`project_report.tex`, `proposal.tex`), PowerPoint |
| **Version Control** | Git, GitHub (Branching, Merge Resolution, Pull Requests) |

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

1. **Complete Cross-Platform App:** 9 fully styled Flutter screens covering authentication, camera capture, ingredient review, safety results, alternatives, history, and profile.
2. **Cohesive Design System:** Implemented modern, accessible theme tokens and approachable sticker visual language.
3. **Formal Software Engineering Models:** Complete UML suite delivered (DFDs, Use Cases, ER Diagram, Activity Diagrams, Sequence Diagram, Class Diagram).
4. **Resilient User Flow:** Interactive review step and smart fallback profiles empower users even on imperfect scans and unlabelled local foods.
5. **Offline Readiness:** Scan history and cached records allow seamless browsing without continuous network connectivity.

---

## 🚀 Next Steps
- Conduct pilot user usability testing with 10–15 college students and record UX feedback scores.
- Add regional language UI localization (Hindi language toggle).
- Finalize capstone demonstration video and final project documentation.
