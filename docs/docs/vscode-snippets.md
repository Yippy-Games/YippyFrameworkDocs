---
sidebar_position: 7
---

# 📝 VS Code Snippets

YippyFramework includes pre-made VS Code snippets to speed up development. These snippets provide templates for common patterns and boilerplate code.

## What are Snippets?

Snippets are code templates that:
- **Speed up development** by providing boilerplate code
- **Ensure consistency** across your codebase
- **Reduce typos** and syntax errors
- **Include placeholders** for easy customization
- **Support tab completion** for faster coding

## Installing Framework Snippets

The framework includes a `snippets` folder with pre-configured VS Code snippets for Lua development.

### Step 1: Locate the Snippets

Navigate to your framework directory:
```bash
cd Framework/YippyFramework/snippets
```

You'll find snippet files for different contexts:
- `lua.json` - General Lua snippets
- `framework-service.json` - Service creation snippets  
- `framework-controller.json` - Controller creation snippets
- `framework-component.json` - Component creation snippets

### Step 2: Install in VS Code

1. **Open VS Code Settings** (`Ctrl+,` or `Cmd+,`)
2. **Search for "snippets"**
3. **Click "Configure User Snippets"**
4. **Select "lua" (for Lua files)**
5. **Copy the contents** from the framework's snippet files
6. **Paste into your user snippets** file

### Step 3: Alternative Method (Copy Files)

You can also copy the snippet files directly:

**Windows:**
```bash
cp Framework/YippyFramework/snippets/* %APPDATA%/Code/User/snippets/
```

**Mac/Linux:**
```bash
cp Framework/YippyFramework/snippets/* ~/.config/Code/User/snippets/
```

## Available Snippets

### Service Snippets
- `fws` - Framework Service template
- `fwsinit` - Service with Init method
- `fwsstart` - Service with Start method
- `fwsclient` - Service with client interface

### Controller Snippets  
- `fwc` - Framework Controller template
- `fwcinit` - Controller with Init method
- `fwcstart` - Controller with Start method
- `fwcui` - Controller with UI setup

### Component Snippets
- `fwcomp` - Component template
- `fwcompstart` - Component with Start method
- `fwcompdestroy` - Component with Destroy method

### Built-in Snippets
- `fwdata` - Datastore operations
- `fwui` - UI management
- `fwnotif` - Notification creation
- `fwnet` - Network channel setup

## Using Snippets

1. **Create a new Lua file**
2. **Type the snippet prefix** (e.g., `fws`)
3. **Press Tab** to expand the snippet
4. **Fill in the placeholders** using Tab to navigate
5. **Customize as needed**

### Example Usage

Type `fws` and press Tab to get:

```lua
local ${1:ServiceName} = Framework.CreateService({
    Name = "${1:ServiceName}",
    
    Client = {
        ${2:ClientMethod} = function(self, player, ${3:params})
            ${4:-- Client method implementation}
        end
    }
})

function ${1:ServiceName}:Init()
    ${5:-- Initialize service}
end

function ${1:ServiceName}:Start()
    ${6:-- Start service logic}
end

return ${1:ServiceName}
```

## Customizing Snippets

You can modify the snippets to match your coding style:

1. **Edit the snippet files** in the framework's snippets folder
2. **Add your own snippets** for common patterns you use
3. **Share with your team** by committing snippet updates
4. **Keep them updated** as the framework evolves

## Pro Tips

- **Learn the prefixes** - memorize common snippet shortcuts
- **Use placeholders** - Tab through all placeholders for complete setup
- **Combine snippets** - Use multiple snippets in the same file
- **Create custom ones** - Add snippets for your specific use cases

---

**Previous:** [← Components](./components)
