from fastapi import FastAPI, Request
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

# --- THE LIVE DATABASE ---
# This variable stays alive as long as the server is running
CURRENT_BALANCE = 5250.75


@app.get("/test")
def hello_revolut():
    # Use the live variable instead of the hardcoded 5250.75
    return {
        "status": "online",
        "mock_balance": round(CURRENT_BALANCE, 2),  # Use the variable!
        "spending": [40.0, 80.0, 60.0, 100.0, 20.0],
        "currency": "EUR",
        "transactions": [
            {"id": 1, "name": "Netflix", "amount": -15.99, "category": "Entertainment", "date": "Today"},
            {"id": 2, "name": "Salary Deposit", "amount": 2500.00, "category": "Income", "date": "Yesterday"},
            {"id": 3, "name": "Starbucks", "amount": -6.50, "category": "Coffee", "date": "Yesterday"},
            {"id": 4, "name": "Grocery Store", "amount": -42.30, "category": "Shopping", "date": "2 days ago"}
        ]
    }


@app.post("/send-money")
async def send_money(request: Request):
    global CURRENT_BALANCE  # This is the "Magic" line that lets us edit the balance

    data = await request.json()
    amount = float(data.get("amount", 0))
    recipient = data.get("recipient")

    # SUBTRACT the amount from our live balance
    CURRENT_BALANCE -= amount

    print(f"💰 TRANSACTION RECEIVED: Sending €{amount} to {recipient}")
    print(f"🏦 NEW BALANCE: €{CURRENT_BALANCE}")

    return {"status": "success", "message": f"Sent €{amount} to {recipient}", "new_balance": CURRENT_BALANCE}

# This is a bonus route to check if the server is alive
@app.get("/")
def read_root():
    return {"message": "The Revolut Backend is Running!"}