<<<<<<< HEAD
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
=======