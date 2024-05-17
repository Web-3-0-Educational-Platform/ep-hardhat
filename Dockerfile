FROM node:20-alpine
WORKDIR /app
COPY package.json .
RUN npm ci
COPY . .
EXPOSE 4000
RUN chmod +x /app/start.sh