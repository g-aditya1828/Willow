
---

# 🌿 Willow: AI-Powered Ingredient & Food Safety Scanner

### *"Know what's really in it."*

**Computer Vision · OCR · NLP · Food Safety · Full-Stack Development · FSSAI**

---

## 📌 Overview

In India, consumers frequently encounter packaged and locally sold food products with **incomplete, inconsistent, or even completely absent ingredient labels**. Traditional food-scanning applications often depend on international barcode databases and regulatory standards designed for Western markets, making them unreliable for **regional, unbranded, and locally manufactured Indian food products**. 

**Willow** is an AI-driven ingredient scanner specifically designed for the **Indian food ecosystem**.

Instead of relying on barcodes, Willow allows users to simply **capture or upload a photograph of a food product**. The system uses OCR/Vision technology to extract the ingredient list, normalizes ingredient names and aliases, checks them against a curated database of potentially harmful ingredients, and provides a clear **health-risk assessment** based on FSSAI-aligned information.

When an ingredient panel is unavailable — a common situation with local sweets, bakery products, loose namkeen, and other regional foods — Willow intelligently falls back to a **category-level estimated risk profile** rather than failing completely.

Willow also recommends **healthier, cleaner alternatives within a comparable price range**, helping consumers make more informed purchasing decisions. 

---

# ✨ Key Features

### 📷 AI-Powered Food Image Scanning

Capture a food product using a device camera or upload an existing image. Willow processes the image without requiring a barcode. 

### 🔎 Intelligent OCR & Ingredient Extraction

Extracts raw text from ingredient panels using an abstracted OCR/Vision service and converts the result into a structured ingredient list. 

### 🧹 Ingredient Normalization

Recognizes different names, aliases, E-numbers, and INS codes and maps them to canonical ingredient entities.

For example:

```text
MSG
INS 621
Monosodium Glutamate
        ↓
Monosodium Glutamate
```

This allows Willow to analyze ingredients consistently even when manufacturers use different naming conventions. 

### ⚠️ Harmful Ingredient Detection

Extracted ingredients are checked against a curated harmful-ingredient database containing approximately **150–300 common ingredients and additives**. 

Willow provides:

* Flagged ingredients
* Risk level
* Plain-language health effect information
* Supporting FSSAI references

The PRD specifically requires health-related information to remain traceable to authoritative sources rather than generating unsupported claims.  

### 📊 Product Risk Indicator

Willow calculates an overall product risk indicator based on the ingredients identified during analysis. 

### 🏪 Smart Local-Food Fallback

No ingredient panel?

No problem.

Willow attempts to classify the product into a known food sub-category such as:

```text
Namkeen
Sweets
Bakery
```

It then provides a **generic category-level risk profile** clearly labeled as:

> ⚠️ Estimated, not exact

This is particularly important for unbranded and locally sold food products. 

### 🧾 FSSAI Trust Signal

If a visible FSSAI license number is detected in the product image, Willow can surface it as an additional trust signal. 

### ✍️ Manual Ingredient Input

If OCR fails or no suitable match is found, users can manually enter the ingredients for analysis. 

### 🛒 Healthier Alternatives

Willow recommends alternative products from the same sub-category with cleaner ingredient profiles.

Recommendations are designed to remain within a **comparable price range**, making healthier choices more practical for everyday consumers. 

### 📱 Consumer-Friendly Results Dashboard

The primary results screen presents:

* Extracted ingredients
* Harmful ingredient flags
* Health-effect notes
* Risk indicator
* Analysis confidence
* Recommended alternatives

in a single interface. 

---

# 🧠 Core Processing Pipeline

Willow follows two analysis paths depending on whether an ingredient panel can be detected.

