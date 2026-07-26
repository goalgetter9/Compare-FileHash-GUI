# Compare-FileHash-GUI

Compare-FileHash-GUI is a graphical PowerShell application designed to securely verify file integrity using cryptographic hash values.

The tool was developed to verify downloaded ISO images, backups, and other large files against checksum values provided by vendors or trusted sources. It supports the commonly used hashing algorithms:

- MD5
- SHA1
- SHA256
- SHA384
- SHA512

## Features

- **Graphical user interface** for easy operation
- **Drag & Drop support** for selecting files
- Compare files against:
  - checksum files (e.g. `SHA256SUMS`)
  - manually entered hash values
- Automatic algorithm detection:
  - from checksum files
  - based on hash length
- Hash calculation using the native PowerShell `Get-FileHash` command
- Clear comparison result display

## Verification Process

During verification, the program calculates the actual hash value of the selected file and compares it with the expected checksum.

The result view displays:

- File path
- Used checksum file or manually entered hash value
- Selected hash algorithm
- Calculated hash value
- Expected hash value
- Verification result (`TRUE` / `FALSE`)

## User Experience

A status indicator shows the current operation state, ensuring that users can see that the process is still running, even when processing large files such as ISO images or backups.

The integrated reset function allows users to quickly clear all inputs and perform additional checks without restarting the application.

## Logging

Each verification is automatically recorded in a log file.

The log contains:
- Date and time
- Full file path
- Used hash algorithm
- Calculated hash value
- Expected hash value
- Verification result

This allows multiple verification processes to be reviewed, tracked, and archived.

## Purpose

Compare-FileHash-GUI combines a simple graphical workflow with transparent and reliable integrity verification.
It is especially useful for users who want to verify downloaded files before use and ensure that files have not been corrupted or modified during transfer.
