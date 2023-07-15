FROM node:slim

ENV NODE_ENV=production
ENV PORT=4100

WORKDIR /app
COPY files/* /app/

EXPOSE 4100

RUN apt-get update &&\
    apt-get install -y wget unzip iproute2 &&\
    npm install -g pm2

CMD [ "node", "index.js" ]
