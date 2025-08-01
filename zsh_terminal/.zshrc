[[ $- != *i* ]] && return

# Konfigurasi editor dan environment
export VISUAL="${EDITOR}"
export EDITOR='geany'
export HISTORY_IGNORE="(ls|cd|pwd|exit|sudo reboot|history|cd -|cd)"
export SUDO_PROMPT=$'\e[1;31m[ root access for %u]\e[0m Password: '
export BAT_THEME="Monokai Extended Bright"

# Menambahkan local bin ke PATH
if [ -d "$HOME/.local/bin" ] ;
  then PATH="$HOME/.local/bin:$PATH"
fi

# Inisialisasi completion system
autoload -Uz compinit
zmodload zsh/complist

# Mengoptimalkan waktu loading completion dan memastikan cache completion dibuat
if [[ -n ${HOME}/.config/zsh/zcompdump(#qN.mh+24) ]]; then
  compinit -d ~/.config/zsh/zcompdump
else
  compinit -C -d ~/.config/zsh/zcompdump
fi

# Memuat modul yang diperlukan
autoload -Uz add-zsh-hook
autoload -Uz vcs_info
precmd () { vcs_info }
_comp_options+=(globdots)

# Konfigurasi completion yang lebih bagus
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$HOME/.cache/zsh/.zcompcache"
zstyle ':completion:*' verbose true
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS} 'ma=48;5;197;1'
zstyle ':completion:*' matcher-list \
    'm:{a-zA-Z}={A-Za-z}' \
    'r:|[._-]=* r:|=*' \
    'l:|=* r:|=*'
zstyle ':completion:*:warnings' format "%B%F{red}No matches for:%f %F{magenta}%d%b"
zstyle ':completion:*:descriptions' format '%F{yellow}[-- %d --]%f'
zstyle ':vcs_info:*' formats ' %B%s-[%F{magenta}%f %F{yellow}%b%f]-'

# Animasi loading saat completion
expand-or-complete-with-dots() {
  echo -n "\e[31m…\e[0m"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

# Konfigurasi history untuk berbagi antar tab terminal dan window
HISTFILE=~/.config/zsh/zhistory
HISTSIZE=50000
SAVEHIST=50000
HISTDUP=erase

# Mengaktifkan fitur berbagi history
setopt INC_APPEND_HISTORY        # Menulis ke histfile segera
setopt SHARE_HISTORY            # Berbagi history antar session
setopt HIST_EXPIRE_DUPS_FIRST   # Hapus duplikat pertama saat histfile penuh
setopt HIST_IGNORE_DUPS         # Tidak menyimpan perintah yang sama berurutan
setopt HIST_IGNORE_ALL_DUPS     # Hapus entri lama jika ada yang baru sama
setopt HIST_FIND_NO_DUPS        # Tidak menampilkan duplikat saat pencarian
setopt HIST_SAVE_NO_DUPS        # Tidak menyimpan duplikat
setopt HIST_VERIFY              # Tampilkan perintah sebelum eksekusi dari history

# Opsi tambahan untuk pengalaman yang lebih baik
setopt AUTOCD              # Pindah direktori cukup ketik namanya
setopt PROMPT_SUBST        # Mengaktifkan substitusi perintah di prompt
setopt MENU_COMPLETE       # Highlight otomatis elemen pertama menu completion
setopt LIST_PACKED         # Menu completion lebih ringkas
setopt AUTO_LIST          # List otomatis pilihan saat completion ambigu
setopt COMPLETE_IN_WORD    # Complete dari kedua ujung kata
setopt EXTENDED_GLOB       # Mengaktifkan extended globbing
setopt NO_CASE_GLOB       # Case insensitive globbing

# Fungsi untuk ikon direktori di prompt
function dir_icon {
  if [[ "$PWD" == "$HOME" ]]; then
    echo "%B%F{cyan}󰋜%f%b"
  else
       echo "%B%F{cyan}%f%b"
  fi
}

# Prompt yang lebih keren dengan ikon
PS1='%B%F{blue}󰣇%f%b  %B%F{magenta}%n%f%b $(dir_icon)  %B%F{red}%~%f%b${vcs_info_msg_0_} %(?.%B%F{green}󰄬 >.%F{red}󰅙 >)%f%b '


command_not_found_handler() {
  local pkgs cmd="$1"

  pkgs=(${(f)"$(pkgfile -b -v -- "$cmd" 2>/dev/null)"})
  if [[ -n "$pkgs" ]]; then
    # Menampilkan pesan error dengan warna
    printf '\033[1;31mzsh:\033[0m \033[1;33mcommand\033[0m %s  \033[1;31mnot found\n' "$cmd"

    # Saran paket yang mungkin dimaksud
    printf 'Maybe you meant:\n'
    printf '  \033[1;32m%s\033[0m is provided by:\n' "$cmd"

    for pkg in $pkgs; do
      printf '    \033[1;36m%s\033[0m\n' "$pkg"
    done
  else
    printf '\033[1;31mzsh: command not found:\033[0m %s\n' "$cmd"
  fi 1>&2

  return 127
}

# Plugin ZSH
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null
source /usr/share/zsh/plugins/zsh-history-substring-search/zsh-history-substring-search.zsh 2>/dev/null

# Keybinding
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[3~' delete-char
bindkey '^[[Z' reverse-menu-complete  # Shift-Tab untuk mundur dalam menu completion

# Fungsi untuk judul terminal
function xterm_title_precmd () {
    print -Pn -- '\e]2;%n@%m %~\a'
    [[ "$TERM" == 'screen'* ]] && print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-}\e\\'
}

function xterm_title_preexec () {
    print -Pn -- '\e]2;%n@%m %~ %# ' && print -n -- "${(q)1}\a"
    [[ "$TERM" == 'screen'* ]] && { print -Pn -- '\e_\005{g}%n\005{-}@\005{m}%m\005{-} \005{B}%~\005{-} %# ' && print -n -- "${(q)1}\e\\"; }
}

if [[ "$TERM" == (kitty*|alacritty*|tmux*|screen*|xterm*) ]]; then
    add-zsh-hook -Uz precmd xterm_title_precmd
    add-zsh-hook -Uz preexec xterm_title_preexec
fi

# Alias berguna
alias update="paru -Syu --nocombinedupgrade"
alias grub-update="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias music="ncmpcpp"
alias cat="bat --theme='Monokai Extended Bright' --paging=never "
alias ls='eza --icons=always --color=always -a'
alias ll='eza --icons=always --color=always -la'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias diff='diff --color=auto'
alias cats='/sbin/cat'
alias server='sudo systemctl start nginx && systemctl start php-fpm && systemctl start mariadb'
# Konfigurasi syntax highlighting
ZSH_HIGHLIGHT_STYLES[path]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[command-substitution]='fg=magenta'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=yellow,bold'
export PATH="$HOME/.config/herd-lite/bin:$PATH"
export PHP_INI_SCAN_DIR="$HOME/.config/herd-lite/bin:$PHP_INI_SCAN_DIR"
export PATH=$PATH:$HOME/.local/bin
export PATH=$PATH:$HOME/.local/bin
