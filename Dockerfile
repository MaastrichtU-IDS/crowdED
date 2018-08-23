FROM jupyter/datascience-notebook:latest

#USER root

WORKDIR /app

RUN pip install --upgrade pip && \
  pip3 install crowdED shortuuid pycm

COPY . .

CMD ["bash"]