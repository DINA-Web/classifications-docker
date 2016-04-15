FROM python:3.5
ENV PYTHONUNBUFFERED 1

RUN pip install suds

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD dyntaxa-credentials.cfg /usr/src/app
ADD *.py /usr/src/app/

ADD docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["python", "dyntaxa.py", "-h"]
