#!/bin/bash

# Setting Files
config_file="/etc/shairport-sync.conf"
json_file="/data/options.json"

# Function to get configuration value from environment variable or JSON
get_config_value() {
    local json_key="$1"
    local env_var="$2"
    local default_value="$3"

    # First check if we're in add-on mode (options.json exists)
    if [ -f "$json_file" ]; then
        # Add-on mode: read from JSON
        value=$(jq -r ".$json_key" "$json_file" 2>/dev/null)
        if [ "$value" = "null" ] || [ -z "$value" ]; then
            echo "$default_value"
        else
            echo "$value"
        fi
    else
        # Docker mode: read from environment variable
        local var_value="${!env_var}"
        if [ -z "$var_value" ]; then
            echo "$default_value"
        else
            echo "$var_value"
        fi
    fi
}

# Function to get optional configuration value (may not exist)
get_optional_config_value() {
    local json_key="$1"
    local env_var="$2"

    if [ -f "$json_file" ]; then
        # Add-on mode: check if key exists in JSON
        value=$(jq -r --arg key "$json_key" '.[$key] // empty' "$json_file" 2>/dev/null)
        if [ -n "$value" ] && [ "$value" != "null" ]; then
            echo "$value"
        fi
    else
        # Docker mode: check if environment variable is set
        local var_value="${!env_var}"
        if [ -n "$var_value" ]; then
            echo "$var_value"
        fi
    fi
}

# Check if we have any configuration source
if [ ! -f "$json_file" ]; then
    # Docker mode - check for essential environment variables
    if [ -z "$AIRPLAY_NAME" ]; then
        echo "Warning: AIRPLAY_NAME not set, using default 'Home Assistant'"
    fi
fi

################################################### Name ###################################################

# Get configuration value (environment variable or JSON)
value=$(get_config_value "airplay_name" "AIRPLAY_NAME" "Home Assistant")

# Escape backslashes and dollar signs for safe sed usage
escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
quoted_value="\"$escaped_value\""

# Replace line in config file using sed (target 9th line)
sed -i "9s/.*/        name = $quoted_value/" "$config_file"

################################################### offset ###################################################

# Get configuration value (environment variable or JSON)
value=$(get_config_value "offset" "AUDIO_BACKEND_LATENCY_OFFSET" "0.0")

# Escape backslashes and dollar signs for safe sed usage
escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')

# Replace line in config file using sed (target 72nd line)
sed -i "72s/.*/        audio_backend_latency_offset_in_seconds = $escaped_value/" "$config_file"

################################################### interpolation ###################################################

# Get configuration value (environment variable or JSON)
value=$(get_config_value "interpolation" "INTERPOLATION" "auto")

# Escape backslashes and dollar signs for safe sed usage
escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
quoted_value="\"$escaped_value\""

# Replace line in config file using sed (target 18th line)
sed -i "18s/.*/        interpolation =  $quoted_value/" "$config_file"

################################################### mqtt setting ###################################################

# Get configuration value (environment variable or JSON)
value=$(get_config_value "enabled" "MQTT_ENABLED" "no")

# Escape backslashes and dollar signs for safe sed usage
escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
quoted_value="\"$escaped_value\""

# Replace line in config file using sed (target 273rd line)
sed -i "273s/.*/        enabled = $quoted_value/" "$config_file"

################################################### mqtt hostname ###################################################

# Get configuration value (environment variable or JSON)
value=$(get_config_value "mqtt_host" "MQTT_HOST" "core-mosquitto")

# Escape backslashes and dollar signs for safe sed usage
escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
quoted_value="\"$escaped_value\""

# Replace line in config file using sed (target 274nd line)
sed -i "274s/.*/        hostname = $quoted_value/" "$config_file"

################################################### mqtt username ###################################################

# Get configuration value (environment variable or JSON)
value=$(get_config_value "mqtt_username" "MQTT_USERNAME" "user")

# Escape backslashes and dollar signs for safe sed usage
escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
quoted_value="\"$escaped_value\""

# Replace line in config file using sed (target 276th line)
sed -i "276s/.*/        username = $quoted_value/" "$config_file"

################################################### mqtt password ###################################################

# Get configuration value (environment variable or JSON)
value=$(get_config_value "mqtt_password" "MQTT_PASSWORD" "password")

# Escape backslashes and dollar signs for safe sed usage
escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
quoted_value="\"$escaped_value\""

# Replace line in config file using sed (target 277th line)
sed -i "277s/.*/        password = $quoted_value/" "$config_file"

################################################### mqtt publish cover ###################################################

# Get configuration value (environment variable or JSON)
value=$(get_config_value "mqtt_publish_cover" "MQTT_PUBLISH_COVER" "no")

# Escape backslashes and dollar signs for safe sed usage
escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
quoted_value="\"$escaped_value\""

# Replace line in config file using sed (target 289th line)
sed -i "289s/.*/        publish_cover = $quoted_value/" "$config_file"

