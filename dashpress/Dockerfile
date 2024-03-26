FROM node:18-alpine

ENV NODE_ENV=production

RUN npm install -g dashpress

WORKDIR /app

ENV PORT=80
EXPOSE 80

CMD ["dashpress"]