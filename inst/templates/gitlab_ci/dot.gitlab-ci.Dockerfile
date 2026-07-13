# Use appropriate R version for runner
FROM rstudio/r-base:4.2.2-focal

# Install other app system dependencies here
RUN apt-get update && apt-get install --yes libcurl4-openssl-dev

# Install cypress dependencies
RUN apt-get update && apt-get install --yes \
  libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 \
  libxtst6 xauth xvfb \
  && rm -rf /var/lib/apt/lists/*

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash \
  && apt-get install nodejs -yq \
  && rm -rf /var/lib/apt/lists/*

# Build: docker build -f .gitlab-ci.Dockerfile -t your/image:latest .
# Push: docker push your/image:latest