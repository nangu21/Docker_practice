#イメージのベースを指定
FROM ruby:2.7 

#RUN mkdir /var/www
#COPY main.rb /var/www

#CMD ["ruby", "/var/www/main.rb"]

#-----
#作業ディレクトリを指定
#WORKDIR /var/www

#ローカルのsrc以下ファイルを作業ディレクトリにコピー
#COPY ./src /var/www

#docker起動時にシェルを起動
#コンテナ起動時に-itタグを追加する(インタラクティブモードでbashと接続するため)
#CMD ["/bin/bash"]
# ↓
# ↓
#docker container内で実際にインストールができることを確認してからdockerfileにコマンドを記載
#ライブラリのインストール
#RUN bundle config --local set path 'vendor/bundle'
#RUN bundle install

#CMD ["bundle", "exec", "ruby", "app.rb"]
#-----

#-----
#yarnとnodejsをインストール
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update -qq \
    && apt-get install -y nodejs yarn
WORKDIR /app
COPY ./src /app/
#gemファイルのインストール
RUN bundle config --local set path 'vendor/bundle' \
    && bundle install
#-----
