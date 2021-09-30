FROM archlinux:latest
RUN pacman -Syu --noconfirm
RUN pacman -S git wget opendoas --noconfirm

ARG RELEASE_TAG

WORKDIR /home/

# Downloading the latest VSC Server release
RUN wget https://github.com/gitpod-io/openvscode-server/releases/download/${RELEASE_TAG}/${RELEASE_TAG}-linux-x64.tar.gz

# Extracting the release archive
RUN tar -xzf ${RELEASE_TAG}-linux-x64.tar.gz

# product.json patch
RUN wget https://raw.githubusercontent.com/timescam/openvscode-releases/main/patch.sh
RUN chmod +x patch.sh
RUN ./patch.sh

# Creating the user and usergroup
RUN useradd vscode-server && \
    passwd -d vscode-server && \
    usermod -a -G vscode-server,wheel vscode-server
RUN echo "permit :wheel" > /etc/doas.conf

RUN chmod g+rw /home && \
    mkdir -p /home/vscode && \
    mkdir -p /home/workspace && \
    chown -R vscode-server:vscode-server /home/workspace && \
    chown -R vscode-server:vscode-server /home/vscode && \
    chown -R vscode-server:vscode-server /home/${RELEASE_TAG}-linux-x64;

USER vscode-server

WORKDIR /home/workspace/

ENV HOME=/home/workspace
ENV EDITOR=code
ENV VISUAL=code
ENV GIT_EDITOR="code --wait"
ENV OPENVSCODE_SERVER_ROOT=/home/${RELEASE_TAG}-linux-x64

EXPOSE 3000
# Port 5555 for tabnine
EXPOSE 5555

ENTRYPOINT ${OPENVSCODE_SERVER_ROOT}/server.sh
