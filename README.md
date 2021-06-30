# Dockerの練習
- オライリー『Docker』のサンプルコードエラーまとめ
- Docker Sailについて

# Chapter3.3 Dockerfileからcowsayイメージを構築する回
FROMで指定しているベースイメージ[debian](https://www.debian.org/)のバージョンが古いせいでエラーが出た。`wheezy`はサポートが終了しているので、現在の安定版`buster`に変更。

```Dockerfile:Dockerfile
# 誤
FROM debian:wheezy

RUN apt-get update && apt-get install -y cowsay fortune

# 正
FROM debian:buster

RUN apt-get update && apt-get install -y cowsay fortune
```

この`Dockerfile`からビルドした`cowsayイメージ`の実行コマンドもパスが通っていないとエラーが返ってくる。

```terminal:terminal
$ # 誤
$ docker run test/cowsay-dockerfile "Moo"
docker: Error response from daemon: OCI runtime create failed:
container_linux.go:367: starting container process caused: exec: "Moo": executable file not found in $PATH: unknown.

$ # 正
$ docker run test/cowsay-dockerfile /usr/games/cowsay "Moo"
 _____
< Moo >
 -----
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

# Chapter5.1 "Hello, World!"出力する回
そのまま書き写すと、2行目で`IndentationError`が出る。`Python`は括弧(){}の代わりにインデントでコードをグルーピングする言語なので、タブ・スペースのズレは気を付けないといけない。

```python:identidock.py
# 誤
from flask import Flask
    app = Flask(__name__)  #ここのインデント
 
@app.route('/')
def hello_world():
    return 'Hello World!\n'
 
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')

# 正
from flask import Flask
app = Flask(__name__)
 
@app.route('/')
def hello_world():
    return 'Hello World!\n'
 
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0')
```

# Chapter5.1 "Hello, World!"出力する回 その2
コンテナにアプリケーションサーバ[uWSGI(Web Server Gateway Interface)](https://uwsgi-docs.readthedocs.io/en/latest/)を導入する際、サンプルの通り古いバージョンを指定してしまうとエラーが出る。最新版の2.0.19に直す。

```Dockerfile:Dockerfile
# 誤
FROM python:3.4

RUN pip install Flask==0.10.1 uWSGI==2.0.8
WORKDIR /app
COPY app /app/

CMD ["uwsgi", "--http", "0.0.0.0:9090", "--wsgi-file", "/app/identidock.py", \ "--callable", "app", "--stats", "0.0.0.0:9191"]

# 正
FROM python:3.4

RUN pip install Flask==0.10.1 uWSGI==2.0.19
WORKDIR /app
COPY app /app/

CMD ["uwsgi", "--http", "0.0.0.0:9090", "--wsgi-file", "/app/identidock.py", \ "--callable", "app", "--stats", "0.0.0.0:9191"]
```

# おまけ その１
せっかくDocker版[cowsay](https://ja.wikipedia.org/wiki/Cowsay)を起動したので、cow以外のcowsayを出力させてみた。

```terminal:terminal
$ docker run -it --name cowsay --hostname cowsay debian bash #インタラクティブセッションを要求

root@cowsay:/# apt-get update
root@cowsay:/# apt-get install -y cowsay fortune
root@cowsay:/# /usr/games/fortune | /usr/games/cowsay -l #-lオプションでcow以外のファイルを確認

Cow files in /usr/share/cowsay/cows:
apt bud-frogs bunny calvin cheese cock cower daemon default dragon
dragon-and-cow duck elephant elephant-in-snake eyes flaming-sheep
ghostbusters gnu hellokitty kangaroo kiss koala kosh luke-koala
mech-and-cow milk moofasa moose pony pony-smaller ren sheep skeleton
snowman stegosaurus stimpy suse three-eyes turkey turtle tux unipony
unipony-smaller vader vader-koala www

root@cowsay:/# /usr/games/fortune | /usr/games/cowsay -f dragon #-fオプションで選択
 _________________________________________
/ Truth will out this morning. (Which may \
\ really mess things up.)                 /
 -----------------------------------------
      \                    / \  //\
       \    |\___/|      /   \//  \\
            /0  0  \__  /    //  | \ \    
           /     /  \/_/    //   |  \  \  
           @_^_@'/   \/_   //    |   \   \ 
           //_^_/     \/_ //     |    \    \
        ( //) |        \///      |     \     \
      ( / /) _|_ /   )  //       |      \     _\
    ( // /) '/,_ _ _/  ( ; -.    |    _ _\.-~        .-~~~^-.
  (( / / )) ,-{        _      `-.|.-~-.           .~         `.
 (( // / ))  '/\      /                 ~-. _ .-~      .-~^-.  \
 (( /// ))      `.   {            }                   /      \  \
  (( / ))     .----~-.\        \-'                 .~         \  `. \^-.
             ///.----..>        \             _ -~             `.  ^-`  ^-_
               ///-._ _ _ _ _ _ _}^ - - - - ~                     ~-- ,.-~
                                                                  /.-~


root@cowsay:/# /usr/games/fortune | /usr/games/cowsay -f tux   
 _______________________________________
/ He was part of my dream, of course -- \
| but then I was part of his dream too. |
|                                       |
\ -- Lewis Carroll                      /
 ---------------------------------------
   \
    \
        .--.
       |o_o |
       |:_/ |
      //   \ \
     (|     | )
    /'\_   _/`\
    \___)=(___/
```

# おまけ その2
ポケモンバージョンの[Pokemonsay in Docker](https://github.com/xaviervia/docker-pokemonsay)があったので、やってみた。

```terminal:terminal
$ docker run --rm -it xaviervia/pokemonsay 'Hello World!'
```
ランダムでポケモンが出てきた。かわいい:fire:<br>
![スクリーンショット 2021-06-16 18.56.06.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/1645942/fe85cb79-4cc9-288b-c25a-0ba5db4bf9e7.png)

# Chapter6 シンプルWebアプリケーションを作成する回
第5章と同じく、Pythonファイルのインデントと導入するライブラリのバージョンに気を付けないとエラーが出る。あと`redis`と`radis`のスペルミス沼にハマってしまった。<br>

```Dockerfile:Dockerfile
# 誤
RUN pip install Flask==0.10.1 uWSGI==2.0.19 requests==2.0.8 redis==2.5.1

# 正
RUN pip install Flask==0.10.1 uWSGI==2.0.19 requests==2.10.0 redis==3.0.0
```

```yml:docker-composer.yml
# 誤
redis:
    image: redis:3.0

# 正
redis:
    image: redis:6.2.4
```
#### なんで指定しているバージョンが違うの？
`Dockerfile`と`docker-composer.yml`でライブラリのバージョン表記が違うのは、前者はPython用のクライアントライブラリ、後者はコンテナ(サービス)とそれぞれインストールしているものが違うから。

#### latestタグは非推奨？
Dockerは何も指定しない場合デフォルトで`latest`タグがつく。しかしこれはバージョンの自動更新を強制するものではないため、イメージをpullする際も公開する際もバージョンを明示することが推奨されている。

#### 出力結果
![出力結果](dnmonster.JPG)

# 参考
- https://www.oreilly.co.jp/books/9784873117768/
- https://cloud.ibm.com/docs/Registry?topic=Registry-troubleshoot-docker-latest&locale=ja

<br>
<br>

# Laravel Sailについて
# 新規Laravelアプリの作成とSailのインストール

```terminal:terminal
$ curl -s https://laravel.build/<アプリ名> | bash
```
アプリの作成とsailのインストールは同時に行われる。
これで`mysql`・`redis`・`meilisearch`・`selenium`・`mailhog`がデフォルトで利用できるようになるが、`with`クエリを使って

```
mysql
pgsql
mariadb
redis
memcached
meilisearch
selenium
mailhog
```

から使いたいサービスを個別指定することも可能。

```terminal:mysqlとredisを指定する例
$ curl -s "https://laravel.build/example-app?with=mysql,redis" | bash
```

#既存のLaravelアプリにSailをインストールする場合

```terminal:terminal
$ composer require laravel/sail --dev
$ php artisan sail:install
```

# アプリの起動
```terminal:terminal
$ cd <Laravelアプリ>
$ ./vendor/bin/sail up -d
```

`http://localhost/`にアクセスするとLaravelの初期画面が、`http://localhost:8025`にアクセスするとMailHogが表示される。Sailをバックグラウンドで起動するにはデタッチの`-d`オプションを追加。

# エイリアス設定
呼び出し時に毎回`./vendor/bin/sail`と入力するのが面倒なので、エイリアスを設定。

```terminal:bashシェルの場合
$ alias sail='./vendor/bin/sail'
$ source ~/.bash_profile
```

```terminal:zshシェルの場合
$ alias sail='./vendor/bin/sail'
$ source ~/.zshrc
```

# コマンド実行

```terminal:artisanコマンド
$ sail artisan make:controller コントローラ名
```

```terminal:phpコマンド
$ sail php --version
```

```terminal:composerコマンド
$ sail composer require ベンダー名/パッケージ名
```

```terminal:nodeコマンド
$ sail node --version
```

```terminal:npmコマンド
$ sail npm run dev
```

```terminal:phpunitコマンド
$ sail test 
```

# 例：Vueのセットアップ

コンテナ起動、停止以外は普段通り。

```terminal:terminal
laravel/uiのダウンロード
$ sail composer require --dev laravel/ui #この時点でresources/js/components以下にvueコンポーネントが設置される

vueの認証スカフォールドの生成
$ sail artisan ui vue --auth #認証機能をつけたい場合(ちなみにlaravelはjetstreamを推奨してます)

パッケージのインストール
$ sail npm install

ビルド
$ sail npm run dev #または sail npm run watchで自動コンパイル
```

# アプリ(コンテナ)の停止

```terminal:terminal
$ sail down #または'Ctr + C'
```

# おわりに

```terminal:terminal
$ curl -s https://laravel.build/<アプリ名> | bash
$ ./vendor/bin/sail up
```

の2行で開発環境構築が完了した。めちゃくちゃ便利。

# 参考

https://laravel.com/docs/8.x/sail
https://qiita.com/terufumi1122/items/1bbb1cf96e376e30e9fc
