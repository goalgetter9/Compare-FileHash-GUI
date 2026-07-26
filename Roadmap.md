# Roadmap

This document outlines planned improvements and future features for **Compare-FileHash-GUI**.

The roadmap is subject to change based on project requirements, user feedback, and technical feasibility.

---

# Version 2.3 – Usability & Performance Improvements

## 🚀 Large File Progress Support
**Priority: High**

Implement a real-time progress indicator for large files.

Planned features:
- Custom `FileStream` based hash calculation
- Progress percentage display
- Processed data amount
- Calculation speed
- Estimated remaining time

Goal:
Improve user experience when verifying large ISO images, backups, and archives.

---

## 🔍 Automatic Checksum File Detection
**Priority: High**

Automatically detect matching checksum files in the selected file directory.

Supported examples:

- `.sha256`
- `.sha512`
- `.md5`
- `SHA256SUMS`
- `CHECKSUM`

Goal:
Reduce manual input and simplify verification workflows.

---

## 📋 Hash Validation & Clipboard Integration
**Priority: High**

Improve manual hash handling.

Planned features:
- Validate entered hash length
- Detect invalid characters
- Normalize copied hash values
- Remove spaces and line breaks
- Import hash values directly from clipboard

Goal:
Prevent incorrect comparisons caused by invalid input.

---

# Version 2.4 – Extended Verification Features

## 📁 Multiple File Verification
**Priority: High**

Add support for verifying multiple files in a single operation.

Planned features:
- Multiple file drag & drop
- Batch hash calculation
- Individual verification results
- Summary overview

Example:

| File | Result |
|------|--------|
| File1.iso | TRUE |
| File2.iso | TRUE |
| File3.iso | FALSE |

Goal:
Enable efficient verification of file collections.

---

## 📤 Export Verification Results
**Priority: Medium**

Add export functionality for verification results.

Supported formats:

- CSV
- JSON
- XML

Exported information:

- Date and time
- File path
- Algorithm
- Calculated hash
- Expected hash
- Verification result

Goal:
Improve documentation, auditing, and automated processing.

---

## 📄 Extended File Information
**Priority: Medium**

Display additional information about selected files.

Planned information:

- File size
- Creation date
- Modification date
- File type

Goal:
Provide additional context during verification.

---

# Version 2.5 – User Interface Improvements

## 🌙 Modern UI & Dark Mode
**Priority: Low**

Improve the graphical user interface.

Planned features:

- Dark mode support
- Improved layout
- Better status visualization
- Modern controls

Goal:
Provide a more modern and user-friendly experience.

---

## 🌍 Multi-Language Support
**Priority: Low**

Add localization support.

Planned languages:

- English
- German

Possible future languages:
- French
- Spanish
- Other community contributions

Goal:
Make the application accessible to a wider audience.

---

# Version 3.0 – Advanced Integration & Automation

## ⌨️ Command-Line Interface
**Priority: High**

Add a command-line mode for automation.

Example:

```powershell
Compare-FileHash.exe `
-File Fedora.iso `
-Hash ABC123... `
-Algorithm SHA256
