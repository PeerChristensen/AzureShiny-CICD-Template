FROM rocker/shiny-verse

# Install system requirements for index.R as needed
RUN apt-get update && apt-get install -y 

COPY ./www/* /srv/shiny-server/www/
COPY ./app/install_deps.R /tmp/install_deps.R
RUN Rscript /tmp/install_deps.R

#COPY Rprofile.site /etc/R
RUN install2.r --error --skipinstalled \
    shiny 

#COPY ./app/* /srv/shiny-server/
COPY ./app ./app

# Give write read/write permission
RUN chmod ugo+rwx /app

#USER shiny

EXPOSE 3838

# https://stackoverflow.com/questions/66392202/run-shiny-server-on-different-port-than-3838

#ENTRYPOINT ["/usr/bin/shiny-server"]

# run app on container start
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]


