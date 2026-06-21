# 🔐 Safe QR Code Scanner (FYP Project)

A cross-platform Flutter application designed to enhance QR code safety by detecting and analyzing potentially malicious or suspicious URLs before users access them.

---

## 📱 Project Overview

QR codes are widely used in daily life, but they can be exploited to redirect users to phishing websites or malicious links.  
This project introduces a **Safe QR Code Scanner** that checks scanned URLs using multiple security layers before allowing access.

The system helps users make safer decisions when interacting with QR codes.

---

## 🚀 Features

- 📷 QR Code Scanning (Camera-based)
- 🔍 URL Extraction & Validation
- 🛡️ Blacklist Checking (known malicious links)
- 🧠 Heuristic Analysis (rule-based detection)
- 🌐 Google Safe Browsing API integration
- 🧪 VirusTotal API scanning
- ⚠️ Safety Risk Scoring System
- 📊 Safety Report Card for each scanned QR code
- ✍️ Manual URL input for testing
- 🔗 Redirect protection before opening links

---

## 🏗️ System Architecture

The app uses a multi-layer security approach:

1. **QR Scanner Module**
2. **URL Processing Module**
3. **Security Analysis Engine**
   - Blacklist Service
   - Heuristic Service
   - Safe Browsing API
   - VirusTotal API
4. **Risk Evaluation Engine**
5. **User Result Dashboard**

---

## 🛠️ Tech Stack

- Flutter (Dart)
- Android & iOS Support
- Linux / Windows / Web (Flutter multi-platform)
- Google Safe Browsing API
- VirusTotal API
- REST APIs

---

## 📂 Project Structure
