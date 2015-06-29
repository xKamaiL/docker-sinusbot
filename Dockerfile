# SinusBot

FROM ubuntu
MAINTAINER buschtoens

# SinusBot config
ENV SINUS_VERSION 0.9.8
ENV SINUS_DIR /opt/ts3soundboard
ENV SINUS_TAR /tmp/sinusbot.tar.bz2

# TeamSpeak 3 client config
ENV TS3_VERSION 3.0.16
ENV TS3_OFFSET 49134
ENV TS3_DIR $SINUS_DIR/TeamSpeak3-Client-linux_amd64

# Install apt-get dependencies
RUN apt-get update && apt-get install -y \
  wget \
  screen \
  x11vnc \
  xinit \
  xvfb \
  libxcursor1 \
  ca-certificates \
  bzip2
RUN update-ca-certificates

# Create working directory
RUN mkdir -p $SINUS_DIR
RUN mkdir -p $TS3_DIR
WORKDIR $SINUS_DIR

# Download and install the SinusBot
RUN wget -O $SINUS_TAR http://frie.se/ts3bot/sinusbot-$SINUS_VERSION.tar.bz2
RUN tar -xjf $SINUS_TAR -C ./
RUN rm $SINUS_TAR
RUN cp ./config.ini.dist ./config.ini
RUN echo DataDir = \"/opt/data\" >> ./config.ini

# Download and install the TeamSpeak 3 client
RUN wget -qO- http://dl.4players.de/ts/releases/$TS3_VERSION/TeamSpeak3-Client-linux_amd64-$TS3_VERSION.run | \
  tail -c +$TS3_OFFSET | \
  tar -xf - -C $TS3_DIR
RUN cp ./plugin/libsoundbot_plugin.so ./TeamSpeak3-Client-linux_amd64/plugins

VOLUME /opt/data

# Expose web control panel
EXPOSE 8087

# Run script
ENTRYPOINT ["xinit", "/opt/ts3soundboard/ts3bot", "--", "/usr/bin/Xvfb"]
CMD [":1", "-screen", "0", "800x600x16", "-ac"]
