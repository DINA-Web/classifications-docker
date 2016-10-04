FROM rocker/hadleyverse

USER root

RUN apt-get update && \
	apt-get install -y python-suds python3-suds python-pip

RUN pip install suds

USER rstudio
