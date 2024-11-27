#!/bin/bash

echo_log() {
    local color="$1"
    shift
    echo -e "$(date +'%F %T') -[${color}\033[0m] $*"
}
echo_log_info() {
    echo_log "\033[32mINFO" "$*"
}
echo_log_warn() {
    echo_log "\033[33mWARN" "$*"
}
echo_log_error() {
    echo_log "\033[31mERROR" "$*"
}

ping_ip() {
    local ip_pattern="^([0-9]\.|[1-9][0-9]\.|1[0-9][0-9]\.|2[0-4][0-9]\.|25[0-5]\.){3}([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])$"
    #local ip_pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

    while true; do
        read -rp "Please enter IP addresses (separate multiple addresses with spaces):" ips
        if [ -z "$ips" ]; then
            echo_log_info "The IP address cannot be empty, please re-enter!"
        else
            invalid_ips=0
            for ip in $ips; do
                if ! [[ $ip =~ $ip_pattern ]]; then
                    echo_log_warn "$ip The format is incorrect, please re-enter!"
                    invalid_ips=1
                    break
                fi
            done
            if [ $invalid_ips -eq 0 ]; then
                break
            fi
        fi
    done

    while true; do
        for ip in $ips; do
            if ping -c 2 -W 2 "$ip" &>/dev/null; then
                echo_log_info "$ip Reachable！"
            else
                echo_log_warn "$ip Unreachable！"
            fi
        done
        #sleep 5
        read -t 5 input
        [ $? -eq 0 ] && { echo_log_info "ping IP address $ips Done!"; break; }
    done
}

ping_ip
