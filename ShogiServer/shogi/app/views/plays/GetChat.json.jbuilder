# coding: utf-8
json.chat_num @chats.count

i = 0
@chats.each do |chat|
  i += 1
  json.set! i do # i をキーとして出力
    json.user_id chat.user_id
    json.user_name User.find(chat.user_id).name #ユーザ名の検索
    json.comment chat.comment.force_encoding("UTF-8") #UTF-8に変換
  end
end
