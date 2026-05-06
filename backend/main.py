from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# IMPORTANT: This allows your Flutter app to talk to the Python server
# without being blocked by "CORS" security rules.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods (GET, POST, etc.)
    allow_headers=["*"],
)

@app.get("/test")
def hello_revolut():
    return {
        "status": "online",
        "mock_balance": 5250.75,
        "spending": [40.0, 80.0, 60.0, 100.0, 20.0],  # New data!
        "currency": "EUR",
        "transactions": [
            {
                "id": 1,
                "name": "Netflix",
                "amount": -15.99,
                "category": "Entertainment",
                "date": "Today"
            },
            {
                "id": 2,
                "name": "Salary Deposit",
                "amount": 2500.00,
                "category": "Income",
                "date": "Yesterday"
            },
            {
                "id": 3,
                "name": "Starbucks",
                "amount": -6.50,
                "category": "Coffee",
                "date": "Yesterday"
            },
            {
                "id": 4,
                "name": "Grocery Store",
                "amount": -42.30,
                "category": "Shopping",
                "date": "2 days ago"
            }
        ]
    }

# This is a bonus route to check if the server is alive
@app.get("/")
def read_root():
    return {"message": "The Revolut Backend is Running!"}