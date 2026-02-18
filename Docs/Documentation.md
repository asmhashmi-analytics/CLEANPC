# CleanPC v1.0.0 — Full Documentation
tags: [cleanpc, documentation, windows, governance]

CLEANPC is a modular Windows governance and self‑healing engine designed to maintain system stability, enforce configuration baselines, detect drift, and apply corrective actions automatically. It provides a structured, profile‑aware, cadence‑aware maintenance framework suitable for power users and professionals.

---

## 1. Overview

CLEANPC performs:

- Baseline enforcement  
- Drift detection  
- Automated self‑healing  
- DISM component store health checks  
- SFC system integrity checks  
- Registry, services, and scheduled task governance  
- Certificate store validation  
- AppX, ASR, and telemetry governance  
- SSD, TRIM, and SMART health checks  
- Health scoring  

The engine is fully modular and can be extended with additional governance modules.

---

## 2. Architecture

CLEANPC is divided into five major layers:

### **Core**
Handles baseline, drift detection, self‑healing, DISM, SFC, registry, services, tasks, certificates, and health scoring.

### **Engine**
Orchestrates the entire run:
- Menu system  
- Logging  
- Profile loading  
- Cadence execution  
- Health reporting  

### **Hardening**
Applies:
- AppX governance  
- Attack Surface Reduction  
- Telemetry reduction  

### **Storage**
Monitors:
- SSD health  
- TRIM status  
- SMART diagnostics  
- Secure wipe  

### **Schedules**
Entry points for:
- Weekly  
- Monthly  
- Quarterly  
- As‑Needed  

Each schedule script passes the selected profile into the engine.

---

## 3. Profiles

### **SAFE**
- Minimal changes  
- No ASR  
- Light telemetry reduction  
- SFC verifyonly (Monthly/AsNeeded), scannow (Quarterly)  

### **POWER**
- Balanced governance  
- ASR enabled  
- Moderate telemetry reduction  
- SFC verifyonly (Monthly/AsNeeded), scannow (Quarterly)  

### **HARDCORE**
- Strict governance  
- Aggressive cleanup  
- ASR aggressive  
- Telemetry aggressive  
- SFC scannow for all cadences except Weekly  

---
## 4. Cadence Logic

CLEANPC supports four maintenance cadences:

### **Weekly**
- DISM: checkhealth  
- SFC: skipped  
- Lightest maintenance cycle  

### **Monthly**
- DISM: checkhealth  
- SFC: verifyonly (SAFE/POWER), scannow (HARDCORE)  

### **As‑Needed**
- DISM: checkhealth  
- SFC: verifyonly (SAFE/POWER), scannow (HARDCORE)  

### **Quarterly**
- DISM: checkhealth + restorehealth  
- SFC: scannow (all profiles)  
- Deep maintenance cycle  

---

## 5. Engine Flow

The engine executes the following sequence:

1. Load profile  
2. Load baseline  
3. Perform baseline check  
4. Detect drift  
5. Apply self‑healing  
6. DISM component store health  
7. SFC system integrity  
8. Registry governance  
9. Services governance  
10. Scheduled tasks governance  
11. Certificate store validation  
12. AppX governance  
13. ASR governance  
14. Telemetry governance  
15. SSD health  
16. TRIM status  
17. SMART deep scan  
18. Health score calculation  
19. Output summary  

---

## 6. Baseline & Drift Detection

### Baseline
The baseline defines expected:
- Registry keys  
- Services  
- Scheduled tasks  
- Certificates  
- System configuration  

### Drift Detection
CLEANPC compares the live system against the baseline and reports:
- Missing items  
- Unexpected items  
- Misconfigured items  

### Self‑Healing
If drift is detected, CLEANPC attempts to:
- Restore missing tasks  
- Re‑enable required services  
- Recreate registry keys  
- Remove invalid entries  

---

## 7. System Integrity

### DISM
- `/checkhealth` always runs  
- `/restorehealth` runs only when needed  
- Quarterly forces repair  

### SFC
- `verifyonly` for SAFE/POWER (Monthly/AsNeeded)  
- `scannow` for HARDCORE (Monthly/AsNeeded)  
- `scannow` for all profiles (Quarterly)  
- Skipped for Weekly  

---

## 8. Hardening Modules

### AppX Governance
- Removes bloat  
- Enforces allowed list  
- Profile‑aware  

### ASR (Attack Surface Reduction)
- Disabled in SAFE  
- Enabled in POWER  
- Aggressive in HARDCORE  

### Telemetry Governance
- Light in SAFE  
- Moderate in POWER  
- Strict in HARDCORE  

---

## 9. Storage Health

### SSD Health
Reads device attributes and flags potential issues.

### TRIM Status
Ensures TRIM is enabled for SSD longevity.

### SMART Deep Scan
Evaluates:
- Wear level  
- Reallocated sectors  
- Pending sectors  
- Temperature  
- Lifetime remaining  

### Secure Wipe
Optional module for secure deletion.

---

## 10. Health Score

The health score is calculated from:

- Component store health  
- SFC integrity  
- Registry drift  
- Service drift  
- Task drift  
- Certificate issues  
- Storage health  

Score ranges from **0 to 100**.

---

## 11. Logging

All engine activity is logged to:

cleanpc.log

This file is safe to delete; it will be recreated automatically.


## 12. Folder Structure

```
CLEANPC
│   CLEANPC.ps1
│   cleanpc.cmd
│
├── Core
├── Engine
├── Hardening
├── Schedules
├── Storage
└── Docs
```


CLEANPC │ CLEANPC.ps1 │ cleanpc.cmd │ ├── Core ├── Engine ├── Hardening ├── Schedules ├── Storage └── Docs

---

## 13. Requirements

- Windows 10 or Windows 11  
- PowerShell 5.1 or later  
- Administrator rights  
- Script execution enabled  

---

## 14. Support

For help, refer to:
- About & Support.md  
- Readme.md  
- MIT License v1.0.0.md  

---

## 15. License

CLEANPC is licensed under the MIT License.