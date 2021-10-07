FROM archlinux:base
RUN pacman -Syu --noconfirm && pacman -S git wget jq opendoas ${USER_PKGS} --noconfirm

ARG RELEASE_TAG

WORKDIR /home/

# Downloading the latest VSC Server release
RUN wget https://github.com/gitpod-io/openvscode-server/releases/download/${RELEASE_TAG}/${RELEASE_TAG}-linux-x64.tar.gz

# Extracting the release archive
RUN tar -xzf ${RELEASE_TAG}-linux-x64.tar.gz

# product.json patch
RUN sed -i -e 's/^[[:blank:]]*"serviceUrl":.*/\t\t"serviceUrl": "https:\/\/marketplace.visualstudio.com\/_apis\/public\/gallery"\,/' \
    -e '/^[[:blank:]]*"cacheUrl/d' \
    -e '/^[[:blank:]]*"serviceUrl/a\\t\t"cacheUrl": "https:\/\/vscode.blob.core.windows.net\/gallery\/index"\,' \
    -e 's/^[[:blank:]]*"itemUrl":.*/\t\t"itemUrl": "https:\/\/marketplace.visualstudio.com\/items"/\,' \
    -e '/^[[:blank:]]*"linkProtectionTrustedDomains/d' \
    /home/${RELEASE_TAG}-linux-x64/product.json

RUN cat /home/${RELEASE_TAG}-linux-x64/product.json

# Creating the user and usergroup
RUN useradd vscode-server && \
    passwd -d vscode-server && \
    usermod -a -G vscode-server,wheel vscode-server && \
    echo "permit :wheel" > /etc/doas.conf

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

ENTRYPOINT ${OPENVSCODE_SERVER_ROOT}/server.sh
