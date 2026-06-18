# from fastapi import FastAPI
# from pydantic import BaseModel
# from fastapi.middleware.cors import CORSMiddleware
# import os
# from openai import OpenAI
# from dotenv import load_dotenv

# load_dotenv()
# openai.api_key = os.getenv("OPENAI_API_KEY")

# app = FastAPI()

# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# class MealRequest(BaseModel):
#     country: str
#     goal: str
#     calories: int
#     protein: float
#     carbs: float
#     fats: float

# @app.get("/")
# def home():
#     return {"message": "FitForge Backend Running"}

# @app.post("/generate-mealplan")
# async def generate_mealplan(req: MealRequest):

#     prompt = f"""
#     You are a nutrition expert. Create a JSON-only 7-day meal plan.
#     Requirements:
#     - Country: {req.country}
#     - Goal: {req.goal}
#     - Daily Calories: {req.calories}
#     - Macros: {req.protein}g protein, {req.carbs}g carbs, {req.fats}g fats
#     - Use foods common in {req.country}
#     - Each day must have breakfast, lunch, dinner, snack.

#     Respond ONLY in JSON format:
#     {{
#       "mealplan": [
#         {{
#           "day": 1,
#           "breakfast": "",
#           "lunch": "",
#           "dinner": "",
#           "snack": ""
#         }}
#       ]
#     }}
#     """

#     response = openai.ChatCompletion.create(
#         model="gpt-4o-mini",
#         messages=[{"role": "user", "content": prompt}]
#     )

#     return {"plan": response.choices[0].message["content"]}


# import os
# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from pydantic import BaseModel
# from dotenv import load_dotenv
# from openai import OpenAI

# # Load environment variables
# load_dotenv()

# # Initialize OpenAI client
# client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# # FastAPI app
# app = FastAPI()

# # CORS (Allow iOS App)
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # Input model for requests
# class MealPlanInput(BaseModel):
#     country: str
#     goal: str
#     calories: int
#     protein: int
#     carbs: int
#     fats: int


# @app.get("/")
# def root():
#     return {"message": "FitForge Backend is running!"}


# @app.post("/generate-mealplan")
# async def generate_mealplan(data: MealPlanInput):
#     """
#     Generate a strict 7-day meal plan JSON using GPT-4o-mini.
#     """

#     prompt = f"""
# You are a fitness nutrition AI. Generate a STRICT JSON 7-day meal plan.

# RULES:
# - ONLY return valid JSON.
# - DO NOT return markdown.
# - DO NOT use ```json or code fences.
# - DO NOT add comments or text outside JSON.
# - Use the EXACT structure below:

# {{
#   "mealplan": [
#     {{
#       "day": 1,
#       "breakfast": "string",
#       "lunch": "string",
#       "dinner": "string",
#       "snack": "string"
#     }}
#   ]
# }}

# USER PROFILE:
# Country: {data.country}
# Goal: {data.goal}
# Daily Calories: {data.calories}
# Protein: {data.protein}g
# Carbs: {data.carbs}g
# Fats: {data.fats}g

# Now generate the 7-day meal plan in the exact JSON structure.
# """

#     # Call OpenAI
#     response = client.chat.completions.create(
#         model="gpt-4o-mini",
#         messages=[
#             {"role": "user", "content": prompt}
#         ]
#     )

#     # Extract text response
#     content = response.choices[0].message.content

#     # Return the raw JSON string (iOS will parse it)
#     return content


# import os
# import json
# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from pydantic import BaseModel
# from dotenv import load_dotenv
# from openai import OpenAI

# # Load environment variables
# load_dotenv()

# # Initialize OpenAI client
# client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# # FastAPI app
# app = FastAPI()

# # CORS for iOS app
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # Input model
# class MealPlanInput(BaseModel):
#     country: str
#     goal: str
#     calories: float
#     protein: float
#     carbs: float
#     fats: float


# @app.get("/")
# def root():
#     return {"message": "FitForge Backend is running!"}


