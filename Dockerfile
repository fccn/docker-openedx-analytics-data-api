
# Adapted from https://github.com/overhangio/tutor-discovery/blob/84886feaa76e91b0c725566cef503dd2d215979c/tutordiscovery/templates/discovery/build/discovery/Dockerfile
FROM docker.io/ubuntu:20.04 as openedx

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && \
  apt install -y curl git-core language-pack-en python3 python3-pip python3-venv \
  build-essential libffi-dev libmysqlclient-dev libxml2-dev libxslt-dev libjpeg-dev libssl-dev
ENV LC_ALL en_US.UTF-8

# ARG APP_USER_ID=1000
# RUN useradd --home-dir /openedx --create-home --shell /bin/bash --uid ${APP_USER_ID} app
# USER ${APP_USER_ID}

WORKDIR /openedx/analyticsapi

# Setup empty yml config file, which is required by production settings
RUN echo "{}" > /openedx/config.yml
ENV ANALYTICS_API_CFG /openedx/config.yml

# Install python venv
RUN python3 -m venv ../venv/
ENV PATH "/openedx/venv/bin:$PATH"
# https://pypi.org/project/setuptools/
# https://pypi.org/project/pip/
# https://pypi.org/project/wheel/
RUN pip install setuptools==62.1.0 pip==22.0.4 wheel==0.37.1

# Copy just Python requirements
COPY analyticsapi/requirements/production.txt requirements/production.txt

# Install python requirements
RUN pip install -r requirements/production.txt

# Copy python extra requirements
COPY extra-requirements.txt requirements/extra-requirements.txt

# Install python extra requirements
RUN pip install -r requirements/extra-requirements.txt

# Copy the rest of the code
COPY analyticsapi .

# Collect static assets
RUN DJANGO_SETTINGS_MODULE=analyticsdataserver.settings.base make static

# copy docker production settings
COPY ./settings/docker_production.py ./analyticsdataserver/settings/docker_production.py

# Run production server
ENV DJANGO_SETTINGS_MODULE analyticsdataserver.settings.docker_production

EXPOSE 8000
CMD uwsgi \
    --static-map /static=/openedx/analyticsapi/analyticsdataserver/assets \
    --static-map /media=/openedx/analyticsapi/analyticsdataserver/media \
    --http 0.0.0.0:8000 \
    --thunder-lock \
    --single-interpreter \
    --enable-threads \
    --processes=2 \
    --buffer-size=8192 \
    --wsgi-file analytics_dashboard/wsgi.py