```text
                    ┌─────────────────────┐
                    │  Capture / Upload   │
                    │    Food Image       │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ Quality & Framing   │
                    │     Validation      │
                    └──────────┬──────────┘
                               │
                       ┌───────┴───────┐
                       │               │
                   Low Quality      Good Quality
                       │               │
                       ▼               ▼
                 Retake Image     OCR / Vision
                                       │
                                       ▼
                           ┌─────────────────────┐
                           │ Ingredient Panel    │
                           │     Detected?       │
                           └──────────┬──────────┘
                                      │
                         ┌────────────┴────────────┐
                         │                         │
                        YES                        NO
                         │                         │
                         ▼                         ▼
                Parse & Normalize          Classify Food
                  Ingredients               Sub-category
                         │                         │
                         ▼                         ▼
                  Harm Analysis             Generic Risk
                         │                     Profile
                         ▼                         │
                  Health Scoring                   │
                         │                         │
                         └───────────┬─────────────┘
                                     │
                                     ▼
                           ┌────────────────────┐
                           │ Results Dashboard  │
                           │                    │
                           │ • Ingredients      │
                           │ • Risk Flags       │
                           │ • Health Notes     │
                           │ • Confidence       │
                           │ • Alternatives     │
                           └────────────────────┘
```

The PRD defines this as two distinct paths: **exact analysis when an ingredient panel exists**, and **estimated category-level analysis when it does not**. 

---

# 🏗️ System Architecture

Willow is designed as a modular full-stack system separating image processing, ingredient intelligence, risk analysis, and product recommendation.

```text
                     ┌──────────────────────────┐
                     │       USER / CONSUMER    │
                     └────────────┬─────────────┘
                                  │
                                  ▼
                     ┌──────────────────────────┐
                     │   Mobile-First Frontend  │
                     │                          │
                     │ Camera / Image Upload    │
                     │ Results / Risk Dashboard │
                     └────────────┬─────────────┘
                                  │
                                  ▼
                     ┌──────────────────────────┐
                     │       Backend API        │
                     │ Node.js / Express        │
                     │        OR FastAPI        │
                     └────────────┬─────────────┘
                                  │
               ┌──────────────────┼──────────────────┐
               │                  │                  │
               ▼                  ▼                  ▼
      ┌────────────────┐ ┌────────────────┐ ┌────────────────┐
      │ OCR / Vision   │ │ Risk Analysis  │ │ Recommendation │
      │ Engine         │ │ Engine         │ │ Engine         │
      └───────┬────────┘ └───────┬────────┘ └───────┬────────┘
              │                  │                  │
              ▼                  ▼                  ▼
      ┌────────────────────────────────────────────────────┐
      │                    PostgreSQL                       │
      │                                                    │
      │ Categories · Ingredients · Aliases · Risk Profiles │
      │ Product Alternatives                               │
      └────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌────────────────────┐
                    │ Object Storage     │
                    │ AWS S3 / Cloud     │
                    │ Uploaded Images    │
                    └────────────────────┘
```

The PRD specifies a **mobile-first web application or progressive native app**, a modular backend using Node.js/Express or Python/FastAPI, PostgreSQL, an asynchronous job queue, object storage, and an OCR/Vision provider behind an internal abstraction interface. 

---

# 🔄 Ingredient Analysis Pipeline

Willow transforms an image into an actionable food-safety assessment through the following pipeline:

```text
Food Image
    │
    ▼
Image Quality Validation
    │
    ▼
OCR / Vision Extraction
    │
    ▼
Raw OCR Text
    │
    ▼
Ingredient Parsing
    │
    ▼
Name / Alias Normalization
    │
    ▼
Canonical Ingredient Mapping
    │
    ▼
Harmful Ingredient Database
    │
    ├───────────────┐
    │               │
    ▼               ▼
Safe            Flagged
Ingredients     Ingredients
                    │
                    ▼
              Health Effects
                    │
                    ▼
              Risk Indicator
                    │
                    ▼
         Healthier Alternatives
```

---

# 🗃️ Database Architecture

Willow uses PostgreSQL as the primary relational database.

### Categories

