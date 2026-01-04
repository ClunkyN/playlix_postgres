FROM rocker/shiny:latest

# System libs needed for DB + SSL
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libmariadb-dev \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install R packages (RMariaDB for Aiven)
RUN R -e "install.packages(c('shiny','shinyWidgets','DBI','RMariaDB','jsonlite','digest'), repos='https://cloud.r-project.org')"

# Copy your repo to Shiny Server apps directory
COPY . /srv/shiny-server/app
RUN chmod -R 755 /srv/shiny-server/app

# (Recommended) Put Aiven CA cert in the image
# 1) Download CA cert from Aiven
# 2) Save it in your repo root as: ca.pem
COPY ca.pem /etc/ssl/certs/aiven-ca.pem
ENV DB_SSL_CA=/etc/ssl/certs/aiven-ca.pem

EXPOSE 3838
CMD ["/usr/bin/shiny-server"]