# @app.post("/generate-mealplan")
# async def generate_mealplan(data: MealPlanInput):
#     carbs = int(data.carbs)
#     fats = int(data.fats)
#     protein = int(data.protein)
#     calories = int(data.calories)


#     prompt = f"""
# You are a fitness nutrition AI. Generate a STRICT JSON 7-day meal plan.

# RULES:
# - ONLY return valid JSON.
# - DO NOT return markdown, no ```json.
# - DO NOT add comments.
# - Use the EXACT structure:

# {{
#   "mealplan": [
#     {{
#       "day": 1,
#       "breakfast": "string",
#       "lunch": "string",
#       "dinner": "string",
#       "snack": "string"
#     }}
#   ]
# }}

# USER PROFILE:
# Country: {data.country}
# Goal: {data.goal}
# Daily Calories: {data.calories}
# Protein: {data.protein}g
# Carbs: {data.carbs}g
# Fats: {data.fats}g
# """

#     # Call OpenAI
#     response = client.chat.completions.create(
#         model="gpt-4o-mini",
#         messages=[{"role": "user", "content": prompt}]
#     )

#     # Extract response text
#     content = response.choices[0].message.content

#     # Parse server-side JSON so iOS receives clean JSON
#     try:
#         parsed_json = json.loads(content)
#     except Exception as e:
#         print("❌ JSON Parsing Error:", e)
#         return {"error": "AI returned invalid JSON", "raw": content}

#     return parsed_json

# import os
# import json
# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from pydantic import BaseModel
# from dotenv import load_dotenv
# from openai import OpenAI

# # Load environment variables
# load_dotenv()

# # Initialize OpenAI client
# client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# # FastAPI app
# app = FastAPI()

# # CORS for iOS app
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# # Input model (iOS sends floats → backend converts to int)
# class MealPlanInput(BaseModel):
#     country: str
#     goal: str
#     calories: float
#     protein: float
#     carbs: float
#     fats: float


# @app.get("/")
# def root():
#     return {"message": "FitForge Backend is running!"}


# @app.post("/generate-mealplan")
# async def generate_mealplan(data: MealPlanInput):

#     # Convert macro values to integers
#     calories = int(data.calories)
#     protein = int(data.protein)
#     carbs = int(data.carbs)
#     fats = int(data.fats)

#     prompt = f"""
# You are a fitness nutrition AI. Generate a STRICT JSON 7-day meal plan.

# RULES:
# - ONLY return valid JSON.
# - DO NOT return markdown.
# - DO NOT use ```json.
# - DO NOT add comments or extra text.
# - Follow EXACT structure:

# {{
#   "mealplan": [
#     {{
#       "day": 1,
#       "breakfast": "string",
#       "lunch": "string",
#       "dinner": "string",
#       "snack": "string"
#     }}
#   ]
# }}

# USER PROFILE:
# Country: {data.country}
# Goal: {data.goal}
# Daily Calories: {calories}
# Protein: {protein}g
# Carbs: {carbs}g
# Fats: {fats}g

# Generate the full 7-day JSON now.
# """

#     # Call OpenAI
#     response = client.chat.completions.create(
#         model="gpt-4o-mini",
#         messages=[{"role": "user", "content": prompt}]
#     )

#     # Extract response text
#     content = response.choices[0].message.content

#     # Parse JSON (AI returns string → backend returns dict)
#     try:
#         parsed_json = json.loads(content)
#     except Exception as e:
#         print("❌ JSON Parsing Error:", e)
#         return {"error": "AI returned invalid JSON", "raw": content}

#     return parsed_json



# @app.post("/chat")
# async def chat_endpoint(payload: dict):
#     """
#     AI Fitness Coach — personalized contextual chat endpoint.
#     """

#     # Extract input
#     user_message = payload.get("message", "")
#     profile = payload.get("profile", {})
#     macros = payload.get("macros", {})
#     history = payload.get("history", [])

#     if not user_message:
#         return {"reply": "Please enter a message."}

