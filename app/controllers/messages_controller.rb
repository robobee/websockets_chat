class MessagesController < ApplicationController
  
  before_action :message_params, only: [:create]

  def create
    @room = Room.find(params[:room_id])
    message = Message.new(message_params.merge! room_id: @room.id, user_id: current_user.id)
    if message.save
      redirect_to @room, notice: "Message was successfully created."
    else
      redirect_to @room, alert: "Message was not created."
    end
  end
  
  private

    def message_params
      params.require(:message).permit(:text)
    end
end
