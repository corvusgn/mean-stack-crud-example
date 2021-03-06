FROM node:carbon
RUN mkdir -p /opt/app
# set our node environment, either development or production
# defaults to production, compose overrides this to development on build and run
#ARG NODE_ENV=production
#ENV NODE_ENV $NODE_ENV
# default to port 80 for node, and 5858 or 9229 for debug
#ARG PORT=80
#ENV PORT $PORT
#EXPOSE $PORT 5858 9229
# check every 30s to ensure this service returns HTTP 200
#HEALTHCHECK CMD curl -fs http://localhost:$PORT/healthz || exit 1
# install dependencies first, in a different location for easier app bind mounting for local development
WORKDIR /opt
COPY package.json package-lock.json* ./
RUN npm install && npm cache clean --force
ENV PATH /opt/node_modules/.bin:$PATH
# copy in our source code last, as it changes the most
WORKDIR /opt/app
COPY . /opt/app
# Expose default port
EXPOSE 8080
CMD [ "npm", "start" ]
