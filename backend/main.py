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
TRANSACTIONS = [
    {"id": 1, "name": "Netflix", "amount": -15.99, "category": "Entertainment", "date": "Today"},
    {"id": 2, "name": "Salary Deposit", "amount": 2500.00, "category": "Income", "date": "Yesterday"},
    {"id": 3, "name": "Starbucks", "amount": -6.50, "category": "Coffee", "date": "Yesterday"},
]

@app.get("/test")
def hello_revolut():
    return {
        "status": "online",
        "mock_balance": round(CURRENT_BALANCE, 2),
        "spending": [40.0, 80.0, 60.0, 100.0, 20.0],
        "transactions": TRANSACTIONS[::-1] # Returns list in reverse (newest first)
    }


@app.post("/send-money")
async def send_money(request: Request):
    global CURRENT_BALANCE
    data = await request.json()
    amount = float(data.get("amount", 0))

    # Change recipient to Dilawar
    recipient = "Dilawar"

    # Update Balance
    CURRENT_BALANCE -= amount

    # Create a new transaction object
    new_tx = {
        "id": len(TRANSACTIONS) + 1,
        "name": f"To {recipient}",
        "amount": -amount,
        "category": "Transfer",
        "date": "Just now"
    }
    TRANSACTIONS.append(new_tx)

    print(f"💰 Sent €{amount} to {recipient}")
    return {"status": "success", "new_balance": CURRENT_BALANCE}
# This is a bonus route to check if the server is alive
@app.get("/")
def read_root():
    return {"message": "The Revolut Backend is Running!"}