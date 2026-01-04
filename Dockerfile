FROM rocker/shiny:latest

# System libs commonly needed for DB + some R packages
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libmariadb-dev \
    && rm -rf /var/lib/apt/lists/*

# R packages your Playlix app likely uses
RUN R -e "install.packages(c('shiny','shinyWidgets','DBI','RMySQL','jsonlite','digest'), repos='https://cloud.r-project.org')"

# Copy your repo to Shiny Server apps directory
COPY . /srv/shiny-server/app
RUN chmod -R 755 /srv/shiny-server/app

EXPOSE 3838
CMD ["/usr/bin/shiny-server"]
