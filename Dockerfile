FROM python:2.7
ENV PYTHONUNBUFFERED 1

RUN mkdir /code
ADD ./plutof-taxonomy-module /code/
ADD ./plutof-conf/settings.py /code/taxonomy/
ADD ./plutof-conf/Makefile /code/
ADD ./plutof-conf/requirements.txt /code/
ADD ./plutof-conf/init_once.sh /code/init_once.sh
ADD ./plutof-conf/docker-entrypoint.sh /

WORKDIR /code
RUN make dependencies

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["python", "manage.py", "runserver", "0.0.0.0:7000"]
