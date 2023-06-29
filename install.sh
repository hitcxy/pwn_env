#!/bin/bash
# 环境变量
export DEBIAN_FRONTEND=noninteractive
export TZ=Asia/Shanghai
# 基础包
sudo apt update && sudo apt install -y --fix-missing python3 python3-pip python3-dev lib32z1 \
xinetd curl gcc gdb gdbserver g++ git libssl-dev libffi-dev build-essential tmux \
vim netcat iputils-ping cpio gdb-multiarch file net-tools socat ruby ruby-dev locales \
autoconf automake libtool make zsh openssh-server openssh-client ipython3 \
gdb-multiarch bison

# qemu相关, 需要的话取消注释
# sudo apt install qemu qemu-system qemu-user-static binfmt-support

# ruby包
sudo gem install one_gadget seccomp-tools

# python包
python3 -m pip install --upgrade pip && \
pip3 install ropper capstone unicorn keystone-engine z3-solver qiling lief libnum pycryptodome angr && \
cd $HOME/pwn_env 
git clone https://github.com/pwndbg/pwndbg && \
cd ./pwndbg && \
./setup.sh && \
cd $HOME/pwn_env && \
git clone https://github.com/hugsy/gef.git && \
git clone https://github.com/longld/peda.git && \
git clone https://github.com/RoderickChan/Pwngdb.git && \
git clone https://github.com/Gallopsled/pwntools && \
sudo pip3 install --upgrade --editable ./pwntools && \
git clone https://github.com/RoderickChan/pwncli.git && \
pip3 install --upgrade --editable ./pwncli && \
git clone https://github.com/marin-m/vmlinux-to-elf.git && \
git clone https://github.com/JonathanSalwan/ROPgadget.git && \
sudo python3 ./ROPgadget/setup.py install

# 安装patchelf和r2
git clone https://github.com/NixOS/patchelf.git && \
cd ./patchelf && \
./bootstrap.sh && \
./configure && \
make && \
sudo make install && \
cd $HOME/pwn_env && \
export version=$(curl -s https://api.github.com/repos/radareorg/radare2/releases/latest | grep -P '"tag_name": "(.*)"' -o| awk '{print $2}' | awk -F"\"" '{print $2}') && \
wget https://github.com/radareorg/radare2/releases/download/${version}/radare2_${version}_amd64.deb && \
sudo dpkg -i radare2_${version}_amd64.deb && rm radare2_${version}_amd64.deb


# 配置文件
cat > ~/.tmux.conf << "EOF"
set -g prefix C-a
unbind C-b
bind C-a send-prefix

set-option -g prefix2 `
set-option -g mouse on

unbind '"'
bind - splitw -v -c '#{pane_current_path}' # 垂直方向新增面板，默认进入当前目录
unbind %
bind = splitw -h -c '#{pane_current_path}' # 水平方向新增面板，默认进入当前目录

# 绑定hjkl键为面板切换的上下左右键
bind -r k select-pane -U # 绑定k为↑
bind -r j select-pane -D # 绑定j为↓
bind -r h select-pane -L # 绑定h为←
bind -r l select-pane -R # 绑定l为→

set -g default-terminal "screen-256color"
set -g history-limit 5000

bind j resize-pane -D 10
bind k resize-pane -U 10
bind h resize-pane -L 10
bind l resize-pane -R 10

setw -g automatic-rename off
setw -g allow-rename off

setw -g mode-keys vi
EOF

# 安装musl
sudo apt install musl-dev musl-tools
cd $HOME/pwn_env
wget https://musl.libc.org/releases/musl-1.2.3.tar.gz
tar -xvzf musl-1.2.3.tar.gz
cd musl-1.2.3
CC="gcc" CXX="g++" CFLAGS="-g -g3 -ggdb -gdwarf-4 -Og -Wno-error -z now" CXXFLAGS="-g -g3 -ggdb -gdwarf-4 -Og -Wno-error -z now" ./configure --enable-debug --disable-werror
make -j8
sudo make install

# 安装zsh
export HUB_DOMAIN=github.com
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions && \
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting && \
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions


cat > ~/.zshrc << "EOF"
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
if [ ! "$TMUX" = "" ]; then export TERM=xterm-256color; fi # auto-suggestion in tmux
export ZSH="$HOME/.oh-my-zsh"
export PATH=$PATH:$HOME/.local/bin:$HOME/.cargo/bin
# alias rm='echo "This is not the command you are looking for. Use trash-put instead.";false'
# alias trp=trash-put
# alias tre=trash-empty
# alias trl=trash-list
# alias trr=trash-restore
# alias trm=trash-rm
alias openaslr="sudo -u root sh -c 'echo 2 >/proc/sys/kernel/randomize_va_space'"
alias closeaslr="sudo -u root sh -c 'echo 0 >/proc/sys/kernel/randomize_va_space'"
# alias cat=ccat
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="ys"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting z sudo extract docker rand-quote tmux colored-man-pages zsh-autosuggestions colorize)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
EOF
