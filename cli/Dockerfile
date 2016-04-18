FROM python:2.7
ENV PYTHONUNBUFFERED 1

RUN pip install --upgrade pip
RUN pip install suds

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

ADD dyntaxa-credentials.cfg /usr/src/app
ADD *.py /usr/src/app/

CMD ["python", "dyntaxa.py", "-h"]
