FROM    nodesource/trusty:0.12

# Override with production when deploying to test/live.
ENV NODE_ENV dev

# Bundle app source
COPY . /app

# Install Google App Engine Python SDK.
RUN mkdir /sdk && \
curl https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.35.zip -o /sdk/google_appengine.zip && \
sudo apt-get update && \

# Need unzip, but might as well throw in the other dependencies. Including Java :(
sudo apt-get --yes install unzip python-webtest openjdk-7-jre && \
unzip /sdk/google_appengine.zip && \
# Remove the downloaded file to reduce image size.
rm -rf google_appengine.zip && \
sudo apt-get --yes purge unzip && \
# Free up space.
rm -rf /var/lib/apt/lists/*

# Install app dependencies
RUN cd /app && \
    npm install && \
    npm install --global grunt-cli

# Produce the /app/out directory (build the app).
RUN cd /app && \
    # Make sure the build script can find Java.
    PATH=$PATH:/sdk/google_appengine grunt build

# Expose HTTP port.
EXPOSE 80

# Run the server.
CMD python /sdk/google_appengine/dev_appserver.py /app/out/app_engine