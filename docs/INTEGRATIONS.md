# MCP & Tool Integrations

Open WebUI (and this Filetree fork) can connect to **MCP (Model Context Protocol)** servers and **OpenAPI** tool servers. Use these integrations to give chats access to external tools (e.g. Obsidian, Kanka, Docker).

## Where to configure

- **Admin:** **Admin** → **Settings** → **Integrations** — configure **Tool server connections** and **Terminal server connections** for the whole instance.
- **User:** **Settings** (gear) → **Integrations** — add **Direct** tool connections for your own use.

In both places you can **Add** a new connection and choose **OpenAPI** or **MCP**.

## Connecting MCP servers (Obsidian, Kanka, Docker, etc.)

MCP servers expose tools and resources over the Model Context Protocol. To use them in Open WebUI:

1. **Run the MCP server** so it is reachable at a URL (e.g. `http://localhost:8080` or your server URL).  
   Many MCP servers run over stdio; you may need a small HTTP/SSE bridge or a host that exposes them over HTTP.
2. In Open WebUI go to **Settings** → **Integrations** (or Admin → Integrations).
3. Click **Add** and select type **MCP**.
4. Enter the **URL** of the MCP server (e.g. `http://localhost:8080`).
5. If the server needs auth or custom headers, configure them in the connection settings.
6. Save. The connection appears in the list; models can then use the tools provided by that MCP server.

### Example MCPs

- **Obsidian MCP** – Run an Obsidian MCP server (e.g. [obsidian-mcp](https://github.com/jlowin/obsidian-mcp) or similar) so it exposes an HTTP/SSE endpoint, then add that URL as an MCP connection in Open WebUI.
- **Kanka** – If there is a Kanka MCP server or an HTTP API wrapper that speaks MCP, run it and add its URL as an MCP connection.
- **Docker** – Use a Docker MCP server (e.g. [docker-mcp](https://github.com/modelcontextprotocol/servers) or community equivalents) that exposes an HTTP/SSE endpoint, then add that URL as an MCP connection.

MCP support in Open WebUI is **experimental**; the MCP spec can change. For production, OpenAPI-based tool servers are often more stable.

## OpenAPI tool servers

For tools that expose an **OpenAPI** spec:

1. Add a new connection and choose **OpenAPI**.
2. Enter the **URL** of the OpenAPI spec (e.g. `https://api.example.com/openapi.json`).
3. Configure auth if required. Save.

Models can then call the APIs described in that spec.

## Folder search: `folder:` and `@folder`

In **Search** (sidebar or search modal):

- Use **`folder:FolderName`** or the **`@folder`** option to limit results to a folder and **all its subfolders**.
- Typing `folder:` (or selecting **@folder**) shows a list of your folders; pick one to search only within that folder tree.
- The backend treats `@folder Name` and `folder:Name` the same.

## Folder content sidebar

When a **folder is selected** in the chat view:

- Use the **document icon** next to the folder title to open the **Folder content** sidebar on the right.
- The sidebar lists **files and images** attached to that folder (system prompt / knowledge) and lets you open them.
- Close the sidebar with the X or by clicking outside.

This is similar to Claude’s right-hand panel for attached content.
