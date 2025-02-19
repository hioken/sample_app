# 機能
## 使用
- 既読一表に最後に既読したmessage_idを入れ、ログイン中は0を入れてこれを∞として扱う
## 接続
1. js: paramsに:channel_idを入れてハンドシェイク
2. rails: `connect = current_userにcookiesの:sending_user_id`
3. rails: radisからチャットメンバーの既読位置表`channel:#{channel_id}:last_read_message_ids"`を取得
- 無ければDBから生成してredisに保存
4. rails: redisの既読表のこのuserの現在の既読位置を0に設定, 取得した既読一表からはこのuserのキーを削除
5. rails: stream許可, event: :connected 既読表をtransmit
6. rails: event: :joined このuserのidをブロードキャスト
7. js: event: :connected user_id, 既読表をセット、既読処理

## 退出
1. rails: event: leaved 退出者idと最終既読idをブロードキャスト

## ブロードキャスト受け取り
### joined
1. 参加者idを取得して、既読表を∞に更新、更新前以上のidのメッセージ既読+1
2. activecount +1

### leaved
1. 既読表を更新
2. activecount -1

### message
1. メッセージ追加処理
2. もし追加要素にread-countがあれば(自分の投稿なら)、既読数 = activecount

# memo
channelオブジェクトいる？
current_user.chanel_usersとmessage
# メッセージ機能
## 機能
### step0
- 設計(fin)
- actioncable, redisの設定(fin)

### step1
- model設定(fin)
- テストデータ, seed(fin)
- modelテスト(fin)
- 大まかなview(fin)
- indexのDm作成機能(fin)
- show(fin)

- controller簡易テスト(fin)
- 総合テスト(fin)

- 最初はチャット詳細を開いた時だけwebsocketする形で実装(fin)
- 実装で追加した要素のテスト(fin)
## step2
- js単体読み込み(fin)
- user(fin)
  - 以下の論理削除、idの動作確認
    - 論理削除とidのカラム追加
    - アカウントidの設定(ユニーク等)
    - 今回の学習目的に沿って、削除フラグがtrueなら適当なページに飛ばすだけにする
    - 上記のメソッドを全体に適応
    - editページに論理削除追加
    - フォローとshowページの退会済みアカウントの対応
- user検索機能改善1(fin)
- userの入退出(fin)
- show機能追加(fin)
  - 既読機能
  - 自分がスクロールしている時は勝手にスクロールしない
- 未読があるチャット欄に目印(fin)
- windowのナビゲーション関数の解説をしてもらう
## step3
  - action jobの勉強
    - redis組み込み?
  - current_userを変えて、ログインしていたら常にサブスクライブする
    - チャンネル追加
    - 通知機能
      - sessionStorageに閉じてない通知ホップアップ入れる
      - 未読目印の更新も忘れずに
    - アソシエーションの改良
    - indexに要る時は、メッセージ順変える
  - user検索機能改善2 fix_point_2
    - サジェスト, 名前でも検索可能
  - ブラウザバック / タブ閉じに対応

### step4
- localStorageを使ってUIをカスタマイズできるようにする
- 画像可能、リサイズやサイズ制限など
- indexとshowの読み込み改善
  - index: 一気に読み込まずに、3つずつ読み込む fix_point_3
  - show: 最初の何件かだけ表示して、スクロールで追加読み込み
- DMを送ろうとした側は、メッセージを送っていなくても部屋が作成され、送られる側はメッセージが届くまで部屋が表示されない
- FactoryBotでテストデータ改善
- 本番環境

### step5
- キャッシュ実装
  - キャッシュにしてまとめて保存することで、メッセージ保存時にuser_channleをチェックするようなバリデーションを作れる
    - 最初のメッセージ送信では、DBをチェック、チェック済みの組み合わせをcache
    - 以降はcacheから確認する
  - 既読数処理もキャッシュを上手く使って減らしたい、channel:channel_id:message_idに既読したuser_idを並べていくとか
- DBへのアクセスを減らす
- 通知機能(API)

