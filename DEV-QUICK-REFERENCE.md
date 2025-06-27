# 🚀 Quick Development Reference

## Start Development
```bash
./dev-mode.sh              # Start hot reload development
```

## Access Services
- **Grafana**: http://localhost:3000 (admin/admin)
- **Server API**: http://localhost:4000/metrics
- **Requester**: http://localhost:4001/metrics  
- **Recorder**: http://localhost:4002/metrics

## Make Changes
Edit files in `source/` and see them reload automatically:
- `source/mythical-beasts-server/index.js`
- `source/mythical-beasts-requester/index.js`
- `source/mythical-beasts-recorder/index.js`
- `source/common/`

## Useful Commands
```bash
./dev-mode.sh logs          # View logs
./dev-mode.sh status        # Check pods
./dev-mode.sh delete        # Clean up
./test-dev-setup.sh         # Test setup
```

## Production vs Development

| Mode | Image Source | Namespace | Resources |
|------|-------------|-----------|-----------|
| **Production** | Registry (`grafana/intro-to-mltp`) | `mltp` | Full |
| **Development** | Local build | `mltp-dev` | Reduced |

## File Sync
Changes to these patterns trigger sync:
- `**/*.js` → Container `/usr/src/app/`
- No pod restart needed!

## Troubleshooting
```bash
# Check if everything is ready
./test-dev-setup.sh

# Reset everything
./dev-mode.sh delete
docker system prune -f

# Force rebuild
skaffold dev --no-prune=false
```
