
# **CLEANPC — Windows Governance & Self‑Healing Engine (v1.0.0)**

A modular, profile‑driven Windows governance engine designed to keep systems stable, predictable, and free from configuration drift. CLEANPC enforces baselines, applies hardening, manages services and scheduled tasks, monitors system integrity, and performs automated self‑healing — all without heavy enterprise tooling.

## **Features**

### **Governance**

- Registry governance
    
- Services governance
    
- Scheduled tasks governance
    
- Certificate store governance
    
- Component store (DISM) governance
    
- Drift detection
    
- Automated self‑healing
    

### **Hardening**

- AppX governance
    
- Attack Surface Reduction (ASR)
    
- Telemetry governance
    

### **System Integrity & Storage**

- SFC integration (verifyonly / scannow based on profile & cadence)
    
- SSD health (SMART)
    
- TRIM enforcement
    
- Secure wipe
    
- Health scoring engine
    

## **Profiles**

### **SAFE**

Minimal changes, low‑risk governance.

### **POWER**

Balanced governance. Recommended default.

### **HARDCORE**

Strict governance and aggressive cleanup.

## **Cadences**

CLEANPC supports both interactive mode and direct execution.

### **Interactive Mode** 

```
.\CLEANPC.ps1
```

### **Direct Cadence Execution**

```
.\CLEANPC.ps1 -Weekly
.\CLEANPC.ps1 -Monthly
.\CLEANPC.ps1 -Quarterly
.\CLEANPC.ps1 -AsNeeded
.\CLEANPC.ps1 -Health
```

## **Requirements**

- Windows 10 or Windows 11
    
- PowerShell 5.1 or later
    
- Administrator rights
    
- Execution policy allowing script execution
    

## **Quick Start**

1. Download or clone the repository
    
2. Open PowerShell as Administrator
    
3. Navigate to the CLEANPC folder
    
4. Run:
    
```
.\CLEANPC.ps1
```

Choose a profile and cadence from the menu.

## **Folder Structure**

```
CLEANPC
│   CLEANPC.ps1
│   cleanpc.cmd
│
├── Core
│       Baseline.ps1
│       Certificates.ps1
│       ComponentStore.ps1
│       DriftDetection.ps1
│       HealthScore.ps1
│       RegistryGovernance.ps1
│       SelfHealing.ps1
│       ServicesGovernance.ps1
│       SystemIntegrity.ps1
│       TasksGovernance.ps1
│
├── Engine
│       HealthReport.ps1
│       Logging.ps1
│       Menu.ps1
│       Profiles.ps1
│       Run.ps1
│
├── Hardening
│       AppX.ps1
│       AttackSurface.ps1
│       Telemetry.ps1
│
├── Schedules
│       Weekly.ps1
│       Monthly.ps1
│       Quarterly.ps1
│       AsNeeded.ps1
│
├── Storage
│       SSDHealth.ps1
│       TRIM.ps1
│       SMART.ps1
│       SecureWipe.ps1
│
└── Docs
        Readme.md
        Documentation.md
        About & Support.md
        MIT License v1.0.0.md
```

## **Logging**

Runtime logs are written to:

```
cleanpc.log
```

This file is safe to delete; it will be recreated automatically.

## **Documentation**

Full documentation is available in the `Docs/` folder.

## **Author**

CLEANPC was created and maintained by **Asim Hashmi**.

## **License**

This project is licensed under the MIT License (CLEANPC Variant). See **MIT License v1.0.0.md** for details.

