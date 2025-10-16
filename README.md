# memo
## コード
channelオブジェクトいる？
current_user.chanel_usersとmessage
1. 今アプリが機能しているか確認と、redisに接続  
2. **サジェスト作成job作る**  
   1. **app/jobs/build\_suggest\_index\_job.rb**  
   2. **redis**  
3. **サジェストリクエストを受け取ってredisからとってきて返す処理**  
   1. **channels\#suggest(def make\_suggestも)**
4. **channels\#suggestにリクエストを送るスクリプト組む & サジェストが帰ってきたときのレイヤー**  
   1. **app/javascript/message\_index\_channel.js**  
   2. **app/views/channels/index.html.erb, *add*\_member\_form.html.erb**  

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

## サジェスト
### 機能
1. redisの/2にunique_id:name(code変換)のindexを作成
2. @が有れば`word*`を、そうでなければ`*:word:*`をscan
3. code変換を済ませて返す
### code
1. 設定とseedの更新: seedで使うactionJob作成, seeds.rb(userの名前も工夫して変更する)
2. サジェストを作る機能のコーディング: job(本来はredisを分けたりして、更新中にアクセスされても大丈夫なようにするんだろうけど割愛)
3. フロント側でデータ送れるように、inputのnameとか1に合わせる: channels/_add_member_form.html.erb, message_index_channel.js
- ※コード変換は、codepoints, pack("U*")で可能
- ※基数変換はto_s(x), to_i(x)で可能


# メッセージ機能
## 機能
## step3
- action job + sidekiqの導入(意味なかったけど勉強にはなった)(fin)
- ログインしていたら常にサブスクライブする
  - チャンネル追加(fin)
  - 通知機能 全体
    - サブスクライブ無事できているか動作確認(fin)
    - ホップアップボックス追加(fin)
    - js処理(fin)
    - sessionStorageに閉じてない通知ホップアップ入れる(fin)
      - ホップアップクリックした時
        - 全ホップアップ削除
      - それ以外(fin)
        - notificationContainerから全てのnotificationを取得
        - その子要素をnotificationの中にidxのキーをさらに入れ、その中に入れて行く
        - notification_channel.jsでsessionStorage.notificationから展開
- 通知機能 channels#index(fin)
  - indexに要る時は、メッセージ順変える
- user検索機能改善2 fix_point_2(next)
  - サジェスト
- 既読バグ調査(3/4)
- ブラウザバック / タブ閉じに対応(3/5)
  - ホップアップが消えない

### step3α
- サジェストソート + limit
  - フォローしている人 > フォロワー数 > 投稿数

### step4
- バッチ処理学習(sidekiqとその他で一つずつ)
- バッチ処理でキャッシュ更新
  - キャッシュの寿命設定
- 画像可能、リサイズやサイズ制限など
- localStorageを使ってUIをカスタマイズできるようにする(拘らずに、時間大切)(3/12)
- indexとshowの読み込み改善(3/12~14)
  - index: 一気に読み込まずに、3つずつ読み込む fix_point_3
  - show: 最初の何件かだけ表示して、スクロールで追加読み込み
- DMを送ろうとした側は、メッセージを送っていなくても部屋が作成され、送られる側はメッセージが届くまで部屋が表示されない(3/14)
- FactoryBotでテストデータ改善
- 保存失敗ログを作って最終的な不整合を防ぐ
  - 保存直前でDBを落としたりして検証
  - バッチ処理も

### step5
- 本番環境
- キャッシュ実装
  - キャッシュにしてまとめて保存することで、メッセージ保存時にuser_channleをチェックするようなバリデーションを作れる
    - 最初のメッセージ送信では、DBをチェック、チェック済みの組み合わせをcache
    - 以降はcacheから確認する
  - 既読数処理もキャッシュを上手く使って減らしたい、channel:channel_id:message_idに既読したuser_idを並べていくとか
- DBへのアクセスを減らす

### step6
- 通知機能(API)

## 済
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
