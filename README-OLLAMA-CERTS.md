# Ollama TLS Certificate Fix (Corporate Proxy)

If `ollama pull` fails with:

```
tls: failed to verify certificate: x509: certificate signed by unknown authority
```

your corporate proxy is intercepting HTTPS and using its own certificate. Add that CA cert to trust it.

---

## Option A: Add Corporate CA Certificate (Recommended)

### 1. Get the corporate CA certificate

**From Windows (if proxy/Zscaler/etc.):**
- Open **certmgr.msc** (Certificate Manager)
- Go to **Trusted Root Certification Authorities** → **Certificates**
- Find your corp CA (e.g. Zscaler Root CA, Corporate Root CA)
- Right‑click → **All Tasks** → **Export**
- Export as **Base-64 encoded X.509 (.CER)** 
- Save as `corporate-ca.crt`

**Or ask IT** for the root CA certificate file used by the proxy.

### 2. Place the cert

```
open-webui-Filetree/
  certs/
    corporate-ca.crt   <-- your exported cert here
```

### 3. Build and run

```powershell
cd open-webui-Filetree
docker compose -f docker-compose.yaml -f docker-compose.ollama-certs.yaml down
docker compose -f docker-compose.yaml -f docker-compose.ollama-certs.yaml up -d --build
```

### 4. Pull the model

```powershell
docker exec ollama ollama pull qwen3.5:9b
```

---

## Option B: Different Network

Use a network that doesn’t go through the corporate proxy:

- Home Wi‑Fi
- Mobile hotspot
- Personal VPN that bypasses the proxy

Then run `ollama pull` as usual.

---

## Option C: Manual Model Transfer

1. On a machine with working access (e.g. home), run `ollama pull qwen3.5:9b`
2. Copy the model files from `~/.ollama/models` into the Docker volume
3. Restart the Ollama container

---

## Note on `--insecure`

`ollama pull --insecure` does **not** skip TLS verification. It only allows HTTP (non‑HTTPS) registries. TLS checks still apply.
