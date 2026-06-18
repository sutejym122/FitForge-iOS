# FitForge Backend

FastAPI backend for FitForge.

This backend powers:
- AI-generated 7-day meal plans
- Profile-aware AI fitness coach chat
- OpenAI-powered nutrition and workout guidance

## Tech Stack

- FastAPI
- Uvicorn
- OpenAI Python SDK
- python-dotenv
- Docker

## Local Setup

Create a virtual environment:

python3 -m venv venv
source venv/bin/activate

Install dependencies:

pip install -r requirements.txt

Create a local environment file:

cp .env.example .env

Then add your OpenAI API key to `.env`.

Run the backend locally:

uvicorn main:app --reload --host 127.0.0.1 --port 5050

Health check:

curl http://127.0.0.1:5050

## API Endpoints

GET /

Health check endpoint.

POST /generate-mealplan

Generates a structured 7-day meal plan from user profile, goal, calories, macros, country, and diet preference.

POST /chat

Provides profile-aware AI fitness coaching using the user's message, profile, macros, and chat history.

## Do Not Commit

Never commit:
- .env
- venv/
- memories.json
- __pycache__/
