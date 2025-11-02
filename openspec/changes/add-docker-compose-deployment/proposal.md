## Why

Users running Home Assistant in Docker Container mode (rather than Home Assistant OS or Supervised mode) cannot use Home Assistant add-ons because add-ons require the Supervisor component. This prevents Docker-mode users from utilizing the AirPlay 2 functionality provided by this add-on, forcing them to either:
1. Switch to a different Home Assistant installation method (significant migration effort)
2. Manually configure Shairport Sync outside Home Assistant (complex setup, no integration)
3. Forgo AirPlay 2 capabilities entirely

By transforming this add-on into a standalone Docker container that can run alongside Home Assistant via Docker Compose, we enable Docker-mode users to access AirPlay 2 functionality while maintaining the same configuration experience through environment variables mapped from the existing add-on options.

## What Changes

- Create Docker Compose configuration file for sidecar deployment alongside Home Assistant Container
- Replace Home Assistant add-on's `/data/options.json` contract with environment variable configuration
- Refactor [`apply-config.sh`](../../apply-config.sh) to read from environment variables instead of JSON file
- Add comprehensive documentation for Docker Compose deployment (installation, configuration, networking)
- Maintain backward compatibility with existing Home Assistant add-on deployment
- Provide migration guide for users transitioning from add-on to standalone container

### Configuration Mapping (Add-on → Docker Compose)

| Add-on Option | Environment Variable | Docker Compose Usage |
|---------------|---------------------|----------------------|
| `airplay_name` | `AIRPLAY_NAME` | Service discovery name |
| `offset` | `AUDIO_BACKEND_LATENCY_OFFSET` | Audio sync offset |
| `interpolation` | `INTERPOLATION` | Audio interpolation method |
| `output_backend` | `OUTPUT_BACKEND` | Audio backend (pa/alsa) |
| `mqtt_enabled` | `MQTT_ENABLED` | Enable MQTT telemetry |
| `mqtt_host` | `MQTT_HOST` | MQTT broker hostname |
| `mqtt_username` | `MQTT_USERNAME` | MQTT authentication |
| `mqtt_password` | `MQTT_PASSWORD` | MQTT authentication |
| `default_airplay_volume` | `DEFAULT_AIRPLAY_VOLUME` | Initial volume level |

## Impact

- **Affected specs**: New capability [`docker-deployment`](specs/docker-deployment/spec.md)
- **Affected code**: 
  - [`apply-config.sh`](../../apply-config.sh) - Configuration script refactoring
  - [`Dockerfile`](../../Dockerfile) - No changes required (already self-contained)
  - [`supervisord.conf`](../../supervisord.conf) - No changes required
  - New files: `docker-compose.yml`, `docker-compose.example.yml`, `DOCKER_DEPLOYMENT.md`
- **Breaking changes**: None - existing add-on deployment remains unchanged
- **User impact**: Expands deployment options for Docker Container mode users without affecting existing add-on users
- **Dependencies**: Requires Docker and Docker Compose on host system
- **Testing**: Manual validation on Docker Container mode Home Assistant instance with MQTT integration