class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # POST /users/login
  def login
    # begin
      @user = User.new(:name => params[:name])
      @user.save!

      @play = Play.where(:room_no => params[:room_no]).last

      # 対戦テーブルの最後のレコードの終了フラグが立っていれば
      if Play.where(:room_no => params[:room_no]).count.zero? || @play.end?
        # roleをプレイヤーで指定
        @role = 'player'

        @play = Play.new(:room_no => params[:room_no])
        @play.save!
        initalize_pieces @play
      else
        # 入室テーブルの対戦IDが一致し、roleが"player"数が2未満（＝対戦待ち中）ならプレイヤーとして追加
        # それ以外の場合は観戦者として追加
        @count = PlayingUser.play_is(@play.id).where(:role => "player").count
        if @count < 2
          # roleをプレイヤー、状態をstartに変更
          @role = 'player'
          @play.state = "playing"

          # 先手／後手をランダムに決定
          players = [ @user.id, PlayingUser.other_player_is(@play.id).user_id ].shuffle
          @play.first_player = players.pop
          @play.turn_player = @play.first_player
          @play.last_player = players.pop
          @play.save

          update_pieces @play
        else 
          # roleを観戦者に
          @role = 'watcher'
        end
      end
      PlayingUser.create( :play => @play, :user => @user, :role => @role, :exit_flag => false )

      render "login", :formats => [:json], :handlers => [:jbuilder]
    # rescue
    #   @error = "error!"
    #   render :json => @error
    # end
  end

  def logout
    @user = PlayingUser.where( :user_id => params[:user_id], :play_id => params[:play_id]).first
    @user.exit_flag = true
    @user.save!

    if @user.role == "player"
      @play = Play.find(params[:play_id])
      @play.state = "exit"
      winner = PlayingUser.where(:play_id => params[:play_id],  :role => "player").where.not( :user_id => params[:user_id]  ).last
      @play.winner = winner.id unless winner.nil?
      @play.save!

      users = PlayingUser.where( :user_id => params[:user_id], :play_id => params[:play_id] ).all
      users.each do |user|
        user.exit_flag = true
        user.save!
      end
    end
    render :json => [ @user, @play ]
  end

#user test
  def test
    #render text: "Hello,world!"
    @value = 0
    @str = ""
    #render "test", :formats => [:json], :hamdlers => [:jbuilder]
#全部屋の取得
    @play = Play.find(1)
    @plays = Play.all
    @allHash = Hash.new()
    @plays.each{ |p|
        @room_no = p.room_no	#部屋番号
        if p.state != "finish" && p.state != "exit" then
            @value += 1		#入室可能な部屋の数をカウント
            #@str += @room_no.to_s + ":" +  p.state + " "
            #@hash[@room_no.to_s] = p.state  # "部屋番号" : "状態"の形にする
            @hash = Hash.new()
	    @hash["room_no"] = @room_no.to_s
	    @hash["state"] = p.state
            @allHash[@value.to_s] = @hash
        end
    }
    #@value = @play.id
    @str = @allHash
    render "test", :formats => [:json], :hamdlers => [:jbuilder]
  end

  private
  def update_pieces(play)
    pieces = Piece.where( :play_id => play.id )
    pieces.each do |piece|
      players = [ play.first_player, play.last_player]
      piece.owner = players[ piece.owner - 1 ]
      piece.save!
    end
  end
    def initalize_pieces(play)

      (1..40).to_a.each do |id|
        master = MasterPiece.find(id)
        Piece.create(
          # data[:owner]が1なら先手、2なら後手の駒。
          :piece_id => master.id, :play => play, :posx => master.posx, :posy => master.posy, :promote => false, :owner => master.owner
        )
      end
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name)
    end
end