#     # Pull profile fields safely
#     name = profile.get("name", "User")
#     age = profile.get("age", "Unknown")
#     gender = profile.get("gender", "Unknown")
#     height = profile.get("height", "Unknown")
#     weight = profile.get("weight", "Unknown")
#     activity = profile.get("activityLevel", "Unknown")
#     goal = profile.get("goal", "Unknown")
#     country = profile.get("country", "Unknown")

#     # Macro stats
#     calories = macros.get("goalCalories", 0)
#     protein = macros.get("protein", 0)
#     carbs = macros.get("carbs", 0)
#     fats = macros.get("fats", 0)

#     # Build system message
#     system_prompt = f"""
# You are FITFORGE AI — a world-class fitness coach, personal trainer, and nutrition expert.

# Your coaching style:
# - Motivational but not cringe
# - Clear, simple, no overthinking
# - Accurate, science-based advice
# - No emojis unless user uses them first
# - Never mention that you're an AI
# - Never break character

# USER PROFILE:
# - Name: {name}
# - Age: {age}
# - Gender: {gender}
# - Height: {height}
# - Weight: {weight}
# - Activity Level: {activity}
# - Goal: {goal}
# - Country: {country}

# MACRO TARGETS:
# - Daily Calories: {calories}
# - Protein: {protein}g
# - Carbs: {carbs}g
# - Fats: {fats}g

# COACHING RULES:
# 1. Always personalize responses using the user's profile.
# 2. Consider user's goal in every reply.
# 3. Adjust advice based on their activity level.
# 4. Provide realistic steps, not generic nonsense.
# 5. If user lives in a specific country, tailor food examples to culture.
# 6. If user asks for workouts, include sets & reps.
# 7. If user mentions progress or frustration, respond emotionally like a real coach.
# 8. Keep responses concise unless user requests detail.
# """

#     # Build conversation → includes system + history + new message
#     messages = [{"role": "system", "content": system_prompt}]

#     # Append past history
#     for msg in history:
#         role = msg.get("role", "user")
#         content = msg.get("content", "")
#         messages.append({"role": role, "content": content})

#     # Append new message
#     messages.append({"role": "user", "content": user_message})

#     # Call GPT model
#     response = client.chat.completions.create(
#         model="gpt-4o-mini",
#         messages=messages
#     )

#     reply = response.choices[0].message.content
#     return {"reply": reply}

# import os
# import json
# from datetime import datetime

# from fastapi import FastAPI
# from fastapi.middleware.cors import CORSMiddleware
# from pydantic import BaseModel
# from dotenv import load_dotenv
# from openai import OpenAI

# # Load environment variables
# load_dotenv()

# # Initialize OpenAI client
# client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# # FastAPI app
# app = FastAPI()

# # CORS for iOS app
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],       # in prod you’d lock this down
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )



# # -----------------------------
# # MEMORY STORAGE (7D)
# # -----------------------------
# MEMORY_FILE = "memories.json"


# def load_memories():
#     """Load long-term memories from disk."""
#     if not os.path.exists(MEMORY_FILE):
#         return []
#     try:
#         with open(MEMORY_FILE, "r") as f:
#             return json.load(f)
#     except Exception as e:
#         print("❌ Failed to load memories:", e)
#         return []


# def save_memories(memories):
#     """Persist memories to disk."""
#     try:
#         with open(MEMORY_FILE, "w") as f:
#             json.dump(memories, f, indent=2)
#     except Exception as e:
#         print("❌ Failed to save memories:", e)


# def add_memory_if_new(memories, new_memory: str):
#     """Append a new memory if it’s not empty and not already stored."""
#     if not new_memory:
#         return memories

#     # Simple duplicate check by text
#     for m in memories:
#         if m.get("text") == new_memory:
#             return memories

#     memories.append(
#         {
#             "id": len(memories) + 1,
#             "text": new_memory,
#             "created_at": datetime.utcnow().isoformat() + "Z",
#         }
#     )
#     save_memories(memories)
#     print(f"💾 Stored new memory: {new_memory}")
#     return memories


# # -----------------------------
# # MODELS
# # -----------------------------
# class MealPlanInput(BaseModel):
#     country: str
#     goal: str
#     calories: float
#     protein: float
#     carbs: float
#     fats: float


