# CLIProxyAPI in local T3 Code

Investigated 2026-10-12. Recommendation: add separate **Codex Proxy** and **Claude Proxy** instances in T3's Settings → Providers. The installed version supports instance-specific environment variables and launch arguments, so no wrapper, app patch, global shell variables, or systemd service changes are needed.

## Current setup

- Local T3 is `/opt/t3code-nightly-bin/t3code`, version `0.0.46-nightly.20261008.2813`, commit `30cc78897550`. It runs as an Electron desktop app with a child server. There is no active local T3 systemd unit. [Installed package and bundle](</opt/t3code-nightly-bin/resources/app.asar>)
- Local settings already contain a CLIProxy usage source at `https://proxy.oli.systems`. This supplies quota information; it does not route agent requests. There are no proxy provider instances. The existing Claude instance uses the normal Claude home. [Local settings](</home/oli/.t3/userdata/settings.json>)
- The reference machine was inspected through `ssh coder@sate.local`. Its `t3code.service` drop-in `proxy.conf` loads `/home/coder/.config/t3code/proxy.env`, setting `OPENAI_API_KEY`, `ANTHROPIC_AUTH_TOKEN`, and `ANTHROPIC_BASE_URL=http://127.0.0.1:8317`. Its `/home/coder/.codex/config.toml` selects provider `cliproxy`, with `base_url=http://127.0.0.1:8317/v1`, `env_key=OPENAI_API_KEY`, `wire_api=responses`, and `requires_openai_auth=false`. The installed T3 version matches local. These are remote primary configuration sources, inspected read-only; no secret values are recorded here.

## Exact local configuration

In Settings → Providers, use **Add provider** to add another Codex instance using the existing CLI setup. Name it **Codex Proxy**. The underlying `config.setupMode` must be `existing`, not managed. Keep the normal Codex instance available.

Set its environment variables:

| Name | Value | Sensitive |
| --- | --- | --- |
| `CLIPROXY_API_KEY` | The proxy's client API key | Yes |
| `T3CODE_CODEX_LAUNCH_ARGS` | Empty | No |

The empty second variable prevents an inherited nonempty `T3CODE_CODEX_LAUNCH_ARGS` from overriding this instance's Launch arguments field. If none is inherited, it is unnecessary.

Use these **Launch arguments**, as one line:

```text
-c 'model_provider="cliproxy"' -c 'model_providers.cliproxy.name="CLIProxyAPI"' -c 'model_providers.cliproxy.base_url="https://proxy.oli.systems/v1"' -c 'model_providers.cliproxy.env_key="CLIPROXY_API_KEY"' -c 'model_providers.cliproxy.wire_api="responses"' -c 'model_providers.cliproxy.requires_openai_auth=false'
```

Leave CODEX_HOME and shadow home blank initially. These CLI overrides select the proxy only for this instance while retaining the user's normal Codex skills/configuration. They do not change `/home/oli/.codex/config.toml` or the Codex desktop app. `requires_openai_auth=false` is essential to use the proxy API key instead of requiring ChatGPT authentication. For completely separate session storage, use a dedicated CODEX_HOME, accepting that its skills/configuration must then be configured separately.

For **Claude Proxy**, add a separate Claude instance and set:

| Name | Value | Sensitive |
| --- | --- | --- |
| `ANTHROPIC_BASE_URL` | `https://proxy.oli.systems` | No |
| `ANTHROPIC_AUTH_TOKEN` | The proxy's client API key | Yes |

For auth/config isolation, set **CLAUDE_CONFIG_DIR path** to `/home/oli/.claude-cliproxy`. Do not copy the existing Claude OAuth credential files into it. Local Claude already has an OAuth account; a dedicated config directory prevents this proxy instance from sharing that account/configuration. The installed Claude binary explicitly recognizes `ANTHROPIC_AUTH_TOKEN` as API-key authentication. Do not assume that copying the existing Claude home is necessary. A dedicated directory may require separate onboarding and user settings/skills setup.

