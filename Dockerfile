FROM debian:bookworm-slim

# Install Dependencies for the build
RUN apt-get -y update && \
	apt-get install -y \
		libavutil-dev \
		libavformat-dev \
		libavcodec-dev \
		libmicrohttpd-dev \
		libjansson-dev \
		libssl-dev \
		libsofia-sip-ua-dev \
		libglib2.0-dev \
		libopus-dev \
		libogg-dev \
		libcurl4-openssl-dev \
		liblua5.3-dev \
		libconfig-dev \
		libusrsctp-dev \
		libwebsockets-dev \
		libnanomsg-dev \
		librabbitmq-dev \
		pkg-config \
		gengetopt \
		libtool \
		automake \
		build-essential \
		wget \
		git \
        python3 \
        python3-pip \
        ninja-build \
        avahi-daemon \ 
        avahi-discover \
        libnss-mdns \
		gtk-doc-tools && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

# Compile libnice
RUN git clone https://gitlab.freedesktop.org/libnice/libnice
WORKDIR /libnice
RUN pip3 install meson
RUN meson --prefix=/usr build && ninja -C build && ninja -C build install
WORKDIR /

# Compile libsrtp from source
RUN wget https://github.com/cisco/libsrtp/archive/v2.2.0.tar.gz
RUN tar xfv v2.2.0.tar.gz
WORKDIR /libsrtp-2.2.0
RUN ./configure --prefix=/usr --enable-openssl
RUN make shared_library &&  make install
WORKDIR /

# Compile usrsctp from source
RUN git clone https://github.com/sctplab/usrsctp
WORKDIR /usrsctp
RUN ./bootstrap
RUN ./configure --prefix=/usr --disable-programs --disable-inet --disable-inet6
RUN make && make install
WORKDIR /

# Compile janus-gateway
RUN git clone https://github.com/meetecho/janus-gateway.git
WORKDIR /janus-gateway
RUN ./autogen.sh
RUN ./configure --prefix=/opt/janus --disable-rabbitmq 
RUN make && make install
RUN make configs 
WORKDIR /

RUN apt-get -y update && \
	apt-get install -y \
		libmicrohttpd12 \
		libavutil-dev \
		libavformat-dev \
		libavcodec-dev \
		libjansson4 \
		libssl1.1 \
		libsofia-sip-ua0 \
		libglib2.0-0 \
		libopus0 \
		libogg0 \
		libcurl4 \
		liblua5.3-0 \
		libconfig9 \
		libusrsctp2 \
        libusrsctp-dev \
		libwebsockets16 \
		libnanomsg5 \
		librabbitmq4 && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

EXPOSE 10000-10200/udp
EXPOSE 8188
EXPOSE 8088
EXPOSE 8089
EXPOSE 8889
EXPOSE 8000
EXPOSE 7088
EXPOSE 7089

CMD ["/opt/janus/bin/janus"]