FROM hashicorp/packer:1.3.5

RUN apk add --no-cache jq curl
RUN curl -sfL $(curl -s https://api.github.com/repos/powerman/dockerize/releases/latest | grep -i /dockerize-$(uname -s)-$(uname -m)\" | cut -d\" -f4) | install /dev/stdin /usr/local/bin/dockerize

WORKDIR /work
COPY build-info.tpl.json /build-info.tpl.json
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh




ENTRYPOINT [ "/entrypoint.sh" ]