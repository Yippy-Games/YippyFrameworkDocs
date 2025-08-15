---
sidebar_position: 1
---

# Welcome to Yippy Framework

**Yippy Framework** is a powerful, modular framework for Roblox game development that provides a comprehensive set of tools and utilities to streamline your development process.

![Yippy Framework Banner](/img/yippy-banner.png)

## What is Yippy Framework?

Yippy Framework is designed to provide Roblox developers with:

- **Fast Development** - Pre-built modules for common game systems
- **Modular Architecture** - Use only what you need
- **Developer Tools** - Built-in debugging and command systems
- **Cross-Platform** - Works seamlessly across all Roblox platforms
- **Modern UI** - Beautiful notification and UI systems
- **Data Safety** - Robust data storage with ProfileService integration

## Key Features

### Services & Controllers
Organize your code with a clean service-controller architecture that separates server and client logic.

### Built-in Modules
Choose from 15+ pre-built modules including:
- **Camera** - Advanced camera controls
- **UI** - Modern interface components
- **Datastore** - Safe data persistence
- **Animations** - Character animation system
- **Network** - Client-server communication
- **And many more...**

### Developer Experience
- Code snippets for VS Code
- Comprehensive debugging tools
- Hot-reload development
- Type definitions support

## Quick Start

Get up and running with Yippy Framework in minutes:

```lua
-- Get the framework
local Framework = require(ReplicatedFirst.Framework)

-- Create a service
local MyService = Framework.CreateService {
    Name = "MyService"
}

function MyService:Start()
    print("My service started!")
end

return MyService
```

## Community & Support

- **[GitHub Repository](https://github.com/rask/YippyFrameworkDocs)** - Source code and issues
- **[Roblox Group](https://www.roblox.com/groups/34305087)** - Official Yippy Games group
- **[DevForum](https://devforum.roblox.com/)** - Roblox developer community
- **[Examples](/docs/examples)** - Ready-to-use code examples

## Ready to Get Started?

Choose your path:

import DocCardList from '@theme/DocCardList';

<DocCardList />