---
sidebar_position: 1
---

# Installation

This guide will walk you through setting up Yippy Framework in your Roblox project.

## Prerequisites

Before installing Yippy Framework, ensure you have:

- **Roblox Studio** installed and updated to the latest version
- Basic knowledge of **Lua** and **Roblox development**
- A **Roblox game/place** where you want to use the framework

## Installation Methods

### Method 1: Manual Installation (Recommended)

1. **Download the Framework**
   - Download the latest release from [GitHub](https://github.com/rask/YippyFrameworkDocs)
   - Extract the `YippyFramework` folder

2. **Place in ReplicatedFirst**
   ```
   ReplicatedFirst/
   ├── Framework/           <- Place the framework here
   │   ├── YippyFramework/
   │   ├── Client-Initialization/
   │   └── Server-Initialization/
   ```

3. **Set up Initialization Scripts**
   - Copy the initialization scripts to `ServerScriptService` and `StarterPlayerScripts`
   - Ensure the framework loads before your game scripts

### Method 2: Model Import

1. **Get the Model**
   - Search for "Yippy Framework" in the Roblox catalog
   - Insert the model into your game

2. **Configure Placement**
   - Move the framework to `ReplicatedFirst`
   - Follow the folder structure shown above

## Verification

To verify the installation was successful:

1. **Run a Test**
   ```lua
   local Framework = require(game.ReplicatedFirst.Framework)
   print("Framework loaded:", Framework.Version)
   ```

2. **Check Console Output**
   - Look for framework initialization messages
   - Ensure no error messages appear

## Next Steps

Once installed, you're ready to:

- 📖 **[Quick Start](/docs/getting-started/quick-start)** - Create your first service
- 🏗️ **[Project Structure](/docs/getting-started/project-structure)** - Organize your code
- ⚙️ **[Configuration](/docs/getting-started/configuration)** - Customize the framework

## Troubleshooting

### Common Issues

**Framework not found**
```
Framework is not a valid member of ReplicatedFirst
```
- Ensure the framework is placed in `ReplicatedFirst`
- Check that the folder is named exactly "Framework"

**Loading order issues**
```
attempt to call a nil value
```
- Make sure initialization scripts run before your game scripts
- Check that all dependencies are properly placed

**Version conflicts**
- Ensure you're using the latest version
- Remove any old framework installations

For more help, visit our [Troubleshooting](/docs/troubleshooting) guide.
