# memo
2. sample_appのstep1完成させる
3. 以下の解消
キャッシュ戦略の詳細
複数コンテナ作って耐障害性のシミュレート
redisに対してコマンドをrailsで送るには、redisに限らず外部にコマンドを送るには
4. チャット移動
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
- 実装で追加した要素のテスト(next)
- fix_point修正
## step2
- `javascript/channels/index.js`について学ぶ
  - js単体読み込み
- 以下の機能を本格的に(テストから)
  - user
    - 論理削除
    - アカウントidの設定(認証済みとかも)
  - user検索機能改善1
    - idをauto_incrimantから変える、fixtures訂正
    - 名前, idのどちらか検索, @+id
    - 渡す値もidに変更、テストも変更
    - fix_point_1
  - userの入退出と、消したときの機能
    - 2人の時は、今の使用のまま、退出したりuser削除になったら消去、論理削除で非表示
    - 3人以上の時は、自由に部屋を建てれる
  - show機能追加
    - 既読機能
    - 未読があるチャット欄に目印
    - 自分の発言だけ右よせ
    - 自分がスクロールしている時は勝手にスクロールしない
## step3
  - action jobの勉強
  - current_userを変えて、ログインしていたら常にサブスクライブする
    - チャンネル追加
    - 通知機能
    - アソシエーションの改良
    - indexに要る時は、メッセージ順変える
  - user検索機能改善2
    - サジェスト

### step4
- 画像可能、リサイズやサイズ制限など
- indexとshowの読み込み改善
  - index: 一気に読み込まずに、3つずつ読み込む
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

## 暫定ロジック
- messagesを降順に読み込むんで、チャンネル名からDM一覧を展開