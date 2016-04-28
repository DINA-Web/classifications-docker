FROM python:2.7
ENV PYTHONUNBUFFERED 1

RUN mkdir /code
ADD ./plutof-taxonomy-module /code/

ADD ./plutof-conf/base.py /code/settings/

ADD ./plutof-conf/add_oauth2_client.py /code/
ADD ./plutof-conf/docker-entrypoint.sh /

WORKDIR /code
RUN make dependencies

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["make", "fast-server"]
