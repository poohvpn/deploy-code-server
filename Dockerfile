# Start from the code-server Debian base image
FROM codercom/code-server:3.10.2

USER coder

# Apply VS Code settings
COPY deploy-container/settings.json .local/share/code-server/User/settings.json

# Use bash shell
ENV SHELL=/bin/bash

# Install unzip + rclone (support for remote filesystem)
RUN sudo apt-get update && sudo apt-get install unzip -y
RUN curl https://rclone.org/install.sh | sudo bash

# Copy rclone tasks to /tmp, to potentially be used
COPY deploy-container/rclone-tasks.json /tmp/rclone-tasks.json

# Fix permissions for code-server
RUN sudo chown -R coder:coder /home/coder/.local

# You can add custom software and dependencies for your environment below
# -----------

# Install a VS Code extension:
# Note: we use a different marketplace than VS Code. See https://github.com/cdr/code-server/blob/main/docs/FAQ.md#differences-compared-to-vs-code
# RUN code-server --install-extension esbenp.prettier-vscode

# Install Build Tools
RUN sudo apt-get install -y build-essential

# Install Golang
RUN curl https://dl.google.com/go/go1.16.6.linux-amd64.tar.gz -o /tmp/go.tar.gz &&\
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz &&\
    rm /tmp/go.tar.gz
ENV PATH="${PATH}:/usr/local/go/bin"

# Configure Git
RUN git clone https://github.com/poohvpn/script /home/coder/script
RUN git config --global core.hooksPath /home/coder/script/git-hooks &&\
    sudo git config --global core.hooksPath /home/coder/script/git-hooks

# Copy files: 
# COPY deploy-container/myTool /home/coder/myTool

# -----------

# Port
ENV PORT=8080

# Use our custom entrypoint script first
COPY deploy-container/entrypoint.sh /usr/bin/deploy-container-entrypoint.sh
ENTRYPOINT ["/usr/bin/deploy-container-entrypoint.sh"]
