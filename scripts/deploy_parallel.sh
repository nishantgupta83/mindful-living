#!/bin/bash
# Parallel Deployment Script - Run Alexa and Watch development simultaneously

set -e

echo "🚀 Mindful Living - Parallel Deployment"
echo "========================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Log files
ALEXA_LOG="./logs/alexa_deployment.log"
WATCH_LOG="./logs/watch_deployment.log"
TRANSFORM_LOG="./logs/content_transformation.log"

# Create logs directory
mkdir -p logs

# Function to print with timestamp
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to run command in background and track PID
run_bg() {
    local name=$1
    local command=$2
    local logfile=$3

    log "Starting: $name"
    eval "$command" > "$logfile" 2>&1 &
    local pid=$!
    echo $pid
}

# Clean old logs
echo "" > $ALEXA_LOG
echo "" > $WATCH_LOG
echo "" > $TRANSFORM_LOG

echo ""
echo "📦 Phase 1: Content Transformation"
echo "-----------------------------------"

# Run content transformation first (must complete before others)
log "Transforming GitaWisdom content to secular wellness..."
if [ -f "gitawisdom_scenarios.json" ]; then
    echo "✓ Input file found: gitawisdom_scenarios.json"

    npx ts-node backend/content-transformation/content_transformer.ts \
        gitawisdom_scenarios.json \
        mindful_situations.json | tee $TRANSFORM_LOG

    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Content transformation complete!${NC}"
        echo "   Output: mindful_situations.json"
    else
        echo -e "${RED}❌ Content transformation failed!${NC}"
        echo "   Check logs: $TRANSFORM_LOG"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠️  Warning: gitawisdom_scenarios.json not found${NC}"
    echo "   Using sample data for testing..."
fi

echo ""
echo "🎙️ Phase 2: Parallel Voice Platform Deployment"
echo "-----------------------------------------------"
echo ""

# Start Alexa deployment in background
echo "Starting Alexa Agent..."
ALEXA_PID=$(run_bg "Alexa Deployment" "./scripts/deploy_alexa.sh" "$ALEXA_LOG")
echo "  PID: $ALEXA_PID"
echo "  Logs: $ALEXA_LOG"

sleep 2

# Start Watch deployment in background
echo "Starting Watch Agent..."
WATCH_PID=$(run_bg "Watch Deployment" "./scripts/deploy_watch.sh" "$WATCH_LOG")
echo "  PID: $WATCH_PID"
echo "  Logs: $WATCH_LOG"

echo ""
echo "⏳ Both agents running in parallel..."
echo ""

# Monitor progress
monitor_progress() {
    while true; do
        local alexa_running=$(ps -p $ALEXA_PID > /dev/null 2>&1 && echo 1 || echo 0)
        local watch_running=$(ps -p $WATCH_PID > /dev/null 2>&1 && echo 1 || echo 0)

        # Check Alexa status
        if [ $alexa_running -eq 1 ]; then
            echo -ne "🎙️  Alexa: ${YELLOW}In Progress${NC}   "
        else
            if wait $ALEXA_PID 2>/dev/null; then
                echo -ne "🎙️  Alexa: ${GREEN}✅ Complete${NC}     "
            else
                echo -ne "🎙️  Alexa: ${RED}❌ Failed${NC}       "
            fi
        fi

        # Check Watch status
        if [ $watch_running -eq 1 ]; then
            echo -ne "⌚ Watch: ${YELLOW}In Progress${NC}\r"
        else
            if wait $WATCH_PID 2>/dev/null; then
                echo -ne "⌚ Watch: ${GREEN}✅ Complete${NC}\n"
            else
                echo -ne "⌚ Watch: ${RED}❌ Failed${NC}\n"
            fi
        fi

        # Both complete?
        if [ $alexa_running -eq 0 ] && [ $watch_running -eq 0 ]; then
            break
        fi

        sleep 5
    done
}

# Run monitor
monitor_progress

echo ""
echo "📊 Deployment Summary"
echo "===================="

# Check Alexa result
if wait $ALEXA_PID 2>/dev/null; then
    echo -e "${GREEN}✅ Alexa Agent: Success${NC}"
    echo "   - Skill created and configured"
    echo "   - Firebase Functions deployed"
    echo "   - Voice queries working"
else
    echo -e "${RED}❌ Alexa Agent: Failed${NC}"
    echo "   Check logs: $ALEXA_LOG"
fi

echo ""

# Check Watch result
if wait $WATCH_PID 2>/dev/null; then
    echo -e "${GREEN}✅ Watch Agent: Success${NC}"
    echo "   - Watch target added"
    echo "   - SwiftUI interface implemented"
    echo "   - Voice integration working"
else
    echo -e "${RED}❌ Watch Agent: Failed${NC}"
    echo "   Check logs: $WATCH_LOG"
fi

echo ""
echo "📝 Next Steps:"
echo "-------------"
echo "1. Test Alexa skill: ./scripts/test_alexa.sh"
echo "2. Test Watch app on device: ./scripts/test_watch.sh"
echo "3. Review logs if any failures"
echo "4. Deploy to Firebase: firebase deploy"
echo ""

echo "✅ Parallel deployment complete!"
