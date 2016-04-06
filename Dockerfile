FROM    nodesource/trusty:0.12

# Install Google App Engine Python SDK.
RUN mkdir /sdk && \
curl https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.35.zip -o /sdk/google_appengine.zip && \
sudo apt-get update && \

# Need unzip, but might as well throw in the other dependencies. Including Java :(
sudo apt-get --yes install unzip \
                           python-webtest \
                           openjdk-7-jre \
                           && \
cd /sdk && \
unzip /sdk/google_appengine.zip && \
# Remove the downloaded file to reduce image size.
rm -rf google_appengine.zip && \
sudo apt-get --yes purge unzip && \
# Free up space.
rm -rf /var/lib/apt/lists/*

# Bundle app source
COPY . /app

# Override with production when deploying to test/live.
ENV NODE_ENV dev

# Install app dependencies
RUN cd /app && \
    npm install && \
    npm install --global grunt-cli

# Produce the /app/out directory (build the app).
RUN cd /app && \
    # Make sure the build script can find Java.
    PATH=$PATH:/sdk/google_appengine grunt build

# Allow overriding port (useful for running locally).
ENV PORT 8080
ENV ADMIN_PORT 8090

# Expose HTTP port.
EXPOSE $PORT
EXPOSE $ADMIN_PORT

# If this doesn't work, try setting to 0.0.0.0
ENV HOST localhost

# Run the server.
CMD python /sdk/google_appengine/dev_appserver.py --skip_sdk_update_check=true --host=$HOST --port=$PORT --admin_host=$HOST --admin_port=$ADMIN_PORT /app/out/app_engine