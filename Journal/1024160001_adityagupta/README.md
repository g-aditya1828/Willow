# 📓 My Dev Journal: Food Scanner App

Welcome to my project journal! In this repository, I document my progress, technical decisions, and challenges while building my **Food Scanner & Ingredient Analysis App**.

---

## 🗓️ Weekly Progress Log

### 📌 Week 1: Research & Database Feasibility

- **Focus:** Understanding the market and finding the right databases.
- **What I Did:**
  - Researched existing food scanner apps like **Yuka** and explored public databases to see how product information is stored and structured.
  - Investigated data models, API access, and open-source datasets (like Open Food Facts) for ingredient safety and nutrition data.
  - Identified initial technical hurdles: database coverage gaps, parsing non-standard ingredient labels, and handling real-time queries.
- **My Key Takeaway:** Existing open databases are great starting points, but relying solely on them isn't enough—I need a custom extraction pipeline for unlisted products.

---

### 📌 Week 2: Deep Dive & Pitching the Idea

- **Focus:** Refining the architecture and presenting the vision.
- **What I Did:**
  - Conducted a deeper technical exploration into combining image extraction with AI to parse food packaging.
  - Created a comprehensive presentation deck (PPT) detailing my concept, architectural design, target audience, and roadmap.
  - Defined my core technical pipeline: *Camera Capture → OCR Extraction → AI Structuring → Safety Scoring → UI Display*.
- **My Key Takeaway:** Structuring my thoughts into a presentation gave me a much clearer blueprint for building the backend.

---

### 📌 Week 3: Backend Kickoff & Tesseract OCR

- **Focus:** Starting backend development and building an extraction pipeline.
- **What I Did:**
  - Set up my backend workspace and designed the initial server architecture.
  - Integrated **Tesseract OCR** as my baseline engine to extract text directly from ingredient photo.
- **Challenges I Ran Into:** Tesseract worked well for flat, clear images, but struggled significantly with curved packages, shiny surfaces, and complex typography.

---

### 📌 Week 4: Gemini Vision API Integration

- **Focus:** Tackling complex labels with multimodal AI.
- **What I Did:**
  - Integrated the **Google Gemini Vision API** into my backend pipeline to overcome Tesseract's visual limitations.
  - Prompted Gemini to return clean, structured JSON containing ingredients, additives, and potential allergens.
  - Compared performance between standard local OCR and cloud-based AI vision processing.
  - made Gantt chart.
- **My Results:** Extraction accuracy improved drastically—Gemini effortlessly parsed distorted, low-contrast, and multilingual ingredient panels that Tesseract failed on.

---

### 📌 Week 5: End-to-End App Integration

- **Focus:** Connecting the backend parser directly to my application.
- **What I Did:**
  - Integrated the new Gemini-powered extraction engine into my core backend architecture.
  - Connected the mobile/client interface to my API endpoints so the app can process user-uploaded photos in real time.
  - Tested the complete end-to-end user flow: *Scan Photo → Backend Parsing → Additive/Risk Analysis → Structured Results Display*.
- **Current Status:** The core extraction pipeline is live and successfully running inside my app!

---

## 🛠️ My Tech Stack

| Component                    | Technology                              |
| :--------------------------- | :-------------------------------------- |
| **OCR & AI Vision**    | Tesseract OCR, Google Gemini Vision API |
| **Backend**            | Python / REST API Architecture          |
| **Databases Explored** | Open Food Facts, Yuka Data Models       |
| **Tools & Planning**   | PowerPoint (Pitch Deck), Git, Markdown  |
