# coding: utf-8
class PlaysController < ApplicationController
  before_action :set_play, only: [:state, :users, :get_winner, :show, :get_pieces, :GetChat]#GetChat追加
  skip_before_action :set_play, only: [:test]

#チャット用
#チャット取得
  def GetChat
    #@chats = Chat.all()
    @chats = Chat.where(:play_id => @play.id).all()
    #render :text => 'chat' + @play.state
    render "GetChat", :formats => [:json], :hamdlers => [:jbuilder]
  end
#チャット送信
  def PostChat
    #チャットを作成し、データベースに保存する
    new_chat = Chat.new(:comment => params[:comment])
    new_chat.user_id = params[:user_id]
    new_chat.play_id = params[:play_id]
    new_chat.save!
    @debug_str = new_chat.comment
    render "PostChat", :formats => [:json], :hamdlers => [:jbuilder]
    
    #@user = User.new(:name => params[:name])
  end
#部屋番号から部屋情報を返す関数
  def CreateRoomDataHashForPlay (play)
    room_no = play.room_no	#部屋番号
    hash = Hash.new()
    # "インデックス" : {"room_no": "部屋番号", "state"  : "状態"} の形にする
    hash["room_no"] = room_no.to_s
    hash["state"] = play.state
    #全プレイヤーからこの部屋にいるプレイヤーを取得する
    users = PlayingUser.where( :play_id => play.id ).all
    i = 0
    users.each do |u|
      i += 1
      user = User.find(u.user_id)
      if(u.role != "watcher") then #観戦者は省く
    	hash["player" + i.to_s] = user.name
      end
    end
    hash["player_num"] = i
    return hash
  end

#対戦または観戦可能な部屋の取得
  def GetRoom
    @room_num = 0
    @plays = Play.all
    @allHash = Hash.new()
    @plays.each{ |p|
        @room_no = p.room_no	#部屋番号
        if p.state != "finish" && p.state != "exit" then
            @room_num += 1		#入室可能な部屋の数をカウント
            #部屋情報作成
            @hash = CreateRoomDataHashForPlay(p)
            #データの記録
            @allHash[@room_num.to_s] = @hash
        end
    }
    @room_data = @allHash
    render "GetRoom", :formats => [:json], :hamdlers => [:jbuilder]
  end

#ユーザ名で検索して部屋を探す
  def SearchRoomForUserName
    @search_name = params[:search_name]
    #@search_name = "murata"
    @room_num = 0
    @allHash = Hash.new()
    @room_no	#部屋番号
    @playing_users = PlayingUser.all
    @playing_users.each do |u|
        @user = User.find(u.user_id)
        if  @user.name == @search_name then
            # "インデックス" : {"room_no": "部屋番号", "state"  : "状態"} の形にする
            #ユーザのいるplay_idから部屋番号を取得
            @play = Play.find(u.play_id)
            if @play.state != "finish" && @play.state != "exit" then #対戦可能な部屋のみをカウントする
            	@room_num += 1	#見つかった部屋の数をカウント
                #部屋情報作成
                @hash = CreateRoomDataHashForPlay(@play)
            	#データの記録
            	@allHash[@room_num.to_s] = @hash
            end
        end
    end
    @room_data = @allHash
    render "SearchRoomForUserName", :formats => [:json], :hamdlers => [:jbuilder]
  end

  def state
    render "state", :formats => [:json], :handlers => [:jbuilder]
  end

  def users
    render "users", :formats => [:json], :handlers => [:jbuilder]
  end

  def show
    # 現在のターン数、観客の人数、状態を返す
    @watcher_count = PlayingUser.where( :play => @play, :role => 'watcher' ).count
    render "show", :formats => [:json], :handlers => [:jbuilder]
  end

  def get_winner
    render "winner", :formats => [:json], :handlers => [:jbuilder]
  end

  def get_pieces
    @pieces = Piece.where( :play => @play.id ).all
    # binding.pry
    render "pieces", :formats => [:json], :hanlders => [:jbuilder]
  end

  # 駒情報の更新
  def update
    # begin
      # 1. play_idとuser_idとmove_idでpiecesテーブルからデータを拾ってくる
      @p_move = Piece.where( :play_id => params[:play_id], :piece_id => params[:move_id] ).first
      # 2. posxとposyを更新
      @p_move.posx = params[:posx]
      @p_move.posy = params[:posy]
      # binding.pry
      @p_move.promote = (params[:promote] == "True")? true : false
      @p_move.save!

      # render :json => @p_move
      @play = Play.find(params[:play_id])

      # binding.pry
      # 3. get_idが-1かどうか確認
      if params[:get_id] != "-1"
        # 4. get_idが-1でない場合、play_idとget_idでpiecesテーブルからデータを拾ってくる
        if params[:get_id] != ""
          @p_get = Piece.where( :play_id => params[:play_id], :piece_id => params[:get_id] ).first
          # 5. posxとposyを更新して保存
          @p_get.posx = 0
          @p_get.posy = 0
          @p_get.promote = false
          @p_get.owner = params[:user_id]
          @p_get.save!
          # 6. get_idが39or40なら終了処理
          if params[:get_id] == "40" || params[:get_id] == "39"
            @play.winner = @play.turn_player
            @play.state = "finish"
            # 7. ルーム内全員を退出処理
            @users = PlayingUser.where( :play_id => params[:play_id] ).all
            @users.each do |user|
              user.exit_flag = true
              user.save!
            end
          end
        end
      end
      # 8. ターン数を増やす
      @play.turn_count += 1
      if @play.turn_player == @play.first_player 
        @play.turn_player = @play.last_player 
      else
        @play.turn_player = @play.first_player
      end
      @play.save!
      # レスポンスは成功したかしてないか
    @pieces = Piece.where( :play => @play.id ).all
    render "pieces", :formats => [:json], :hanlders => [:jbuilder]
    # rescue
    #   @error = "error!"
    #   render "user/error", :formats => [:json], :handlers => [:jbuilder]
    # end
  end

  # debug用
  def end
    @play = Play.find(params[:id])
    render 'state', :formats => [:json], :hanlders => [:jbuilder]
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_play
      begin
        @play = Play.find(params[:id])
      rescue
        @error = "record not found test"
        render "users/error", :formats => [:json], :handlers => [:jbuilder] and return
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def play_params
      params.require(:play).permit(:turn_player, :turn_number, :end_flag, :room_no)
    end
end
