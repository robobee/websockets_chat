class ChatSocket
  def initialize(app)
    @app = app
    @clients = []
  end
  
  def call(env)
    @env = env
    if socket_request?
      socket = spawn_socket
      @clients << socket
      socket.rack_response
    else
      @app.call(env)
    end
  end

  private

    attr_reader :env

    def spawn_socket
      socket = Faye::WebSocket.new(env)
      
      socket.on :open do
        socket.send "Hello!"
      end

      socket.on :message do |event|

        begin
          tokens = event.data.split(" ")
          operation = tokens.delete_at(0)

          case operation
          when "msg"
            msg(socket, tokens)
          end

        rescue Exeption => e
          p e
          p e.backtrace
        end
      end

      socket
    end

    def socket_request?
      Faye::WebSocket.websocket? env
    end

    def msg(socket, tokens)
      user_id = tokens[0]
      room_id = tokens[1]
      text = tokens[2..-1].join(" ")

      message = Message.new(user_id: user_id,
                            room_id: room_id,
                            text: text)
      if message.save
        socket.send "msgok"
        update_clients(socket, user_id, room_id, text)
      else
        socket.send "msgerror #{message.errors.full_messages.first}"
      end
    end

    def update_clients(socket, user_id, room_id, text)
      user_email = User.find_by_id(user_id).email
      
      @clients.reject { |client| client == socket || !same_room?(client, socket) }.each do |client|
        client.send "new #{user_id} #{user_email} #{room_id} #{text}"
      end
    end

    def same_room?(other_socket, socket)
      other_socket.env['REQUEST_PATH'] == socket.env['REQUEST_PATH']
    end
end
