# 🧪 Test Guide - First Login Notification

## What to Do

1. **Clean and rebuild**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

2. **Open the Flutter logs**:
   ```bash
   # In another terminal
   flutter logs
   ```

3. **On first login**:
   - ✅ Login successfully
   - Watch for: `✅ Socket CONNECTED`
   - Toggle "Go Online" 
   - Watch for: `🟢 AGENT MARKED AVAILABLE`
   - Watch for: `READY TO RECEIVE ORDERS`

4. **Server sends an order**:
   - Send an order to this agent (from your backend/dashboard)
   - Watch logs for:
     ```
     ═══════════════════════════════════════
     🆕 NEW ORDER ARRIVED 🆕
     ═══════════════════════════════════════
     DATA: {...}
     ✅ Parsed order: order123
     ```

5. **Check if notification appears**:
   - Does a notification popup appear? ✅ or ❌
   - Does a bottom sheet show? ✅ or ❌

---

## Debugging Checklist

### ❓ If notification doesn't appear, check these logs in order:

#### 1️⃣ Socket Connected?
```
✅✅✅ Socket CONNECTED ✅✅✅
   _isConnected: true
```
🔴 **NO?** → Socket connection failed. Check WiFi/server.

#### 2️⃣ Agent Available?
```
🟢 ═══════════════════════════════════════════════════════
🟢 AGENT MARKED AVAILABLE
🟢 READY TO RECEIVE ORDERS
```
🔴 **NO?** → Available toggle didn't work.

#### 3️⃣ Order Event Received?
```
═══════════════════════════════════════════
🆕 NEW ORDER ARRIVED 🆕
═══════════════════════════════════════════
```
🔴 **NO?** → Server didn't send order or socket not listening.

#### 4️⃣ Order Parsed?
```
✅ Parsed order: order123
```
🔴 **NO?** → Order format incompatible. Check error:
```
❌ Parse error: ...
Stack: ...
```

#### 5️⃣ Notification Shown?
```
✅ [SOCKET] Order notification shown successfully
```
🔴 **NO?** → Notification service error. Check for:
```
❌ [SOCKET] Notification error: ...
```

---

## What I Fixed

✅ **Added socket connection check before marking available**
- When you toggle "Go Online", socket connects first
- Then `onNewOrder` handler is active and listening
- Orders won't be missed

✅ **Better debugging logs**
- Clear visual separators (`═══════`) for easy scanning
- State tracking at each step
- Error messages with stack traces

---

## Expected Success Scenario

```
═══════════════════════════════════════════════════════
updateAgentAvailability CALLED
═══════════════════════════════════════════════════════
Incoming isAvailable: true
Current _isConnected: true
🔵 Checking socket connection...
✅ Socket already connected

💾 Saved to prefs: agent_available = true

🟢 ═══════════════════════════════════════════════════════
🟢 AGENT MARKED AVAILABLE
🟢 ═══════════════════════════════════════════════════════
🟢 READY TO RECEIVE ORDERS
🟢 Socket connected: true
🟢 Agent available: true

[Order arrives...]

═══════════════════════════════════════════
🆕 NEW ORDER ARRIVED 🆕
═══════════════════════════════════════════
✅ Parsed order: order123
🔔 [SOCKET] Attempting to show order notification...
✅ [SOCKET] Order notification shown successfully
```

---

## Next Steps

1. Run the app with these changes
2. **Share the logs** when you toggle availability and when order arrives
3. I'll pinpoint exactly where it's breaking
