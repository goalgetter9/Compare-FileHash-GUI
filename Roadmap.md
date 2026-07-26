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

Example:
Calculate SHA256...

████████████░░░░░░░ 62 %

12.4 GB / 20 GB

Speed: 450 MB/s

Remaining time: 18 Sekunden

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

Example:
Matching Checksum-File was found:
D:\Downloads\SHA256SUMS

Use?
[Yes] [No]

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

# Version 2.4 – Extended Verification & Hash Engine Support

## ⚙️ Selectable Hash Engine
**Priority: Medium**

Add support for multiple hash calculation engines.

Planned features:

- Add a dropdown selection for the hash calculation method
- Allow users to choose between:
  - PowerShell `Get-FileHash`
  - Windows `certutil`

Example:
Hash Engine: [ Get-FileHash ▼ ]

Options:
- Get-FileHash
- certutil
- OpenSSL
- BLAKE3


Goal:
Provide users with more flexibility when calculating file hashes and improve compatibility with different Windows environments.

---

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

Example CSV:
Date,File,Algorithm,Calculated,Expected,Result
YYYY-MM-DD HH:MM:SS,D:\Downloads\Fedora.iso,SHA256,ABC123,ABC123,TRUE

---

## 📄 Extended File Information
**Priority: Medium**

Display additional information about selected files.

Planned information:
- File path
- File type
- File size
- Creation date
- Modification date

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
- Better status visualization (green = success, red = failed, blue = in progress)
- Modern controls

Goal:
Provide a more modern and user-friendly experience.

---

## ⌨️  Windows Explorer Integration
**Priority: Low**

Add integration with Windows Explorer.

Planned features:

Right-click menu:
Verify Hash
→ Compare-FileHash-GUI

Goal:
Allow quick verification directly from the file system.

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

# Version 2.6 – Advanced Integration & Automation

## ⌨️ Command-Line Interface
**Priority: High**

Add a command-line mode for automation.

Example:
```powershell
Compare-FileHash.exe `
-File Fedora.iso `
-Hash ABC123... `
-Algorithm SHA256
```

Use cases:
- Automation scripts
- CI/CD pipelines
- Server environments

Goal:
Enable professional and automated verification workflows.

---

# Version 2.7 – Advanced Verification

## 🔐 Digital Signature Verification
**Priority: Medium**

Extend verification capabilities beyond hash comparison.

Planned support:
- Authenticode signatures
- GPG signatures (.asc)

Goal:
Provide additional authenticity verification for downloaded software.


# Future Ideas

Different format (exe?) and codebase are up for discussion.

Additional features may be considered based on user feedback:
- Portable application package
- Automatic update checks
- Plugin-based architecture
- Advanced reporting
- Integration with software distribution systems

# Contributing
Feature requests, suggestions, and contributions are welcome.

If you have ideas for improving Compare-FileHash-GUI, please open an issue or submit a pull request.
