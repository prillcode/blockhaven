#!/bin/bash
# Memory diagnostic script for BlockHaven Minecraft server

echo "=========================================="
echo "BlockHaven Memory Diagnostic"
echo "=========================================="
echo ""

echo "1. System Memory Overview:"
echo "-------------------------------------------"
free -h
echo ""

echo "2. Detailed Memory Breakdown:"
echo "-------------------------------------------"
free -m | awk 'NR==2{printf "Total: %sMB\nUsed: %sMB (%.2f%%)\nFree: %sMB\nAvailable: %sMB\n", $2,$3,$3*100/$2,$4,$7}'
echo ""

echo "3. Top 10 Memory Consuming Processes:"
echo "-------------------------------------------"
ps aux --sort=-%mem | head -11
echo ""

echo "4. Docker Container Memory Usage:"
echo "-------------------------------------------"
if docker ps -q &>/dev/null; then
    docker stats --no-stream --format "table {{.Name}}\t{{.MemUsage}}\t{{.MemPerc}}"
else
    echo "Docker not running or no containers found"
fi
echo ""

echo "5. Docker Container Inspect (Memory Limits):"
echo "-------------------------------------------"
if docker ps -q --filter name=blockhaven-mc &>/dev/null; then
    echo "Container: blockhaven-mc"
    docker inspect blockhaven-mc | grep -A 5 Memory
else
    echo "blockhaven-mc container not running"
fi
echo ""

echo "6. Java Process Details:"
echo "-------------------------------------------"
ps aux | grep java | grep -v grep
echo ""

echo "7. System Load and Uptime:"
echo "-------------------------------------------"
uptime
echo ""

echo "8. Zombie Processes:"
echo "-------------------------------------------"
ps aux | grep 'Z' | grep -v grep
echo ""

echo "=========================================="
echo "Recommendations:"
echo "=========================================="
echo ""
echo "Current Configuration:"
echo "  - Instance Type: t3a.large (8GB RAM)"
echo "  - Minecraft Memory: 6GB"
echo "  - Remaining for OS/Docker: ~2GB"
echo ""
echo "If memory usage is consistently high (>85%), consider:"
echo "  1. Reduce Minecraft memory to 5GB or 5.5GB"
echo "  2. Upgrade to t3a.xlarge (16GB RAM) - ~$4.51/day"
echo "  3. Monitor for memory leaks in plugins"
echo "  4. Review JVM garbage collection logs"
echo ""
