#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if D-Bus is available
check_dbus() {
    if [ -S "/run/dbus/system_bus_socket" ] || [ -S "/var/run/dbus/system_bus_socket" ]; then
        print_info "D-Bus socket is available"
        return 0
    else
        print_warning "D-Bus socket not found - services may not work properly"
        return 1
    fi
}

# Function to start Avahi if needed
start_avahi() {
    # Check if avahi-daemon is already running on host
    if pgrep -f "avahi-daemon" > /dev/null; then
        print_info "Avahi daemon is already running on host"
        return 0
    fi

    # Try to start avahi-daemon
    print_info "Starting Avahi daemon for mDNS service discovery"
    if command -v avahi-daemon > /dev/null; then
        # Start avahi-daemon in background
        avahi-daemon --no-chroot --daemonize &
        AVAHI_PID=$!

        # Wait a moment for it to start
        sleep 2

        # Check if it started successfully
        if kill -0 $AVAHI_PID 2>/dev/null; then
            print_info "Avahi daemon started successfully (PID: $AVAHI_PID)"
            echo $AVAHI_PID > /tmp/avahi.pid
        else
            print_error "Failed to start Avahi daemon"
            return 1
        fi
    else
        print_error "Avahi daemon not found in PATH"
        return 1
    fi
}

# Function to cleanup on exit
cleanup() {
    print_info "Cleaning up..."

    # Stop Avahi if we started it
    if [ -f "/tmp/avahi.pid" ]; then
        AVAHI_PID=$(cat /tmp/avahi.pid)
        if kill -0 $AVAHI_PID 2>/dev/null; then
            print_info "Stopping Avahi daemon (PID: $AVAHI_PID)"
            kill $AVAHI_PID 2>/dev/null || true
        fi
        rm -f /tmp/avahi.pid
    fi

    print_info "Cleanup completed"
}

# Set up signal handlers
trap cleanup SIGTERM SIGINT

# Main script starts here
print_info "AirPlay 2 Docker Container Starting..."
print_info "Container Architecture: $(uname -m)"

# Print environment variables (without sensitive data)
print_info "Configuration:"
print_info "  AIRPLAY_NAME: ${AIRPLAY_NAME:-Home Assistant}"
print_info "  OUTPUT_BACKEND: ${OUTPUT_BACKEND:-pa}"
print_info "  MQTT_ENABLED: ${MQTT_ENABLED:-no}"
print_info "  INTERPOLATION: ${INTERPOLATION:-auto}"

# Check dependencies
print_info "Checking dependencies..."

# Check D-Bus
check_dbus

# Check audio system
if [ "$OUTPUT_BACKEND" = "pa" ]; then
    if command -v pulseaudio > /dev/null; then
        print_info "PulseAudio backend available"
    else
        print_warning "PulseAudio not found - consider switching to ALSA backend"
    fi
elif [ "$OUTPUT_BACKEND" = "alsa" ]; then
    if [ -d "/proc/asound" ]; then
        print_info "ALSA backend available"
    else
        print_warning "ALSA not available - audio may not work"
    fi
fi

# Run configuration script
print_info "Applying configuration..."

# Copy template if it doesn't exist
if [ ! -f "/etc/shairport-sync.conf" ]; then
    if [ -f "/etc/shairport-sync.conf.template" ]; then
        print_info "Creating shairport-sync.conf from template..."
        cp /etc/shairport-sync.conf.template /etc/shairport-sync.conf
    else
        print_error "Template file not found - cannot create configuration"
        exit 1
    fi
fi

# Apply configuration
/apply-config.sh

# Check if configuration was successful
if [ -f "/etc/shairport-sync.conf" ]; then
    print_info "Configuration applied successfully"
else
    print_error "Configuration failed - /etc/shairport-sync.conf not found"
    exit 1
fi

# Start mDNS service
start_avahi

# Start main application
print_info "Starting Shairport-sync..."
print_info "AirPlay service should be available shortly..."

# Start shairport-sync in foreground
# This keeps the container running and allows proper signal handling
exec shairport-sync