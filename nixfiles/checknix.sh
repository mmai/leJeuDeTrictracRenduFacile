GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

if ! command -v nix &> /dev/null; then
  echo -e "${RED}\xE2\x9D\x8C Nix non trouvé${RESET}"
  echo "Veuillez installer nix https://nixos.org/guides/install-nix.html"
  exit 1
else
  echo -e "${GREEN}\xE2\x9C\x94 Nix est installé${RESET}"


  if ! `nix flake --help &>/dev/null` ; then
    echo -e "${RED}\xE2\x9D\x8C Nix flake non disponible${RESET}"
    echo "Veuillez configurer nix flake https://nixos.wiki/wiki/Flakes"
    exit 1
  fi
  echo -e "${GREEN}\xE2\x9C\x94 Nix flake activé${RESET}"

fi
