FROM archlinux:base
RUN pacman -Syu --noconfirm && pacman -S git wget jq opendoas zsh ${USER_PKGS} --noconfirm
ENV SHELL=/bin/zsh

ARG RELEASE_TAG

WORKDIR /home/

# Downloading the latest VSC Server release
RUN curl -fsSL https://code-server.dev/install.sh | sh

# Patching product.json
#RUN cat <<< $(jq '.extensionsGallery |= . + {"serviceUrl": "https://marketplace.visualstudio.com/_apis/public/gallery","cacheUrl": "https://vscode.blob.core.windows.net/gallery/index","itemUrl": "https://marketplace.visualstudio.com/items","resourceUrlTemplate": "https://{publisher}.vscode-unpkg.net/{publisher}/{name}/{version}/{path}","controlUrl": "https://az764295.vo.msecnd.net/extensions/marketplace.json","recommendationsUrl": "https://az764295.vo.msecnd.net/extensions/workspaceRecommendations.json.gz"}' \
 #   /usr/lib/code/product.json) > /usr/lib/code/product.json

# Configering doas
#RUN echo "permit :wheel" > /etc/doas.conf

#ENV PORT=8080
