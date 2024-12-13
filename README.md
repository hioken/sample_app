# メッセージ機能
## 機能
### step0
- 設計(fin)
- actioncable, redisの設定(fin)

### step1
- model設定(fin)
- テストデータ, seed(fin)
- modelテスト(next)
  - gptの説明見る
  - userのテストも追加
- 大まかなview()
- controllerテスト
  - index
    - viewに最新順にチャンネルが並ぶ
    - チャンネルに飛べる
  - show
    - メッセージ一覧が表示
- 総合テスト
  - チャンネルを作れる
  - メッセージを送る
    - 下にスクロール
  - メッセージを受信する
    - 下にスクロール
- 大まかなメソッド
- 最初はチャット詳細を開いた時だけwebsocketする形で実装
  - 複数人可能
  - 受信したら最新のメッセージが表示されるようにスクロール
- 実装で追加した要素のテスト追記

## step2
- 以下の機能を本格的に(テストから)
  - 画像可能、リサイズやサイズ制限など
  - 既読機能
  - 未読があるチャット欄に目印
  - 自分の発言だけ右よせ
  - 自分がスクロールしている時は勝手にスクロールしない
  - current_userを変えて、ログインしていたら常にサブスクライブする
    - 通知機能
    - アソシエーションの改良
  - 最初の何件かだけ表示して、スクロールで追加読み込み

### step3
- 一気に読み込まずに、3つずつ読み込む
- DMを送ろうとした側は、メッセージを送っていなくても部屋が作成され、送られる側はメッセージが届くまで部屋が表示されない
- トランザクション
- FactoryBotでテストデータ改善
- 本番環境

### step4
- redis等のキャッシュ機能を学習
  - キャッシュにすることで、メッセージ保存時にuser_channleをチェックするようなバリデーションを作れる
- DBへのアクセスを減らす
- 通知機能(API)

## 暫定ロジック
- messagesを降順に読み込むんで、チャンネル名からDM一覧を展開