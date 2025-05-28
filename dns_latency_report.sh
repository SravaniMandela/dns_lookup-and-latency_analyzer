#!/bin/bash

input_file="domains.txt"
output_dir="output"
output_file="$output_dir/report.csv"

mkdir -p "$output_dir"
echo "Domain,IP Address,Location,DNS Time (ms),Ping Latency (ms)" > "$output_file"

while IFS= read -r domain || [ -n "$domain" ]; do
  if [[ -z "$domain" ]]; then continue; fi

  # Measure DNS resolution time
  dns_start=$(date +%s%3N)
  ip=$(dig +short "$domain" | head -n 1)
  dns_end=$(date +%s%3N)
  dns_time=$((dns_end - dns_start))

  if [[ -z "$ip" ]]; then
    echo "$domain,Unresolved,N/A,N/A,N/A" >> "$output_file"
    continue
  fi

  # Measure ping latency
  ping_latency=$(ping -c 1 -W 1 "$ip" | grep 'time=' | awk -F'time=' '{print $2}' | cut -d' ' -f1)
  ping_latency=${ping_latency:-"N/A"}

  # Get location using ip-api.com
  location=$(curl -s "http://ip-api.com/json/$ip" | jq -r '.city + ", " + .country' 2>/dev/null)
  location=${location:-"N/A"}

  echo "$domain,$ip,$location,$dns_time,$ping_latency" >> "$output_file"

done < "$input_file"

echo "Report saved to $output_file"
