# Dockerfile
#
#	Use in "docker build ." to create the latest docker container

# Base layer
#	Use python 3.13 image as common base.
FROM python:3.13-slim AS common-base

#ENV DJANGO_SETTINGS_MODULE foo.settings

#	Our UID and GID
ENV UID=1001
ENV GID=1001

#	Make our local user the www-data user in the container,
#	such that files that belong to us locally are accessible.
RUN groupmod -g $GID www-data
RUN usermod -u $UID -g $GID -d /opt/bitpoll www-data
RUN mkdir -p /opt/bitpoll
WORKDIR /opt/bitpoll

RUN apt update && \
	apt install -y --no-install-recommends \
		libldap2 libsasl2-2 uwsgi uwsgi-plugin-python3 && \
	rm -rf /var/lib/apt/lists/*

# Second layer
#	Add python tools for building
FROM common-base AS base-builder
RUN pip install -U pip setuptools

# Third layer
#	Add dependecies for build
FROM base-builder AS dependencies

RUN apt-get update && \
	apt install -y --no-install-recommends \
		g++ wget python3-pip make gettext gcc python3-dev \
		libldap2-dev gpg gpg-agent curl libsasl2-dev npm

#	-EITHER- Copy python requirements for development
COPY requirements.txt requirements.txt
#	-OR- Copy python requirements for production
# COPY requirements-production.txt requirements.txt

RUN pip install --no-warn-script-location --prefix=/install -U -r requirements.txt

# Fourth layer:
#	Copy static files to destination and minify them
FROM dependencies AS collect-static

RUN npm install cssmin uglify-js -g

COPY manage.py .
COPY bitpoll bitpoll
COPY locale locale
COPY docker_files/config/settings.py bitpoll/settings_local.py

#	Set Pythonpath to the packages installed with pip before
#	so they are available in this actual build step.
RUN export PYTHONPATH=/install/lib/python$(python3 --version | \
	cut -d ' ' -f 2 | cut -d '.' -f 1,2)/site-packages && \
	python3 /opt/bitpoll/manage.py collectstatic --noinput && \
	python3 manage.py compilemessages && \
	rm bitpoll/settings_local.py

# Fifth layer
#	Merge the file collected in the previous two layer into target
FROM common-base

#RUN apt-get -y --no-install-recommends install python3-psycopg2 python3-ldap3 gettext

COPY --from=dependencies /install /usr/local
COPY --from=collect-static /opt/bitpoll .

COPY docker_files/run /usr/local/bin
COPY docker_files/uwsgi-bitpoll.ini /etc/uwsgi/bitpoll.ini

#	The files in _static will replace all files in /opt/static
#	on container startup
RUN chown $UID:$GID -R _static
RUN chmod o+r -R .

RUN ln -sf /opt/config/settings.py /opt/bitpoll/bitpoll/settings_local.py
RUN ln -sf /opt/storage/media /opt/bitpoll/_media

ARG RELEASE_VERSION=2026.03.22
RUN echo $RELEASE_VERSION > /opt/bitpoll/.releaseversion

ENV LANG=C.UTF-8
EXPOSE 3008/tcp
EXPOSE 3009/tcp

VOLUME /opt/static
VOLUME /opt/config
VOLUME /opt/log

ENTRYPOINT [ "/usr/local/bin/run" ]