# # -----------------------------
# # ROOT
# # -----------------------------
# @app.get("/")
# def root():
#     return {"message": "FitForge Backend is running!"}


# # -----------------------------
# # MEAL PLAN ENDPOINT (unchanged)
# # -----------------------------
# @app.post("/generate-mealplan")
# async def generate_mealplan(data: MealPlanInput):

#     calories = int(data.calories)
#     protein = int(data.protein)
#     carbs = int(data.carbs)
#     fats = int(data.fats)

#     prompt = f"""
# You are a fitness nutrition AI. Generate a STRICT JSON 7-day meal plan.

# RULES:
# - ONLY return valid JSON.
# - DO NOT return markdown.
# - DO NOT use ```json.
# - DO NOT add comments or extra text.
# - Follow EXACT structure:

# {{
#   "mealplan": [
#     {{
#       "day": 1,
#       "breakfast": "string",
#       "lunch": "string",
#       "dinner": "string",
#       "snack": "string"
#     }}
#   ]
# }}

# USER PROFILE:
# Country: {data.country}
# Goal: {data.goal}
# Daily Calories: {calories}
# Protein: {protein}g
# Carbs: {carbs}g
# Fats: {fats}g

# Generate the full 7-day JSON now.
# """

#     response = client.chat.completions.create(
#         model="gpt-4o-mini",
#         messages=[{"role": "user", "content": prompt}],
#     )

#     content = response.choices[0].message.content

#     try:
#         parsed_json = json.loads(content)
#     except Exception as e:
#         print("❌ JSON Parsing Error:", e)
#         return {"error": "AI returned invalid JSON", "raw": content}

#     return parsed_json


# # -----------------------------
# # CHAT ENDPOINT WITH MEMORY (7D)
# # -----------------------------
# @app.post("/chat")
# async def chat_endpoint(payload: dict):
#     """
#     AI Fitness Coach — personalized chat response with long-term memory.

#     iOS sends (from AIChatService.sendMessageAdvanced):
#     {
#         "message": "user question",
#         "profile": {...},
#         "macros": {...},
#         "history": [
#             {"role": "user" | "assistant", "content": "..."},
#             ...
#         ]
#     }
#     """

#     user_message = (payload.get("message") or "").strip()
#     profile = payload.get("profile") or {}
#     macros = payload.get("macros") or {}
#     history = payload.get("history") or []

#     if not user_message:
#         return {"reply": "Please enter a message."}

#     # 1) Load long-term memories
#     memories = load_memories()
#     if memories:
#         memories_text = "\n".join(f"- {m.get('text', '')}" for m in memories)
#     else:
#         memories_text = "No long-term memories stored yet."

#     # 2) Build system prompt including profile, macros, and memories
#     system_prompt = f"""
# You are FITFORGE AI — an elite, disciplined fitness coach.

# You are coaching ONE specific user. Use the profile, macros, and long-term memories
# below to give highly personalized advice.

# USER PROFILE:
# - Name: {profile.get('name', '')}
# - Age: {profile.get('age', '')}
# - Gender: {profile.get('gender', '')}
# - Height: {profile.get('height', '')}
# - Weight: {profile.get('weight', '')}
# - Activity Level: {profile.get('activityLevel', '')}
# - Goal: {profile.get('goal', '')}
# - Country: {profile.get('country', '')}

# CURRENT MACROS:
# - Calories: {macros.get('goalCalories', 0)}
# - Protein: {macros.get('protein', 0)} g
# - Carbs: {macros.get('carbs', 0)} g
# - Fats: {macros.get('fats', 0)} g

# LONG-TERM USER MEMORIES:
# {memories_text}

# COACHING RULES:
# - Be direct, positive, serious and practical.
# - Speak like a real experienced trainer, not a generic chatbot.
# - Use memories when they are relevant (e.g. schedule, equipment, dislikes).
# - Do NOT say the word "memory" or mention that you store data.
# - No markdown code blocks.
# - No numbered markdown lists; short plain lists or paragraphs are fine.
# - No emojis unless the user uses them first.
# """

