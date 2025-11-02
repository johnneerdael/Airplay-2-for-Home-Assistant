# Release Notes v0.2.0

## 🎉 Major New Feature: Docker Compose Deployment

We're excited to announce that AirPlay 2 now supports Docker Compose deployment! This enables users running Home Assistant in Docker Container mode to use AirPlay 2 functionality without switching to Home Assistant OS or Supervisor.

## ✨ New Features

### 🐳 Docker Compose Deployment
- **New Deployment Option:** Standalone Docker container deployment alongside Home Assistant Container
- **Environment Variable Configuration:** All add-on options now available as environment variables
- **Backward Compatibility:** Existing Home Assistant add-on deployment unchanged
- **Multi-Architecture Support:** Automatic detection and deployment for all supported architectures
- **Deployment Script:** Easy-to-use deployment script with automatic setup

### 🔧 Configuration Enhancements
- **Dual-Mode Configuration Script:** Updated `apply-config.sh` supports both JSON and environment variable inputs
- **Automatic Mode Detection:** Script automatically detects add-on vs Docker deployment
- **Enhanced Validation:** Better error handling and configuration validation

## 📋 Files Added

- `docker-compose.yml` - Main Docker Compose configuration
- `docker-compose.multiarch.yml` - Multi-architecture support
- `.env.example` - Environment variable template with documentation
- `deploy.sh` - Automated deployment script with architecture detection
- `DOCKER_DEPLOYMENT.md` - Comprehensive deployment documentation
- `RELEASE_NOTES_v0.2.0.md` - This release notes file

## 🏗️ Architecture Improvements

### Configuration System
- **Modular Functions:** Refactored configuration script with reusable functions
- **Environment Variable Mapping:** 1:1 mapping from add-on options to environment variables
- **Graceful Fallbacks:** Sensible defaults for missing configuration

### Container Infrastructure
- **Host Networking:** Proper mDNS/Bonjour support for AirPlay discovery
- **Audio Device Access:** Configured access to D-Bus and audio subsystem
- **Health Checks:** Built-in service monitoring and health validation
- **Resource Limits:** Configurable memory and CPU limits

## 📖 Documentation Updates

### Updated README.md
- **Deployment Options Guide:** Clear comparison of add-on vs Docker deployment
- **Quick Start Instructions:** Fast deployment for both methods
- **Migration Guidance:** Step-by-step migration between deployment types
- **Troubleshooting Section:** Expanded troubleshooting for both deployment types

### New DOCKER_DEPLOYMENT.md
- **Comprehensive Guide:** 500+ line deployment documentation
- **Installation Instructions:** Step-by-step setup for various systems
- **Configuration Reference:** Complete environment variable documentation
- **Troubleshooting Guide:** Detailed problem resolution
- **Security Considerations:** Best practices for production deployment

## 🔄 Migration Path

### For Existing Add-on Users
- **No Action Required:** Existing add-on deployments continue unchanged
- **Optional Migration:** Users can migrate to Docker if desired
- **Rollback Support:** Easy rollback to add-on if needed

### For New Docker Users
- **Quick Setup:** 3-command deployment using provided script
- **Configuration Templates:** Pre-configured environment examples
- **Architecture Detection:** Automatic image selection for your system

## 🛠️ Technical Details

### Environment Variable Mapping

| Add-on Option | Environment Variable | Description |
|---------------|---------------------|-------------|
| `airplay_name` | `AIRPLAY_NAME` | Service discovery name |
| `offset` | `AUDIO_BACKEND_LATENCY_OFFSET` | Audio sync offset |
| `interpolation` | `INTERPOLATION` | Audio interpolation method |
| `output_backend` | `OUTPUT_BACKEND` | Audio backend (pa/alsa) |
| `enabled` | `MQTT_ENABLED` | Enable MQTT telemetry |
| `mqtt_host` | `MQTT_HOST` | MQTT broker hostname |
| `mqtt_username` | `MQTT_USERNAME` | MQTT authentication |
| `mqtt_password` | `MQTT_PASSWORD` | MQTT authentication |
| `mqtt_publish_cover` | `MQTT_PUBLISH_COVER` | Publish album art |
| `default_airplay_volume` | `DEFAULT_AIRPLAY_VOLUME` | Initial volume level |

### Advanced Configuration

All optional add-on settings are available as environment variables:
- Volume control settings
- Audio format configuration
- Timing and synchronization
- Advanced backend options

## 🐛 Bug Fixes

- **Configuration Script:** Improved error handling and validation
- **Documentation:** Fixed broken links and outdated information
- **Examples:** Corrected configuration examples and templates

## 🧪 Testing

### Automated Testing
- **Configuration Script:** Tested with both JSON and environment variable inputs
- **Docker Deployment:** Validated on multiple architectures
- **Service Discovery:** Verified mDNS/Bonjour functionality

### Manual Testing Checklist
- [x] Basic AirPlay streaming functionality
- [x] MQTT integration and auto-discovery
- [x] Volume control and metadata publishing
- [x] Container restart and configuration persistence
- [x] Audio output with PulseAudio backend
- [x] Service discovery on multiple platforms

## 📦 Installation

### Home Assistant Add-on (Existing Users)
1. Update through Home Assistant Supervisor
2. No configuration changes required

### Docker Compose (New Users)
```bash
# Quick deployment
curl -LO https://raw.githubusercontent.com/JohannVR/JohannVRs-Home-Assistant-Addons/main/Airplay2/deploy.sh
curl -LO https://raw.githubusercontent.com/JohannVR/JohannVRs-Home-Assistant-Addons/main/Airplay2/.env.example
curl -LO https://raw.githubusercontent.com/JohannVR/JohannVRs-Home-Assistant-Addons/main/Airplay2/docker-compose.yml

chmod +x deploy.sh
cp .env.example .env
# Edit .env with your configuration
./deploy.sh deploy
```

## 🔄 Upgrade Instructions

### From v0.1.5 to v0.2.0

#### Home Assistant Add-on Users
- **Automatic:** Update through Home Assistant Supervisor
- **No Configuration Changes:** All existing settings preserved
- **Optional:** Consider Docker deployment if you want standalone operation

#### Manual Docker Users
- **Recreate:** Update your Docker configuration if using manual setup
- **Environment Variables:** Update to use new environment variable names
- **Documentation:** Review DOCKER_DEPLOYMENT.md for updated instructions

## 🚀 Breaking Changes

### None
- **Backward Compatible:** All existing add-on deployments continue unchanged
- **Optional Features:** Docker deployment is an additional option, not a replacement
- **Configuration Mapping:** Environment variables follow clear naming conventions

## 🙏 Acknowledgments

- **Community Feedback:** Thanks to users who requested Docker Container support
- **Shairport-Sync Project:** Foundation of AirPlay 2 functionality
- **Home Assistant Team:** Excellent add-on framework and inspiration

## 🔮 Future Plans

- **Watchtower Integration:** Automatic updates for Docker deployments
- **Kubernetes Support:** Potential K8s deployment manifests
- **Performance Monitoring:** Enhanced metrics and monitoring
- **Audio Backends:** Additional audio backend support

## 📞 Support

- **Issues:** Report issues on [GitHub](https://github.com/JohannVR/JohannVRs-Home-Assistant-Addons/issues)
- **Documentation:** See updated README.md and DOCKER_DEPLOYMENT.md
- **Questions:** Check existing issues before creating new ones

---

**Upgrade today and enjoy flexible AirPlay 2 deployment options!** 🎵