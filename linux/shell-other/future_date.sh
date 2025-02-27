#!/bin/bash

future_date="2025-01-28"
current_date=$(date +"%Y-%m-%d")

futrue_timestamp=$(date -d "$future_date" +"%s")
current_timestamp=$(date -d "$current_date" +"%s")

days_passed=$(( ( futrue_timestamp - current_timestamp ) / 86400 ))

echo "从 $current_date 到 $future_date 还要 $days_passed 天。"