#     # 3) Build full OpenAI messages array
#     messages = [{"role": "system", "content": system_prompt}]

#     for item in history:
#         role = item.get("role", "user")
#         content = item.get("content", "")
#         if not content:
#             continue
#         if role not in ("user", "assistant", "system"):
#             role = "user"
#         messages.append({"role": role, "content": content})

#     # NOTE: history already includes the latest user message (from iOS).
#     # We don't need to append user_message again.

#     # 4) Call OpenAI for the coach reply
#     chat_response = client.chat.completions.create(
#         model="gpt-4o-mini",
#         messages=messages,
#     )

#     reply_text = chat_response.choices[0].message.content

#     # 5) Second AI call: decide if we should store a new long-term memory
#     try:
#         memory_prompt = f"""
# You are a memory extraction engine for a fitness coaching app.

# You will be given:
# - The user's latest message.
# - The assistant's latest reply.
# - A list of existing long-term memories.

# A "long-term memory" is something stable and useful for future coaching, such as:
# - Preferred workout time or schedule (e.g. "I train at 8 PM")
# - Preferred style (home workouts, PPL split, full body, etc.)
# - Diet preferences or restrictions (vegetarian, hates dairy, etc.)
# - Equipment access (only dumbbells at home, full gym, resistance bands)
# - Injuries or pain (knee pain when squatting, shoulder issues)
# - Strong dislikes (e.g. "I hate running, prefer cycling")
# - Motivation patterns (e.g. struggles with consistency on weekends)

# DO NOT store:
# - One-off meals ("I ate pizza today")
# - Generic questions without new info
# - Very short emotional expressions ("today sucked", "I'm tired")

# Existing memories:
# {memories_text}

# Latest user message:
# \"\"\"{user_message}\"\"\"

# Latest assistant reply:
# \"\"\"{reply_text}\"\"\"

# Respond ONLY with valid JSON in this form:
# {{
#   "should_write_memory": true or false,
#   "memory": "short first-person sentence capturing the new fact, or empty string"
# }}
# """

#         mem_response = client.chat.completions.create(
#             model="gpt-4o-mini",
#             messages=[{"role": "user", "content": memory_prompt}],
#         )
#         mem_content = mem_response.choices[0].message.content.strip()

#         data = json.loads(mem_content)
#         if (
#             isinstance(data, dict)
#             and data.get("should_write_memory") is True
#             and isinstance(data.get("memory"), str)
#             and data["memory"].strip()
#         ):
#             memories = add_memory_if_new(memories, data["memory"].strip())

#     except Exception as e:
#         print("❌ Memory extraction error:", e)

#     # 6) Return reply to iOS
#     return {"reply": reply_text}


import os
import json
from datetime import datetime

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
from openai import OpenAI

# Load environment variables
load_dotenv()

# Initialize OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# FastAPI app
app = FastAPI()

# CORS for iOS app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Lock down in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ----------------------------------------------------------
#  SHORT-TERM MEMORY (Step 6)
# ----------------------------------------------------------
coach_memory = {
    "last_workout": None,
    "soreness": [],
    "energy": None,
    "injuries": [],
    "preferences": {
        "equipment": [],
        "style": [],
        "intensity": None
    }
}


