# Railway CLI Guide - What to Select

When running `railway link` or `railway variables`, you'll see prompts. Here's what to choose:

## Prompts Explained

### 1. "Select a project"
**Choose:** `VoxaNote` (or whatever you named your Railway project)

### 2. "Select an environment"
**Choose:** `production` (this is your live environment)

### 3. "Select a service"
**Choose:** `voxaNote` (this is your Node.js backend service that runs the API)

**Note:** If you see `<esc to skip>`, you can press ESC to skip, but it's better to select the service so variables are set on the right service.

## Quick Reference

```
Project: VoxaNote
Environment: production  
Service: voxaNote (your Node.js backend)
```

That's it! The script will handle the rest.
