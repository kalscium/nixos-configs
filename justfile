# cleans and removes any unused packages from the nix store, it also removes all the past nixos generations
full-clean:
    sudo nix-collect-garbage -d
    sudo nix-store --optimise

# removes unnecessary nixos packages and also optimises the nixos store
clean:
	sudo nix-collect-garbage
	sudo nix-store --optimise