def extract_short_term_memory(user_message: str):
    """Update coach_memory based on keywords in the user's message."""
    text = user_message.lower()

    # SORENESS DETECTION
    sore_keywords = ["sore", "pain", "tight", "hurts", "stiff"]
    body_parts = [
        "chest", "back", "triceps", "biceps", "legs",
        "quads", "hamstrings", "glutes", "shoulders", "abs"
    ]

    for part in body_parts:
        for key in sore_keywords:
            if part in text and key in text:
                if part not in coach_memory["soreness"]:
                    coach_memory["soreness"].append(part)

    # LAST WORKOUT DETECTION
    workout_keywords = ["push", "pull", "legs", "chest", "back", "arms", "shoulders"]
    for wk in workout_keywords:
        if wk in text:
            coach_memory["last_workout"] = wk

    # ENERGY LEVEL
    if "tired" in text or "low energy" in text or "fatigued" in text:
        coach_memory["energy"] = "low"
    elif "energized" in text or "felt strong" in text:
        coach_memory["energy"] = "high"

    # INJURIES
    if "injury" in text or "hurt" in text or "injured" in text:
        coach_memory["injuries"].append(user_message)

    # PREFERENCES
    if "superset" in text:
        coach_memory["preferences"]["style"].append("supersets")
    if "no equipment" in text:
        coach_memory["preferences"]["equipment"].append("bodyweight")
    if "light" in text:
        coach_memory["preferences"]["intensity"] = "light"
    if "heavy" in text:
        coach_memory["preferences"]["intensity"] = "heavy"


# ----------------------------------------------------------
#  LONG-TERM MEMORY (Step 7D)
# ----------------------------------------------------------
MEMORY_FILE = "memories.json"


def load_memories():
    if not os.path.exists(MEMORY_FILE):
        return []
    try:
        with open(MEMORY_FILE, "r") as f:
            return json.load(f)
    except Exception as e:
        print("❌ Failed to load memories:", e)
        return []


def save_memories(memories):
    try:
        with open(MEMORY_FILE, "w") as f:
            json.dump(memories, f, indent=2)
    except Exception as e:
        print("❌ Failed to save memories:", e)


def add_memory_if_new(memories, new_memory: str):
    if not new_memory:
        return memories

    for m in memories:
        if m.get("text") == new_memory:
            return memories

    memories.append({
        "id": len(memories) + 1,
        "text": new_memory,
        "created_at": datetime.utcnow().isoformat() + "Z",
    })

    save_memories(memories)
    print(f"💾 Stored new memory: {new_memory}")
    return memories


# ----------------------------------------------------------
# MODELS
# ----------------------------------------------------------
class MealPlanInput(BaseModel):
    country: str
    goal: str
    calories: float
    protein: float
    carbs: float
    fats: float
    diet_preference: str | None = "mixed"
    preferences: str | None = ""


# ----------------------------------------------------------
# ROOT
# ----------------------------------------------------------
@app.get("/")
def root():
    return {"message": "FitForge Backend is running!"}

@app.post("/generate-mealplan")
async def generate_mealplan(data: MealPlanInput):
    calories = int(data.calories)
    protein = int(data.protein)
    carbs = int(data.carbs)
    fats = int(data.fats)

    # New fields with defaults
    diet_pref = getattr(data, "diet_preference", "mixed") or "mixed"
    preferences_text = getattr(data, "preferences", "") or ""

    prompt = f"""
You are a nutrition AI. You MUST output ONLY valid JSON. 
No markdown. No explanations. No text before or after JSON.

REQUIRED JSON FORMAT (FOLLOW EXACTLY):

{{
  "mealplan": [
    {{
      "day": 1,
      "breakfast": "string",
      "lunch": "string",
      "dinner": "string",
      "snack": "string"
    }},
    {{
      "day": 2,
      "breakfast": "string",
      "lunch": "string",
      "dinner": "string",
      "snack": "string"
    }}
  ]
}}

RULES:
- Output EXACTLY 7 objects in the array (day 1 to day 7)
- Keys MUST be lowercase: "mealplan", "day", "breakfast", "lunch", "dinner", "snack"
- Values MUST be plain strings (no nested objects, no ingredient arrays)
- NO markdown, no backticks, no commentary
- NO paragraphs or explanation outside JSON
- If unsure, simplify meals but ALWAYS keep valid JSON

USER PROFILE:
- Country: {data.country}
- Goal: {data.goal}
- Daily Calories: {calories}
- Protein: {protein} g
- Carbs: {carbs} g
- Fats: {fats} g

DIET PREFERENCE: {diet_pref}
- If "veg": 
  - No meat or fish.
  - Use staples like lentils, beans, paneer/tofu, yogurt, vegetables, rice, roti, potatoes, oats.
  - Eggs and dairy are allowed.
- If "non_veg":
  - Prioritize chicken, fish, eggs and other lean meats.
  - Always pair with rice, roti, potatoes, vegetables or salads.
- If "mixed":
  - Use a balance of vegetarian meals and non-vegetarian meals.
  - You may freely mix beans, lentils, paneer, tofu, eggs, chicken and fish.

COUNTRY & FOOD RULES:
- Use simple, easy-to-cook meals that a normal person can make at home.
- Prefer COMFORT foods common in the user's country:
  - For India: dal, rice, roti/chapati, sabzi (simple veg curry), paneer, curd, poha, upma, dosa, idli.
  - For United States: oats, toast, grilled chicken, rice, wraps, salads, yogurt bowls, potatoes.
  - For other countries: use globally available basics like eggs, chicken, fish, yogurt, rice, potatoes, vegetables, fruits.
- You can ALWAYS use common proteins like eggs, chicken and fish when allowed by diet preference.

USER EXTRA PREFERENCES:
"{preferences_text}"

- Respect these preferences as much as possible (likes, dislikes, spicy/non-spicy, etc.).
- Avoid foods the user says they "hate" or "cannot eat".

Now return ONLY the JSON in the exact required format.
"""

    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "user", "content": prompt}],
    )

    content = response.choices[0].message.content

    try:
        clean = content.replace("```json", "").replace("```", "").strip()
        parsed_json = json.loads(clean)
    except Exception:
        return {"error": "AI returned invalid JSON", "raw": content}

    return parsed_json




