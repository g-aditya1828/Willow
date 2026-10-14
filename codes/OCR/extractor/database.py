"""
Database layer for Willow: AI-Powered Ingredient & Food Safety Scanner.
Implements relational schema in SQLite with:
- Categories (with generic risk profiles for unbranded Indian foods)
- Ingredients (canonical names, FSSAI risk levels, plain-language health effects, FSSAI compendium refs)
- Aliases (mapping INS codes, E-numbers, regional terms to canonical ingredients)
- Healthier Alternatives (price-comparable clean swaps)
- Users & Authentication
- Scan History & Bookmarks
"""

import sqlite3
import json
import os
from pathlib import Path

DB_PATH = Path(__file__).resolve().parent / "willow.db"


def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    conn.execute("PRAGMA journal_mode = WAL")
    return conn


def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()

    # 1. Users table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    """)

    # 2. Categories table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,
        generic_risk INTEGER NOT NULL,
        note TEXT NOT NULL,
        keywords TEXT NOT NULL
    )
    """)

    # 3. Ingredients table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        canonical_name TEXT UNIQUE NOT NULL,
        category_name TEXT,
        risk_level TEXT CHECK(risk_level IN ('clean', 'watch', 'high')) NOT NULL,
        health_effects TEXT NOT NULL,
        fssai_ref TEXT
    )
    """)

    # 4. Aliases table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS aliases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ingredient_id INTEGER NOT NULL,
        alias TEXT UNIQUE NOT NULL,
        FOREIGN KEY(ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
    )
    """)

    # 5. Product alternatives table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS alternatives (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_name TEXT NOT NULL,
        name TEXT NOT NULL,
        score INTEGER NOT NULL,
        price TEXT NOT NULL,
        note TEXT
    )
    """)

    # 6. Scan history table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS scans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        product_name TEXT NOT NULL,
        category TEXT NOT NULL,
        risk_score INTEGER NOT NULL,
        confidence INTEGER NOT NULL,
        flagged_json TEXT NOT NULL,
        clean_json TEXT NOT NULL,
        unknown_json TEXT NOT NULL,
        fssai_number TEXT,
        is_fallback INTEGER NOT NULL DEFAULT 0,
        fallback_note TEXT,
        image_path TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE SET NULL
    )
    """)

    # 7. Favorites table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        scan_id INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(user_id, scan_id),
        FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY(scan_id) REFERENCES scans(id) ON DELETE CASCADE
    )
    """)

    conn.commit()

    # Seed data if empty
    cursor.execute("SELECT COUNT(*) FROM categories")
    if cursor.fetchone()[0] == 0:
        _seed_initial_data(conn)

    conn.close()


