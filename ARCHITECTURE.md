# Architecture Approaches for AirPlay 2 Docker Deployment

This document explains the different architectural approaches available for running AirPlay 2 in Docker, and helps you choose the right one for your needs.

## 🏗️ Available Architectures

### 1. Legacy Add-on Architecture (with Supervisord)
**Files**: `Dockerfile`, `supervisord.conf`, `docker-compose.yml`

**Characteristics:**
- Uses supervisord for process management
- Originally designed for Home Assistant add-ons
- Multiple processes managed by supervisord:
  - `nqptp` (time synchronization)
  - `dbus-daemon` (system message bus)
  - `avahi-daemon` (mDNS service discovery)
  - `shairport-sync` (main AirPlay service)

**Pros:**
- ✅ Compatible with existing Home Assistant add-on infrastructure
- ✅ Handles process restarts automatically
- ✅ Comprehensive logging and monitoring
- ✅ Mature and tested architecture

**Cons:**
- ❌ Adds unnecessary complexity for standalone Docker
- ❌ Non-Docker-native approach
- ❌ Additional resource overhead
- ❌ Harder to debug with multiple process layers

### 2. Native Docker Architecture (Recommended)
**Files**: `Dockerfile.native`, `docker-entrypoint.sh`, `docker-compose.native.yml`

**Characteristics:**
- Eliminates supervisord completely
- Uses Docker-native process management
- Single process per container approach
- Smart detection of host services

**Pros:**
- ✅ Docker-native best practices
- ✅ Lower resource overhead
- ✅ Simpler debugging and troubleshooting
- ✅ Better container isolation
- ✅ Follows single responsibility principle

**Cons:**
- ❌ Less automatic process recovery
- ❌ Requires careful signal handling
- ❌ Newer approach, less battle-tested

## 📊 Architecture Comparison

| Feature | Legacy (Supervisord) | Native Docker |
|---------|---------------------|----------------|
| **Process Management** | Supervisord manages all processes | Docker manages main process only |
| **Resource Usage** | Higher (supervisord overhead) | Lower (direct process execution) |
| **Complexity** | Higher (multiple process layers) | Lower (single process focus) |
| **Debugging** | More complex (multiple layers) | Simpler (direct process access) |
| **Docker Best Practices** | ❌ Anti-pattern | ✅ Follows best practices |
| **Signal Handling** | Automatic via supervisord | Manual implementation required |
| **Process Recovery** | Automatic restarts | Container restart only |
| **Home Assistant Add-on** | ✅ Required | ❌ Not compatible |

## 🎯 Which Architecture Should You Use?

### Use Legacy Architecture (Supervisord) if:
- You need compatibility with Home Assistant add-ons
- You want automatic process recovery within the container
- You prefer the tested, battle-hardened approach
- You're migrating from the existing add-on

### Use Native Docker Architecture if:
- You're doing standalone Docker deployment
- You want to follow Docker best practices
- You prefer simpler, more maintainable containers
- You want lower resource overhead
- You're comfortable with container-native approaches

## 🔄 Migration Path

### From Legacy to Native Architecture

1. **Backup current configuration:**
   ```bash
   cp docker-compose.yml docker-compose.legacy.yml
   cp .env .env.backup
   ```

2. **Switch to native files:**
   ```bash
   cp docker-compose.native.yml docker-compose.yml
   # Build native image
   docker-compose build
   ```

3. **Test the new architecture:**
   ```bash
   docker-compose up -d
   docker-compose logs -f
   ```

4. **Verify functionality:**
   - Check if AirPlay device appears in your device list
   - Test audio playback
   - Verify MQTT integration (if enabled)

## 🔧 Implementation Details

### Legacy Architecture Process Flow

```
Docker Container Entry
    ↓
Supervisord (PID 1)
    ↓
┌─────────────┬─────────────┬─────────────┬─────────────┐
│   nqptp      │ dbus-daemon │ avahi-daemon │ shairport-sync │
│ (time sync)  │ (msg bus)   │ (mDNS)      │ (AirPlay)     │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

### Native Architecture Process Flow

```
Docker Container Entry
    ↓
docker-entrypoint.sh
    ↓
┌─────────────────────────────────────────────────────────┐
│ Configuration Application                               │
│ Service Detection (D-Bus, Avahi)                      │
│                                                    │
└─────────────────────────────────────────────────────────┘
    ↓
shairport-sync (PID 1)
    ↓
Optional background services (Avahi if not running on host)
```

## 🐛 Debugging Differences

### Legacy Architecture
```bash
# Check supervisord status
docker-compose exec airplay2 supervisorctl status

# Check individual service logs
docker-compose exec airplay2 tail -f /var/log/supervisor/shairport.out.log
docker-compose exec airplay2 tail -f /var/log/supervisor/avahi.out.log
```

### Native Architecture
```bash
# Check container logs (everything goes to main log)
docker-compose logs -f airplay2

# Check running processes
docker-compose exec airplay2 ps aux

# Check configuration
docker-compose exec airplay2 cat /etc/shairport-sync.conf
```

## 🚀 Getting Started with Native Architecture

### Quick Start
```bash
# Use native Docker Compose file
cp docker-compose.native.yml docker-compose.yml

# Build and run
docker-compose up -d --build

# Check logs
docker-compose logs -f
```

### Custom Configuration
The native architecture uses the same environment variables as the legacy approach:

```bash
# .env file
AIRPLAY_NAME=My AirPlay
OUTPUT_BACKEND=pa
MQTT_ENABLED=yes
MQTT_HOST=homeassistant.local
```

## 🔮 Future Considerations

### Potential Improvements

1. **Multi-Container Approach**
   - Separate containers for different services
   - Docker networking instead of host networking
   - Better isolation and scaling

2. **Kubernetes Deployment**
   - Native Kubernetes manifests
   - Service discovery via K8s services
   - ConfigMaps and Secrets management

3. **Health Monitoring**
   - Prometheus metrics
   - Better health checks
   - Alerting integration

## 📚 Related Documentation

- [Docker Compose Deployment Guide](DOCKER_DEPLOYMENT.md)
- [Troubleshooting Guide](DOCKER_DEPLOYMENT.md#troubleshooting)
- [Environment Variable Reference](DOCKER_DEPLOYMENT.md#configuration)

---

**Recommendation:** For most users doing standalone Docker deployment, the **Native Docker Architecture** is recommended as it follows modern container best practices and provides a cleaner, more maintainable solution.