#!/usr/bin/env bash
set -euo pipefail

# Collect logs on each fleet host with multiple ansible shell calls, then copy logs via scp.
#
# Usage:
#   ./fetch_logs.bash [inventory] [output_dir]
#
# Environment variables:
#   HOSTS                  Space-separated host aliases (default: auto-discover fleet group, fallback manager member0 member1)
#   REMOTE_BASE            Base directory on remote hosts (default: /tmp/qa_logs)
#   SSH_TARGET_USER        If set, scp uses SSH_TARGET_USER@<host>
#   STRICT_HOST_KEY_CHECK  yes/no (default: no)
#   LOG_WINDOW             journalctl window (default: 1hour ago)

INVENTORY="${1:-./staging/provisioned_inventory.yml}"
OUTPUT_DIR="${2:-./qa_artifacts_test}"
REMOTE_BASE="${REMOTE_BASE:-/tmp/qa_logs}"
SSH_TARGET_USER="${SSH_TARGET_USER:-}"
STRICT_HOST_KEY_CHECK="${STRICT_HOST_KEY_CHECK:-no}"
LOG_WINDOW="${LOG_WINDOW:-1hour ago}"

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

run_ansible() {
	local host="$1"
	local cmd="$2"
	ansible "$host" -i "$INVENTORY" -m shell -a "$cmd"
}

mkdir -p "$OUTPUT_DIR"
FAILURES_FILE="$OUTPUT_DIR/collection_failures.txt"
: > "$FAILURES_FILE"

if [[ ! -f "$INVENTORY" ]]; then
	echo "ERROR: Inventory file not found: $INVENTORY" >&2
	exit 1
fi

if [[ -z "${HOSTS:-}" ]]; then
	HOSTS="$(ansible fleet -i "$INVENTORY" --list-hosts 2>/dev/null | tail -n +2 | xargs || true)"
fi

if [[ -z "$HOSTS" ]]; then
	HOSTS="manager member0 member1"
	echo "WARN: Could not discover fleet group; using fallback hosts: $HOSTS" | tee -a "$FAILURES_FILE"
fi

echo "Inventory: $INVENTORY"
echo "Output:    $OUTPUT_DIR"
echo "Hosts:     $HOSTS"
echo "Window:    $LOG_WINDOW"

total_hosts=0
failed_hosts=0

for host in $HOSTS; do
	total_hosts=$((total_hosts + 1))
	log "==> [$host] prepare remote folder"
	remote_dir="$REMOTE_BASE/$host"
	host_failed=0

	if ! run_ansible "$host" "mkdir -p '$remote_dir'" >> "$OUTPUT_DIR/ansible_collect.log" 2>> "$OUTPUT_DIR/ansible_collect.err"; then
		echo "ansible mkdir failed on host=$host" >> "$FAILURES_FILE"
		host_failed=1
	fi

	log "==> [$host] collect movai-service journal"
	if ! run_ansible "$host" "journalctl -u movai-service --since '$LOG_WINDOW' > '$remote_dir/movai-service.log' 2>&1 || true" >> "$OUTPUT_DIR/ansible_collect.log" 2>> "$OUTPUT_DIR/ansible_collect.err"; then
		echo "ansible movai-service journal failed on host=$host" >> "$FAILURES_FILE"
		host_failed=1
	fi

	log "==> [$host] collect docker ps and docker journal"
	if ! run_ansible "$host" "docker ps -a --no-trunc > '$remote_dir/docker-ps.log' 2>&1 || true" >> "$OUTPUT_DIR/ansible_collect.log" 2>> "$OUTPUT_DIR/ansible_collect.err"; then
		echo "ansible docker ps failed on host=$host" >> "$FAILURES_FILE"
		host_failed=1
	fi
	if ! run_ansible "$host" "journalctl -u docker --boot --lines=all > '$remote_dir/docker-journal.log' 2>&1 || true" >> "$OUTPUT_DIR/ansible_collect.log" 2>> "$OUTPUT_DIR/ansible_collect.err"; then
		echo "ansible docker journal failed on host=$host" >> "$FAILURES_FILE"
		host_failed=1
	fi

	log "==> [$host] discover containers"
	container_out="$(ansible "$host" -i "$INVENTORY" -m shell -a "docker ps -a --format '{% raw %}{{.Names}}{% endraw %}'" 2>> "$OUTPUT_DIR/ansible_collect.err" || true)"
	containers="$(printf '%s\n' "$container_out" | awk 'found { print } />>/ { found=1 }' | sed '/^[[:space:]]*$/d' | sort -u)"

	container_total=0
	container_failed=0
	if [[ -z "$containers" ]]; then
		log "==> [$host] no containers found"
		echo "no containers found on host=$host" >> "$FAILURES_FILE"
	else
		while IFS= read -r container; do
			[[ -z "$container" ]] && continue
			container_total=$((container_total + 1))
			safe="$(echo "$container" | tr '/: ' '___' | tr -cd 'A-Za-z0-9._-')"
			[[ -z "$safe" ]] && safe="unnamed"

			log "==> [$host] collect container log: $container"
			if ! run_ansible "$host" "docker logs --timestamps '$container' > '$remote_dir/container-$safe.log' 2>&1 || echo 'docker logs failed: $container' >> '$remote_dir/failures.log'" >> "$OUTPUT_DIR/ansible_collect.log" 2>> "$OUTPUT_DIR/ansible_collect.err"; then
				echo "ansible docker logs command failed on host=$host container=$container" >> "$FAILURES_FILE"
				container_failed=$((container_failed + 1))
				host_failed=1
			fi
		done <<< "$containers"
	fi

	echo "host=$host containers_total=$container_total containers_failed=$container_failed remote_dir=$remote_dir" >> "$OUTPUT_DIR/host_summary.log"

	target_host="$host"
	if [[ -n "$SSH_TARGET_USER" ]]; then
		target_host="$SSH_TARGET_USER@$host"
	fi

	mkdir -p "$OUTPUT_DIR/$host"
	log "==> [$host] fetch logs with scp from: $target_host"

	scp -o "StrictHostKeyChecking=$STRICT_HOST_KEY_CHECK" -r \
		"$target_host:$REMOTE_BASE/$host/" \
		"$OUTPUT_DIR/$host/" >> "$OUTPUT_DIR/scp_fetch.log" 2>> "$OUTPUT_DIR/scp_fetch.err" || \
		{
			echo "scp fetch failed on host=$host" >> "$FAILURES_FILE"
			host_failed=1
		}

	if [[ $host_failed -eq 1 ]]; then
		failed_hosts=$((failed_hosts + 1))
		log "==> [$host] completed with warnings"
	else
		log "==> [$host] completed successfully"
	fi
done

log "Done. Local artifacts directory: $OUTPUT_DIR"
log "Failure summary (if any): $FAILURES_FILE"
log "Host totals: total=$total_hosts failed=$failed_hosts success=$((total_hosts - failed_hosts))"
