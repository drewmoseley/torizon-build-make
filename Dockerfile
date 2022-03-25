FROM node:latest
WORKDIR /usr/src/app
COPY hello-react/package*.json ./
RUN npm install
COPY hello-react .
EXPOSE 3000
CMD [ "npm", "start" ]
#CMD [ "bash" ]