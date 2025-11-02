## 1. Configuration Layer

- [ ] 1.1 Refactor `apply-config.sh` to support dual input sources (environment variables OR `/data/options.json`)
- [ ] 1.2 Create environment variable lookup with fallback to JSON for backward compatibility
- [ ] 1.3 Add validation for environment variable format and required values
- [ ] 1.4 Test configuration script with both input methods to ensure no regressions

## 2. Docker Compose Infrastructure

- [ ] 2.1 Create `docker-compose.yml` with service definition for airplay2
- [ ] ] 2.2 Configure host networking mode for mDNS/Bonjour discovery
- [ ] 2.3 Add audio device access configuration (`/run/dbus`, capabilities)
- [ ] 2.4 Define volume mounts for persistent configuration
- [ ] 2.5 Create `.env.example` file with all configurable environment variables
- [ ] 2.6 Add health check configuration for service monitoring

## 3. Documentation

- [ ] 3.1 Write `DOCKER_DEPLOYMENT.md` with installation instructions
- [ ] 3.2 Document environment variable configuration reference
- [ ] 3.3 Add troubleshooting section (audio devices, networking, MQTT)
- [ ] 3.4 Create migration guide from Home Assistant add-on to Docker Compose
- [ ] 3.5 Update main [`README.md`](../../README.md) with deployment options overview
- [ ] 3.6 Document differences between add-on and standalone deployment

## 4. Testing & Validation

- [ ] 4.1 Test basic AirPlay 2 streaming from iOS device
- [ ] 4.2 Verify mDNS service discovery and device visibility
- [ ] 4.3 Test MQTT integration with Home Assistant Container
- [ ] 4.4 Validate volume control and metadata publishing
- [ ] 4.5 Test container restart and configuration persistence
- [ ] 4.6 Verify audio output with both PulseAudio and ALSA backends

## 5. Release Preparation

- [ ] 5.1 Update version in [`config.yaml`](../../config.yaml) for add-on
- [ ] 5.2 Create release notes detailing new deployment option
- [ ] 5.3 Tag Docker images with appropriate version labels
- [ ] 5.4 Update repository badges and installation count if applicable