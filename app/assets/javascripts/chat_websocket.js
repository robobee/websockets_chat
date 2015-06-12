var ChatSocket = function(user_id, room_id, user_email, form) {
  this.user_id = user_id;
  this.user_email = user_email;
  this.room_id = room_id;
  this.form = form;
  this.message_template = '<div class="media"><div class="media-left media-middle"><img class="media-object" src="http://lorempixel.com/64/64/people/"></div><div class="media-body"><h4 class="media-heading">{{user_email}},<small> {{time}}</small></h4><p>{{message}}</p></div></div>';

  this.socket = new WebSocket(App.websocket_host + "rooms/" + this.room_id);

  this.initBinds();
};

ChatSocket.prototype.initBinds = function() {
  var _this = this;

  this.form.submit(function(e) {
    e.preventDefault();
    _this.sendMessage($("#message_text").val());
  });

  this.socket.onmessage = function(e) {
    var tokens, user_id, user_email, text, error;

    //console.log(e);

    tokens = e.data.split(" ");

    switch(tokens[0]) {
      case "new":
        user_id = tokens[1];
        user_email = tokens[2];
        text = tokens.slice(4).join(" ");

        _this.newMessage(user_id, user_email, text);
        break;
      case "msgok":
        _this.msgOk();
        break;
      case "msgerror":
        console.log(tokens);
        error = tokens.slice(1).join(" ");
        _this.msgError(error);
        break;
    }
  };
};

ChatSocket.prototype.sendMessage = function(message) {
  this.message = message;
  var template = "msg {{user_id}} {{room_id}} {{message}}"
  this.socket.send(Mustache.render(template, {
    user_id: this.user_id,
    room_id: this.room_id,
    message: this.message
  }));
};

ChatSocket.prototype.msgOk = function() {
  $('#messages').append(Mustache.render(this.message_template, {
    user_id: this.user_id,
    user_email: this.user_email,
    time: 12345,
    message: this.message
  }));
};

ChatSocket.prototype.newMessage = function(user_id, user_email, text) {
  $('#messages').append(Mustache.render(this.message_template, {
    user_id: user_id,
    user_email: user_email,
    time: 12345,
    message: text
  }));
};

ChatSocket.prototype.msgError = function(error) {
  var template = '<div class="alert alert-danger">{{error}}</div>'
  $('#alerts').html(Mustache.render(template, { error: error }));
};

// msg user_id room_id message
// new user_id user_email room_id message
// msgok
// msgerror