Use the proxy's **client API key**, not the management key from T3's existing usage source. Add model slugs exposed by the proxy as custom models only if they do not appear in the instance's model picker. Do not infer model availability from the normal provider's catalog.

## Why the native settings work

The installed bundle contains these primary source modules:

- `packages/contracts/src/providerInstance.ts`: an instance has its own driver, display name, config, and `environment` list. Each variable supports `name`, `value`, `sensitive`, and `valueRedacted`.
- `src/provider/ProviderInstanceEnvironment.ts`: merges those variables into a copy of the server environment. Codex and Claude drivers pass that environment to their runtimes.
- `src/provider/codexLaunchArgs.ts`: builds `codex app-server` followed by the tokenized Launch arguments. It also preserves `-c` overrides for `codex exec` used by ancillary generation. A nonempty inherited `T3CODE_CODEX_LAUNCH_ARGS` takes priority over the settings field.
- `src/provider/Drivers/CodexDriver.ts`: `setupMode=managed` uses a separate managed path; `existing` uses the instance configuration.
- `src/provider/Drivers/CodexHomeLayout.ts`: blank home uses the normal Codex home; a shadow home shares much of that home's state and is not needed merely to override the provider.
- `src/provider/Drivers/ClaudeDriver.ts` and its home helpers: export the configured home as `CLAUDE_CONFIG_DIR`.
- Server settings persistence writes sensitive environment values to T3's secret store and persists empty values with `valueRedacted=true` in settings. Use the UI's lock toggle to mark keys sensitive; do not put keys into launch arguments or tracked files.

These modules are embedded in `apps/server/dist/binCli-CYDSS-4S.mjs` inside [app.asar](</opt/t3code-nightly-bin/resources/app.asar>). The provider UI is embedded in `apps/server/dist/client/assets/settings.providers-C72fmfsZ.js` in the same archive and includes **Add instance**, environment inputs, and **Sensitive, stored separately** controls. These archive member paths are identifiers, not standalone filesystem files.

Local `/home/oli/.bun/bin/codex app-server --help` confirms `-c` is valid after `app-server` and overrides values from the normal config file. [Claude binary](</home/oli/.local/share/claude/versions/2.1.294>) contains the auth-token behavior described above. Token precedence across every possible inherited host-auth variable was not tested; if the instance still reports OAuth, inspect its inherited auth environment before changing global settings.

## Validation before relying on it

1. Confirm authenticated access to the public proxy's `/v1/models` using a client key and record available model slugs without logging the key.
2. Save each instance through T3, refresh its status, and confirm sensitive values are redacted in the settings file.
3. Start one new thread per proxy instance with a model actually returned by the proxy. Check a short reply and one harmless tool operation, then inspect the proxy's request/usage record to confirm routing.
4. Confirm normal Codex and Claude instances remain usable. Proxy changes apply to newly started runtimes; do not assume existing threads have switched providers.

## Applied locally on 2026-10-12

Added `codex_proxy` (Codex Proxy) and `claude_proxy` (Claude Proxy) in `/home/oli/.t3/userdata/settings.json`, using the configuration above. Stored the existing working client API key in T3's separate secret files with mode 0600; settings contain only redacted placeholders. Created `/home/oli/.claude-cliproxy` with mode 0700.

Mapped the local global default and existing local project model defaults to the corresponding proxy instances, preserving selected models and options. Existing threads and normal providers remain available. No global Codex config, shell environment, or Sate configuration changed.

T3 hot-reloaded both entries. Its provider UI shows Codex Proxy as Available and Claude Proxy as Authenticated with Claude API Key. Authenticated public `/v1/models` returned both model families. Using the saved instance environment and launch settings, Codex `gpt-6-luna` and Claude `claude-haiku-5-5` each completed a fresh CLI session, ran `pwd`, and returned `PROXY_OK`. This verifies inference and shell-tool round trips through the public endpoint. Tests used the CLIs directly; a full chat through T3's own UI was not exercised because Linux desktop keyboard automation was unavailable.

