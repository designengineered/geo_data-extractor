# 📸 Geo-Data Extractor
**Media Metadata Extraction Tool**

> Extract metadata from your photos and videos with ease! 🎯

This repository contains a bash script for extracting metadata from media files:

- 🖼️ Images: JPG, JPEG, PNG
- 🎥 Videos: MOV, MP4

## ✨ Features

- 📅 Extracts creation date/time
- 🌍 Extracts GPS coordinates (when available)
- 📊 Generates detailed reports in a `reports` directory
- ⚡ Shows processing time and statistics
- 🎯 Identifies files with valid GPS data
- 📁 Handles both images and videos in a single pass

## 🛠️ Dependencies

The script requires `exiftool` to be installed on your system.

### 📦 Installing Dependencies

<details>
<summary>Ubuntu/Debian</summary>

```bash
sudo apt-get update
sudo apt-get install exiftool
```

</details>

<details>
<summary>MacOS (Homebrew)</summary>

```bash
brew install exiftool
```

</details>

<details>
<summary>Other Unix Systems</summary>

Visit the [ExifTool website](https://exiftool.org/) for installation instructions.
</details>

## 🚀 Usage

```bash
./extract_metadata.sh [input_directory]
```

> If no input directory is specified, the current directory will be used.

## 📋 Output

The script will:

1. 📁 Create a `reports` directory if it doesn't exist
2. 📝 Generate a report file with timestamp (e.g., `media_metadata_20240101_120000.txt`)
3. 🌍 Include a summary of files with GPS data
4. 📊 List detailed metadata for each processed file
5. 📈 Show processing statistics

## 📑 Report Format

Each report includes:

- 🗺️ Files with GPS coordinates (summary)
- 📝 Detailed metadata for each file
- 🔢 Total number of files processed
- 🌍 Number of files with GPS data
- ⏱️ Processing time
- 🕒 Timestamp of report generation

## 💡 Notes

- ✅ The script handles errors gracefully and will notify if ExifTool is not installed
- 🌐 GPS coordinates of (0,0) are treated as invalid and marked as "Not available"
- 🔄 All reports are timestamped to prevent overwriting

---

<div align="center">

### Happy metadata extracting! 🎉

⭐ Don't forget to star this repo if you found it useful! ⭐

</div>
