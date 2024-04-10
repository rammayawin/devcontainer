FROM node:changeme

# Install basic development tools
RUN apt update && apt install -y less sudo zip jq

# Ensure user has access to `sudo`
ENV USERNAME=changeme
RUN useradd --uid 1001 --gid node --shell /bin/bash --create-home $USERNAME
RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install SF CLIs
RUN npm install -g sfcc-ci sfdx-cli vlocity

# Increase heap size to 16GB
ENV GENERATE_SOURCEMAP=false
ENV NODE_OPTIONS=--max-old-space-size=16384

# Set `DEVCONTAINER` environment variable to help with orientation
ENV DEVCONTAINER=true