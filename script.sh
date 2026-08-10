set -a
source .env
set +a
rm -rf "$PATH_NVIM_CONFIG"
mkdir -p "$PATH_NVIM_CONFIG"
cp -r * $pwd "$PATH_NVIM_CONFIG"
cp .env "$PATH_NVIM_CONFIG"