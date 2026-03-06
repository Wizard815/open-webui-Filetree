# Open WebUI - Connection Troubleshooting

## Issue: "Connection was reset" at http://localhost:3000

### Root cause

Open WebUI performs **blocking startup tasks** before the HTTP server starts listening:

1. **`install_tool_and_function_dependencies()`** – downloads 30+ files from Hugging Face (often 5–10 minutes on first run, rate-limited without `HF_TOKEN`)
2. Pre-fetch models from Ollama  
3. Initialize tool/terminal servers  

Uvicorn only binds to port 8080 **after** this startup completes. Until then, connections are refused or reset.

---

## Fixes

### 1. Wait for first startup (recommended)

On the **first run**, startup can take **5–15 minutes** while dependencies are downloaded.

- Run in foreground to watch progress:
  ```bash
  docker compose up
  ```
- Wait until you see something like:
  ```
  INFO:     Uvicorn running on http://0.0.0.0:8080
  INFO:     Application startup complete.
  ```
- Then open http://localhost:3000 – it should work.

Subsequent starts are usually faster because files are cached.

---

### 2. Speed up startup with HF_TOKEN

If you have a [Hugging Face token](https://huggingface.co/settings/tokens):

Add to `docker-compose.yaml` under `open-webui` `environment`:

```yaml
- 'HF_TOKEN=your_token_here'
```

This avoids anonymous rate limits and speeds up downloads.

---

### 3. Use the slim image (skip heavy downloads)

Build and run with `USE_SLIM=true` to avoid downloading large embedding/whisper models:

```bash
docker compose build --build-arg USE_SLIM=true
docker compose up -d
```

Startup is much faster, but some RAG/whisper features may be limited.

---

### 4. Disable the healthcheck (optional)

The failing healthcheck can cause Docker to report the container as unhealthy before startup finishes. Temporarily disable it:

In `Dockerfile`, comment out or remove the `HEALTHCHECK` line, then rebuild.

---

## Verify

After startup completes:

```bash
# From host
curl -s http://localhost:3000/health

# Or in browser
http://localhost:3000
```

---

## Quick check

```bash
# See if server is listening inside the container
docker exec open-webui python3 -c "
import urllib.request
try:
    r = urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=5)
    print('OK:', r.status)
except Exception as e:
    print('Not ready:', e)
"
```

If you see "Connection refused", the app is still starting. Wait and try again.