Backup before the change: `/home/oli/.t3/userdata/backups/settings-before-cliproxy-20261012-122241.json`. To revert defaults and instances, restore that settings file; T3 watches it for changes. The backup contains no new proxy credentials.

### Follow-up verification

At approximately 12:25 Europe/Amsterdam on 2026-10-12, fresh CLI tests using the saved instance configuration passed with `gpt-6-astra` and `claude-opus-5-5`. Both ran `pwd` in temporary directories and returned `PROXY_VERIFY_20261012`, exiting successfully. Claude reported no permission denials or API error.

The management access log confirms HTTP 200 for both requests in each tool round trip:

| Provider | Endpoint | Request IDs | Duration per request |
| --- | --- | --- | --- |
| Codex | `/v1/responses` | `765ea81d`, `698a23c9` | 2.878s, 1.908s |
| Claude | `/v1/messages?beta=true` | `a8c980b0`, `e5241e62` | 5.216s, 2.494s |

The server log displayed 18:24:59–18:25:03 for these requests, six hours ahead of Amsterdam. No T3 error spans appeared in the inspected setup/test window. Codex emitted pre-existing warnings about ignored `mcp_servers.executor.type`, credential-store fallback, and plugin icon paths; none prevented the query. Other proxy access-log 404s were for `/api/hello` probes and favicons, not the tested inference endpoints. Successful request bodies are not retained by the proxy's current logging configuration, so request-detail lookup was unavailable; access statuses and CLI results provide the evidence above.

### Local skills fix

The separate Claude home initially omitted local skills. Added `/home/oli/.claude-cliproxy/skills -> /home/oli/.claude/skills`, preserving isolated credentials while sharing live skill updates. Verified with the actual Claude startup event: local skills absent before, present after, including architect, review, tdd, and unslop. Codex Proxy already discovers 40 local skills through app-server `skills/list` (52 total, no discovery errors); no Codex home change was needed. Refreshed T3 provider discovery. Existing Claude sessions may need `/reload-skills` or a fresh session.

## Retry incident, 2026-10-12 18:43–18:53 Amsterdam

Reproduced the user's five retries through Codex app-server with T3's saved provider settings, `serviceTier: default`, reasoning effort high, and detailed summary. Removing the tier or using automatic summary did not help. The earlier Codex CLI smoke test also failed on rerun; Claude still passed.

A minimal `/v1/responses` request exposed the underlying HTTP 500: `quota_exhausted: every candidate credential is out of quota, below minimum_headroom, disabled or cooling down`. Codex obscured this as a generic high-demand error. The authenticated `/v0/management/quota-router/status` endpoint showed plugin `0.1.0-rc.1` blocking one Codex account from an October 11 cached zero-quota observation, despite live management quota showing 82% remaining. The other account, with 88% remaining, was blocked for `host status error`. Plugin source rejects status error before probing, and exhausted cached quota before the stale-data branch.

Disabled only `plugins.configs.cliproxyapi-quota-router.enabled` through the management UI. Verified saved config and inactive plugin state. Built-in routing remains round-robin with one-hour session affinity and `quota-exceeded.switch-project: true`, so automatic account switching remains available. The plugin is installed but inactive; its quota-based ranking needs repair before re-enabling. This is a server-wide routing change, also affecting other clients of this proxy.

Verification after the change:
- Original app-server reproduction, gpt-6.1-sol: completed, expected reply, no retries.
- App-server gpt-6-astra with T3 reasoning/tier options: `pwd` tool completed with exit 0, expected final reply, no retries.
- Codex CLI gpt-6-astra: shell tool plus final reply completed.
- Claude CLI claude-opus-5-5: shell tool plus final reply completed.

These exercise the actual app-server protocol and provider config but do not submit a new turn through the T3 graphical interface. No local T3 provider options needed changing.

Proxy logs confirmed HTTP 200 for all five post-fix Codex requests: `a21e4b1d`, `10025dc8`, `a59138fc`, `53a80cd8`, and `91e8bc02` (18:51:27–18:51:50 Amsterdam).
