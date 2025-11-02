## ADDED Requirements

### Requirement: Docker Compose Configuration

The system SHALL provide a Docker Compose configuration file that enables deployment of the AirPlay 2 service alongside Home Assistant Container installations.

#### Scenario: Service Definition

- **GIVEN** a user with Home Assistant running in Docker Container mode
- **WHEN** they deploy using the provided `docker-compose.yml`
- **THEN** the AirPlay 2 service starts with proper networking, audio access, and volume mounts

#### Scenario: Host Network Mode

- **GIVEN** the Docker Compose configuration
- **WHEN** the container is started
- **THEN** it uses host networking mode for mDNS/Bonjour service discovery

#### Scenario: Audio Device Access

- **GIVEN** the Docker Compose configuration
- **WHEN** the container is started
- **THEN** it has access to the host's D-Bus socket and audio devices

### Requirement: Environment Variable Configuration

The system SHALL support configuration via environment variables as an alternative to the Home Assistant add-on's `/data/options.json` file.

#### Scenario: Add-on Mode Detection

- **GIVEN** the configuration script runs at container startup
- **WHEN** `/data/options.json` exists
- **THEN** configuration is read from the JSON file (add-on mode)

#### Scenario: Standalone Mode Detection

- **GIVEN** the configuration script runs at container startup
- **WHEN** `/data/options.json` does not exist
- **THEN** configuration is read from environment variables (standalone mode)

#### Scenario: Required Variables

- **GIVEN** standalone deployment mode
- **WHEN** required environment variables are missing
- **THEN** default values are applied with appropriate logging

#### Scenario: Environment Variable Mapping

- **GIVEN** an add-on configuration option (e.g., `airplay_name`)
- **WHEN** deploying in standalone mode
- **THEN** the equivalent environment variable (`AIRPLAY_NAME`) configures the same functionality

### Requirement: Backward Compatibility

The system SHALL maintain full backward compatibility with existing Home Assistant add-on deployments.

#### Scenario: Add-on Unchanged

- **GIVEN** an existing Home Assistant add-on installation
- **WHEN** the user updates to a version with Docker Compose support
- **THEN** the add-on continues to function without configuration changes

#### Scenario: Configuration Script Compatibility

- **GIVEN** the refactored `apply-config.sh` script
- **WHEN** executed in add-on mode with `/data/options.json`
- **THEN** all configuration options are applied identically to previous versions

### Requirement: Service Discovery

The system SHALL advertise the AirPlay 2 service via mDNS/Bonjour for automatic discovery by Apple devices.

#### Scenario: Service Advertisement

- **GIVEN** the container is running in standalone mode
- **WHEN** Avahi daemon starts
- **THEN** the `_airplay._tcp` service is advertised with the configured name

#### Scenario: Network Discovery

- **GIVEN** an Apple device on the same network
- **WHEN** the user opens AirPlay selection
- **THEN** the service appears in the available devices list

### Requirement: MQTT Integration

The system SHALL support optional MQTT telemetry publishing when configured via environment variables.

#### Scenario: MQTT Connection

- **GIVEN** `MQTT_ENABLED=yes` and valid MQTT credentials
- **WHEN** the container starts and AirPlay playback begins
- **THEN** metadata is published to the configured MQTT topic

#### Scenario: MQTT Disabled

- **GIVEN** `MQTT_ENABLED=no` or missing MQTT environment variables
- **WHEN** the container starts
- **THEN** MQTT functionality is disabled without affecting core AirPlay service

### Requirement: Audio Backend Selection

The system SHALL support both PulseAudio and ALSA audio backends configured via environment variables.

#### Scenario: PulseAudio Backend

- **GIVEN** `OUTPUT_BACKEND=pa`
- **WHEN** audio playback starts
- **THEN** audio is routed through PulseAudio

#### Scenario: ALSA Backend

- **GIVEN** `OUTPUT_BACKEND=alsa`
- **WHEN** audio playback starts
- **THEN** audio is routed directly through ALSA

### Requirement: Volume Persistence

The system SHALL provide persistent storage for configuration and runtime data via volume mounts.

#### Scenario: Configuration Persistence

- **GIVEN** a volume mounted at `/config`
- **WHEN** the container is recreated
- **THEN** persistent data is retained across restarts

### Requirement: Documentation

The system SHALL provide comprehensive documentation for Docker Compose deployment.

#### Scenario: Installation Instructions

- **GIVEN** a user wanting to deploy via Docker Compose
- **WHEN** they read `DOCKER_DEPLOYMENT.md`
- **THEN** they find step-by-step installation instructions

#### Scenario: Environment Variable Reference

- **GIVEN** a user configuring the service
- **WHEN** they read the environment variable documentation
- **THEN** they find all available variables with descriptions and default values

#### Scenario: Troubleshooting Guide

- **GIVEN** a user encountering deployment issues
- **WHEN** they consult the troubleshooting section
- **THEN** they find solutions for common problems (audio access, networking, MQTT)

#### Scenario: Migration Guide

- **GIVEN** a user with existing Shairport Sync setup
- **WHEN** they read the migration guide
- **THEN** they find instructions for transitioning to Docker Compose deployment

### Requirement: Health Monitoring

The system SHALL provide health check capabilities for container orchestration.

#### Scenario: Service Health

- **GIVEN** the container is running
- **WHEN** health check is executed
- **THEN** it reports healthy if core services (nqptp, shairport-sync, avahi) are running

#### Scenario: Service Failure

- **GIVEN** a core service fails
- **WHEN** health check is executed
- **THEN** it reports unhealthy and logs the failure reason