```sql
CREATE TABLE categories (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Ingredients

```sql
CREATE TABLE ingredients (
    id SERIAL PRIMARY KEY,
    category_id INT REFERENCES categories(id),
    canonical_name VARCHAR(150) NOT NULL,
    risk_level VARCHAR(20)
        CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH')),
    health_effects_description TEXT,
    fssai_reference VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Ingredient Aliases

```sql
CREATE TABLE ingredient_aliases (
    id SERIAL PRIMARY KEY,
    ingredient_id INT REFERENCES ingredients(id),
    alias_name VARCHAR(150) NOT NULL
);
```

This allows Willow to map identifiers such as:

```text
INS 621
MSG
Monosodium Glutamate
```

to a common canonical ingredient entity. 

### Category Risk Profiles

```sql
CREATE TABLE category_risk_profiles (
    id SERIAL PRIMARY KEY,
    sub_category_name VARCHAR(100) NOT NULL,
    estimated_risk_summary TEXT NOT NULL,
    typical_harmful_additives TEXT
);
```

These profiles power Willow's fallback mode for products without visible ingredient panels. 

### Product Alternatives

```sql
CREATE TABLE product_alternatives (
    id SERIAL PRIMARY KEY,
    sub_category_name VARCHAR(100) NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    brand_name VARCHAR(100),
    price_band VARCHAR(50),
    clean_ingredient_summary TEXT,
    image_url TEXT
);
```

The recommendation database allows alternatives to be filtered by food sub-category and comparable price band. 

---

# 📚 Data Sources

Willow's food-safety knowledge base is designed around multiple data sources:

### 🇮🇳 FSSAI Regulations

FSSAI regulatory documents are parsed into structured ingredient and risk mappings.

### 🌎 Open Food Facts

Openly licensed food additive datasets are filtered for Indian products.

### 📊 Kaggle Datasets

Machine-learning-ready ingredient datasets are used to bootstrap preliminary classification categories. 

---

# ⚙️ Technology Stack

| Layer                         | Technology                                 |
| ----------------------------- | ------------------------------------------ |
| **Frontend**                  | Mobile-first Web / Progressive Native App  |
| **Backend**                   | Node.js + Express **or** Python + FastAPI  |
| **Database**                  | PostgreSQL                                 |
| **Async Processing**          | BullMQ / Celery                            |
| **Object Storage**            | AWS S3 / Cloud Storage                     |
| **OCR / Vision**              | Multimodal Model / Vision API              |
| **Ingredient Knowledge Base** | FSSAI + Open Food Facts + curated datasets |

The OCR/Vision provider is intentionally placed behind an internal abstraction interface so that providers can be swapped without rewriting the core extraction engine. 

---

# 📋 Functional Requirements

Willow's MVP is built around the following core capabilities:

| ID    | Feature                               | Priority    |
| ----- | ------------------------------------- | ----------- |
| FR-1  | Capture/upload food image             | Must-Have   |
| FR-2  | Capture guidance for lighting/framing | Should-Have |
| FR-3  | Image quality validation              | Should-Have |
| FR-4  | OCR ingredient extraction             | Must-Have   |
| FR-5  | Ingredient parsing                    | Must-Have   |
| FR-6  | Ingredient normalization              | Must-Have   |
| FR-7  | Pluggable OCR/Vision architecture     | Must-Have   |
| FR-8  | Harmful ingredient detection          | Must-Have   |
| FR-9  | Plain-language health explanations    | Must-Have   |
| FR-10 | Overall product risk indicator        | Should-Have |
| FR-11 | Config-driven category classification | Must-Have   |
| FR-12 | No-ingredient-panel fallback          | Must-Have   |
| FR-13 | Estimated category-level risk profile | Must-Have   |
| FR-14 | FSSAI license trust signal            | Could-Have  |
| FR-15 | Manual ingredient entry               | Should-Have |
| FR-16 | Healthier alternatives                | Must-Have   |
| FR-17 | Comparable-price alternatives         | Should-Have |
| FR-18 | Unified results dashboard             | Must-Have   |
| FR-19 | Analysis confidence display           | Must-Have   |

These priorities follow the MoSCoW classification in the PRD.    

---

# 🛡️ Reliability, Security & Privacy

Willow is designed with several important non-functional requirements.

### ⚡ Performance

End-to-end analysis from photo upload to results should complete within **a few seconds under normal network conditions**.

Heavy OCR/Vision operations should execute asynchronously using job queues. 

### 🎯 Accuracy & Transparency

Extraction confidence must be surfaced to users.

Low-confidence results should trigger either:

```text
Retake Image
      OR
Manual Ingredient Input
```

rather than presenting uncertain extraction as fact. 

### 🔐 Data Security

Uploaded product images should be securely stored in object storage, while personal data collection should be minimized. 

### 🧾 Traceable Health Claims

Harmful-ingredient classifications and health-effect descriptions must be traceable to authoritative records such as FSSAI regulations.

> **Unsubstantiated or generated health claims are prohibited.** 

---

# 🇮🇳 Why Willow?

Traditional food scanners often follow this model:

```text
Barcode
   ↓
International Database
   ↓
Product Match
   ↓
Risk Score
```

Willow takes a different approach:

```text
             FOOD IMAGE
                 │
                 ▼
        ┌──────────────────┐
        │   OCR / VISION   │
        └────────┬─────────┘
                 │
          Ingredient Text
                 │
                 ▼
        ┌──────────────────┐
        │   NORMALIZATION  │
        └────────┬─────────┘
                 │
                 ▼
          FSSAI / Risk DB
                 │
                 ▼
          Health Analysis
                 │
                 ▼
      Better Food Decisions
```

This makes the system particularly suitable for **regional, unbranded, and barcode-unindexed Indian food products**. 

---

# 🎯 MVP Scope

### ✅ In Scope

* Packaged food products
* Packaged spices and masalas
* Camera-based scanning
* Image upload
* English ingredient labels
* Curated harmful-ingredient database
* Ingredient normalization
* Category-level fallback profiles
* Healthier alternatives
* Price-comparable recommendations

### 🔮 Future Work

The following are explicitly outside the MVP:

* Cosmetics and other non-food categories
* Large-scale crowdsourced ingredient contributions
* Real-time FoSCoS/FSSAI license API verification
* Regional-language OCR beyond English
* Visual matching of previously scanned unbranded products without text 

---

# 📈 Success Criteria & KPIs

Willow's success will be evaluated through:

### 🔎 OCR & Extraction Accuracy

Users should receive an accurate, structured ingredient list from legible food-product photographs.

### ⚠️ Flagging Precision

Harmful additives should be correctly identified with appropriate health notes.

### 🏪 Fallback Utility

Products without ingredient lists should receive a relevant **clearly labeled generic risk profile**.

### 🛒 Alternative Relevance

When harmful ingredients are detected, Willow should provide at least one **healthier, price-comparable alternative**.

### 🏗️ Architectural Extensibility

A second product category, such as cosmetics, should eventually be introducible through **data/configuration changes rather than rewriting the core processing engine**. 

---

# 🌱 Product Philosophy

> **Don't just scan the product. Understand what's really in it.**

Willow is designed around a simple principle:

**A consumer shouldn't need to understand barcodes, E-numbers, food regulations, or chemical terminology to make an informed food choice.**

Willow converts complex ingredient information into a simple, transparent and actionable experience.

---

# 👥 Project Information

**Project:** Willow
**Tagline:** *Know what's really in it*
**Institution:** Thapar Institute of Engineering & Technology
**Course:** Software Engineering — UCS 503
**Domain:** Computer Vision · NLP · Full-Stack Development
**Target Market:** India

### Authors

| Name                | Role           |
| ------------------- | -------------- |
| **Aditya Gupta**    | Project Author |
| **Akanksha Thakur** | Project Author |

The project context, authorship, target market, and technical domain are specified in the PRD. 

---

## 🌿 Willow

### **Know what's really in it.**

**AI-powered ingredient intelligence for Indian food products.**
