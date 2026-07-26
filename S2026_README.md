# ReadRight

## Platform Requirements

This application is connected to **Firestore** for email logins and user management. The existing Firebase configuration is set up for **iOS and Android** applications only.

> ⚠️ **The app must be run on iOS or Android.** Web-based running will not work.

## Known Issues

### Microphone Input Bug

We encountered a severe, systemic bug that prevented microphone testing from working consistently during development. To workaround this, we added "simulator" buttons to showcase application flow of screens.

**Environments tested:**
- iOS Simulator
- Android Emulators
- Physical devices

**Findings:**
- The only environment where the microphone worked consistently was an **older Android device**.
- Research and community articles confirm this is a **widespread platform/tooling issue**, not a bug in our codebase.

### Audio Output Requirement

The following features rely on AI-generated speech reading words or sentences aloud:

- **Speech-to-Text Verifier**
- **Word Pop**

These features require testing on a **device with working volume/audio output**.

## Starting the Backend Proxy (AI Story Builder)

The AI Story Builder features rely on a lightweight Express Node.js proxy server (`backend_proxy/`) that securely routes story generation prompts to the OpenAI API (`gpt-4o-mini`) without exposing API keys inside the client app.

### 1. Environment Configuration
Navigate to the proxy directory and configure your environment variables:
```bash
cd backend_proxy
```

Create a `.env` file from the provided example template:
```bash
cp .env.example .env
```

Open `.env` and set your OpenAI API key:
```env
OPENAI_API_KEY=your_actual_openai_api_key
PORT=3000
```
> 💡 **Mock Mode Support:** If `OPENAI_API_KEY` is omitted or left as default, the server will automatically run in **Mock Mode**, returning local fallback stories for testing without hitting OpenAI.

### 2. Installation & Server Execution
Install the dependencies (first time only) and start the server:
```bash
# Install dependencies
npm install

# Start the server (runs on port 3000 by default)
npm start
```

### 3. API Endpoints & Testing
Once running, the backend proxy exposes two main endpoints:
- **`GET /health`**: Health check returning `{ "status": "ok" }`.
- **`POST /api/story`**: Accepts JSON containing either a prompt string (`{ "prompt": "..." }`) or word array (`{ "words": ["jump", "run"] }`) and returns `{ "story": "..." }`.

To test end-to-end story generation from the terminal:
```bash
npm test
# Or run: node test_client.js
```

### 4. Client Connection Notes (Flutter App)
The Flutter `OpenAIService` ([`openai_service.dart`](file:///a:/X4/master-branch/6150_Grad_Proj/lib/services/openai_service.dart)) connects to the backend proxy depending on the environment:
- **iOS Simulator:** Connects to `http://localhost:3000`
- **Android Emulator:** Connects to `http://10.0.2.2:3000`
- **Physical Device:** Update `_baseUrl` in `openai_service.dart` to your host computer's local network IP address (e.g., `http://192.168.x.x:3000`).

