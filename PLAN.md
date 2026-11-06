# Plano

1. **Base** (`scripts/00-base.sh`): git, base-devel, ferramentas CLI, yay, paccache.
2. **Pacotes**: listas em `packages/` (pacman e AUR), instaladas pelo `install.sh`.
3. **Sistema**: serviços systemd e ajustes em /etc (scripts numerados em `scripts/`).
4. **KDE Plasma**: copiar só os rc files alterados (kdeglobals, kwinrc, atalhos) para ~/.config.
5. **Dotfiles de usuário**: bash, git, etc., via symlink feito por script.

Regras: scripts idempotentes, numerados pela ordem de execução, sem segredos no repo.
