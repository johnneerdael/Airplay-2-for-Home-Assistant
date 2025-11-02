# Airplay 2

This Home Assistant addon allows your device to function as an AirPlay 2 receiver.
Stream audio directly from your iPhone, iPad, or Mac to speakers connected to your Home Assistant setup.

<img width=25% src="logo.png">

### Key Features:

* **AirPlay 2 Compatibility:** Play audio from Apple devices on your Home Assistant system.
* **MQTT Integration:** Sends out status reports to the "airplay2" topic when enabled. Check out the [docs](https://github.com/mikebrady/shairport-sync/blob/master/MQTT.md).
* **Multiple Deployment Options:** Available as both Home Assistant add-on and standalone Docker container.
* **Cross-Platform Support:** Works with Home Assistant OS, Supervised, and Docker Container installations.

### Technical Notes:

* **Shairport-Sync:** Utilizes the [Shairport-Sync](https://github.com/mikebrady/shairport-sync) library by mikebrady for AirPlay 2 functionality.
* **Debian Container:** Built using a Debian image (may be larger than some addons).
* **Multi-Architecture:** Supports AMD64, ARM64, ARMv7, i386, and ARMHF architectures.

## Deployment Options

### Option 1: Home Assistant Add-on (Recommended for Home Assistant OS/Supervised)

**Best for:** Home Assistant OS, Home Assistant Supervised, and users who prefer GUI configuration.

To install this addon, you must first add its repository URL to your Home Assistant instance.
To do so, add the repository URL below to the Home Assistant add-on store:

`https://github.com/JohannVR/JohannVRs-Home-Assistant-Addons`

Then install the "Airplay 2" add-on from the store and configure it through the Home Assistant UI.

### Option 2: Docker Compose (For Docker Container Mode)

**Best for:** Users running Home Assistant in Docker Container mode who cannot use add-ons.

📖 **Detailed Guide:** See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md) and [ARCHITECTURE.md](ARCHITECTURE.md)

🏗️ **Architecture Choices:**

#### Native Docker Architecture (Recommended)
- ✅ Modern container best practices
- ✅ Lower resource overhead
- ✅ Simpler debugging
- 🚀 **Quick Start:**
  ```bash
  # Download required files
  wget https://raw.githubusercontent.com/JohannVR/JohannVRs-Home-Assistant-Addons/main/Airplay2/docker-compose.native.yml
  wget https://raw.githubusercontent.com/JohannVR/JohannVRs-Home-Assistant-Addons/main/Airplay2/.env.example

  # Configure
  cp docker-compose.native.yml docker-compose.yml
  cp .env.example .env
  # Edit .env with your settings

  # Deploy
  docker-compose up -d --build
  ```

#### Legacy Supervisord Architecture
- ✅ Compatible with original add-on design
- ✅ Automatic process recovery
- 🚀 **Quick Start:**
  ```bash
  # Download required files
  wget https://raw.githubusercontent.com/JohannVR/JohannVRs-Home-Assistant-Addons/main/Airplay2/docker-compose.yml
  wget https://raw.githubusercontent.com/JohannVR/JohannVRs-Home-Assistant-Addons/main/Airplay2/.env.example
  wget https://raw.githubusercontent.com/JohannVR/JohannVRs-Home-Assistant-Addons/main/Airplay2/deploy.sh

  # Configure
  cp .env.example .env
  # Edit .env with your settings

  # Deploy
  chmod +x deploy.sh
  ./deploy.sh deploy
  ```

**Key Differences:**

| Feature | Home Assistant Add-on | Docker Compose |
|---------|---------------------|----------------|
| **Configuration** | Web UI | Environment variables (.env file) |
| **Deployment** | Automatic via Supervisor | Manual via `docker-compose up` |
| **Updates** | Automatic in Home Assistant | Manual (`docker-compose pull`) |
| **Logging** | Home Assistant logs | `docker-compose logs` |
| **Networking** | Automatic | Host networking required |
| **Audio Access** | Automatic | Manual configuration needed |

## Configuration

### Add-on Configuration

Configure through Home Assistant UI with these options:

- **AirPlay Name:** Device name shown in AirPlay lists
- **Audio Backend:** PulseAudio (pa) or ALSA
- **MQTT Integration:** Optional Home Assistant integration
- **Advanced Settings:** Volume control, timing, and audio format options

### Docker Compose Configuration

Configure via environment variables in `.env` file:

```bash
# Basic configuration
AIRPLAY_NAME=Home Assistant
OUTPUT_BACKEND=pa
MQTT_ENABLED=yes
MQTT_HOST=homeassistant.local

# Advanced options available
DEFAULT_AIRPLAY_VOLUME=-24.0
INTERPOLATION=auto
# ... see .env.example for full list
```

## Home Assistant Integration

### Auto-Discovery

Both deployment methods support automatic discovery in Home Assistant when MQTT is enabled:

1. **Add-on:** Enable "Enabled" in MQTT settings
2. **Docker:** Set `MQTT_ENABLED=yes` in `.env`

The AirPlay 2 device will appear as:
- **Media Player** entity for control
- **Sensors** for track information and status
- **Binary Sensor** for playing state

### Manual MQTT Configuration

If auto-discovery doesn't work, add to `configuration.yaml`:

```yaml
media_player:
  - platform: mqtt
    name: "AirPlay 2"
    state_topic: "airplay2/shairport-sync/state"
    command_topic: "airplay2/shairport-sync/command"
    volume_topic: "airplay2/shairport-sync/volume"
```

## Troubleshooting

### Add-on Issues

1. **Service not appearing:** Check Home Assistant Supervisor logs
2. **Audio problems:** Verify audio backend selection (pa vs alsa)
3. **MQTT not working:** Check broker connection and credentials

### Docker Compose Issues

1. **Service not starting:** Check `docker-compose logs`
2. **Device not visible:** Ensure host networking is working
3. **Audio no sound:** Check D-Bus access and audio subsystem

For detailed troubleshooting, see [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md#troubleshooting).

## Migration

### From Add-on to Docker Compose

See [Migration Guide](DOCKER_DEPLOYMENT.md#migration-from-home-assistant-addon) for step-by-step instructions.

### From Manual Shairport-sync

Both deployment methods provide a simpler, managed alternative to manual Shairport-sync installation with automatic Home Assistant integration.

## Support

- **Add-on Issues:** Check Home Assistant logs and create issue in this repository
- **Docker Issues:** See [DOCKER_DEPLOYMENT.md](DOCKER_DEPLOYMENT.md#support) for debugging steps
- **General Questions:** Check existing issues before creating new ones

### Contributing

Contributions are welcome! Please see the main repository for contribution guidelines.

