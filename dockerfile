FROM haxe:latest AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
 && rm -rf /var/lib/apt/lists/*


WORKDIR /app
COPY . /app

RUN haxelib git weblink https://github.com/PXshadow/weblink 
RUN haxelib install hashlink

RUN haxe build.hxml

## pull hashlink
WORKDIR /hashlink
RUN git clone https://github.com/HaxeFoundation/hashlink .


FROM haxe:latest


## pre setup mopidy
RUN mkdir -p /etc/apt/keyrings
RUN wget -q -O /etc/apt/keyrings/mopidy-archive-keyring.gpg https://apt.mopidy.com/mopidy-archive-keyring.gpg
RUN wget -q -O /etc/apt/sources.list.d/mopidy.sources https://apt.mopidy.com/bookworm.sources

# ## Install hashlink and media deps
RUN apt-get update && apt-get install -y --no-install-recommends \
    g++ \
    libmbedtls-dev \
    libopenal-dev \
    libpng-dev \
    libsdl2-dev \
    libturbojpeg-dev \
    libuv1-dev \
    libvorbis-dev \
    libsqlite3-dev \
    libglu1-mesa-dev \
    libgl-dev \
    python3-pip \
    yt-dlp \
    sox \
    mpv \
    mopidy \
    mpd \
    mpc \
    mopidy-mpd \
    mopidy-alsamixer \
    gstreamer1.0-alsa \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly\
    make




## non apt deps
COPY --from=build /app/assets/deps /app/deps
RUN apt install /app/deps/gst-plugin-spotify_0.15.0.alpha.1-3_amd64.deb 
RUN python3 -m pip install --break-system-packages mopidy-spotify==5.0.0a3



WORKDIR /hashlink
COPY --from=build /hashlink /hashlink
RUN make && make install
## clean up
RUN cd /
RUN rm -rf /hashlink


WORKDIR /app
COPY --from=build /app/dist /app

## setup volume files
RUN mkdir /app/appdata

## basic default config - will be used to populate if not there
COPY --from=build /app/assets/defaultconfigs /app/defaultconfigs

## Simple stub file so the app can tell if its running in docker
RUN touch /app/IS_DOCKER.file

ENTRYPOINT ["hl", "/app/RFIDTriggerServer.hl"]
# ENTRYPOINT ["tail", "-f", "/dev/null"]
