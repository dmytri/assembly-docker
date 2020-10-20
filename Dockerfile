FROM dmytri/toaststunt:latest
WORKDIR /app/toaststunt
RUN pacman -S --noconfirm openssh sshpass npm supervisor \
  && ssh-keygen -A
COPY sshd_config /etc/ssh/sshd_config
COPY supervisord.conf /etc/supervisord.conf
RUN git clone https://github.com/butlerx/wetty.git \
  && cd wetty \
  && npm install \
  && npm run build
EXPOSE 7777
EXPOSE 3000
COPY blightmud-2.0.1-1-x86_64.pkg.tar.zst pkg/blightmud-2.0.1-1-x86_64.pkg.tar.zst
RUN pacman -U --noconfirm pkg/blightmud-2.0.1-1-x86_64.pkg.tar.zst
RUN useradd --create-home somebody
RUN echo "somebody:somebody" | chpasswd
COPY ssh.config /home/somebody/.ssh/config
COPY start.lua /home/somebody/.config/blightmud/start.lua
CMD ["/usr/bin/supervisord"]
