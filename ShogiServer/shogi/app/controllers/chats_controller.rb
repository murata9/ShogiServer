# coding: utf-8
class ChatsController < ApplicationController

#チャット用
#チャット取得
  def GetChat
    @play = Play.find(params[:id])
    @chats = Chat.where(:play_id => @play.id).all()
    render "GetChat", :formats => [:json], :hamdlers => [:jbuilder]
  end
#チャット送信
  def PostChat
    #チャットを作成し、データベースに保存する
    new_chat = Chat.new(:comment => params[:comment])
    new_chat.user_id = params[:user_id]
    new_chat.play_id = params[:play_id]
    new_chat.save!
    render "PostChat", :formats => [:json], :hamdlers => [:jbuilder]
  end

end
