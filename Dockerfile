FROM centos

ADD  ./file /file

RUN bash /file/run.sh

#CMD [ "bash ./file/run.sh" ]