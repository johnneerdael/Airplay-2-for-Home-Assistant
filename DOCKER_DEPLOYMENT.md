# Docker Compose Deployment

This guide explains how to deploy AirPlay 2 using Docker Compose alongside Home Assistant Container. This method is ideal for users running Home Assistant in Docker Container mode who cannot use Home Assistant add-ons.

## Prerequisites

### Required Software

- **Docker Engine** 20.10+
- **Docker Compose** 1.29+ (or `docker compose` plugin)
- **Linux host** with audio subsystem (PulseAudio or ALSA)

### Installation

```bash
# Install Docker on Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.12.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

For other operating systems, see [Docker Installation Guide](https://docs.docker.com/get-docker/) and [Docker Compose Installation](https://docs.docker.com/compose/install/).

## Quick Start

### 1. Clone or Download Files

Get the necessary files from this repository:

```bash
# Option A: Clone the repository
git clone https://github.com/JohannVR/JohannVRs-Home-Assistant-Addons.git
cd JohannVRs-Home-Assistant-Addons/Airplay2

# Option B: Download individual files
# Download: docker-compose.yml, .env.example, deploy.sh
```

### 2. Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit the configuration
nano .env
```

**Essential configuration:**
```bash
# Set your preferred AirPlay name
AIRPLAY_NAME=My Home Assistant

# Configure MQTT if you want Home Assistant integration
MQTT_ENABLED=yes
MQTT_HOST=your-mqtt-broker  #通常是 homeassistant.local 或 IP地址
MQTT_USERNAME=your-mqtt-user
MQTT_PASSWORD=your-mqtt-password
```

### 3. Deploy Using the Script (Recommended)

```bash
# Make the deploy script executable
chmod +x deploy.sh

# Deploy the service
./deploy.sh deploy
```

The script will:
- Detect your system architecture
- Create necessary directories
- Update the Docker image for your architecture
- Start the AirPlay 2 service

### 4. Manual Deployment (Alternative)

```bash
# Create config directory
mkdir -p config

# Detect your architecture and update docker-compose.yml manually
# Architecture mapping:
# - Intel/AMD64: johannvr/ha-airplay2-amd64-debian
# - ARM64: johannvr/ha-airplay2-aarch64-debian
# - ARMv7: johannvr/ha-airplay2-armv7-debian
# - i386: johannvr/ha-airplay2-i386-debian
# - ARMHF: johannvr/ha-airplay2-armhf-debian

# Start the service
docker-compose up -d

# Check status
docker-compose ps
```

## Configuration

### Environment Variables

All configuration is done through environment variables in the `.env` file. These map 1:1 from the Home Assistant add-on options.

#### Basic Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `AIRPLAY_NAME` | Home Assistant | Name shown in AirPlay device lists |
| `AUDIO_BACKEND_LATENCY_OFFSET` | 0.0 | Audio sync offset in seconds |
| `INTERPOLATION` | auto | Audio interpolation (auto/basic/none) |
| `OUTPUT_BACKEND` | pa | Audio backend (pa/alsa) |
| `DEFAULT_AIRPLAY_VOLUME` | -24.0 | Default volume in decibels |

#### MQTT Integration

| Variable | Default | Description |
|----------|---------|-------------|
| `MQTT_ENABLED` | no | Enable MQTT telemetry |
| `MQTT_HOST` | core-mosquitto | MQTT broker hostname |
| `MQTT_USERNAME` | user | MQTT username |
| `MQTT_PASSWORD` | password | MQTT password |
| `MQTT_PUBLISH_COVER` | no | Publish album art via MQTT |

#### Advanced Audio Settings

See `.env.example` for all available advanced options like volume control, timing, and audio format settings.

## Home Assistant Integration

### Auto-Discovery via MQTT

When MQTT is enabled, AirPlay 2 will be automatically discovered by Home Assistant:

1. Enable MQTT in `.env`:
   ```bash
   MQTT_ENABLED=yes
   MQTT_HOST=homeassistant.local  # or your broker IP
   MQTT_USERNAME=your_username
   MQTT_PASSWORD=your_password
   ```

2. Restart the service:
   ```bash
   docker-compose restart
   ```

3. The AirPlay 2 device will appear in Home Assistant under:
   - **Media Player** entity
   - **Binary Sensor** for playing status
   - **Sensor** for current track information

### Manual Configuration

If auto-discovery doesn't work, add this to your `configuration.yaml`:

```yaml
media_player:
  - platform: mqtt
    name: "AirPlay 2"
    state_topic: "airplay2/shairport-sync/state"
    command_topic: "airplay2/shairport-sync/command"
    volume_topic: "airplay2/shairport-sync/volume"
```

## Audio Configuration

### PulseAudio (Recommended)

For most users, the PulseAudio backend (`OUTPUT_BACKEND=pa`) works best:

1. **System requirements:**
   ```bash
   # Install PulseAudio (Ubuntu/Debian)
   sudo apt-get install pulseaudio pulseaudio-utils

   # Ensure your user is in the audio group
   sudo usermod -a -G audio $USER
   ```

2. **Container setup:**
   - The Docker container mounts `/run/dbus:/run/dbus:ro` for system access
   - Uses `SYS_NICE` capability for real-time audio processing

### ALSA (Advanced)

For lower latency or specific hardware requirements:

1. **Enable device access:**
   ```yaml
   # In docker-compose.yml, uncomment:
   devices:
     - /dev/snd:/dev/snd
   ```

2. **Configure backend:**
   ```bash
   OUTPUT_BACKEND=alsa
   MIXER_CONTROL_NAME=Master  # Adjust for your hardware
   ```

## Management

### Using the Deploy Script

```bash
# Show all commands
./deploy.sh help

# Start the service
./deploy.sh start

# Stop the service
./deploy.sh stop

# Restart the service
./deploy.sh restart

# View logs
./deploy.sh logs

# Update to latest version
./deploy.sh update

# Check status
./deploy.sh status
```

### Using Docker Compose Directly

```bash
# Start service
docker-compose up -d

# Stop service
docker-compose down

# View logs
docker-compose logs -f

# Update service
docker-compose pull && docker-compose up -d

# Execute commands in container
docker-compose exec airplay2 bash
```

## Troubleshooting

### Service Not Appearing in AirPlay List

1. **Check service status:**
   ```bash
   docker-compose ps
   docker-compose logs
   ```

2. **Verify networking:**
   - Ensure `network_mode: host` is in `docker-compose.yml`
   - Check firewall settings for port 5000/tcp and 5353/udp
   - Try restarting: `docker-compose restart`

3. **Check host requirements:**
   ```bash
   # Verify D-Bus is running
   systemctl status dbus

   # Check audio subsystem
   systemctl status pulseaudio  # or alsa
   ```

### Audio Issues

1. **No sound output:**
   ```bash
   # Check audio devices
   aplay -l               # List ALSA devices
   pactl list sinks       # List PulseAudio sinks

   # Test audio
   speaker-test -t wav    # ALSA test
   paplay /usr/share/sounds/alsa/Front_Center.wav  # PulseAudio test
   ```

2. **Permission issues:**
   ```bash
   # Ensure user is in audio group
   groups $USER

   # Add to audio group if needed
   sudo usermod -a -G audio $USER
   # Then logout and login again
   ```

### MQTT Integration Issues

1. **Connection problems:**
   ```bash
   # Test MQTT connection
   mosquitto_pub -h $MQTT_HOST -u $MQTT_USERNAME -P $MQTT_PASSWORD -t test -m "hello"
   ```

2. **Check Home Assistant MQTT configuration:**
   - Verify MQTT integration is configured in Home Assistant
   - Check broker hostname and credentials
   - Review Home Assistant logs for MQTT errors

