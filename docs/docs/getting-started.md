---
sidebar_position: 2
---

# Getting Started

## Prerequisites

Before you can use YippyFramework, you'll need to install the required tools:

### 1. Install Rojo for Roblox Studio

Rojo is essential for syncing your code between your editor and Roblox Studio.

**Install the Rojo plugin in Roblox Studio:**
- Visit: [Rojo Plugin on Roblox](https://create.roblox.com/store/asset/6415005344/Rojo-7%3Fkeyword=&pageNumber=&pagePosition=)
- Click "Get" to install the plugin in Roblox Studio

### 2. Install Rojo VS Code Extension

For the best development experience, install the Rojo extension for Visual Studio Code:

**Install from VS Code Marketplace:**
- Visit: [Rojo VS Code Extension](https://marketplace.visualstudio.com/items?itemName=evaera.vscode-rojo)
- Click "Install" or use the VS Code Quick Open (`Ctrl+P`) and paste:
  ```
  ext install evaera.vscode-rojo
  ```

## Installation

### 1. Clone Your Project Repository

Start with a repository that includes YippyFramework as a submodule. The framework folder will initially be empty.

### 2. Initialize the Framework Submodule

Navigate to your project directory and initialize the framework submodule:

```bash
git submodule update --init --recursive
```

The framework subfolder should now be populated with all the necessary files.

### 3. Switch to Main Branch

Navigate to the framework directory and ensure you're on the latest version:

```bash
cd Framework/YippyFramework
git switch main
```

### 4. Install Dependencies and Setup Linting

Run the installation script to set up all dependencies and configure the linter with pre-commit hooks:

```bash
./install.sh
```

> **Important**: The linter is mandatory for maintaining code quality. Pre-commit hooks will prevent commits that don't meet our coding standards. **No linter issues allowed!**

## You're Ready!

Once the installation is complete, you can start developing with YippyFramework. All systems are now configured and ready to use.

Next, explore the [API Reference](../api) for detailed implementation guides and learn about the available built-in systems.
