# AtenaViewer

- 宛名職人xmlを開き、編集し CSVで保存するプログラムを作った
  - SwiftUI + CoreDataを使用
  - 住所や名前のいわゆるエントリの作成、編集、削除、更新(CRUD)は宛名職人でやって。
  - 開くのと保存するところまで作った
  
- 宛名職人xmlの作成方法
  - 宛名職人のメニューから ContactXML 形式で書き出す 日本語コード UTF-8 改行コード LF  
  
- Fileメニューから XMLを開くで そのContactXMLを指定すると読み込まれる
  - 同じくFileメニューから年賀家族CSVあるいはキタムラCSV、挨拶状.com CSV形式で書き出す
  - あまりに長い住所は年賀家族でエラーとなるため適当にカタカナの前で区切ってみた

- 変更履歴
  - 敬称をサポート
  - 連名をサポート
  - 構造書き直し
  - openして新しいデータを読み込まない限りcore dataによりデータが自動保存される
  - 追加機能を追加（右上の＋マークを押すとシートが出て新規名前・ふりがな・アドレスを入力可能）
  - 削除機能を追加（左のリストの名前を右クリックするとContext Menuが出て、削除を選べる）
  - 挨拶状.com に対応　（2024年分はこちらから出すことになりました）
