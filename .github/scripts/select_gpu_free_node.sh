#!/usr/bin/env bash
set -euo pipefail

# Priority-ordered list of allowed nodes
PRIORITY_NODES=("mary" "kx-01" "kx-02" "bb-8" "bb-9" "marvin")

# Default values
PVE_HOST="${PVE_HOST:-https://127.0.0.1:8006}"
PVE_TOKEN_ID="${PVE_TOKEN_ID:-root@pam!mytoken}"
PVE_TOKEN_SECRET="${PVE_TOKEN_SECRET:-00000000-0000-0000-0000-000000000000}"
INSECURE_SSL="${INSECURE_SSL:-true}"
VERBOSE="${VERBOSE:-false}"

usage() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  -H, --host URL          Proxmox API endpoint (default: https://127.0.0.1:8006)
  -i, --token-id ID       PVE Token ID (default: root@pam!mytoken)
  -s, --token-secret SEC  PVE Token Secret
  -v, --verbose, --debug  Enable debug logging output to stderr
  -k, --insecure          Disable SSL certificate verification (default: true)
  --secure                Enable SSL certificate verification
  -h, --help              Show this help message
EOF
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    -H|--host)          PVE_HOST="$2"; shift 2 ;;
    -i|--token-id)      PVE_TOKEN_ID="$2"; shift 2 ;;
    -s|--token-secret)  PVE_TOKEN_SECRET="$2"; shift 2 ;;
    -v|--verbose|-d|--debug) VERBOSE="true"; shift ;;
    -k|--insecure)      INSECURE_SSL="true"; shift ;;
    --secure)           INSECURE_SSL="false"; shift ;;
    -h|--help)          usage; exit 0 ;;
    *)                  echo "Error: Unknown option '$1'" >&2; usage >&2; exit 1 ;;
  esac
done

log_debug() {
  if [[ "${VERBOSE}" == "true" ]]; then
    echo -e "[DEBUG] $*" >&2
  fi
}

# Pre-flight binary checks
for cmd in curl jq grep; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: Required binary '$cmd' is not installed." >&2
    exit 1
  fi
done

CURL_ARGS=(-s -S)
if [[ "${INSECURE_SSL}" == "true" ]]; then
  CURL_ARGS+=(-k)
fi

AUTH_HEADER="Authorization: PVEAPIToken=${PVE_TOKEN_ID}=${PVE_TOKEN_SECRET}"

api_get() {
  local path="$1"
  curl "${CURL_ARGS[@]}" \
    -H "$AUTH_HEADER" \
    "${PVE_HOST}/api2/json${path}"
}

# 1. Query Proxmox Cluster Resources
log_debug "Connecting to Proxmox API at ${PVE_HOST} as ${PVE_TOKEN_ID}..."
RESOURCES_JSON=$(api_get "/cluster/resources" 2>/dev/null) || {
  echo "Error: Failed to connect to Proxmox API at ${PVE_HOST}" >&2
  exit 1
}

if ! echo "$RESOURCES_JSON" | jq -e '.data' >/dev/null 2>&1; then
  echo "Error: Invalid response from Proxmox API. Verify credentials and permissions." >&2
  exit 1
fi

# 2. Extract online node names
ONLINE_NODES=$(echo "$RESOURCES_JSON" | jq -r '.data[] | select(.type == "node" and .status == "online") | .node')
log_debug "Online nodes detected: $(echo "$ONLINE_NODES" | xargs)"

# 3. Extract running QEMU VMs
RUNNING_VMS=$(echo "$RESOURCES_JSON" | jq -r '.data[] | select(.type == "qemu" and .status == "running") | "\(.node) \(.vmid)"')

# 4. Identify nodes actively hosting running VMs with 'hostpci' devices
BUSY_GPU_NODES=()

if [[ -n "$RUNNING_VMS" ]]; then
  while read -r node vmid; do
    [[ -z "$node" || -z "$vmid" ]] && continue

    log_debug "Checking VM ${vmid} on node '${node}' for GPU passthrough..."
    VM_CONFIG=$(api_get "/nodes/${node}/qemu/${vmid}/config" 2>/dev/null) || continue

    HAS_GPU=$(echo "$VM_CONFIG" | jq -r '.data // {} | keys[]? | select(startswith("hostpci"))' 2>/dev/null | head -n 1)

    if [[ -n "$HAS_GPU" ]]; then
      log_debug " -> VM ${vmid} on node '${node}' has GPU passthrough device (${HAS_GPU})"
      BUSY_GPU_NODES+=("$node")
    fi
  done <<< "$RUNNING_VMS"
fi

# Deduplicate busy nodes list for log clarity
BUSY_GPU_NODES=($(printf "%s\n" "${BUSY_GPU_NODES[@]}" 2>/dev/null | sort -u))
log_debug "Nodes currently running GPU passthrough VMs: [${BUSY_GPU_NODES[*]:-none}]"

# 5. Evaluate nodes in strict priority order
SELECTED_NODE=""

log_debug "Evaluating priority node list: [${PRIORITY_NODES[*]}]"
for node in "${PRIORITY_NODES[@]}"; do
  log_debug "Evaluating node '${node}'..."

  # Skip node if offline/missing
  if ! echo "$ONLINE_NODES" | grep -q -x "$node"; then
    log_debug " -> '${node}' is offline or not part of the cluster. Skipping."
    continue
  fi

  # Skip node if running a GPU passthrough VM
  IS_BUSY=false
  if [[ ${#BUSY_GPU_NODES[@]} -gt 0 ]]; then
    for busy_node in "${BUSY_GPU_NODES[@]}"; do
      if [[ "$busy_node" == "$node" ]]; then
        IS_BUSY=true
        break
      fi
    done
  fi

  if [[ "$IS_BUSY" == "true" ]]; then
    log_debug " -> '${node}' is running an active GPU VM. Skipping."
    continue
  fi

  log_debug " -> '${node}' is online and free of active GPU VMs. Selected!"
  SELECTED_NODE="$node"
  break
done

# Output result
if [[ -n "$SELECTED_NODE" ]]; then
  echo "$SELECTED_NODE"
  exit 0
else
  echo "Error: No online priority node found without active GPU passthrough VMs." >&2
  exit 1
fi
