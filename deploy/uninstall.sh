#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$ROOT_DIR/.env"
COMPOSE_FILE="$ROOT_DIR/deploy/docker-compose.yml"
PURGE_DATA=false

usage() {
  cat <<'USAGE'
Usage:
  ./deploy/uninstall.sh [--purge-data]

Default behavior:
  - Stop platform compose containers
  - Preserve .env
  - Preserve data/
  - Preserve sources/
  - Do not modify firewall or system SSH configuration

Options:
  --purge-data    Delete data/ after stopping containers. Use carefully.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --purge-data)
      PURGE_DATA=true
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker not found; nothing to stop."
  exit 0
fi

compose_cmd() {
  if docker compose version >/dev/null 2>&1; then
    docker compose --project-directory "$ROOT_DIR" "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose --project-directory "$ROOT_DIR" "$@"
  else
    echo "Docker Compose not found; cannot stop compose services." >&2
    exit 1
  fi
}

if [ -f "$ENV_FILE" ]; then
  compose_cmd --env-file "$ENV_FILE" -f "$COMPOSE_FILE" --profile backend --profile frontend --profile agent down --remove-orphans || true
else
  compose_cmd -f "$COMPOSE_FILE" --profile backend --profile frontend --profile agent down --remove-orphans || true
fi

if [ "$PURGE_DATA" = true ]; then
  rm -rf "$ROOT_DIR/data"
  echo "Deleted data/ because --purge-data was provided."
else
  echo "Stopped platform containers. Data was preserved."
fi
