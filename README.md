# dotfiles

Configuração do meu Arch + KDE Plasma, recriável com scripts (sem Stow, Ansible ou Nix).

    git clone <repo> ~/.dotfiles && ~/.dotfiles/install.sh

## Uso

    ./install.sh          # menu: escolha os módulos pelo número, ou 'a' para todos
    ./install.sh --all    # instala tudo, sem perguntar
    ./install.sh --list   # só lista os módulos

Sempre roda antes, mesmo sem escolher nada: `scripts/00-base.sh` (git, base-devel, yay)
e `scripts/10-pacman.sh` (pacman.conf: Color, ILoveCandy, multilib).
Depois: listas de pacotes (pacman, depois AUR) e então os scripts, em ordem numérica.
Os scripts são idempotentes: pode rodar mais de uma vez.

## Módulos

| Módulo | O que faz |
|---|---|
| `packages/core.txt`, `fonts.txt`, `gaming.txt`, `theme.txt` | Pacotes do repositório oficial, por tema |
| `packages/aur.txt`, `aur-theme.txt`, `aur-gaming.txt` | Pacotes do AUR (via yay) |
| `scripts/20-zsh.sh` | zsh, plugins, `~/.zshrc`, shell padrão |
| `scripts/25-terminal.sh` | tmux, alacritty, mise, fonte Hack; links das configs |
| `scripts/30-mise.sh` | linguagens via mise (`mise/config.toml`) |
| `scripts/35-git.sh` | identidade global do git |
| `scripts/40-nvim.sh` | neovim + config (github.com/magnuspedro/nvim) |
| `scripts/50-keyboard.sh` | US internacional (acentos) + Alt/Win trocados, como no Mac |
| `scripts/60-defaults.sh` | alacritty como terminal padrão |
| `scripts/65-theme.sh` | tema Gruvbox Dark no KDE (cores, ícones, cursor, Kvantum, GTK, wallpaper, lock screen) |
| `scripts/70-desktops.sh` | 5 áreas de trabalho virtuais |
| `scripts/80-panel.sh` | menu global no topo, dock com auto-hide, botões à esquerda, Overview em Ctrl+↑ |

## Estrutura

    alacritty/  atac/  mise/  tmux/  zsh/   configs, ligadas por symlink no $HOME
    packages/                               listas de pacotes (uma por tema)
    scripts/                                passos de instalação, numerados pela ordem

## Regras

- Scripts idempotentes, numerados pela ordem de execução.
- Sem segredos no repo.
- Pacote novo: adicione na lista do tema certo em `packages/`, não dentro de um script.
- Ajustes do KDE (teclado, tema, painel) ficam em scripts; o KWin e o Plasma só
  recarregam parte deles ao vivo, o resto vale após um novo login.
- Tema e painel dependem dos pacotes de `theme.txt` e `aur-theme.txt`.
- Os `.dot` do Mac não são usados aqui: só as configs foram copiadas e adaptadas ao Linux.