### Performance Issues

1. **High CPU usage:**
   - Try `OUTPUT_BACKEND=alsa` for lower CPU usage
   - Adjust buffer settings: `AUDIO_BACKEND_BUFFER_DESIRED_LENGTH_IN_SECONDS`
   - Disable unused features: `MQTT_PUBLISH_COVER=no`

2. **Audio glitches:**
   - Increase buffer size in settings
   - Try different interpolation methods
   - Check system load and prioritize audio processes

## Networking Considerations

### Host Networking

The service uses `network_mode: host` which:

- **Pros:** Reliable mDNS/Bonjour discovery, simple setup
- **Cons:** Less container isolation, potential port conflicts

### Port Usage

- **5000/tcp:** AirPlay audio/control
- **6000/tcp:** AirPlay timing/ synchronization
- **7000/tcp:** AirPlay remote control
- **5353/udp:** mDNS/Bonjour service discovery

### Firewall Configuration

If using a firewall, ensure these ports are allowed:

```bash
# UFW (Ubuntu)
sudo ufw allow 5000:7000/tcp
sudo ufw allow 5353/udp

# iptables
sudo iptables -A INPUT -p tcp --dport 5000:7000 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 5353 -j ACCEPT
```

## Updates and Maintenance

### Updating the Service

```bash
# Using deploy script
./deploy.sh update

# Or manually
docker-compose pull
docker-compose up -d
```

### Backup Configuration

```bash
# Backup configuration
tar -czf airplay2-backup-$(date +%Y%m%d).tar.gz .env config/

# Restore configuration
tar -xzf airplay2-backup-YYYYMMDD.tar.gz
```

### Migration from Add-on

See [Migration Guide](#migration-from-home-assistant-addon) below.

## Migration from Home Assistant Add-on

If you're currently using the Home Assistant add-on and want to switch to Docker Compose:

### Step 1: Export Current Configuration

1. Note your current add-on settings from Home Assistant UI
2. Export any custom MQTT automations or scripts

### Step 2: Stop Add-on

1. In Home Assistant, stop the AirPlay 2 add-on
2. Wait for the container to be removed by Supervisor

### Step 3: Deploy Docker Version

1. Follow the Quick Start guide above
2. Create `.env` file with matching configuration:
   ```bash
   # Example mapping from add-on to environment variables
   AIRPLAY_NAME=Hass.io              # From add-on "airplay_name"
   OUTPUT_BACKEND=pa                 # From add-on "output_backend"
   MQTT_ENABLED=yes                  # From add-on "enabled"
   MQTT_HOST=core-mosquitto          # From add-on "mqtt_host"
   # ... map all other settings
   ```

### Step 4: Test and Verify

1. Start the Docker service
2. Verify the device appears in AirPlay lists
3. Test MQTT integration in Home Assistant
4. Keep add-on available for quick rollback if needed

### Rollback (if needed)

1. Stop Docker service: `docker-compose down`
2. Start Home Assistant add-on
3. Configuration is independent, so no data loss occurs

## Security Considerations

### MQTT Credentials

- Use strong, unique passwords for MQTT authentication
- Consider using Docker secrets for production deployments
- Regularly rotate MQTT credentials

### Network Isolation

- Host networking reduces container isolation
- Monitor network traffic if security is a concern
- Consider running on dedicated network segments

### File Permissions

```bash
# Secure environment file
chmod 600 .env

# Secure config directory
chmod 700 config/
```

## Support

### Getting Help

1. **Check logs first:** `./deploy.sh logs`
2. **Review troubleshooting section** above
3. **Search existing issues** in the GitHub repository
4. **Create new issue** with:
   - System information (OS, architecture)
   - Docker and Docker Compose versions
   - Configuration (.env file, remove passwords)
   - Service logs
   - Steps to reproduce the issue

### Contributing

Contributions are welcome! Please see the main repository for contribution guidelines.