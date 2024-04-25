Dotfiles

basic configuration of standard tools like bash and vim



install-dotfiles

examples: 

bashrc
   - a file 
   - to be linked into ~/.bashrc

bin:
   - a folder
   - its contents (files) are linked into ~/.bin/

fish-config

    a file fish-config/config.fish is linked to ~/.config/fish/config.fish


USER-aliases  : 
   - a folder 
   - USER is a environent variable ('$USER') to be resolved
   - its contents are linked into ~/.$USER/fish


USER-vimutils.d
   - a folder 
   - USER is a environent variable ('$USER') to be resolved
   - the entire dir (.d) is linked into ~/.$USER/vimutils

