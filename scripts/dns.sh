#!/bin/bash

function set_google_dns() {
    echo "Setting Google DNS..."
    rm /etc/resolv.conf
    echo "nameserver 4.2.2.4" >> /etc/resolv.conf
    echo "nameserver 8.8.8.8" >> /etc/resolv.conf
    echo "Google DNS set successfully."
}

function set_cloudflare_dns() {
    echo "Setting Cloudflare DNS..."
    rm /etc/resolv.conf
    echo "nameserver 1.1.1.1" >> /etc/resolv.conf
    echo "Cloudflare DNS set successfully."
}

function set_shecan_dns() {
    echo "Setting Shecan DNS..."
    rm /etc/resolv.conf
    echo "nameserver 178.22.122.100" >> /etc/resolv.conf
    echo "nameserver 185.51.200.2" >> /etc/resolv.conf
    echo "Shecan DNS set successfully."
}

# Display menu
echo "DNS Configuration Menu:"
echo "1. Set Google DNS"
echo "2. Set Cloudflare DNS"
echo "3. Set Shecan DNS"
echo -n "Please enter your choice (1-3): "

read choice

case $choice in
    1)
        set_google_dns
        ;;
    2)
        set_cloudflare_dns
        ;;
    3)
        set_shecan_dns
        ;;
    *)
        echo "Invalid choice. Exiting."
        ;;
esac

