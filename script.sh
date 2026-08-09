set -a
source .env
set +a
rm -rf "$PATH_NVIM_CONFIG"
mkdir -p "$PATH_NVIM_CONFIG"
cp -r * . "$PATH_NVIM_CONFIG"
