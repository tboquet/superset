FROM amancevice/pandas:0.18.1-python3

# Install
ENV SUPERSET_VERSION 0.16.1
RUN apk add --no-cache \
        curl \
        libffi-dev \
        cyrus-sasl-dev \
        mariadb-dev \
        postgresql-dev && \
    pip3 install \
        superset==$SUPERSET_VERSION \
        mysqlclient==1.3.7 \
        ldap3==2.1.1 \
        psycopg2==2.6.1 \
        redis==2.10.5 \
        sqlalchemy-redshift==0.5.0 \
        gunicorn

# Default config
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PATH=$PATH:/home/superset/.bin \
    PYTHONPATH=/home/superset/superset_config.py:$PYTHONPATH

# Run as superset user
WORKDIR /home/superset
COPY superset .
RUN addgroup superset && \
    adduser -h /home/superset -G superset -D superset && \
    chown -R superset:superset /home/superset
USER superset

# Deploy
EXPOSE 8088
HEALTHCHECK CMD ["curl", "-f", "http://localhost:8088/health"]
ENTRYPOINT ["superset"]
# CMD ["runserver"]
CMD ["gunicorn", "-w", "6", "--timeout", "60", "-b", "0.0.0.0:8088" "--limit-request-line", "0", "--limit-request-field_size", "0", "superset:app"]
