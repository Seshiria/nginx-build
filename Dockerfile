FROM centos:7

ADD  ./file /file

RUN bash -x /file/run.sh

#CMD [ "bash ./file/run.sh" ]