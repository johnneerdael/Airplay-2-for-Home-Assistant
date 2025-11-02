## Context

The current AirPlay 2 add-on is tightly coupled to the Home Assistant Supervisor architecture, which provides:
- Configuration via `/data/options.json` managed through the Home Assistant UI
- Automatic container lifecycle management
- Built-in service discovery through Supervisor's add-on registry

Users running Home Assistant in Docker Container mode lack the Supervisor component and therefore cannot install add-ons. This architectural constraint prevents a significant user segment from accessing AirPlay 2 functionality without manual Shairport Sync configuration or switching installation methods.

**Stakeholders:**
- Docker Container mode users (cannot use add-ons)
- Existing add-on users (must maintain backward compatibility)
- Maintainers (single codebase for both deployment methods)

**Constraints:**
- Must maintain existing add-on functionality without breaking changes
- Container image and core services (nqptp, shairport-sync, avahi) remain unchanged
- Configuration script must support both JSON and environment variable inputs
- No changes to Dockerfile or supervisord.conf required

## Goals / Non-Goals

**Goals:**
- Enable Docker Compose deployment alongside Home Assistant Container
- Provide environment variable configuration mapped 1:1 from add-on options
- Maintain single container image compatible with both deployment modes
- Document clear migration path from other AirPlay solutions
- Preserve all existing features (MQTT, audio backend selection, volume control)

**Non-Goals:**
- Creating a separate Docker image for standalone deployment (use existing image)
- Modifying Dockerfile or supervisord.conf architecture
- Implementing GUI-based configuration for Docker Compose deployment
- Supporting Kubernetes or other orchestration platforms (out of scope for this change)
- Breaking compatibility with Home Assistant Supervisor add-on deployment

## Decisions

### Decision 1: Dual-Mode Configuration Script

**Choice:** Refactor `apply-config.sh` to detect and use either environment variables or `/data/options.json`

**Rationale:**
- Single script maintains both deployment modes without code duplication
- Environment variables are Docker-native and well-understood by Docker Compose users
- Graceful fallback preserves add-on functionality: if `/data/options.json` exists, use it (add-on mode); otherwise read from env vars (standalone mode)
- No changes to Dockerfile or container entrypoint required

**Implementation:**
```bash
# Pseudo-code for dual-mode config
if [ -f "/data/options.json" ]; then
    # Add-on mode: existing JSON parsing logic
    value=$(jq -r ".airplay_name" /data/options.json)
else
    # Standalone mode: environment variable fallback
    value="${AIRPLAY_NAME:-Home Assistant}"
fi
```

**Alternatives Considered:**
- **Separate script for Docker Compose:** Rejected due to maintenance burden and code duplication
- **Configuration file in volume mount:** Rejected as environment variables are more Docker-native and easier for users
- **Template-based config generation:** Rejected as overly complex for the number of configuration options

### Decision 2: Host Network Mode

**Choice:** Use `network_mode: host` in Docker Compose for mDNS/Bonjour discovery

**Rationale:**
- AirPlay 2 requires multicast DNS (mDNS) for service discovery, which doesn't work reliably with Docker bridge networking
- Avahi daemon needs direct network access to advertise `_airplay._tcp` service
- Consistent with add-on deployment which uses `host_network: true`
- Home Assistant Container typically also uses host networking, so no additional security concerns

**Trade-offs:**
- ✅ Pro: Reliable service discovery without complex networking configuration
- ✅ Pro: Consistent with existing add-on behavior
- ⚠️ Con: Port conflicts possible if multiple AirPlay services run on same host
- ⚠️ Con: Less isolation than bridge networking

**Alternatives Considered:**
- **Bridge networking with published ports:** Rejected because mDNS multicast doesn't traverse bridge networks reliably
- **Macvlan network:** Rejected as overly complex for typical home users and requires kernel support

### Decision 3: Environment Variable Naming Convention

**Choice:** Use SCREAMING_SNAKE_CASE with descriptive names: `AIRPLAY_NAME`, `MQTT_ENABLED`, `DEFAULT_AIRPLAY_VOLUME`

