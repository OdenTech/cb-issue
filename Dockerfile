FROM debian

WORKDIR /
ADD test.sh .

ENTRYPOINT ["/test.sh"]
