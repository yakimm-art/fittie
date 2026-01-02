#!/bin/bash

# Local Development Environment Manager
# Start/stop local DynamoDB and related services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

command="$1"

case "$command" in
  start)
    echo "🚀 Starting local development environment..."
    cd "$PROJECT_ROOT"
    docker-compose up -d
    echo ""
    echo "⏳ Waiting for services to be ready..."
    sleep 3
    echo ""
    echo "📊 Initializing DynamoDB tables..."
    "$SCRIPT_DIR/init-local-dynamodb.sh"
    echo ""
    echo "✅ Local environment is ready!"
    echo ""
    echo "🔗 Services:"
    echo "   - DynamoDB Local: http://localhost:8000"
    echo "   - DynamoDB Admin: http://localhost:8001"
    ;;
    
  stop)
    echo "🛑 Stopping local development environment..."
    cd "$PROJECT_ROOT"
    docker-compose down
    echo "✅ Local environment stopped"
    ;;
    
  restart)
    echo "🔄 Restarting local development environment..."
    "$0" stop
    sleep 2
    "$0" start
    ;;
    
  status)
    echo "📊 Local environment status:"
    cd "$PROJECT_ROOT"
    docker-compose ps
    ;;
    
  logs)
    cd "$PROJECT_ROOT"
    docker-compose logs -f
    ;;
    
  *)
    echo "Usage: $0 {start|stop|restart|status|logs}"
    echo ""
    echo "Commands:"
    echo "  start   - Start local DynamoDB and initialize tables"
    echo "  stop    - Stop all local services"
    echo "  restart - Restart all local services"
    echo "  status  - Show status of local services"
    echo "  logs    - Show and follow logs from local services"
    exit 1
    ;;
esac
