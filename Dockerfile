FROM dmytri/toaststunt:latest
ENV DEBIAN_FRONTEND=noninteractiv
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
  && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
  && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
  && apt-get update \
  && apt-get -y install pkg-config openssl openssh-server sshpass python3-pip yarn \
  && pip3 install supervisor \
  && ssh-keygen -A
RUN useradd --create-home somebody \
  && echo "somebody:somebody" | chpasswd
COPY ssh.config /home/somebody/.ssh/config
COPY start.lua /home/somebody/.config/blightmud/start.lua
COPY sshd_config /etc/ssh/sshd_config
COPY supervisord.conf /etc/supervisord.conf
WORKDIR /app/toaststunt
RUN git clone https://github.com/dmytri/wetty.git \
  && cd wetty \
  && yarn install \
  && yarn run build
WORKDIR /app/toaststunt
RUN git clone https://github.com/Blightmud/Blightmud.git \
  && cd Blightmud \
  && git checkout v2.3.2 \
  && cargo build --release
RUN install /app/toaststunt/Blightmud/target/release/blightmud /usr/local/bin/blightmud
EXPOSE 7777
EXPOSE 3000
RUN mkdir -p /run/sshd \
  && mkdir -p /app/certs
CMD ["/usr/local/bin/supervisord"]
