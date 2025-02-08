FROM node:18

WORKDIR /app
COPY ./nodeapp/package.json ./nodeapp/package-lock.json ./
RUN npm install
COPY nodeapp/ .
