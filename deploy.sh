#!/bin/bash

# AirPlay 2 Docker Deployment Script
# This script helps deploy AirPlay 2 using Docker Compose

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to detect system architecture
detect_architecture() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            ARCH="amd64"
            ;;
        aarch64|arm64)
            ARCH="aarch64"
            ;;
        armv7l)
            ARCH="armv7"
            ;;
        i386|i686)
            ARCH="i386"
            ;;
        armv6l)
            ARCH="armhf"
            ;;
        *)
            print_error "Unsupported architecture: $ARCH"
            print_error "Supported architectures: amd64, aarch64, armv7, i386, armhf"
            exit 1
            ;;
    esac
    print_status "Detected architecture: $ARCH"
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        print_error "Please install Docker first: https://docs.docker.com/get-docker/"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose is not installed or not in PATH"
        print_error "Please install Docker Compose first: https://docs.docker.com/compose/install/"
        exit 1
    fi

    print_success "Docker and Docker Compose are available"
}

# Function to setup environment file
setup_env_file() {
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            print_status "Creating .env file from .env.example"
            cp .env.example .env
            print_warning "Please edit .env file with your configuration before running the service"
            print_warning "Important: Set AIRPLAY_NAME and MQTT credentials if needed"
        else
            print_error ".env.example file not found"
            exit 1
        fi
    else
        print_status ".env file already exists"
    fi
}

# Function to create config directory
create_config_dir() {
    if [ ! -d "config" ]; then
        print_status "Creating config directory"
        mkdir -p config
        print_success "Config directory created"
    else
        print_status "Config directory already exists"
    fi
}

# Function to update docker-compose.yml with correct architecture
update_compose_file() {
    print_status "Updating docker-compose.yml for $ARCH architecture"

    # Create a temporary compose file with the correct architecture
    sed "s/johannvr\/ha-airplay2-amd64-debian:latest/johannvr\/ha-airplay2-$ARCH-debian:latest/" docker-compose.yml > docker-compose.tmp.yml

    # Replace the original file
    mv docker-compose.tmp.yml docker-compose.yml
    print_success "Updated docker-compose.yml for $ARCH architecture"
}

# Function to start the service
start_service() {
    print_status "Starting AirPlay 2 service..."

    # Use docker compose or docker-compose based on what's available
    if docker compose version &> /dev/null; then
        docker compose up -d
    else
        docker-compose up -d
    fi

    print_success "AirPlay 2 service started"
}

# Function to show status
show_status() {
    print_status "Checking service status..."

    if docker compose version &> /dev/null; then
        docker compose ps
    else
        docker-compose ps
    fi
}

# Function to show logs
show_logs() {
    print_status "Showing service logs (press Ctrl+C to exit)..."

    if docker compose version &> /dev/null; then
        docker compose logs -f
    else
        docker-compose logs -f
    fi
}

# Main deployment function
deploy() {
    print_status "Starting AirPlay 2 Docker deployment..."

    check_docker
    detect_architecture
    setup_env_file
    create_config_dir
    update_compose_file
    start_service
    show_status

    print_success "Deployment completed!"
    print_success "Your AirPlay 2 service should now be available on your network"
    print_warning "It may take a minute for the service to appear in AirPlay device lists"
}

# Function to stop the service
stop_service() {
    print_status "Stopping AirPlay 2 service..."

    if docker compose version &> /dev/null; then
        docker compose down
    else
        docker-compose down
    fi

    print_success "AirPlay 2 service stopped"
}

# Function to update the service
update_service() {
    print_status "Updating AirPlay 2 service..."

    if docker compose version &> /dev/null; then
        docker compose pull
        docker compose up -d
    else
        docker-compose pull
        docker-compose up -d
    fi

    print_success "AirPlay 2 service updated"
}

# Show usage
show_usage() {
    echo "AirPlay 2 Docker Deployment Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  deploy    Deploy AirPlay 2 service (default)"
    echo "  start     Start the service"
    echo "  stop      Stop the service"
    echo "  restart   Restart the service"
    echo "  status    Show service status"
    echo "  logs      Show service logs"
    echo "  update    Update the service"
    echo "  help      Show this help message"
}

# Parse command line arguments
case "${1:-deploy}" in
    deploy)
        deploy
        ;;
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        stop_service
        start_service
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    update)
        update_service
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        print_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac