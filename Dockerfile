from golang:alpine as builder

run apk add make git curl ca-certificates zip unzip tar

workdir /root
run git clone https://github.com/mkaczanowski/packer-builder-arm
workdir /root/packer-builder-arm
run go mod download
run go build

from ubuntu as packer

copy --from=builder /root/packer-builder-arm/packer-builder-arm /usr/local/bin/

run apt update && \
    apt install -y -qq git unzip qemu-user-static e2fsprogs dosfstools bsdtar jq curl wget vim bash && \
    apt autoclean -y && apt autoremove -y

run VERSION=$(curl -SsLk https://releases.hashicorp.com/index.json | jq -r '.packer.versions[].version' | tail -1 | xargs) && \
    FILENAME="packer_${VERSION}_linux_amd64.zip" && \
    LINK="https://releases.hashicorp.com/packer/${VERSION}/${FILENAME}" && \
    curl -SsLko "$FILENAME" "$LINK" && \
    unzip -qq "$FILENAME" -d /usr/local/bin && \
    rm -f $FILENAME

run apt install -y gettext-base

copy raspbian.json /root/template.json

run export RD=`curl -LSs https://downloads.raspberrypi.org/raspbian/images/ | grep "raspbian-" | tail -1 | sed -r 's/.*href="([^"/]+).*/\1/g'` && \
    export RF=`curl -LSs https://downloads.raspberrypi.org/raspbian/images/$(curl -LSs https://downloads.raspberrypi.org/raspbian/images/ | grep "raspbian-" | tail -1 | sed -r 's/.*href="([^"/]+).*/\1/g') | grep \.zip | head -1 | sed -r 's/.*href="([^"]+).*/\1/g'` && \
    envsubst < /root/template.json > /root/raspbian.json

from ubuntu
copy --from=packer /usr/local/bin/* /usr/local/bin/
copy --from=packer /root/raspbian.json /root/
run apt update -y && apt upgrade -y && \
    apt install -y -qq git zip unzip qemu-user-static e2fsprogs dosfstools bsdtar jq curl wget make && \
    apt autoclean -y && apt autoremove -y

env PACKER_PLUGINS=$HOME/.packer.d/plugins
run mkdir -p $PACKER_PLUGINS && \
    cp /usr/local/bin/packer-builder-arm $PACKER_PLUGINS && \
    chmod a+rwx $PACKER_PLUGINS/packer-builder-arm

