"""
Integration test script for Willow API.
Tests all major endpoints to confirm the full pipeline works end-to-end.
Run from: codes/OCR/extractor/
Usage:  python test_api.py
"""
import requests
import json
import sys
import os

BASE = "http://127.0.0.1:5000"
HEADERS = {"Content-Type": "application/json"}

# -------------------------------------------------------------------
# Helpers
# -------------------------------------------------------------------
PASS = "\033[92m[PASS]\033[0m"
FAIL = "\033[91m[FAIL]\033[0m"
SKIP = "\033[93m[SKIP]\033[0m"
results = []

def check(name, condition, detail=""):
    status = PASS if condition else FAIL
    results.append(condition)
    detail_str = f"  -> {detail}" if detail else ""
    print(f"  {status} {name}{detail_str}")

def section(title):
    print(f"\n{'='*55}")
    print(f"  {title}")
    print(f"{'='*55}")

# -------------------------------------------------------------------
# 1. Health check
# -------------------------------------------------------------------
section("1. Health Check")
try:
    r = requests.get(f"{BASE}/api/health", timeout=5)
    data = r.json()
    check("Server is up", r.status_code == 200)
    check("Version ≥ 2.0.0", data.get("version", "0") >= "2.0.0", data.get("version"))
    check("OFF integration enabled", data.get("off") == "enabled")
except Exception as e:
    check("Server reachable", False, str(e))
    print(f"\n  {FAIL} Cannot reach the server. Start it with: python api_server.py")
    sys.exit(1)

# -------------------------------------------------------------------
# 2. Auth — Register + Login
# -------------------------------------------------------------------
section("2. Auth: Register & Login")
TEST_USER = "testuser_willow_ci"
TEST_PASS = "TestPass@123"
TEST_EMAIL = f"{TEST_USER}@test.com"
token = None

try:
    r = requests.post(f"{BASE}/api/auth/register", headers=HEADERS,
                      json={"username": TEST_USER, "email": TEST_EMAIL, "password": TEST_PASS}, timeout=5)
    # 201 = new user, 400 = already exists (both are ok for test)
    check("Register (201 or 400)", r.status_code in (201, 400), str(r.status_code))

    r = requests.post(f"{BASE}/api/auth/login", headers=HEADERS,
                      json={"identifier": TEST_USER, "password": TEST_PASS}, timeout=5)
    check("Login returns 200", r.status_code == 200, str(r.status_code))
    if r.status_code == 200:
        token = r.json().get("access_token")
        check("JWT token in response", bool(token), f"token length={len(token or '')}")
except Exception as e:
    check("Auth flow", False, str(e))

auth_headers = {**HEADERS, "Authorization": f"Bearer {token}"} if token else HEADERS

# -------------------------------------------------------------------
# 3. Analyze — Direct classification (no image)
# -------------------------------------------------------------------
section("3. Analyze: FSSAI + OFF classification")
try:
    payload = {
        "product_name": "Haldiram Bhujia",
        "ingredients": ["refined wheat flour", "palm oil", "salt", "monosodium glutamate", "tartrazine", "sodium benzoate"],
        "fssai_number": "10015011002804"
    }
    r = requests.post(f"{BASE}/api/analyze", headers=auth_headers, json=payload, timeout=15)
    check("Analyze returns 200", r.status_code == 200, str(r.status_code))
    if r.status_code == 200:
        data = r.json()
        check("risk_score present", "risk_score" in data, str(data.get("risk_score")))
        check("blended_score present", "blended_score" in data, str(data.get("blended_score")))
        check("flagged list present", "flagged" in data, f"{len(data.get('flagged', []))} flagged")
        check("alternatives present", "alternatives" in data, f"{len(data.get('alternatives', []))} alternatives")
        check("off_data field present", "off_data" in data)
        print(f"          Score: {data.get('risk_score')} | Blended: {data.get('blended_score')}")
        print(f"          Flagged: {[f['canonical'] for f in data.get('flagged', [])]}")
except Exception as e:
    check("Analyze endpoint", False, str(e))

# -------------------------------------------------------------------
# 4. OFF Lookup
# -------------------------------------------------------------------
section("4. Open Food Facts Lookup")
try:
    r = requests.post(f"{BASE}/api/off/lookup", headers=HEADERS,
                      json={"product_name": "Lays chips"}, timeout=10)
    check("OFF lookup returns 200", r.status_code == 200, str(r.status_code))
    if r.status_code == 200:
        data = r.json()
        found = data.get("found", False)
        if found:
            check("NutriScore grade present", "nutriscore_grade" in data)
            check("Nutrients present", "nutrients" in data)
            print(f"          Found: {data.get('off_product_name')} | NutriScore: {data.get('nutriscore_grade')}")
        else:
            print(f"          {SKIP} Product not found on OFF (API may be down) — graceful fallback OK")
except Exception as e:
    check("OFF lookup endpoint", False, str(e))

# -------------------------------------------------------------------
# 5. Categories & Risk Profiles (FR-12/FR-13)
# -------------------------------------------------------------------
section("5. Categories & Risk Profiles (Unbranded Fallback)")
try:
    r = requests.get(f"{BASE}/api/categories", timeout=5)
    check("Categories returns 200", r.status_code == 200)
    data = r.json()
    cats = data.get("categories", [])
    check(f"Has ≥5 categories", len(cats) >= 5, f"{len(cats)} categories")

    r2 = requests.get(f"{BASE}/api/categories/risk-profiles", timeout=5)
    check("Risk profiles returns 200", r2.status_code == 200)
    profiles = r2.json().get("profiles", [])
    check(f"Has ≥3 risk profiles", len(profiles) >= 3, f"{len(profiles)} profiles")
    if profiles:
        p = profiles[0]
        check("Profile has note field", "note" in p)
        check("Profile has generic_risk", "generic_risk" in p)
except Exception as e:
    check("Categories/Profiles", False, str(e))

# -------------------------------------------------------------------
# 6. Scan History (requires auth)
# -------------------------------------------------------------------
section("6. Scan History (Auth required)")
if token:
    try:
        r = requests.get(f"{BASE}/api/history", headers=auth_headers, timeout=5)
        check("History returns 200", r.status_code == 200, str(r.status_code))
        hist = r.json().get("history", [])
        check("History is a list", isinstance(hist, list), f"{len(hist)} items")
    except Exception as e:
        check("History endpoint", False, str(e))
else:
    print(f"  {SKIP} Skipped — no auth token")

# -------------------------------------------------------------------
# 7. Manual Analyze (FR-15 — no image)
# -------------------------------------------------------------------
section("7. Manual Entry Flow (FR-15)")
try:
    payload = {
        "product_name": "Homemade Namkeen",
        "ingredients": ["besan", "refined oil", "salt", "red chili", "ajwain"],
    }
    r = requests.post(f"{BASE}/api/analyze", headers=HEADERS, json=payload, timeout=12)
    check("Manual analyze returns 200", r.status_code == 200, str(r.status_code))
    if r.status_code == 200:
        d = r.json()
        check("score_label present", "score_label" in d, d.get("score_label"))
        check("is_fallback field present", "is_fallback" in d)
except Exception as e:
    check("Manual analyze", False, str(e))

# -------------------------------------------------------------------
# Summary
# -------------------------------------------------------------------
section("Summary")
total = len(results)
passed = sum(results)
failed = total - passed
emoji = "✅" if failed == 0 else "⚠️"
print(f"\n  {emoji}  {passed}/{total} checks passed", end="")
if failed > 0:
    print(f"  ({failed} failed)")
else:
    print("  — All clear!")
print()
sys.exit(0 if failed == 0 else 1)
