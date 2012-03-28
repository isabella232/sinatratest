# example code to submit data to the Librato Metrics API
# this is a small sinatra web application that keeps track of how many times
# the main page has been hit. when desired, the user can submit that data to metrics

# for more info visit http://dev.librato.com/

module Sample
  class Application < Sinatra::Base
    configure do
      # these are automatically set by the Librato Metrics Engine Yard Service
      # if you already have a username and token, place them here

      user = EY::Config.get('librato-metrics','LIBRATO_METRICS_USER')
      token = EY::Config.get('librato-metrics','LIBRATO_METRICS_TOKEN')
      Librato::Metrics.authenticate user, token

      @@count = 0
    end

    get '/' do
      @@count += 1

      "<p>current count: #{@@count}</p>" +
      "<p>reload to increase the count</p>" +
      "<p>submit to metrics <a href=\"/submit\">here</a></p>"
    end

    get '/submit' do
      # send some data to the counter
      # available metrics are 'counters' and 'gauges'
      # counters go continually up and wrap around ('total bytes sent')
      # while gauges are realtime samples ('current temperature')

      begin
        Librato::Metrics.submit(:hits => {
                                  :type => :counter,
                                  :value => @@count
                                })
      rescue
        return "<h1>Failed to submit metric!</h1>"
      end

      "<p>submitted: #{@@count}</p>" +
      "<p><a href=\"/\">go back</a></p>" +
      "<p>view uploaded data over time  at <a href=\"https://metrics.librato.com\">https://metrics.librato.com</a></p>"
    end
  end
end
