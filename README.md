# memo
5. step2
6. step3
action job単体, redis組み込み


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
- show機能追加
  - 既読機能
    1. redisのキャッシュ設定
    2. channelとjsのsubscribe, unsubscribeの記述、データの受け渡しとredisまで
    3. 既読数のviewと計算ロジック、ついでに右よせも済ます(next)
    4. ２人部屋の既読
  - 未読があるチャット欄に目印
    - そのチャンネル+自身のchannel_usersのlast_read_message_idより大きいidのメッセージがあったら
  - 自分がスクロールしている時は勝手にスクロールしない
## step3
  - action jobの勉強
  - current_userを変えて、ログインしていたら常にサブスクライブする
    - チャンネル追加
    - 通知機能
    - アソシエーションの改良
    - indexに要る時は、メッセージ順変える
  - user検索機能改善2 fix_point_2
    - サジェスト, 名前でも検索可能

### step4
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
- DBへのアクセスを減らす
- 通知機能(API)

