"""
Security & Authentication layer for Willow.
Provides:
- PBKDF2-SHA256 salted password hashing & verification
- Cryptographic JWT tokens with 7-day expiration
- Token authentication decorators for Flask endpoints
- Input sanitization & validation (email, username, password)
"""

import os
import re
import datetime
from functools import wraps
from flask import request, jsonify
import jwt
from werkzeug.security import generate_password_hash, check_password_hash

# Secret key for JWT signing - defaults to a secure fallback, configurable via environment
JWT_SECRET = os.environ.get("WILLOW_JWT_SECRET", "willow-fssai-ai-secret-key-2026-v1-supersecure")
JWT_ALGORITHM = "HS256"
JWT_EXPIRATION_DAYS = 7

EMAIL_REGEX = re.compile(r"^[\w\.\+\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z0-9\-\.]+$")


def hash_password(password: str) -> str:
    """Hash password using salted PBKDF2 with SHA-256."""
    return generate_password_hash(password, method="pbkdf2:sha256", salt_length=16)


def verify_password(password: str, hashed: str) -> bool:
    """Verify password against stored salt and hash."""
    return check_password_hash(hashed, password)


def generate_token(user_id: int, username: str, email: str) -> str:
    """Create a signed JWT token with 7-day expiry."""
    payload = {
        "sub": str(user_id),
        "username": username,
        "email": email,
        "iat": datetime.datetime.now(datetime.timezone.utc),
        "exp": datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(days=JWT_EXPIRATION_DAYS),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def decode_token(token: str) -> dict | None:
    """Decode and verify JWT token. Returns payload or None if invalid/expired."""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        if "sub" in payload:
            payload["user_id"] = int(payload["sub"])
        return payload
    except (jwt.ExpiredSignatureError, jwt.InvalidTokenError):
        return None


def validate_user_input(username: str, email: str, password: str) -> str | None:
    """Validate user registration inputs. Returns error message or None if valid."""
    username = (username or "").strip()
    email = (email or "").strip().lower()
    password = password or ""

    if len(username) < 3 or len(username) > 30:
        return "Username must be between 3 and 30 characters."

    if not re.match(r"^[a-zA-Z0-9_\-\. ]+$", username):
        return "Username contains invalid characters. Use letters, numbers, hyphens, and underscores."

    if not EMAIL_REGEX.match(email):
        return "Please enter a valid email address."

    if len(password) < 6:
        return "Password must be at least 6 characters long."

    return None


def token_required(f):
    """Flask decorator requiring a valid Bearer JWT token."""
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            return jsonify({"error": "Authorization token required", "code": "UNAUTHORIZED"}), 401

        token = auth_header.split(" ", 1)[1].strip()
        payload = decode_token(token)
        if not payload:
            return jsonify({"error": "Invalid or expired authorization token", "code": "INVALID_TOKEN"}), 401

        request.user = payload
        return f(*args, **kwargs)
    return decorated


def optional_token(f):
    """Flask decorator that parses token if provided, but allows guest access."""
    @wraps(f)
    def decorated(*args, **kwargs):
        auth_header = request.headers.get("Authorization")
        request.user = None
        if auth_header and auth_header.startswith("Bearer "):
            token = auth_header.split(" ", 1)[1].strip()
            payload = decode_token(token)
            if payload:
                request.user = payload
        return f(*args, **kwargs)
    return decorated
