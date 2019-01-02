FROM ruby:2.5
MAINTAINER Geoffrey Bilder <gbilder@crossref.org>

RUN apt-get update && \
    apt-get install -y net-tools

# Install gems
ENV APP_HOME /app
ENV HOME /root
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
COPY Gemfile* $APP_HOME/
RUN bundle install

# Upload source
COPY . $APP_HOME

# Start server
ENV PORT 3100
EXPOSE 3100
CMD ["ruby", "ror-reconciler.rb","-p 3100"]
