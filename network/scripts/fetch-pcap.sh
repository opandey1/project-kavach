#!/usr/bin/env bash
#
# fetch-pcap.sh — Fetch and verify the Nemotodes PCAP for Workstream A.
#
# Downloads Brad Duncan's 2024-11-26 traffic analysis exercise from
# Malware-Traffic-Analysis.net, extracts the PCAP and Suricata-style alerts,
# and verifies the SHA-256 of the PCAP against a recorded baseline.
#
# Source:    https://www.malware-traffic-analysis.net/2024/11/26/index.html
# Licence:   Educational use; attribution to Brad Duncan / MTA preserved.
#
# Password handling:
#   The MTA zip files are password-protected. The current password is
#   documented on the "about" page of malware-traffic-analysis.net.
#   Provide it via the MTA_PASSWORD environment variable to skip the
#   interactive prompt:
#
#       MTA_PASSWORD='<password>' ./scripts/fetch-pcap.sh
#
# Outputs (relative to network/):
#   2024-11-26-traffic-analysis-exercise.pcap
#   alerts/        (contents of the alerts zip)
#
# Exit codes:
#   0  success (download, extraction, and SHA-256 verification passed)
#   1  setup error (missing dependency, no password, etc.)
#   2  SHA-256 mismatch — capture differs from the locked baseline
#

set -euo pipefail

# ----- Configuration -------------------------------------------------------

readonly PCAP_URL="https://www.malware-traffic-analysis.net/2024/11/26/2024-11-26-traffic-analysis-exercise.pcap.zip"
readonly ALERTS_URL="https://www.malware-traffic-analysis.net/2024/11/26/2024-11-26-traffic-analysis-exercise-alerts.zip"

readonly PCAP_ZIP_NAME="2024-11-26-traffic-analysis-exercise.pcap.zip"
readonly ALERTS_ZIP_NAME="2024-11-26-traffic-analysis-exercise-alerts.zip"
readonly PCAP_FILE_NAME="2024-11-26-traffic-analysis-exercise.pcap"

# Expected SHA-256 of the extracted PCAP.
# Leave empty on first run; the script will compute and print the value.
# After the first run, paste the printed value here and update pcap-selection.md
# so a future reviewer can verify they downloaded the same file.
readonly EXPECTED_SHA256=""

# ----- Setup ---------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NETWORK_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ALERTS_DIR="$NETWORK_DIR/alerts"

log()  { echo "[fetch-pcap] $*"; }
fail() { echo "[fetch-pcap] error: $*" >&2; exit 1; }

for cmd in curl unzip sha256sum awk; do
    command -v "$cmd" >/dev/null 2>&1 \
        || fail "required command '$cmd' is not installed."
done

# ----- Password ------------------------------------------------------------

if [[ -z "${MTA_PASSWORD:-}" ]]; then
    echo
    echo "  The MTA zip files are password-protected."
    echo "  See the 'about' page of malware-traffic-analysis.net for the current password."
    echo
    read -srp "  Password: " MTA_PASSWORD
    echo
fi
[[ -n "$MTA_PASSWORD" ]] || fail "no password provided."

# ----- Download ------------------------------------------------------------

fetch() {
    local url="$1" name="$2"
    local out="$NETWORK_DIR/$name"
    if [[ -f "$out" ]]; then
        log "skip download: $name already present."
        return 0
    fi
    log "download: $name"
    curl -fsSL --retry 3 --retry-delay 2 -o "$out" "$url" \
        || fail "download failed: $url"
}

fetch "$PCAP_URL"   "$PCAP_ZIP_NAME"
fetch "$ALERTS_URL" "$ALERTS_ZIP_NAME"

# ----- Extract -------------------------------------------------------------

extract_pcap() {
    if [[ -f "$NETWORK_DIR/$PCAP_FILE_NAME" ]]; then
        log "skip extract: $PCAP_FILE_NAME already present."
        return 0
    fi
    log "extract: $PCAP_ZIP_NAME"
    unzip -P "$MTA_PASSWORD" -o "$NETWORK_DIR/$PCAP_ZIP_NAME" \
            -d "$NETWORK_DIR" >/dev/null 2>&1 \
        || fail "PCAP extraction failed — wrong password, or zip is corrupted."
}

extract_alerts() {
    if [[ -d "$ALERTS_DIR" ]] && [[ -n "$(ls -A "$ALERTS_DIR" 2>/dev/null)" ]]; then
        log "skip extract: alerts/ already populated."
        return 0
    fi
    log "extract: $ALERTS_ZIP_NAME → alerts/"
    mkdir -p "$ALERTS_DIR"
    unzip -P "$MTA_PASSWORD" -o "$NETWORK_DIR/$ALERTS_ZIP_NAME" \
            -d "$ALERTS_DIR" >/dev/null 2>&1 \
        || fail "alerts extraction failed — wrong password, or zip is corrupted."
}

extract_pcap
extract_alerts

# ----- Verify --------------------------------------------------------------

computed_sha="$(sha256sum "$NETWORK_DIR/$PCAP_FILE_NAME" | awk '{print $1}')"

echo
if [[ -z "$EXPECTED_SHA256" ]]; then
    cat <<EOF
[fetch-pcap] first run — no expected SHA-256 configured.

  Computed SHA-256: $computed_sha

  Action required to lock reproducibility:
    1. Edit this script and set:
         EXPECTED_SHA256="$computed_sha"
    2. Update network/pcap-selection.md §1 and §6 with the same hash.
    3. Re-run this script to confirm verification works end-to-end.

EOF
elif [[ "$computed_sha" == "$EXPECTED_SHA256" ]]; then
    log "sha-256 verified: $computed_sha"
else
    echo "[fetch-pcap] error: sha-256 mismatch." >&2
    echo "  expected: $EXPECTED_SHA256" >&2
    echo "  got:      $computed_sha" >&2
    exit 2
fi

log "done."
log "  pcap:   $NETWORK_DIR/$PCAP_FILE_NAME"
log "  alerts: $ALERTS_DIR/"