def _seed_initial_data(conn):
    cursor = conn.cursor()

    # Categories & generic risk profiles
    categories = [
        (
            "Namkeen / Fried Snacks",
            42,
            "Namkeen and fried snacks are commonly deep-fried in reused palm oil and high in added sodium/TBHQ.",
            "namkeen,bhujia,chips,mixture,sev,chivda,fryums,crisps,kurkure,wafers"
        ),
        (
            "Bakery / Biscuits",
            50,
            "Commercial bakery goods frequently rely on refined maida, partially hydrogenated vegetable oils, and synthetic emulsifiers.",
            "biscuit,cookie,bread,bakery,rusk,cracker,cake,toast,bun,wafer"
        ),
        (
            "Sweets / Mithai",
            38,
            "Traditional Indian sweets often contain high refined sugar, khoya/ghee substitutes, and synthetic food colors like Tartrazine.",
            "mithai,sweet,barfi,ladoo,halwa,peda,gulab jamun,rasgulla,kaju katli,jalebi"
        ),
        (
            "Packaged Spices / Masala",
            68,
            "Generally low intrinsic harm, but unbranded spices carry documented adulteration risks (lead chromate, pesticide residues).",
            "masala,spice,powder,seasoning,turmeric,chilli powder,garam masala,coriander,curry powder"
        ),
        (
            "Beverages",
            45,
            "Packaged sodas and juices contain concentrated refined sugars or artificial sweeteners (Aspartame, Acesulfame K).",
            "drink,beverage,juice,cola,soda,squash,syrup,energy drink,concentrate"
        ),
        (
            "Instant Foods / Ready-to-Eat",
            40,
            "Instant noodles and ready meals often contain high sodium, MSG/INS 621, and hydrolyzed vegetable proteins.",
            "instant,noodle,pasta,soup,ready to eat,ready-to-eat,maggi,cup noodle"
        ),
        (
            "Dairy",
            64,
            "Generally high nutritional value, though flavored yogurts and dairy desserts contain added sugars and thickeners.",
            "milk,curd,paneer,cheese,dairy,yogurt,chaas,lassi,butter"
        ),
    ]
    cursor.executemany(
        "INSERT INTO categories (name, generic_risk, note, keywords) VALUES (?, ?, ?, ?)",
        categories
    )

    # Curated Indian ingredients & additives aligned with FSSAI regulations
    ingredients = [
        # Flagged High Risk
        (
            "Partially Hydrogenated Vegetable Oil",
            "Fats & Oils",
            "high",
            "Industrial trans fat known to raise LDL (bad) cholesterol and significantly elevate coronary heart disease risk. FSSAI mandates strict trans fat limits under 2%.",
            "FSSAI Food Safety Standards (Food Products Standards and Food Additives) Regulation, 2011"
        ),
        (
            "Tartrazine (E102 / INS 102)",
            "Synthetic Food Colour",
            "high",
            "Synthetic azo dye linked to hyperactivity in children, asthma exacerbation, and urticaria in sensitive individuals. Restricted in several global jurisdictions.",
            "FSSAI Compendium Food Additives Table 4"
        ),
        (
            "Sunset Yellow FCF (E110 / INS 110)",
            "Synthetic Food Colour",
            "high",
            "Petroleum-derived synthetic dye associated with allergic responses, gastrointestinal upset, and hyperactivity in pediatric cohorts.",
            "FSSAI Compendium Food Additives Table 4"
        ),
        (
            "Allura Red (E129 / INS 129)",
            "Synthetic Food Colour",
            "high",
            "Synthetic azo dye associated with allergic reactions, inflammation, and potential behavioral changes in children.",
            "FSSAI Food Additives Regulation 2011"
        ),
        (
            "BHA (E320 / INS 320)",
            "Antioxidant / Preservative",
            "high",
            "Butylated hydroxyanisole is a synthetic preservative categorized by IARC as a possible human carcinogen; causes endocrine disruption in animal studies.",
            "FSSAI Regulation Section 3.1.5"
        ),
        (
            "High Fructose Corn Syrup",
            "Sweetener",
            "high",
            "Highly processed simple sugar linked to non-alcoholic fatty liver disease (NAFLD), insulin resistance, and visceral obesity.",
            "FSSAI Labelling and Display Regulations 2020"
        ),
        (
            "Potassium Bromate",
            "Flour Improver",
            "high",
            "Recognized category 2B carcinogen; completely banned by FSSAI in commercial bread and bakery processing since 2016.",
            "FSSAI Notification No. 1-110/SP/SP-Food Additives/2014"
        ),

        # Watch / Moderate Risk
        (
            "Monosodium Glutamate (MSG / INS 621)",
            "Flavor Enhancer",
            "watch",
            "Excitotoxin flavor enhancer that can trigger headaches, numbness, and flushing in sensitive individuals. FSSAI requires mandatory warning label on packaging.",
            "FSSAI Packaging and Labelling Regulation 2.4.5"
        ),
        (
            "Palm Oil / Palmolein",
            "Fats & Oils",
            "watch",
            "High in saturated palmitic acid (around 50%); regular high consumption is linked to elevated LDL cholesterol and arterial stiffness.",
            "FSSAI Dietary Guidelines for Indians"
        ),
        (
            "TBHQ (E319 / INS 319)",
            "Antioxidant / Preservative",
            "watch",
            "Synthetic phenol antioxidant used to prevent rancidity in fried snacks. High dosage in animal studies shows immune alterations.",
            "FSSAI Food Additives Permitted Limits Table 1"
        ),
        (
            "BHT (E321 / INS 321)",
            "Antioxidant / Preservative",
            "watch",
            "Synthetic antioxidant preservative; high exposure has been linked to liver enlargement in animal models.",
            "FSSAI Food Additives Permitted Limits"
        ),
        (
            "Sodium Benzoate (E211 / INS 211)",
            "Preservative",
            "watch",
            "Widely used preservative. Can react with ascorbic acid (Vitamin C) in beverages to form small amounts of carcinogenic benzene.",
            "FSSAI Food Additives Compendium Part II"
        ),
        (
            "Aspartame (E951 / INS 951)",
            "Artificial Sweetener",
            "watch",
            "Intense artificial sweetener; dangerous for individuals suffering from Phenylketonuria (PKU). Classified as possibly carcinogenic (Group 2B) by WHO IARC in 2023.",
            "FSSAI Warning Requirements Regulation 2.4.5(24)"
        ),
        (
            "Acesulfame Potassium (E950 / INS 950)",
            "Artificial Sweetener",
            "watch",
            "Zero-calorie sweetener often paired with sucralose. Contains methylene chloride residues during manufacturing; long-term metabolic effects are under scrutiny.",
            "FSSAI Compendium Artificial Sweeteners"
        ),
        (
            "Refined Wheat Flour (Maida)",
            "Refined Grain",
            "watch",
            "Stripped of endosperm bran and germ; has high glycemic index (>70), causing rapid insulin spikes and low satiety.",
            "FSSAI Food Safety Guidance"
        ),
        (
            "Refined Sugar / Added Sugar",
            "Carbohydrate",
            "watch",
            "Excess added sucrose promotes dental caries, metabolic syndrome, and cardiovascular disease.",
            "ICMR-NIN Dietary Guidelines for Indians"
        ),
        (
            "Caramel Colour (Class IV / INS 150d)",
            "Food Colour",
            "watch",
            "Ammonia-sulfite processed caramel contains 4-methylimidazole (4-MEI), a compound flagged for potential carcinogenic risk.",
            "FSSAI Food Colours Regulation"
        ),
        (
            "Hydrolyzed Vegetable Protein (HVP)",
            "Flavor Enhancer",
            "watch",
            "Manufactured via acid hydrolysis; contains naturally occurring free glutamates similar to MSG and may contain 3-MCPD chloropropanols.",
            "FSSAI Food Additives Standard"
        ),
        (
            "Artificial Flavoring Substances",
            "Flavoring",
            "watch",
            "Chemically synthesized flavor compounds that mimic natural flavors without providing nutritional value.",
            "FSSAI Flavoring Substances Standards"
        ),
        (
            "Excess Sodium / Salt",
            "Mineral",
            "watch",
            "Excess dietary sodium (>2000mg/day) is a primary risk factor for hypertension and stroke in urban Indian populations.",
            "FSSAI Eat Right India Initiative"
        ),

        # Clean / Safe Ingredients
        (
            "Whole Wheat Flour (Atta)",
            "Whole Grain",
            "clean",
            "Unrefined whole grain rich in dietary fiber, B-vitamins, and complex carbohydrates supporting steady blood sugar.",
            "FSSAI Whole Grain Standards"
        ),
        (
            "Oats",
            "Whole Grain",
            "clean",
            "High in beta-glucan soluble fiber proven to lower blood LDL cholesterol levels and improve gut microbiota.",
            "FSSAI Grain Products"
        ),
        (
            "Ragi (Finger Millet)",
            "Nutri-Cereal",
            "clean",
            "Traditional Indian superfood rich in dietary calcium, iron, and slow-digesting resistant starch.",
            "FSSAI Millets Specification 2023"
        ),
        (
            "Bajra (Pearl Millet)",
            "Nutri-Cereal",
            "clean",
            "Gluten-free nutrient-dense millet high in dietary fiber, phosphorus, and plant antioxidants.",
            "FSSAI Millets Specification 2023"
        ),
        (
            "Turmeric (Haldi)",
            "Traditional Spice",
            "clean",
            "Ancient Indian rhizome containing curcumin, a potent anti-inflammatory and cellular antioxidant.",
            "FSSAI Spices & Condiments Standards"
        ),
        (
            "Desi Ghee",
            "Traditional Fat",
            "clean",
            "Clarified butter containing butyric acid and fat-soluble vitamins (A, D, E). Healthy when consumed in moderate dietary portions.",
            "FSSAI Milk and Milk Products Regulations"
        ),
        (
            "Jaggery (Gur)",
            "Natural Sweetener",
            "clean",
            "Traditional unrefined sugarcane extract retaining trace minerals like iron, magnesium, and potassium.",
            "FSSAI Cane Jaggery Specification"
        ),
        (
            "Cold Pressed Mustard Oil",
            "Healthy Fat",
            "clean",
            "Kachi Ghani oil with balanced omega-3 and omega-6 fatty acids, free of chemical solvent refinement.",
            "FSSAI Edible Oils Standards"
        ),
        (
            "Roasted Chana (Chickpeas)",
            "Legume",
            "clean",
            "High plant protein and fiber snack promoting satiety and digestive wellness.",
            "FSSAI Pulses Standards"
        ),
        (
            "Makhana (Fox Nuts)",
            "Seed Snack",
            "clean",
            "Naturally low-calorie, low-sodium puffed lotus seed snack rich in plant flavonoids.",
            "FSSAI Agricultural Produce"
        ),
        (
            "Citric Acid (INS 330)",
            "Acidity Regulator",
            "clean",
            "Naturally occurring organic acid commonly found in citrus fruits; safe acidity regulator with minimal toxicity.",
            "FSSAI Table of Permitted Acidity Regulators"
        ),
        (
            "Soy Lecithin (INS 322)",
            "Emulsifier",
            "clean",
            "Natural phospholipid derived from soybeans; safe emulsifier with GRAS status.",
            "FSSAI Permitted Emulsifying Agents"
        ),
        (
            "Potassium Sorbate (INS 202)",
            "Preservative",
            "clean",
            "Naturally derived organic salt that metabolizes into water and CO2 in the human body; low toxicity profile.",
            "FSSAI Permitted Preservatives Table"
        ),
    ]

    for ing in ingredients:
        cursor.execute(
            "INSERT INTO ingredients (canonical_name, category_name, risk_level, health_effects, fssai_ref) VALUES (?, ?, ?, ?, ?)",
            ing
        )
        ing_id = cursor.lastrowid

        # Insert aliases for this ingredient
        aliases = _get_aliases_for_canonical(ing[0])
        for alias in aliases:
            cursor.execute(
                "INSERT OR IGNORE INTO aliases (ingredient_id, alias) VALUES (?, ?)",
                (ing_id, alias.lower().strip())
            )

    # Healthier Alternatives data
    alternatives = [
        ("Namkeen / Fried Snacks", "Roasted Foxnuts (Makhana) - Himalayan Pink Salt", 88, "₹80 / 100g", "Roasted in cold-pressed olive oil, zero palm oil or TBHQ"),
        ("Namkeen / Fried Snacks", "Baked Chana Jor Chaat (No Palm Oil)", 82, "₹65 / 100g", "High protein roasted black chickpeas with natural spices"),
        ("Namkeen / Fried Snacks", "Multigrain Roasted Sev / Bajra Crisps", 78, "₹75 / 100g", "Made with ragi, jowar and bajra; baked not deep fried"),
        ("Bakery / Biscuits", "Whole Wheat & Ragi Biscuits (Jaggery Sweetened)", 84, "₹60 / pack", "Zero maida, zero trans fat, sweetened with unrefined gur"),
        ("Bakery / Biscuits", "100% Whole Wheat Sourdough Bread", 86, "₹70 / loaf", "Traditional fermentation, zero chemical dough conditioners"),
        ("Bakery / Biscuits", "Oats & Honey Crunch Crackers", 80, "₹55 / pack", "High fiber, free from artificial food colorings or BHA"),
        ("Sweets / Mithai", "Dry Fruit & Seed Ladoo (Sugar-Free)", 85, "₹350 / 500g", "Naturally sweetened with dates, figs and organic desi ghee"),
        ("Sweets / Mithai", "Artisanal Kaju Katli (Khand / Jaggery)", 79, "₹420 / 500g", "100% cashews, zero synthetic silver foil (vark) adulterants"),
        ("Packaged Spices / Masala", "Agmark Single-Origin Certified Haldi Powder", 94, "₹90 / 200g", "Lab-tested for lead chromate and ethylene oxide safety"),
        ("Packaged Spices / Masala", "FSSAI Organic Certified Garam Masala Whole/Crushed", 92, "₹120 / 100g", "Whole spice blend without loose anti-caking fillers"),
        ("Beverages", "Tender Coconut Water (Fresh / Biopacked)", 95, "₹50 / piece", "Natural electrolytes, 0g added refined sugar"),
        ("Beverages", "Spiced Chaas (Traditional Indian Buttermilk)", 90, "₹25 / 200ml", "Probiotic curd with roasted cumin and mint, no preservatives"),
        ("Instant Foods / Ready-to-Eat", "Millet Hakka Noodles (Air Dried)", 83, "₹85 / pack", "Made with foxtail millet, air dried, zero MSG tastemaker"),
        ("Instant Foods / Ready-to-Eat", "Instant Oats & Moong Dal Khichdi Mix", 88, "₹75 / box", "Freeze-dried whole ingredients, no hydrogenated fats"),
        ("Dairy", "A2 Desi Cow Bilona Ghee", 92, "₹850 / 500ml", "Traditional bilona churning, rich in natural omega-3 and CLA"),
        ("Dairy", "Fresh Country Curd (Dahi)", 94, "₹40 / 400g", "Live active cultures, no added gelatins or stabilizers"),
    ]
    cursor.executemany(
        "INSERT INTO alternatives (category_name, name, score, price, note) VALUES (?, ?, ?, ?, ?)",
        alternatives
    )

    conn.commit()


