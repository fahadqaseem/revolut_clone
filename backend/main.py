from fastapi import FastAPI

app = FastAPI()

@app.get("/test")
@app.get("/test")
def hello_revolut():
    return {
        "status": "online",
        "mock_balance": 5250.75,
        "transactions": [
            {"id": 1, "name": "Apple Services", "amount": -9.99, "icon": "apple"},
            {"id": 2, "name": "Salary Deposit", "amount": 3000.00, "icon": "work"},
            {"id": 3, "name": "Starbucks", "amount": -5.50, "icon": "coffee"},
        ]
    }