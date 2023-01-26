FROM rocker/shiny-verse

# Install system requirements for index.R as needed
RUN apt-get update && apt-get install -y 

# Copy the 'app' folder with all necessary application files
COPY ./app ./app

# install packages
RUN Rscript ./app/install_deps.R

# Give write read/write permission
RUN chmod ugo+rwx /app

# expose port
# https://stackoverflow.com/questions/66392202/run-shiny-server-on-different-port-than-3838
EXPOSE 3838

# run app on container start
CMD ["R", "-e", "shiny::runApp('/app', host = '0.0.0.0', port = 3838)"]


