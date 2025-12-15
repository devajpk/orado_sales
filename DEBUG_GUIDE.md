# 🐛 Debug Guide - First Login Notification Issue

## What I Fixed

### **Root Cause**
When you toggle "Go Online" on first login, the socket might not be connected yet. When the order arrives, the `onNewOrder` handler wasn't registered, so notifications were missed.

### **Solution**
Added automatic socket connection check in `updateAgentAvailability()`:
- Before marking agent as available, it checks if socket is connected
- If NOT connected → connects now
- Then marks as available
- Now `onNewOrder` handler is guaranteed to be active

---

## Expected Log Output on First Login

### **Step 1: App Starts**
```
Firebase initialized successfully
✅ Notification channels initialized early
```

### **Step 2: User Toggles "Go Online"**
```
🟡 [updateAgentAvailability] CALLED
🟡 Incoming isAvailable = true
🔌 Current socket state: _isConnected = false
🔵 Checking socket connection...
⚠️ Socket NOT connected! Connecting now before marking available...
✅✅✅ Socket connected successfully
✅ onNewOrder handler is NOW LISTENING
✅ Socket connection attempted. Connected = true
🟣 AFTER STATE CHANGE
🟣 _isAvailable (new) = true
🟣 Socket connected = true
🟢🟢🟢 Agent marked AVAILABLE 🟢🟢🟢
✅ Socket is ready to receive orders now!
▶ Starting location timer
```

### **Step 3: Order Arrives**
```
🆕🆕🆕 NEW ORDER RECEIVED 🆕🆕🆕
📩 Socket event data: {...order data...}
🔌 Socket connected: true
📍 Is available: true
✅ Order parsed: order123
💰 Earning: ₹150
🔔 [SOCKET] Attempting to show order notification...
🔔 Order ID: order123
🔔 Earning: ₹150
✅ [SOCKET] Order notification shown successfully
```

---

## ⚠️ If Notification Still Doesn't Show

### **Check these logs in order:**

#### 1️⃣ Socket Connected?
```
✅ Socket connected successfully
```
If you DON'T see this → socket connection failed

#### 2️⃣ Order Event Received?
```
🆕🆕🆕 NEW ORDER RECEIVED 🆕🆕🆕
```
If you DON'T see this → server not sending order to socket

#### 3️⃣ Notification Called?
```
🔔 [SOCKET] Attempting to show order notification...
```
If you DON'T see this → order parsing failed

#### 4️⃣ Notification Error?
```
❌ [SOCKET] Notification error: ...
```
If you see this → notification service has an issue

---

## 🧪 How to Test

```bash
# 1. Clean and rebuild
flutter clean
flutter pub get
flutter run

# 2. On first login:
#    - View logs (flutter logs)
#    - Look for ✅ Socket connected
#    - Toggle "Go Online"
#    - Look for 🟢🟢🟢 Agent marked AVAILABLE
#    - Ask server to send order
#    - Look for 🆕🆕🆕 NEW ORDER RECEIVED
#    - Look for ✅ [SOCKET] Order notification shown
```

---

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| Socket never connects | Agent ID missing | Check SharedPreferences has 'agentId' |
| Order event received but no notification | Channel not created | Check NotificationService.initializeChannelsEarly() ran |
| Notification error: "Channel not found" | Channels not created in time | Ensure `initializeChannelsEarly()` is in main.dart before runApp() |
| App crashes when tapping notification | Stale context | Check `NavigationService.navigatorKey` is set in MaterialApp |

---

## Code Changes Made

1. **socket_controller.dart - connectSocket()**
   - Added detailed logging for socket connection
   - Better error handling in onNewOrder

2. **socket_controller.dart - updateAgentAvailability()**
   - Added socket connection check BEFORE marking available
   - Waits for socket to connect
   - Logs socket state at each step

3. **Debug output**
   - Visual separators (✅, 🆕, 🔴, 🟢) for easy log scanning
   - State tracking at each step
   - Error stack traces for debugging
