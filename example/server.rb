# 
# Server Configration
# 

server = SimpleHttpServer.new({

  :server_ip => "0.0.0.0",
  :port  =>  8000,
  :document_root => "./",
})


#
# HTTP Initialize Configuration Per Request
#

# You can use request parameters at http or location configration
#   r.method
#   r.schema
#   r.host
#   r.port
#   r.path
#   r.query
#   r.headers
#   r.body

server.http do |r|
  server.set_response_headers({
    "Server" => "my-mruby-simplehttpserver",
    "Date" => server.http_date,
  })
end

# 
# Location Configration
# 

# /mruby location config
server.location "/mruby" do |r|
  if r.method == "POST"
    server.response_body = "Hello mruby World. Your post is '#{r.body}'\n"
  else
    server.response_body = "Hello mruby World at '#{r.path}'\n"
  end
  server.create_response
end

# /mruby/ruby location config, location config longest match
server.location "/mruby/ruby" do |r|
  server.response_body = "Hello mruby World. longest matche.\n"
  server.create_response
end

server.location "/html" do |r|
  server.set_response_headers "Content-type" => "text/html; charset=utf-8"
  # or server.response_headers << "Content-type" => "text/html; charset=utf-8"
  server.response_body = "<H1>Hello mruby World.</H1>\n"
  server.create_response
end

# Custom error response message
server.location "/notfound" do |r|
  server.response_body = "Not Found on this server: #{r.path}\n"
  server.create_response 404
end

# Static html file contents
server.location "/static/" do |r|
  response = ""
  #is_dir = r.path[-1] == '/'
  #is_html = r.path.split(".")[-1] == "html"

  if r.method == 'GET' && r.path.is_dir? || r.path.is_html?
    filename = server.config[:document_root] + r.path
    filename += r.path.is_dir? ? 'index.html' : ''
    begin
      fp = File.open filename
      server.set_response_headers "Content-Type" => "text/html; charset=utf-8"
      # TODO: Add last-modified header, need File.mtime but not implemented
      server.response_body = fp.read
      response = server.create_response
    rescue File::FileError
      server.response_body = "Not Found on this server: #{r.path}\n"
      response = server.create_response 404
    rescue
      server.response_body = "Internal Server Error\n"
      response = server.create_response 500
    ensure
      fp.close if fp
    end
  else
    server.response_body = "Service Unavailable\n"
    response = server.create_response 503
  end
  response
end

server.run