# ----------------------------------------------------------
# # MEAL PLAN ENDPOINT
# @app.post("/generate-mealplan")
# async def generate_mealplan(data: MealPlanInput):
#     calories = int(data.calories)
#     protein = int(data.protein)
#     carbs = int(data.carbs)
#     fats = int(data.fats)

#     # New fields with defaults
#     diet_pref = getattr(data, "diet_preference", "mixed") or "mixed"
#     preferences_text = getattr(data, "preferences", "") or ""

#     prompt = f"""
# You are a nutrition AI. You MUST output ONLY valid JSON. 
# No markdown. No explanations. No text before or after JSON.

# REQUIRED JSON FORMAT (FOLLOW EXACTLY):

# {{
#   "mealplan": [
#     {{
#       "day": 1,
#       "breakfast": "string",
#       "lunch": "string",
#       "dinner": "string",
#       "snack": "string"
#     }},
#     {{
#       "day": 2,
#       "breakfast": "string",
#       "lunch": "string",
#       "dinner": "string",
#       "snack": "string"
#     }}
#   ]
# }}

# RULES:
# - Output EXACTLY 7 objects in the array (day 1 to day 7)
# - Keys MUST be lowercase: "mealplan", "day", "breakfast", "lunch", "dinner", "snack"
# - Values MUST be plain strings (no nested objects, no ingredient arrays)
# - NO markdown, no backticks, no commentary
# - NO paragraphs or explanation outside JSON
# - If unsure, simplify meals but ALWAYS keep valid JSON

# USER PROFILE:
# - Country: {data.country}
# - Goal: {data.goal}
# - Daily Calories: {calories}
# - Protein: {protein} g
# - Carbs: {carbs} g
# - Fats: {fats} g

# DIET PREFERENCE: {diet_pref}
# - If "veg": 
#   - No meat or fish.
#   - Use staples like lentils, beans, paneer/tofu, yogurt, vegetables, rice, roti, potatoes, oats.
#   - Eggs and dairy are allowed.
# - If "non_veg":
#   - Prioritize chicken, fish, eggs and other lean meats.
#   - Always pair with rice, roti, potatoes, vegetables or salads.
# - If "mixed":
#   - Use a balance of vegetarian meals and non-vegetarian meals.
#   - You may freely mix beans, lentils, paneer, tofu, eggs, chicken and fish.

