#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Download a StackGen CLI release binary.

Usage:
  download-stackgen.sh <version> <architecture> [options]

Arguments:
  version         Release version (e.g. 0.79.1 or v0.79.1)
  architecture    Target architecture: amd64 | arm64
                  Aliases: x86_64 -> amd64, aarch64 -> arm64

Options:
  -o, --os OS         Target OS: darwin | linux (default: auto-detect)
  -d, --dir DIR       Output directory (default: current directory)
  -O, --output NAME   Output binary name (default: stackgen)
  -h, --help          Show this help

Binary URL pattern (from homebrew-stackgen):
  https://releases.stackgen.com/binaries/stackgen-cli/v<version>/stackgen-cli_<version>_<os>_<arch>.tar.gz

Examples:
  download-stackgen.sh 0.79.1 arm64
  download-stackgen.sh v0.79.1 amd64 --os linux
  download-stackgen.sh 0.79.1 arm64 --dir /usr/local/bin
EOF
}

normalize_version() {
  local version="${1#v}"
  if [[ -z "${version}" ]]; then
    echo "error: version cannot be empty" >&2
    exit 1
  fi
  printf '%s' "${version}"
}

normalize_arch() {
  case "${1,,}" in
    amd64 | x86_64) printf '%s' "amd64" ;;
    arm64 | aarch64) printf '%s' "arm64" ;;
    *)
      echo "error: unsupported architecture '${1}' (expected amd64 or arm64)" >&2
      exit 1
      ;;
  esac
}

detect_os() {
  case "$(uname -s)" in
    Darwin) printf '%s' "darwin" ;;
    Linux) printf '%s' "linux" ;;
    *)
      echo "error: unsupported OS '$(uname -s)' (use --os darwin or --os linux)" >&2
      exit 1
      ;;
  esac
}

normalize_os() {
  case "${1,,}" in
    darwin | macos | osx) printf '%s' "darwin" ;;
    linux) printf '%s' "linux" ;;
    *)
      echo "error: unsupported OS '${1}' (expected darwin or linux)" >&2
      exit 1
      ;;
  esac
}

VERSION=""
ARCH=""
OS=""
OUT_DIR="."
OUT_NAME="stackgen"

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    -o | --os)
      [[ $# -ge 2 ]] || { echo "error: --os requires a value" >&2; exit 1; }
      OS="$2"
      shift 2
      ;;
    -d | --dir)
      [[ $# -ge 2 ]] || { echo "error: --dir requires a value" >&2; exit 1; }
      OUT_DIR="$2"
      shift 2
      ;;
    -O | --output)
      [[ $# -ge 2 ]] || { echo "error: --output requires a value" >&2; exit 1; }
      OUT_NAME="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "error: unknown option '$1'" >&2
      usage >&2
      exit 1
      ;;
    *)
      if [[ -z "${VERSION}" ]]; then
        VERSION="$1"
      elif [[ -z "${ARCH}" ]]; then
        ARCH="$1"
      else
        echo "error: unexpected argument '$1'" >&2
        usage >&2
        exit 1
      fi
      shift
      ;;
  esac
done

if [[ -z "${VERSION}" || -z "${ARCH}" ]]; then
  echo "error: version and architecture are required" >&2
  usage >&2
  exit 1
fi

VERSION="$(normalize_version "${VERSION}")"
ARCH="$(normalize_arch "${ARCH}")"
OS="${OS:-$(detect_os)}"
OS="$(normalize_os "${OS}")"

BASE_URL="https://releases.stackgen.com/binaries/stackgen-cli"
ARCHIVE="stackgen-cli_${VERSION}_${OS}_${ARCH}.tar.gz"
URL="${BASE_URL}/v${VERSION}/${ARCHIVE}"

mkdir -p "${OUT_DIR}"

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

echo "Downloading ${URL}"
curl -fsSL "${URL}" -o "${TMP_DIR}/${ARCHIVE}"

tar -xzf "${TMP_DIR}/${ARCHIVE}" -C "${TMP_DIR}"
install -m 0755 "${TMP_DIR}/stackgen" "${OUT_DIR}/${OUT_NAME}"

echo "Installed ${OUT_DIR}/${OUT_NAME} ($( "${OUT_DIR}/${OUT_NAME}" version 2>/dev/null || true ))"