def _get_aliases_for_canonical(canonical_name: str) -> list[str]:
    mapping = {
        "Partially Hydrogenated Vegetable Oil": [
            "partially hydrogenated vegetable oil", "partially hydrogenated oil",
            "vanaspati", "dalda", "hydrogenated fat", "hydrogenated vegetable oil",
            "trans fat", "trans fatty acids"
        ],
        "Tartrazine (E102 / INS 102)": [
            "tartrazine", "e102", "ins 102", "ins102", "fd&c yellow 5", "yellow 5",
            "synthetic food colour (102)", "food colour 102"
        ],
        "Sunset Yellow FCF (E110 / INS 110)": [
            "sunset yellow", "sunset yellow fcf", "e110", "ins 110", "ins110",
            "fd&c yellow 6", "yellow 6", "food colour 110"
        ],
        "Allura Red (E129 / INS 129)": [
            "allura red", "allura red ac", "e129", "ins 129", "ins129",
            "fd&c red 40", "red 40"
        ],
        "BHA (E320 / INS 320)": [
            "bha", "e320", "ins 320", "ins320", "butylated hydroxyanisole", "antioxidant 320"
        ],
        "High Fructose Corn Syrup": [
            "high fructose corn syrup", "hfcs", "corn syrup", "glucose-fructose syrup",
            "isoglucose"
        ],
        "Potassium Bromate": [
            "potassium bromate", "e924", "flour treatment agent 924"
        ],
        "Monosodium Glutamate (MSG / INS 621)": [
            "monosodium glutamate", "msg", "ajinomoto", "e621", "ins 621", "ins621",
            "flavour enhancer 621", "flavor enhancer (621)", "yeast extract msg"
        ],
        "Palm Oil / Palmolein": [
            "palm oil", "palmolein", "refined palm oil", "refined palmolein",
            "palm kernel oil", "fractionated palm oil", "edible vegetable oil (palm)"
        ],
        "TBHQ (E319 / INS 319)": [
            "tbhq", "e319", "ins 319", "ins319", "tertiary butylhydroquinone",
            "antioxidant 319"
        ],
        "BHT (E321 / INS 321)": [
            "bht", "e321", "ins 321", "ins321", "butylated hydroxytoluene", "antioxidant 321"
        ],
        "Sodium Benzoate (E211 / INS 211)": [
            "sodium benzoate", "e211", "ins 211", "ins211", "preservative 211", "benzoate"
        ],
        "Aspartame (E951 / INS 951)": [
            "aspartame", "e951", "ins 951", "ins951", "artificial sweetener (951)",
            "nutrasweet", "equal"
        ],
        "Acesulfame Potassium (E950 / INS 950)": [
            "acesulfame potassium", "acesulfame k", "ace-k", "e950", "ins 950", "ins950",
            "artificial sweetener (950)"
        ],
        "Refined Wheat Flour (Maida)": [
            "maida", "refined wheat flour", "refined flour", "all purpose flour",
            "wheat flour (maida)", "bleached flour"
        ],
        "Refined Sugar / Added Sugar": [
            "sugar", "refined sugar", "sucrose", "added sugar", "cane sugar",
            "white sugar", "invert sugar syrup"
        ],
        "Caramel Colour (Class IV / INS 150d)": [
            "caramel colour", "caramel color", "e150d", "ins 150d", "ins150d",
            "caramel class iv", "ammonia sulfite caramel"
        ],
        "Hydrolyzed Vegetable Protein (HVP)": [
            "hydrolyzed vegetable protein", "hvp", "hydrolysed plant protein",
            "soy protein isolate hydrolyzed"
        ],
        "Artificial Flavoring Substances": [
            "artificial flavor", "artificial flavour", "artificial flavoring substances",
            "nature identical flavouring", "nature identical flavor", "synthetic flavoring"
        ],
        "Excess Sodium / Salt": [
            "salt", "iodised salt", "edible common salt", "sodium chloride", "excess sodium"
        ],
        "Whole Wheat Flour (Atta)": [
            "whole wheat", "whole wheat flour", "atta", "whole grain wheat", "chakki atta"
        ],
        "Oats": [
            "oats", "rolled oats", "wholegrain oats", "oat flakes", "oat flour"
        ],
        "Ragi (Finger Millet)": [
            "ragi", "finger millet", "nachni", "mandua", "ragi flour"
        ],
        "Bajra (Pearl Millet)": [
            "bajra", "pearl millet", "kambu", "sajjalu"
        ],
        "Turmeric (Haldi)": [
            "turmeric", "haldi", "curcuma longa", "turmeric powder"
        ],
        "Desi Ghee": [
            "desi ghee", "ghee", "clarified butter", "cow ghee"
        ],
        "Jaggery (Gur)": [
            "jaggery", "gur", "gud", "unrefined cane sugar", "organic jaggery"
        ],
        "Cold Pressed Mustard Oil": [
            "mustard oil", "kachi ghani mustard oil", "cold pressed oil", "sarson tel"
        ],
        "Roasted Chana (Chickpeas)": [
            "roasted chana", "chana", "bengal gram", "roasted chickpeas"
        ],
        "Makhana (Fox Nuts)": [
            "makhana", "fox nuts", "lotus seeds", "phool makhana"
        ],
        "Citric Acid (INS 330)": [
            "citric acid", "e330", "ins 330", "ins330", "acidity regulator (330)"
        ],
        "Soy Lecithin (INS 322)": [
            "soy lecithin", "soya lecithin", "lecithin", "e322", "ins 322", "ins322",
            "emulsifier (322)"
        ],
        "Potassium Sorbate (INS 202)": [
            "potassium sorbate", "e202", "ins 202", "ins202", "preservative 202"
        ],
    }
    return mapping.get(canonical_name, [canonical_name.lower()])


# Initialize database upon module import
init_db()
