import os
from pathlib import Path
from dotenv import load_dotenv
from google import genai

# Load .env
env_path = Path(__file__).resolve().parent / ".env"
load_dotenv(env_path)

api_key = os.getenv("GEMINI_API_KEY")

print("ENV FILE:", env_path)
print("API KEY FOUND:", bool(api_key))

if not api_key:
    raise RuntimeError("GEMINI_API_KEY was not found")

client = genai.Client(api_key=api_key)

response = client.models.generate_content(
    model="gemini-3.6-flash",
    contents="Say hello in one sentence."
)

print("\nGemini response:")
print(response.text)