**Rationale:**
- Standard Docker/Linux convention for environment variables
- Clear and self-documenting variable names
- Avoids collisions with system environment variables by prefixing with domain-specific terms
- Consistent with Home Assistant Container's own environment variables (`TZ`, etc.)

**Mapping Strategy:**
- Direct mapping: `airplay_name` → `AIRPLAY_NAME`
- Boolean string values: `"yes"`/`"no"` for consistency with Shairport Sync config format
- Numeric values: passed as strings, parsed by script (e.g., `DEFAULT_AIRPLAY_VOLUME="-24.0"`)

### Decision 4: Volume Mount Strategy

**Choice:** Single volume mount at `./config:/config` for persistent data, with container managing `/etc/shairport-sync.conf` internally

**Rationale:**
- Minimal volume requirements simplify deployment
- Configuration changes applied via environment variables, not direct file editing
- `/config` mount provides location for future extensions (logs, cache, etc.)
- Consistent with Home Assistant Container's volume strategy

**Alternatives Considered:**
- **Mount shairport-sync.conf directly:** Rejected because `apply-config.sh` modifies it at runtime based on options
- **Multiple specific volumes:** Rejected as unnecessary complexity for current feature set

## Risks / Trade-offs

### Risk 1: Configuration Drift Between Add-on and Docker Compose

**Mitigation:**
- Single source of truth: `apply-config.sh` supports both modes
- Automated testing checklist validates both deployment methods
- Documentation clearly maps add-on options to environment variables
- Consider CI/CD validation of both modes in future enhancement

### Risk 2: Audio Device Access Permissions

**Issue:** Docker containers may not have access to audio hardware by default

**Mitigation:**
- Document required D-Bus socket mount: `-v /run/dbus:/run/dbus:ro`
- Add troubleshooting section for PulseAudio and ALSA configuration
- Provide fallback to software-only mode if hardware access fails
- Include device permissions in compose file comments

### Risk 3: MQTT Credential Security

**Issue:** Environment variables in Docker Compose files are less secure than Home Assistant's secrets management

**Mitigation:**
- Document best practices for `.env` files (add to `.gitignore`, proper file permissions)
- Recommend using Docker secrets for production deployments
- Provide example of external secrets management integration
- Document MQTT credential rotation procedures

### Risk 4: Version Compatibility

**Issue:** Docker Compose deployment may lag behind add-on updates if not carefully managed

**Mitigation:**
- Use same Docker image for both deployment modes (no image fork)
- Tag releases consistently across deployment methods
- Document version compatibility in release notes
- Keep `docker-compose.yml` version in sync with `config.yaml` version

## Migration Plan

### From Existing Add-on (Optional - for users wanting standalone deployment)

1. Note current configuration from Home Assistant add-on UI
2. Stop the add-on (container will be removed by Supervisor)
3. Create `docker-compose.yml` with equivalent environment variables
4. Start container with `docker compose up -d`
5. Verify AirPlay service appears on Apple devices
6. Test MQTT telemetry if enabled

**Rollback:** Restart add-on in Home Assistant - no data loss as configurations are independent

### From Manual Shairport Sync Installation

1. Document existing `shairport-sync.conf` settings
2. Map configuration to environment variables using provided reference
3. Deploy via Docker Compose
4. Disable/remove manual Shairport Sync service
5. Verify service discovery and audio playback

**Rollback:** Re-enable manual service, remove container

### No Migration (Fresh Install)

Standard Docker Compose deployment for new users without existing setup.

## Open Questions

1. **Multi-architecture image distribution:** Should we publish multi-arch images to Docker Hub/GHCR for easier deployment, or continue relying on users building from source?
   - *Recommendation:* Publish to GHCR for convenience, document local build process as alternative

2. **Default volume location:** Should we recommend relative `./config` or absolute paths in documentation?
   - *Recommendation:* Use relative paths in examples, explain absolute path option in docs

3. **Compose file placement:** Should `docker-compose.yml` live in repository root or in a `docker/` subdirectory?
   - *Recommendation:* Repository root for visibility, with clear naming (`docker-compose.airplay2.yml`)

4. **Auto-update strategy:** How should Docker Compose users receive updates compared to add-on users with auto-update?
   - *Recommendation:* Document Watchtower integration, manual update process, and version pinning options