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
    sox \
    mpv \
    make

# COPY ./assets/deps /app/deps



WORKDIR /hashlink
COPY --from=build /hashlink /hashlink
RUN make && make install
## clean up
RUN cd /
RUN rm -rf /hashlink

# # Install Node.js
# RUN apt-get update && apt-get install -y --no-install-recommends gnupg 
# RUN curl -sL https://deb.nodesource.com/setup_20.x | bash -
# RUN apt-get install nodejs -y

WORKDIR /app
COPY --from=build /app/dist /app
RUN mkdir /app/appdata

# ENTRYPOINT ["hl", "/app/RFIDTriggerServer.hl"]
ENTRYPOINT ["tail", "-f", "/dev/null"]
