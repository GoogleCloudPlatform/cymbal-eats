FROM ubuntu:latest
RUN apt-get update && apt-get install -y postgresql-client && apt-get clean
COPY script.sh /
RUN chmod +x /script.sh
CMD ["/script.sh"]
ENTRYPOINT ["/bin/bash"]