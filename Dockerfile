FROM kasmweb/core-ubuntu-jammy:1.15.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########


RUN apt update -y && apt install -y git sudo stow zsh build-essential procps curl file glibc-source
RUN git clone https://gitlab.com/developerdurp/dotfiles.git $HOME/.dotfiles
WORKDIR $HOME/.dotfiles
RUN stow --adopt . && git restore .

RUN useradd -m -s /bin/zsh linuxbrew && \
    usermod -aG sudo linuxbrew &&  \
    mkdir -p /home/linuxbrew/.linuxbrew && \
    chown -R linuxbrew: /home/linuxbrew/.linuxbrew

USER linuxbrew
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

USER root
RUN chown -R $CONTAINER_USER: /home/linuxbrew/.linuxbrew
ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
RUN git config --global --add safe.directory /home/linuxbrew/.linuxbrew/Homebrew

USER linuxbrew
RUN brew update
RUN brew doctor
RUN brew install neovim 

USER root
RUN chmod 755 -R /home/linuxbrew
######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
