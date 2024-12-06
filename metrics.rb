require 'socket'

system("upsdrvctl start")
upsd_result = system("upsd")

if !upsd_result
    system("upsd -c reload")
end

server = TCPServer.new 80

PREFIX = "upsc_"
HOSTNAME = "localhost"
VERBOSE = false

STDERR_REDIRECT = VERBOSE ? "" : "2>/dev/null"

def is_number? string
    true if Float(string) rescue false
end

def print_metrics_for_ups(session, ups_name)
    metrics_raw = %x|upsc #{ups_name}@#{HOSTNAME} #{STDERR_REDIRECT}|
    metrics = metrics_raw.split("\n")

    metrics.each do |row|
        metric = row.split(":", 2)
        name="#{PREFIX}#{metric[0].gsub(".","_")}"
        value = metric[1]

        if is_number?(value)
            session.print "\# TYPE #{name} gauge\n"
            session.print "#{name}{ups=\"#{ups_name}\"} #{value}\n"
            session.print "\n"
        end
    end
end

while session = server.accept
    request = session.gets
    puts request 

    upses_raw = %x|upsc -l #{STDERR_REDIRECT}|
    upses = upses_raw.split("\n")
    
    session.print "HTTP/1.1 200\n"
    session.print "Content-Type: text/plain\n"
    session.print "\n"

    upses.each do |ups_name|
        print_metrics_for_ups(session, ups_name)
    end

    session.close
end