# COUNTRY & FOOD RULES:
# - Use simple, easy-to-cook meals that a normal person can make at home.
# - Prefer COMFORT foods common in the user's country:
#   - For India: dal, rice, roti/chapati, sabzi (simple veg curry), paneer, curd, poha, upma, dosa, idli.
#   - For United States: oats, toast, grilled chicken, rice, wraps, salads, yogurt bowls, potatoes.
#   - For other countries: use globally available basics like eggs, chicken, fish, yogurt, rice, potatoes, vegetables, fruits.
# - You can ALWAYS use common proteins like eggs, chicken and fish when allowed by diet preference.

# USER EXTRA PREFERENCES:
# "{preferences_text}"

# - Respect these preferences as much as possible (likes, dislikes, spicy/non-spicy, etc.).
# - Avoid foods the user says they "hate" or "cannot eat".

# Now return ONLY the JSON in the exact required format.
# """

#     response = client.chat.completions.create(
#         model="gpt-4o-mini",
#         messages=[{"role": "user", "content": prompt}],
#     )

#     content = response.choices[0].message.content

#     try:
#         clean = content.replace("```json", "").replace("```", "").strip()
#         parsed_json = json.loads(clean)
#     except Exception:
#         return {"error": "AI returned invalid JSON", "raw": content}

#     return parsed_json

# ----------------------------------------------------------
#  CHAT ENDPOINT (FINAL COMBINED VERSION)
# ----------------------------------------------------------
@app.post("/chat")
async def chat_endpoint(payload: dict):

    user_message = (payload.get("message") or "").strip()
    profile = payload.get("profile") or {}
    macros = payload.get("macros") or {}
    history = payload.get("history") or []

    if not user_message:
        return {"reply": "Please enter a message."}

    # SHORT-TERM MEMORY UPDATE
    extract_short_term_memory(user_message)

    # LOAD LONG-TERM MEMORY
    memories = load_memories()
    memories_text = "\n".join(f"- {m.get('text', '')}" for m in memories) if memories else "No long-term memories yet."

    # SYSTEM PROMPT
    system_prompt = f"""
You are FITFORGE AI — an elite personal trainer.

USER PROFILE:
Name: {profile.get('name', '')}
Age: {profile.get('age', '')}
Gender: {profile.get('gender', '')}
Height: {profile.get('height', '')}
Weight: {profile.get('weight', '')}
Activity Level: {profile.get('activityLevel', '')}
Goal: {profile.get('goal', '')}
Country: {profile.get('country', '')}

CURRENT MACROS:
Calories: {macros.get('goalCalories', 0)}
Protein: {macros.get('protein', 0)}
Carbs: {macros.get('carbs', 0)}
Fats: {macros.get('fats', 0)}

SHORT-TERM MEMORY:
Last workout: {coach_memory["last_workout"]}
Soreness: {coach_memory["soreness"]}
Energy: {coach_memory["energy"]}
Injuries: {coach_memory["injuries"]}
Preferences: {coach_memory["preferences"]}

LONG-TERM MEMORY:
{memories_text}

COACHING RULES:
- Adjust intensity if energy is low
- Avoid muscles that are sore
- Do not schedule back-to-back same muscle groups
- Consider injuries & preferences
- Be strict, disciplined, and realistic
- Speak like a real coach
- NEVER reveal memory systems
"""

    # BUILD MESSAGE HISTORY FOR OPENAI
    full_messages = [{"role": "system", "content": system_prompt}]
    full_messages.extend(history)

    # CALL OPENAI FOR COACH REPLY
    ai_response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=full_messages,
    )

    reply_text = ai_response.choices[0].message.content

    # LONG-TERM MEMORY EXTRACTION AI CALL
    try:
        memory_prompt = f"""
You are a memory extraction engine...
"""

        mem_response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[{"role": "user", "content": memory_prompt}],
        )

        mem_data = json.loads(mem_response.choices[0].message.content)

        if (
            mem_data.get("should_write_memory") is True
            and mem_data.get("memory")
            and isinstance(mem_data["memory"], str)
        ):
            add_memory_if_new(memories, mem_data["memory"])

    except Exception as e:
        print("❌ Memory extraction error:", e)

    return {"reply": reply_text}

