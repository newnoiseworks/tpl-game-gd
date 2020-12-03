FROM newnoiseworks/godot-mono-builder:latest
LABEL author="hello@newnoiseworks.com"

RUN rm -rf /root/game/*

ADD ./ /root/game
