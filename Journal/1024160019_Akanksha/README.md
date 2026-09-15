# 📓 My Dev Journal: Food Scanner App

Welcome to my project journal! In this repository, I document my step-by-step progress, design decisions, and system architecture while building my **Food Scanner & Ingredient Analysis App**.

---

## 🗓️ Weekly Progress Log

### 📌 Week 1: Research & Database Feasibility

- **Focus:** Understanding the market and evaluating food databases.
- **What I Did:**
  - Researched existing food scanner apps like **Yuka** and explored public databases to see how product information is stored and structured.
  - Investigated data models, API access, and open-source datasets (like Open Food Facts) for ingredient safety and nutrition data.
  - Identified initial technical hurdles: database coverage gaps, parsing non-standard ingredient labels, and handling real-time queries.
- **My Key Takeaway:** Existing open databases are great starting points, but relying solely on them isn't enough—I need a custom extraction pipeline for unlisted products.

---

### 📌 Week 2: Repository Setup & Project Blueprinting

- **Focus:** Initializing workspace, defining architecture, and setting up project documentation.
- **What I Did:**
  - Created the main GitHub repository and configured branch rules and project structure.
  - Drafted a detailed project blueprint and system outline to define module boundaries and tech stack choices.
  - Configured and deployed **GitHub Pages** to host live project documentation, updates, and progress logs.
- **My Key Takeaway:** Setting up the repository and documentation site early gave me a clear roadmap and structure before writing core application code.

---

### 📌 Week 3: System Modeling (DFD & Use-Case Diagrams)

- **Focus:** Architectural visualization and process flow modeling.
- **What I Did:**
  - Designed **Data Flow Diagrams (DFD Level 0 & Level 1)** to map how ingredient images and barcode data move through the processing pipeline.
  - Created **Use case Class Diagrams** to define object structures for food products, scan logs, user profiles, and additive safety rules.
  - Mapped out sequence diagrams showing client-server interaction during scanning and risk evaluation.
- **My Key Takeaway:** Mapping out DFDs and Use case diagrams early highlighted potential data bottlenecks and simplified API endpoint design.

---

### 📌 Week 4: Frontend Development with Flutter

- **Focus:** UI/UX design and cross-platform frontend implementation.
- **What I Did:**
  - Initialized the mobile application frontend using **Flutter**.
  - Built core user interface screens: Camera Scanner View, Product Search, and Detailed Ingredient Breakdown display.
  - Integrated custom Flutter packages for camera preview handling, barcode scanning overlay, and state management.
- **My Results:** Created a responsive, clean mobile UI ready to be connected to the backend extraction service.

---

### 📌 Week 5: Database & Behavioral Modeling (ER & Activity Diagrams)

- **Focus:** Database architecture design and user workflow mapping.
- **What I Did:**
  - Designed **Entity-Relationship (ER) Diagrams** to model database schemas (products, ingredients, additive risk ratings, user scan history).
  - Constructed **Activity Diagrams** to illustrate operational workflows, including edge cases like low-light scans or unlisted product handling.
  - Normalized relational tables to ensure efficient lookup times during live barcode/OCR queries.
- **Current Status:** System architecture, database schematics, and mobile UI foundation are complete and fully documented!

---

## 🛠️ My Tech Stack & Tools

| Component                         | Technology                                         |
| :-------------------------------- | :------------------------------------------------- |
| **Frontend**                | Flutter, Dart                                      |
| **System Modeling**         | UML Diagrams, DFDs, ER Diagrams, Activity Diagrams |
| **Databases Explored**      | Open Food Facts, Yuka Data Models                  |
| **Documentation & Hosting** | GitHub Pages, Markdown, Git                        |
