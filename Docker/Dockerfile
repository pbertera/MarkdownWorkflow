FROM 32bit/ubuntu:14.04

RUN LC_ALL=C DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y net-tools pandoc imagemagick make texlive-xetex texlive-latex-extra texlive-fonts-recommended  vim\ 
    && rm -rf /var/lib/apt/lists/*

COPY fonts/* /usr/local/share/fonts/

VOLUME /data
WORKDIR /data

ENTRYPOINT ["make"]
