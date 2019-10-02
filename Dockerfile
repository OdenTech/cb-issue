FROM debian

WORKDIR /workspace
ADD test.sh .

ENTRYPOINT ["/test.sh"]
