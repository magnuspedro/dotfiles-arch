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
| `packages/core.txt`, `fonts.txt`, `gaming.txt`, `theme.txt`, `bluetooth.txt` | Pacotes do repositório oficial, por tema |
| `packages/aur.txt`, `aur-theme.txt`, `aur-gaming.txt`, `aur-dock.txt` | Pacotes do AUR (via yay) |
| `scripts/15-bluetooth.sh` | habilita o serviço Bluetooth (bluez, bluedevil) |
| `scripts/20-zsh.sh` | zsh, plugins, `~/.zshrc`, shell padrão |
| `scripts/25-terminal.sh` | tmux, alacritty, mise, fonte Hack; links das configs |
| `scripts/30-mise.sh` | linguagens via mise (`mise/config.toml`: Go e Rust, com o cargo) |
| `scripts/35-git.sh` | identidade global do git |
| `scripts/40-nvim.sh` | neovim + config (github.com/magnuspedro/nvim) |
| `scripts/50-keyboard.sh` | teclado US internacional (acentos) |
| `scripts/55-compose.sh` | cedilha no US internacional (`' + c = ç`) via `~/.XCompose` |
| `scripts/60-defaults.sh` | alacritty como terminal padrão |
| `scripts/65-theme.sh` | tema Gruvbox Dark no KDE: cores (com `Complementary`, que a lock screen usa), ícones, cursor, Kvantum, GTK, wallpaper, splash e lock screen |
| `scripts/66-window-buttons.sh` | botões de janela estilo macOS nas cores Gruvbox (tema Aurorae gerado do WhiteSur-kde) |
| `scripts/70-desktops.sh` | 5 áreas de trabalho virtuais |
| `scripts/80-panel.sh` | barra de menu no topo (logo do Arch, menu global) e Overview em Ctrl+↑ |
| `scripts/85-latte.sh` | dock estilo Mac com Latte (zoom parabólico, esconde sozinha); layout em `latte/` |

## Estrutura

    alacritty/  atac/  mise/  tmux/  zsh/  xcompose/   configs, ligadas por symlink no $HOME
    plasma/look-and-feel/                  tema global Gruvbox (copiado para ~/.local/share/plasma)
    latte/                                 layout da dock do Latte
    icons/                                 logo do Arch em amarelo Gruvbox
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