################################################### audio backend ###################################################
# Get configuration value (environment variable or JSON)
value=$(get_config_value "output_backend" "OUTPUT_BACKEND" "pa")

# Escape backslashes and dollar signs for safe sed usage
escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
quoted_value="\"$escaped_value\""

# Replace line in config file using sed (target 19th line)
sed -i "19s/.*/        output_backend = $quoted_value/" "$config_file"

################################################### default_airplay_volume ###################################################
# Get configuration value (environment variable or JSON)
value=$(get_config_value "default_airplay_volume" "DEFAULT_AIRPLAY_VOLUME" "-24.0")

# Escape backslashes and dollar signs for safe sed usage
escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')

# Replace line in config file using sed (target 54th line)
sed -i "54s/.*/        default_airplay_volume = $escaped_value;/" "$config_file"


################################################### volume_max_db ###################################################
value=$(get_optional_config_value "volume_max_db" "VOLUME_MAX_DB")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  sed -i "39s/.*/        volume_max_db = $escaped_value;/" "$config_file"
fi

################################################### output_format ###################################################
value=$(get_optional_config_value "output_format" "OUTPUT_FORMAT")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  quoted_value="\"$escaped_value\""
  sed -i "131s/.*/        output_format = $quoted_value;/" "$config_file"
fi

################################################### output_rate ###################################################
value=$(get_optional_config_value "output_rate" "OUTPUT_RATE")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  quoted_value="\"$escaped_value\""
  sed -i "130s/.*/        output_rate = $quoted_value;/" "$config_file"
fi

################################################### use_precision_timing ###################################################
value=$(get_optional_config_value "use_precision_timing" "USE_PRECISION_TIMING")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  quoted_value="\"$escaped_value\""
  sed -i "140s/.*/        use_precision_timing =  $quoted_value/" "$config_file"
fi

################################################### disable_standby_mode ###################################################
value=$(get_optional_config_value "disable_standby_mode" "DISABLE_STANDBY_MODE")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  quoted_value="\"$escaped_value\""
  sed -i "142s/.*/        disable_standby_mode =  $quoted_value/" "$config_file"
fi

################################################### high_threshold_airplay_volume ###################################################
value=$(get_optional_config_value "high_threshold_airplay_volume" "HIGH_THRESHOLD_AIRPLAY_VOLUME")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  sed -i "63s/.*/        high_threshold_airplay_volume = $escaped_value;/" "$config_file"
fi

################################################### mixer_control_name ###################################################
value=$(get_optional_config_value "mixer_control_name" "MIXER_CONTROL_NAME")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  quoted_value="\"$escaped_value\""
  sed -i "126s/.*/        mixer_control_name = $quoted_value;/" "$config_file"
fi

################################################### mixer_control_index ###################################################
value=$(get_optional_config_value "mixer_control_index" "MIXER_CONTROL_INDEX")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  sed -i "127s/.*/        mixer_control_index = $escaped_value;/" "$config_file"
fi

################################################### volume_control_combined_hardware_priority ###################################################
value=$(get_optional_config_value "volume_control_combined_hardware_priority" "VOLUME_CONTROL_COMBINED_HARDWARE_PRIORITY")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  quoted_value="\"$escaped_value\""
  sed -i "52s/.*/        volume_control_combined_hardware_priority = $quoted_value;/" "$config_file"
fi

################################################### drift_tolerance_in_seconds ###################################################
value=$(get_optional_config_value "drift_tolerance_in_seconds" "DRIFT_TOLERANCE_IN_SECONDS")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  sed -i "29s/.*/        drift_tolerance_in_seconds = $escaped_value;/" "$config_file"
fi

################################################### resync_threshold_in_seconds ###################################################
value=$(get_optional_config_value "resync_threshold_in_seconds" "RESYNC_THRESHOLD_IN_SECONDS")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  sed -i "30s/.*/        resync_threshold_in_seconds = $escaped_value;/" "$config_file"
fi

################################################### resync_recovery_time_in_seconds ###################################################
value=$(get_optional_config_value "resync_recovery_time_in_seconds" "RESYNC_RECOVERY_TIME_IN_SECONDS")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  sed -i "31s/.*/        resync_recovery_time_in_seconds = $escaped_value;/" "$config_file"
fi

################################################### audio_backend_buffer_desired_length_in_seconds ###################################################
value=$(get_optional_config_value "audio_backend_buffer_desired_length_in_seconds" "AUDIO_BACKEND_BUFFER_DESIRED_LENGTH_IN_SECONDS")

if [ -n "$value" ]; then
  escaped_value=$(echo "$value" | sed 's/\\//g' | sed 's/\$/\\\\$/g')
  quoted_value="\"$escaped_value\""
  sed -i "76s/.*/        audio_backend_buffer_desired_length_in_seconds = $quoted_value;/" "$config_file"
fi

