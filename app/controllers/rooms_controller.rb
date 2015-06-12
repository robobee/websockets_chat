class RoomsController < ApplicationController

  before_action :set_room, only: [:show]

  def index
    @rooms = Room.all
  end

  def show
  end

  def create
    room = Room.new(room_params.merge! user_id: current_user.id)
    if room.save
      redirect_to room, notice: "Room was successfully created."
    else
      @rooms = Room.all
      render :index
    end
  end

  private

    def set_room
      @room = Room.find(params[:id])
    end

    def room_params
      params.require(:room).permit(:name)
    end
end
